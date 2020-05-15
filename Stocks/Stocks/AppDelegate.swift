//
//  AppDelegate.swift
//  Stocks
//
//  Created by Tony Mackay on 12/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let dataController = DataController(modelName: "Stocks")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkIfFirstLaunch()
        dataController.load()
        return true
    }
    
    // MARK: Methods
    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.hasLaunchedBefore) {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasLaunchedBefore)
            UserDefaults.standard.synchronize()
        }
    }
}
