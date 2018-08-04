//
//  AsleepTimeSetterInterfaceController.swift
//  PospaneWatch Extension
//
//  Created by Karol Stępień on 03.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import WatchKit
import Foundation

protocol AsleepTimeSetterInterfaceControllerDelegate {
    func proposedSleepStartDecision(buttonValue: Int, sleepStartDate: Date?)
}

class AsleepTimeSetterInterfaceController: WKInterfaceController, WKCrownDelegate {

    @IBOutlet var timeLabel: WKInterfaceLabel!
    private var inputDate = Date()
    private var maxSleepStart = Date()
    private var originalSleepStart = Date()
    private var delegate: AsleepTimeSetterInterfaceControllerDelegate?
    private let labelTimeFormatter = Helpers().dateFormatterForTimeLabels()
    
    // TODO: extract constants
    private var scaleOfTimeLabel = 30.0
    private var scaleCount = 0.0
    
    private let kScaleCountUpperLimit = 11.0
    private let kDefaultFontSizeTimeLabel = 30.0;
    private let kDigitalCrownScrollMultiplier = 500.0;
    
    override init() {
        super.init()
        
        WKInterfaceDevice.current().play(.success)
        self.crownSequencer.delegate = self
        
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        
        if let context = context as? [String: Any] {
            if let contextDelegate = context["delegate"] as? AsleepTimeSetterInterfaceControllerDelegate {
                self.delegate = contextDelegate
            }
            
            guard let time = context["time"] as? Date else { return }
            guard let maxSleepStart = context["maxSleepStart"] as? Date else { return }
            
            self.maxSleepStart = maxSleepStart
            originalSleepStart = time
            inputDate = time
        }
        
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func saveClicked() {
        self.crownSequencer.resignFocus()
        self.dismiss()
        self.delegate?.proposedSleepStartDecision(buttonValue: 0, sleepStartDate: inputDate)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        print("[DEBUG] rotation delta:", rotationalDelta)
        
        if inputDate == originalSleepStart && rotationalDelta <= 0.000001 && scaleCount != kScaleCountUpperLimit {
            inputDate = originalSleepStart
            scaleOfTimeLabel = scaleOfTimeLabel - 0.5
            scaleCount = scaleCount + 1
            if scaleCount == kScaleCountUpperLimit {
                WKInterfaceDevice.current().play(.start)
            }
            self.updateLabel()
        } else if inputDate == maxSleepStart && rotationalDelta >= 0.000001 && scaleCount != kScaleCountUpperLimit {
            inputDate = maxSleepStart
            scaleOfTimeLabel = scaleOfTimeLabel - 0.5
            scaleCount = scaleCount + 1
            if scaleCount == kScaleCountUpperLimit {
                WKInterfaceDevice.current().play(.start)
            }
            self.updateLabel()
        } else if Helpers().compare(originalDate: inputDate, isLaterThanOrEqualTo: originalSleepStart) {
            inputDate = Date(timeInterval: rotationalDelta * kDigitalCrownScrollMultiplier, since: inputDate)
            scaleOfTimeLabel = kDefaultFontSizeTimeLabel
            if Helpers().compare(originalDate: inputDate, isLaterThanOrEqualTo: maxSleepStart) {
                inputDate = maxSleepStart
            }
            self.updateLabel()
        }
        
    }
    
    private func updateLabel() {
        let formattedTime = labelTimeFormatter.string(from: inputDate)
        self.timeLabel.setText(formattedTime)
    }
}
