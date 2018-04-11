//
//  HealthKitOnbardingViewController.swift
//  Pospane
//
//  Created by Karol Stępień on 25.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit
import HealthKit
import SIAlertView
import Font_Awesome_Swift

class HealthKitOnbardingViewController: UIViewController {
    
    @IBOutlet var healthLabel: UILabel!
    private let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthLabel.setFAIcon(icon: .FAHeartbeat, iconSize: 200)

    }
    
    
    @IBAction func authoriseClicked(_ sender: Any) {
        authorizeHealthKit()
    }
    
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
}
