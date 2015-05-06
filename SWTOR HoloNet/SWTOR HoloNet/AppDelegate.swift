//
//  AppDelegate.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Parse
import ParseCrashReporting
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Disable caching
        let cache = NSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        NSURLCache.setSharedURLCache(cache)
        
        // Register notification listeners
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAlert:", name: ShowAlertNotification, object: nil)
        
        // Setup parse
        let parseSettings = InstanceHolder.sharedInstance().settings.parse
#if !DEBUG && !TEST
        ParseCrashReporting.enable()
#endif
        Parse.setApplicationId(parseSettings.applicationId, clientKey: parseSettings.clientId)
        
#if !DEBUG && !TEST
        // Enable Parse analytics
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
#endif
        
        // Register for push notifications
        let pushManager = InstanceHolder.sharedInstance().pushManager
        if pushManager.isPushEnabled {
            pushManager.registerForPush()
        }

        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        InstanceHolder.sharedInstance().pushManager.registerDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == .Inactive {
#if !DEBUG && !TEST
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
#endif
        }
        InstanceHolder.sharedInstance().pushManager.handleRemoteNotification(applicationState: application.applicationState, userInfo: userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Push notification startup
        let pushManager = InstanceHolder.sharedInstance().pushManager
        pushManager.resetBadge()
        if pushManager.shouldRequestPushAccess() {
            if let presenter = self.window?.rootViewController {
                pushManager.requestPushAccess(viewController: presenter)
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
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

