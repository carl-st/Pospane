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
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var endTime: Date!
    var alarmTime: Date!
    var rrWindow: [Double] = []
    private var service: Service?
    @IBOutlet var heartRateLabel: UILabel!
    @IBOutlet var mlSegmentedControl: UISegmentedControl!
    var segmentedControlState = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        sleepButton.setFAIcon(icon: .FAMoonO, iconSize: 200, forState: .normal)
        sleepButton.layer.cornerRadius = 4.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        segmentedControlState = mlSegmentedControl.selectedSegmentIndex
        if segmentedControlState == 0 {
            service?.destroy()
        } else {
            service = Service.sharedInstance
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let managedContext = appDelegate.persistentContainer.viewContext

        guard let request = message["request"] as? String else { return }
        
        print(message)
        var response: [String : Any] = [:]
        if request == "heartRate" {
            // TODO
            guard let heartRate = message["value"] as? Double else { return }
            let rr = 60 / heartRate * 1000

            if segmentedControlState == 1 {
                service?.sendMessage(rr: rr)
                /// Updating the UI with the retrieved value
                DispatchQueue.main.async {
                    self.heartRateLabel.text = String(format: "HR: %.2f RR: %.2f", heartRate, rr)
                }
            } else {
                let resultTuple = slidingWindowFeatures(rr: rr, values: rrWindow, width: 10)
                rrWindow = resultTuple.values
                DispatchQueue.main.async {
                    self.heartRateLabel.text = String(format: "HR: %.2f RR: %.2f\nPhase: %d", heartRate, rr, resultTuple.output)
                }
            }
            print("Phone HR: \(Int(heartRate))")
            print("Phone RR: \(Int(rr))")

        } else if request == "sendData" {
            handleWatchData(message: message, managedContext: managedContext, replyHandler: replyHandler)
        } else {
            print("unknown sleep request")
        }
    }
}

