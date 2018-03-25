//
//  AppDelegate.swift
//  Pospane
//
//  Created by Karol Stępień on 12.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults: UserDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let onboarded: Bool = defaults.bool(forKey: "Onboarded" )
        if !onboarded {
            let storyboard = UIStoryboard(name: StoryboardNames.Onboarding.rawValue, bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: ViewControllerStoryboardIdentifier.PageViewContainer.rawValue)
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

}
