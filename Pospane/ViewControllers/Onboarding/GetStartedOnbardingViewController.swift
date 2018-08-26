//
//  GetStartedOnbardingViewController.swift
//  Pospane
//
//  Created by Karol Stępień on 25.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit

class GetStartedOnbardingViewController: UIViewController {

    @IBOutlet var getStartedLabel: UILabel!
    let defaults: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStartedLabel.setFAIcon(icon: .FACheckCircleO, iconSize: 200)
    }
    
    @IBAction func getStartedClicked(_ sender: Any) {
        defaults.set(true, forKey: "Onboarded")
        self.performSegue(withIdentifier: SegueIdentifier.showMain.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showMain.rawValue {

        }
    }
}
