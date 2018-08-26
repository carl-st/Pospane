//
//  InterfaceController.swift
//  PospaneWatch Extension
//
//  Created by Karol Stępień on 12.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import WatchKit
import WatchConnectivity
import HealthKit
import Foundation
import UserNotifications

class InterfaceController: WKInterfaceController, WCSessionDelegate, ConfirmInterfaceControllerDelegate, AsleepTimeSetterInterfaceControllerDelegate {
    
    @IBOutlet var sleepLabel: WKInterfaceLabel!
    
    private var currentSleepSession = SleepSession()
    private var proposedSleepStart: Date?
    private var sleepSessionToSave: [String : Any] = [:]
    
    @IBOutlet var sleepSessionGroup: WKInterfaceGroup!
    @IBOutlet var stillAwakeGroup: WKInterfaceGroup!
    @IBOutlet var inBedGroup: WKInterfaceGroup!
    @IBOutlet var sleepStartTimer: WKInterfaceLabel!
    @IBOutlet var inBedTimer: WKInterfaceLabel!
    
    private let healthStore = HKHealthStore()
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    override init() {
        super.init()
        checkPlist()
        clearAllMenuItems()
        currentSleepSession.isInProgress = isSleepSessionInProgress()
        
        if currentSleepSession.isInProgress {
            populateSleepSessionWithCurrentSessionData()
            updateLabelsForStartedSleepSession()
            determineMenuIcons()
        } else {
            updateLabelsForEndedSleepSession()
            prepareMenuIconsForUserNotInSleepSession()
        }
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        if WCSession.isSupported() {
            self.session?.delegate = self
            self.session?.activate()
        }
        
        let hasHKSleepDataAccess = healthStore.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
        
        if hasHKSleepDataAccess == .notDetermined || hasHKSleepDataAccess == .sharingDenied {
            authorizeHealthKit()
        }
        
        determineMenuIcons()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    private func checkPlist() {
        if let path = Bundle.main.path(forResource: fileNames.savedSleepSession.rawValue, ofType: "plist") {
            if FileManager().fileExists(atPath: path) {
                return
            }
        }
        
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let documentsDirectory = paths.first else { return }
        let targetPath = "\(documentsDirectory)/\(fileNames.savedSleepSession.rawValue).plist"
        
        if let sleepingFilePath = Bundle.main.path(forResource: fileNames.sleeping.rawValue, ofType: "plist") {
            do {
                try fileManager.copyItem(at: URL(fileURLWithPath: sleepingFilePath), to: URL(fileURLWithPath: targetPath))
            } catch {
                print(error)
            }
        }

    }
    
    private func isSleepSessionInProgress() -> Bool {
        return Helpers().contentsOfCurrentSleepSession().isInProgress
    }
    
    private func isUserAwake() -> Bool {
        let inBed = currentSleepSession.inBed.count
        let awake = currentSleepSession.awake.count
        return awake == inBed && awake > 0
    }
    
    private func populateSleepSessionWithCurrentSessionData() {
        currentSleepSession = Helpers().contentsOfCurrentSleepSession()
    }
    
    func writeRemoveDeferredSleepOptionDate() {
        let path = Helpers().getPathToSleepSessionFile()
        let sleepSessionFile = NSMutableDictionary(contentsOfFile: path)
        let removeDeferredSleepOptionDate = Date.init(timeIntervalSinceNow: numbers.removeDeferredOptionTimer.rawValue)
        
        sleepSessionFile?.setObject(removeDeferredSleepOptionDate, forKey: "removeDeferredSleepOptionDate" as NSString)
        
        if let _ = sleepSessionFile?.write(toFile: path, atomically: true) {
            print("Date to remove sleep deferred option sucessfully written to file.")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    private func writeCurrentSleepSessionToFile() -> NSMutableDictionary {
        let path = Helpers().getPathToSleepSessionFile()
        let sleepSessionFile = NSMutableDictionary(contentsOfFile: path)
        let currentSleepSessionDictionary = NSMutableDictionary(dictionary: sleepSessionFile?.object(forKey: dictionaryKeys.currentSleep.rawValue) as! NSDictionary)
        currentSleepSessionDictionary.setObject(currentSleepSession.isInProgress, forKey: "isInProgress" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.inBed, forKey: "inBed" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.asleep, forKey: "asleep" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.awake, forKey: "awake" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.outOfBed, forKey: "outOfBed" as NSString)
        
        sleepSessionFile?.setObject(currentSleepSessionDictionary, forKey: dictionaryKeys.currentSleep.rawValue)
        print("[DEBUG] POST ADD CONTENTS: ", sleepSessionFile)
        if (sleepSessionFile?.write(toFile: path, atomically: true))! {
            print("file has been saved")
        }

        return currentSleepSessionDictionary
    }
    
    func writeCurrentSleepSessionToFileAndSaveAsPrevious() {
        let path = Helpers().getPathToSleepSessionFile()
        let sleepSessionFile = NSMutableDictionary(contentsOfFile: path)
        let currentSleepSessionDictionary = writeCurrentSleepSessionToFile()
        sleepSessionFile?.setObject(currentSleepSessionDictionary, forKey: dictionaryKeys.previousSleep.rawValue)
        
        if let _ = sleepSessionFile?.write(toFile: path, atomically: true) {
            print("file has been saved")
        }
    }
    
    func deleteSleepSessionFile () {
        let path = Helpers().getPathToSleepSessionFile()
        do {
            try FileManager().removeItem(atPath: path)
        } catch {
            print(error)
        }

    }
    
    // TODO: Extract to common
    private func authorizeHealthKit() {
        let types: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: types, read: types) { (bool, error) in
            if let e = error {
                print("oops something went wrong during authorization \(e.localizedDescription)")
            } else {
                print("User has completed the authorization flow")
            }
        }
    }
    
    private func writeSleepSessionToHealthKit() {
        let samples = NSMutableArray()
        
        guard let categoryType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let awake = currentSleepSession.awake
        let inBed = currentSleepSession.inBed
        let asleep = currentSleepSession.asleep
        let outOfBed = currentSleepSession.outOfBed
        
        for (index, _) in awake.enumerated() {
            if index == 0 {
                let awakeSample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.awake.rawValue, start: inBed[index], end: asleep[index])
                samples.add(awakeSample)
            } else if index == awake.count {
                let awakeSample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.awake.rawValue, start: awake[index - 1], end: outOfBed[index - 1])
                samples.add(awakeSample)
            } else {
                let awakeSample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.awake.rawValue, start: awake[index - 1], end: asleep[index])
                samples.add(awakeSample)
            }
        }
        
        for (index, _) in inBed.enumerated() {
            let inBedSample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: inBed[index], end: outOfBed[index])
            samples.add(inBedSample)
            let asleepSample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: inBed[index], end: outOfBed[index])
            samples.add(asleepSample)
        }
        
        healthStore.save(samples as! Array, withCompletion: { (success, error) in
            if !success {
                print(error ?? "")
            } else {
//                clearAllSleepValues()
            }
        })
    }
    
    private func readHeartRateData() {
        let asleep = currentSleepSession.asleep
        guard let sampleStartDate = asleep.first else { return }
        let sampleEndDate = Date(timeInterval: 3600, since: sampleStartDate)
        
        let sampleType = HKSampleType.quantityType(forIdentifier: .heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: sampleStartDate, end: sampleEndDate, options: [])

        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil, resultsHandler: { (query, results, error) in
            guard let results = results else { return }
            DispatchQueue.main.async {
                var sleepDetected = false
                
                for sample in results {
                    let quantitySample = sample as? HKQuantitySample
                    guard let heartRate = quantitySample?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { return }
                    let predictedSleep = sample.startDate
                    
                    if heartRate <= 52.0 && !sleepDetected {
                        self.proposedSleepStart = predictedSleep
                        sleepDetected = true
                    }

                }
                print("heart rate results:", results)
                self.presentProposedSleepTimeController()
            }
        })
        
        healthStore.execute(query)
    }
    
    // Watch Connectivity Methods
    
    private func populateDictionaryWithSleepSessionData() -> [String : Any] {
        let inBedData = NSKeyedArchiver.archivedData(withRootObject: currentSleepSession.inBed)
        let asleepData = NSKeyedArchiver.archivedData(withRootObject: currentSleepSession.asleep)
        let awakeData = NSKeyedArchiver.archivedData(withRootObject: currentSleepSession.awake)
        let outOfBedData = NSKeyedArchiver.archivedData(withRootObject: currentSleepSession.outOfBed)
        
        var sleepSessionDictionary: [String : Any] = [:]
        sleepSessionDictionary["request"] = "sendData"
        sleepSessionDictionary["name"] = "session"
        sleepSessionDictionary["creationDate"] = Date()
        sleepSessionDictionary["inBed"] = inBedData
        sleepSessionDictionary["asleep"] = asleepData
        sleepSessionDictionary["awake"] = awakeData
        sleepSessionDictionary["outOfBed"] = outOfBedData
        
//        sleepSessionDictionary.setObject("sendData", forKey: "request" as NSString)
//        sleepSessionDictionary.setObject("session", forKey: "name" as NSString)
//        sleepSessionDictionary.setObject(Date(), forKey: "creationDate" as NSString)
//        sleepSessionDictionary.setObject(inBedData, forKey: "inBed" as NSString)
//        sleepSessionDictionary.setObject(asleepData, forKey: "asleep" as NSString)
//        sleepSessionDictionary.setObject(awakeData, forKey: "awake" as NSString)
//        sleepSessionDictionary.setObject(outOfBedData, forKey: "outOfBed" as NSString)
        return sleepSessionDictionary
    }
    
    private func sendSleepSessionDataToPhone() {
        sleepSessionToSave = populateDictionaryWithSleepSessionData()
        WCSession.default.sendMessage(sleepSessionToSave, replyHandler: { replyMessage in
            print(replyMessage)
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "interfaceController", context: [:] as AnyObject)])
        }, errorHandler: { error in
            print(error)
        })
    }
    
    // Menu Icons
    
    private func determineMenuIcons() {
        let path = Helpers().getPathToSleepSessionFile()
        let sleepSessionFile = NSMutableDictionary(contentsOfFile: path)
        guard let removeDeferredSleepOptionDate = sleepSessionFile?.object(forKey: "removeDeferredSleepOptionDate" as? NSString) as? Date else { return }
        
        let activeSleepSession = isSleepSessionInProgress()
        let userAwake = isUserAwake()
        
        print("isUserAwake: \(userAwake) ")
        
        if (Date() > removeDeferredSleepOptionDate && activeSleepSession && !userAwake) {
            prepareMenuIconsForUserAsleepWithoutDeferredOption()
        } else if (activeSleepSession && userAwake) {
            prepareMenuIconsForUserAwake()
        } else if activeSleepSession {
            prepareMenuIconsForUserAsleep()
        }
    }
    
    private func prepareMenuIconsForUserAsleepWithoutDeferredOption() {
        clearAllMenuItems()
        addMenuItem(with: UIImage(), title: "End", action: #selector(sleepStopClicked))
        addMenuItem(with: UIImage(), title: "Cancel", action: #selector(sleepCancelClicked))
        addMenuItem(with: UIImage(), title: "Wake", action: #selector(wakeClicked))
    }
    
    private func prepareMenuIconsForUserAsleep() {
        clearAllMenuItems()
        addMenuItem(with: UIImage(), title: "End", action: #selector(sleepStopClicked))
        addMenuItem(with: UIImage(), title: "Cancel", action: #selector(sleepCancelClicked))
        addMenuItem(with: UIImage(), title: "Wake", action: #selector(wakeClicked))
        addMenuItem(with: UIImage(), title: "Awake?", action: #selector(sleepDeferredClicked))
    }
    
    private func prepareMenuIconsForUserAwake() {
        clearAllMenuItems()
        addMenuItem(with: UIImage(), title: "End", action: #selector(sleepStopClicked))
        addMenuItem(with: UIImage(), title: "Cancel", action: #selector(sleepCancelClicked))
        addMenuItem(with: UIImage(), title: "Back to sleep", action: #selector(sleepClicked))
    }
    
    private func prepareMenuIconsForUserNotInSleepSession() {
        clearAllMenuItems()
        addMenuItem(with: UIImage(), title: "Sleep", action: #selector(sleepClicked))
    }
    
    // private func prepareMenuIconsForDebugging()

    private func updateLabelsForStartedSleepSession() {
        let dateFormatter = Helpers().dateFormatterForTimeLabels()
        sleepLabel.setHidden(true)
        sleepSessionGroup.setHidden(false)
        
        guard let inBed = currentSleepSession.inBed.first else { return }
        inBedTimer.setText(dateFormatter.string(from: inBed))
        inBedGroup.setHidden(false)
    }
    
    private func updateLabelsForEndedSleepSession() {
        sleepLabel.setHidden(false)
        sleepSessionGroup.setHidden(true)
        inBedGroup.setHidden(true)
        stillAwakeGroup.setHidden(true)
    }
    
    private func updateLabelsForDeferredSleepSession() {
        let dateFormatter = Helpers().dateFormatterForTimeLabels()
        sleepLabel.setHidden(true)
        sleepSessionGroup.setHidden(false)
        
        guard let inBed = currentSleepSession.inBed.first else { return }
        guard let asleep = currentSleepSession.asleep.last else { return }
        inBedTimer.setText(dateFormatter.string(from: inBed))
        sleepStartTimer.setText(dateFormatter.string(from: asleep))
        inBedGroup.setHidden(false)
        stillAwakeGroup.setHidden(false)
    }
    
    private func presentProposedSleepTimeController() {
        print("presentProposedSleepTimeController")
        let asleepContext: [String: Any] = ["delegate": self, "time": currentSleepSession.asleep.first ?? Date(), "maxSleepStart": currentSleepSession.awake.first ?? Date()]
        let confirmContext: [String: Any] = ["delegate": self, "time": self.proposedSleepStart ?? Date()]
        if self.proposedSleepStart == nil {
            self.presentController(withName: "asleepInterfaceController", context: asleepContext)
        } else {
            self.presentController(withName: "confirmInterfaceController", context: confirmContext)
        }
    }
    
    private func clearAllSleepValues() {
        currentSleepSession.inBed = []
        currentSleepSession.asleep = []
        currentSleepSession.awake = []
        currentSleepSession.outOfBed = []
        proposedSleepStart = nil
    }
    
    // display wake indicator
    
    @IBAction func sleepClicked() {
        print("sleep")
        let awake = currentSleepSession.awake
        if awake.count > 0 {
            currentSleepSession.outOfBed.append(awake[awake.count - 1])
                // fade wake indicator
                // cancel pending notification
                // remove delivered notifications
        }


        currentSleepSession.inBed.append(Date())
        currentSleepSession.asleep.append(Date(timeInterval: 1, since: Date()))
        currentSleepSession.isInProgress = true
        
        updateLabelsForStartedSleepSession()
        writeCurrentSleepSessionToFile()
        
        prepareMenuIconsForUserAsleep()
        
        writeRemoveDeferredSleepOptionDate()
    }
    
    @IBAction func wakeClicked() {
        print("wake")
        // display wake indicator
        currentSleepSession.awake.append(Date())
        _ = writeCurrentSleepSessionToFile()
        // scheduleUserNotificationToEndSleepSession
        prepareMenuIconsForUserAwake()
    }
    
    @IBAction func sleepDeferredClicked() {
        print("deferred")
        currentSleepSession.asleep[currentSleepSession.asleep.count - 1] = Date()
        updateLabelsForDeferredSleepSession()
        writeRemoveDeferredSleepOptionDate()
    }
    
    @IBAction func sleepStopClicked() {
        print("stop")
        // hideWakeIndicator
        currentSleepSession.outOfBed.append(Date())
        currentSleepSession.isInProgress = false
        if currentSleepSession.awake.count != currentSleepSession.outOfBed.count {
            currentSleepSession.awake.append(Date(timeInterval: -1, since: Date()))
        }
        
        let _ = writeCurrentSleepSessionToFile()
        readHeartRateData()
        // cancelPendingNotifications
        // removeDeliveredNotifications
        prepareMenuIconsForUserNotInSleepSession()
        
    }
    
    @IBAction func sleepCancelClicked() {
        print("cancel")
        currentSleepSession.isInProgress = false
        // hideWakeIndicator
        clearAllSleepValues()
        // removeDeliveredNotifications
        prepareMenuIconsForUserNotInSleepSession()
        writeCurrentSleepSessionToFile()
    }
    
    func proposedSleepStartDecision(buttonValue: Int, sleepStartDate: Date?) {
        if let sleepStartDate = sleepStartDate {
            self.currentSleepSession.asleep[0] = sleepStartDate
            self.performSleepSessionCloseout()
        } else if buttonValue == 0 {
            let context: [String: Any] = ["delegate": self, "time": currentSleepSession.asleep.first ?? Date(), "maxSleepStart": currentSleepSession.awake.first ?? Date()]
            self.presentController(withName: "asleepInterfaceController", context: context)
        } else if buttonValue == 1 {
            guard let proposedSleepStart = self.proposedSleepStart else { return }
            self.currentSleepSession.asleep[0] = proposedSleepStart
            self.performSleepSessionCloseout()
        }
    }
    
    private func performSleepSessionCloseout () {
        guard let session = self.session else { return }
        if session.isReachable {
            self.sendSleepSessionDataToPhone()
        } else {
            print("session unavailable")
        }
        
        self.writeSleepSessionToHealthKit()
        self.writeCurrentSleepSessionToFileAndSaveAsPrevious()
        self.updateLabelsForEndedSleepSession()
        
        // reloadMilestoneInterfaceData
    }
}
