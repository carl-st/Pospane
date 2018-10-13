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

class SleepViewController: UIViewController, WCSessionDelegate {
    @IBOutlet var sleepButton: UIButton!
    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    private let heartRateUnit = HKUnit(from: "count/min")
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    var endTime: Date!
    var alarmTime: Date!
    private var service: Service?
    @IBOutlet var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        service = Service.sharedInstance
        sleepButton.setFAIcon(icon: .FAPowerOff, iconSize: 200, forState: .normal)
        sleepButton.layer.cornerRadius = 4.0
        session?.delegate = self
        session?.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[DEBUG] WatchConnectivity Session state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        guard let request = message["request"] as? String else { return }
        
        print(message)
        var response: [String : Any] = [:]
        if request == "hr" {
            // TODO
            guard let heartRate = message["hr"] as? Double else { return }
            let rr = 60 / heartRate * 1000
            service?.sendMessage(rr: rr)
            /// Updating the UI with the retrieved value
            DispatchQueue.main.async {
                self.heartRateLabel.text = String(format: "HR:%.2f RR:%.2f", heartRate, rr)
                
                print("Phone HR: \(Int(heartRate))")
                print("Phone RR: \(Int(rr))")
            }
            
        } else {
            print("unknown request")
        }
    }
}

