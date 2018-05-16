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

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var sleepLabel: WKInterfaceLabel!
    
    private var currentSleepSession = SleepSession()
    private var proposedSleepStart: Date?
    private var sleepSessionToSave: [String : Any] = [:]
    
    private let healthStore = HKHealthStore()
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    override init() {
        super.init()
        checkPlist()
        clearAllMenuItems()
        currentSleepSession.isInProgress = isSleepSessionInProgress()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let hasHKSleepDataAccess = healthStore.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
        
        if hasHKSleepDataAccess == .notDetermined || hasHKSleepDataAccess == .sharingDenied {
            authorizeHealthKit()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func checkPlist() {
        let path = Bundle.main.path(forResource: fileNames.savedSleepSession.rawValue, ofType: "plist") // TODO: Add to constants file
        if FileManager().fileExists(atPath: path!) {
            return
        }
        let sleepingFilePath = Bundle.main.path(forResource: fileNames.sleeping.rawValue, ofType: "plist")
        do {
            try FileManager().copyItem(at: URL(fileURLWithPath: sleepingFilePath!), to: URL(fileURLWithPath: path!))
        } catch {
            print(error)
        }
    }
    
    private func isSleepSessionInProgress() -> Bool {
        return Helpers().contentsOfCurrentSleepSession().isInProgress!
    }
    
    private func isUserAwake() -> Bool {
        let inBed = currentSleepSession.inBed?.count
        let awake = currentSleepSession.awake?.count
        return awake! == inBed! && awake! > 0
    }
    
    func writeCurrentSleepSessionToFile() -> NSMutableDictionary {
        let path = Helpers().getPathToSleepSessionFile()
        let sleepSessionFile = NSMutableDictionary(contentsOfFile: path)
        let currentSleepSessionDictionary = NSMutableDictionary(dictionary: sleepSessionFile?.object(forKey: dictionaryKeys.currentSleep.rawValue) as! NSMutableDictionary)
        currentSleepSessionDictionary.setObject(currentSleepSession.isInProgress ?? "", forKey: "isInProgress" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.inBed ?? "", forKey: "inBed" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.asleep ?? "", forKey: "asleep" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.awake ?? "", forKey: "awake" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.outOfBed ?? "", forKey: "outOfBed" as NSString)
        
        sleepSessionFile?.setObject(currentSleepSessionDictionary, forKey: dictionaryKeys.currentSleep.rawValue)
        
        if let _ = sleepSessionFile?.write(toFile: path, atomically: true) {
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
        guard let awake = currentSleepSession.awake else { return }
        guard let inBed = currentSleepSession.inBed else { return }
        guard let asleep = currentSleepSession.asleep else { return }
        guard let outOfBed = currentSleepSession.outOfBed else { return }
        
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
        guard let asleep = currentSleepSession.asleep else { return }
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
                    
//                    presentProposedSleepTimeController()
                }
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
        sleepSessionDictionary["inBedData"] = inBedData
        sleepSessionDictionary["asleepData"] = asleepData
        sleepSessionDictionary["awakeData"] = awakeData
        sleepSessionDictionary["outOfBedData"] = outOfBedData
        
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
        addMenuItem(with: UIImage(), title: "End", action: #selector(sleepClicked))
        addMenuItem(with: UIImage(), title: "Cancel", action: #selector(sleepClicked))
        addMenuItem(with: UIImage(), title: "Wake", action: #selector(sleepClicked))
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

    @IBAction func sleepClicked() {
        print("sleep")
    }
    
    @IBAction func wakeClicked() {
        print("wake")
    }
    
    @IBAction func sleepDeferredClicked() {
        print("deferred")
    }
    
    @IBAction func sleepStopClicked() {
        print("stop")
    }
    
    @IBAction func sleepCancelClicked() {
        print("stop")
    }
    
}
