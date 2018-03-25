//
//  Appearance.swift
//  Pospane
//
//  Created by Karol Stępień on 25.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    func applyAppearance() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "GillSans-SemiBold", size: 20.0)!,
                                                            NSAttributedStringKey.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, 0), for: UIBarMetrics.default)
        UINavigationBar.appearance().tintColor = UIColor.lightGray
        UINavigationBar.appearance().barTintColor = UIColor.darkGray
    }
    
}

