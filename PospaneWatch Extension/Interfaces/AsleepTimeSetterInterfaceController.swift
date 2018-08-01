//
//  AsleepTimeSetterInterfaceController.swift
//  PospaneWatch Extension
//
//  Created by Karol Stępień on 03.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import WatchKit
import Foundation


class AsleepTimeSetterInterfaceController: WKInterfaceController {

    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func saveClicked() {
        
    }
    
}
