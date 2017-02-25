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

    var analytics: Analytics?
    var pushManager: PushManager?
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
        if pushManager.isEnabled {
            pushManager.register()
        }
        
        // Check if app was launched via push notification
        if let launchNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            self.launchNotification = launchNotification
        }
        
        // Dependencies
        self.analytics = DefaultAnalytics()
        let alertFactory = DefaultUIAlertFactory()
        self.pushManager = DefaultPushManager(alertFactory: alertFactory, actionFactory: ActionFactory(alertFactory: alertFactory))
        
        // Setup window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = TabViewController(analytics: InstanceHolder.sharedInstance.analytics, settings: InstanceHolder.sharedInstance.settings)
        self.window = window
        window.makeKeyAndVisible()

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushManager?.register(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if application.applicationState == .inactive {
            self.analytics?.appOpened()
        }
        self.pushManager?.handleRemoteNotification(applicationState: application.applicationState, userInfo: userInfo)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Push notification startup
        self.pushManager?.resetBadge()
        
        if self.pushManager?.shouldRequestAccess ?? false {
            if let presenter = self.window?.rootViewController {
                self.pushManager?.requestAccess(presenter: presenter)
            }
        }
        
        // Check if there is a pending launch push notification
        if let launchNotification = self.launchNotification {
            // Handle the notification as if the app was in background
            self.pushManager?.handleRemoteNotification(applicationState: .background, userInfo: launchNotification)
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
