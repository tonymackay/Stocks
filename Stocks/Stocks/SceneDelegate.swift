//
//  SceneDelegate.swift
//  Stocks
//
//  Created by Tony Mackay on 12/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let navigationController = window?.rootViewController as! UINavigationController
        let locationsViewController = navigationController.topViewController as! WatchlistViewController
        locationsViewController.dataController = (UIApplication.shared.delegate as? AppDelegate)?.dataController
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.dataController.saveContext()
    }
}
