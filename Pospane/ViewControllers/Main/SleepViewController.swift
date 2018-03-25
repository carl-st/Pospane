//
//  SleepViewController.swift
//  Pospane
//
//  Created by Karol Stępień on 12.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

class SleepViewController: UIViewController {
    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    private let heartRateUnit = HKUnit(from: "count/min")
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    var endTime: Date!
    var alarmTime: Date!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black 
    }

    
    func saveSleepAnalysis() {
        

        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {

            let object = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.alarmTime, end: self.endTime)

            healthStore.save(object, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    return
                }
                
                if success {
                    print("My new data was saved in HealthKit")
                    
                } else {
 
                }
            })

            let object2 = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: self.alarmTime, end: self.endTime)

            healthStore.save(object2, withCompletion: { (success, error) -> Void in
                if error != nil {
                    return
                }
                
                if success {
                    print("My new data (2) was saved in HealthKit")
                } else {

                }
            })
        }
    }
    
    func retrieveSleepAnalysis() {
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
            }
            
            healthStore.execute(query)
        }
    }
}

