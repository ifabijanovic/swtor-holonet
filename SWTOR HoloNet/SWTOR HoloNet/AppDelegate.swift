//
//  AppDelegate.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var launchNotification: [AnyHashable: Any]? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Disable caching
        let cache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.shared = cache
        
        // Register notification listeners
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.showAlert(notification:)), name: NSNotification.Name(ShowAlertNotification), object: nil)
        
        // Register for push notifications
        let pushManager = InstanceHolder.sharedInstance.pushManager
        if pushManager.isPushEnabled {
            pushManager.registerForPush()
        }
        
        // Check if app was launched via push notification
        if let launchNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            self.launchNotification = launchNotification
        }

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceHolder.sharedInstance.pushManager.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if application.applicationState == .inactive {
#if !DEBUG && !TEST
            // TODO: App opened analytics
#endif
        }
        InstanceHolder.sharedInstance.pushManager.handleRemoteNotification(applicationState: application.applicationState, userInfo: userInfo)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Push notification startup
        let pushManager = InstanceHolder.sharedInstance.pushManager
        pushManager.resetBadge()
        if pushManager.shouldRequestPushAccess() {
            if let presenter = self.window?.rootViewController {
                pushManager.requestPushAccess(viewController: presenter)
            }
        }
        
        // Check if there is a pending launch push notification
        if let launchNotification = self.launchNotification {
            // Handle the notification as if the app was in background
            pushManager.handleRemoteNotification(applicationState: .background, userInfo: launchNotification)
            self.launchNotification = nil
        }
        
        // Save some settings for the user
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func showAlert(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let alert = userInfo["alert"] as? Alert {
                if let presenter = self.window?.rootViewController {
                    alert.presenter = presenter
                    alert.show()
                }
            }
        }
    }

}

