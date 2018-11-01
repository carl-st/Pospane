//
//  ResultsViewController.swift
//  Pospane
//
//  Created by Karol Stępień on 01/11/2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet var resultsTextView: UITextView!
    var resultsText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTextView.text = resultsText
        // Do any additional setup after loading the view.
    }
    

}
