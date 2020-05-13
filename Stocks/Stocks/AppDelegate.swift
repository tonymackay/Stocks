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
        dataController.load()
        return true
    }
}
