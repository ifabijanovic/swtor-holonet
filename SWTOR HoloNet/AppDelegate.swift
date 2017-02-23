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
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.showAlert(notification:)), name: NSNotification.Name(Constants.Notifications.showAlert), object: nil)
        
        // Register for push notifications
        let pushManager = InstanceHolder.sharedInstance.pushManager
        if pushManager.isPushEnabled {
            pushManager.registerForPush()
        }
        
        // Check if app was launched via push notification
        if let launchNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            self.launchNotification = launchNotification
        }
        
        // Setup window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = TabViewController(analytics: InstanceHolder.sharedInstance.analytics, settings: InstanceHolder.sharedInstance.settings)
        self.window = window
        window.makeKeyAndVisible()

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceHolder.sharedInstance.pushManager.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if application.applicationState == .inactive {
            // TODO: App opened analytics
        }
        InstanceHolder.sharedInstance.pushManager.handleRemoteNotification(applicationState: application.applicationState, userInfo: userInfo)
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
    
    func showAlert(notification: NSNotification) {
        guard let alertController = notification.userInfo?[Constants.Notifications.UserInfo.alert] as? UIAlertController,
            let presenter = self.window?.rootViewController
            else { return }
        
        presenter.present(alertController, animated: true, completion: nil)
    }
}

