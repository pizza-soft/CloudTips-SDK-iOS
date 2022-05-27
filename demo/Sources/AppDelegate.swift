//
//  AppDelegate.swift
//  Cloudtips-SDK-iOS-Demo
//
//  Created by Sergey Iskhakov on 29.09.2020.
//

import UIKit
import Cloudtips

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        do {
            let yaAppId = "baaa4b67539a4f479145b644a07cf30a"
            try CloudtipsSDK.initialize(yandexPayAppId: yaAppId, sandboxMode: true)
        } catch {
            fatalError("Unable to initialize CloudtipsSDK.")
        }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        CloudtipsSDK.instance.applicationDidReceiveUserActivity(userActivity)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        CloudtipsSDK.instance.applicationDidReceiveOpen(url, sourceApplication: options[.sourceApplication] as? String)
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        CloudtipsSDK.instance.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        CloudtipsSDK.instance.applicationDidBecomeActive()
    }
    
}

