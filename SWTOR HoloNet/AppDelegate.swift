//
//  AppDelegate.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var analytics: Analytics?
    var pushManager: PushManager?
    var navigator: Navigator?
    var window: UIWindow?
    
    private var launchNotification: [AnyHashable: Any]? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FIRApp.configure()
        
        // Dependencies
        self.analytics = DefaultAnalytics()
        self.navigator = DefaultNavigator(settings: Settings())
        self.pushManager = DefaultPushManager(actionFactory: ActionFactory(navigator: self.navigator!))
        
        // Disable caching
        let cache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.shared = cache
        
        // Register for push notifications
        if self.pushManager?.isEnabled ?? false {
            self.pushManager?.register()
        }
        
        // Check if app was launched via push notification
        if let launchNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            self.launchNotification = launchNotification
        }
        
        // Setup window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = TabViewController(services: StandardServices.instance, pushManager: self.pushManager!)
        self.window = window
        window.makeKeyAndVisible()

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushManager?.register(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        self.pushManager?.handleRemoteNotification(applicationState: application.applicationState, userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.pushManager?.handleRemoteNotification(applicationState: application.applicationState, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.noData)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Push notification startup
        self.pushManager?.resetBadge()
        
        if self.pushManager?.shouldRequestAccess ?? false {
            if let navigator = self.navigator {
                self.pushManager?.requestAccess(navigator: navigator)
            }
        }
        
        // Check if there is a pending launch push notification
        if let launchNotification = self.launchNotification {
            // Handle the notification as if the app was in background
            self.pushManager?.handleRemoteNotification(applicationState: .background, userInfo: launchNotification)
            self.launchNotification = nil
        }
    }
}
