//
//  ConfirmInterfaceController.swift
//  PospaneWatch Extension
//
//  Created by Karol Stępień on 03.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import WatchKit
import Foundation

protocol ConfirmInterfaceControllerDelegate {
    func proposedSleepStartDecision(buttonValue: Int, sleepStartDate: Date)
}

class ConfirmInterfaceController: WKInterfaceController {

    @IBOutlet var confirmMessageLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    var delegate: ConfirmInterfaceControllerDelegate?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        WKInterfaceDevice.current().play(.success)
        
        if let context = context as? [String: Any] {
            if let contextDelegate = context["delegate"] as? ConfirmInterfaceControllerDelegate {
                self.delegate = contextDelegate
            }
            
            if let contextTime = context["time"] as? Date {
                let dateFormatter = Helpers().dateFormatterForTimeLabels()
                self.timeLabel.setText(dateFormatter.string(from: contextTime))
            }
        }
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    @IBAction func confirmClicked() {
        self.dismiss()
        self.delegate?.proposedSleepStartDecision(buttonValue: 0, sleepStartDate: Date()) // nil instead of date?
    }
    
    @IBAction func denyClicked() {
        self.dismiss()
        self.delegate?.proposedSleepStartDecision(buttonValue: 1, sleepStartDate: Date())
    }
    
}
