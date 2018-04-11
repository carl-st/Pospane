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
    
    private func isSleepSessionInProgress() {
//        let session = Utility.contentsOfCurrentSleepSession
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
