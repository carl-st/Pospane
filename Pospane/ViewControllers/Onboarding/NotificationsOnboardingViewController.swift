//
//  NotificationsOnboardingViewController.swift
//  Pospane
//
//  Created by Karol Stępień on 25.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit

class NotificationsOnboardingViewController: UIViewController {

    @IBOutlet var notificationsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsLabel.setFAIcon(icon: .FABellO, iconSize: 200)
    }

}
