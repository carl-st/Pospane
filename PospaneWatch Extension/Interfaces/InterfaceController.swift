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
    private var sleepSessionToSave: Dictionary<String, AnyObject>?
    
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
        let path = Bundle.main.path(forResource: "SavedSleepSession", ofType: "plist") // TODO: Add to constants file
        if FileManager().fileExists(atPath: path!) {
            return
        }
        let sleepingFilePath = Bundle.main.path(forResource: "Sleeping", ofType: "plist")
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
    
    func writeCurrentSleepSessionToFile() {
        let path = Helpers().getPathToSleepSessionFile()
        let sleepSessionFile = NSMutableDictionary(contentsOfFile: path)
        let currentSleepSessionDictionary = NSMutableDictionary(dictionary: sleepSessionFile?.object(forKey: "currentSleepSession") as! NSMutableDictionary)
        currentSleepSessionDictionary.setObject(currentSleepSession.isInProgress ?? "", forKey: "isInProgress" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.inBed ?? "", forKey: "inBed" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.asleep ?? "", forKey: "asleep" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.awake ?? "", forKey: "awake" as NSString)
        currentSleepSessionDictionary.setObject(currentSleepSession.outOfBed ?? "", forKey: "outOfBed" as NSString)
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

    @IBAction func sleepClicked() {
        print("sleep")
    }
    
    @IBAction func wakeClicked() {
        print("wake")
    }
    
}
