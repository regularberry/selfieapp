//
//  AppDelegate.swift
//  selfieapp
//
//  Created by Sean Berry on 9/25/17.
//  Copyright © 2017 Sean Berry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let nav = window?.rootViewController as? UINavigationController,
            let vc = nav.topViewController as? DisplaysSensitiveData {
            vc.hideSensitiveData()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if let nav = window?.rootViewController as? UINavigationController,
            let vc = nav.topViewController as? DisplaysSensitiveData {
            vc.showSensitiveData()
        }
    }
}
