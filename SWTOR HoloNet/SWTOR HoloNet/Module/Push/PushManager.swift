//
//  PushManager.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

let keyDidCancelPushAccess = "pushDidCancelPushAccess"
let keyDidApprovePushAccess = "pushDidApprovePushAccess"
let keyLastPushAccessRequestTimestamp = "pushLastPushAccessRequestTimestamp"

let pushAccessRequestRetryInterval: NSTimeInterval = 5*24*60*60 // 5 days

class PushManager {
    
    // MARK: - Constants
    
    private let requestPushTitle = "Notifications"
    private let requestPushMessage = "Hey, would you like to receive notifications from HoloNet and Dulfy?"
    
    private let useNewApi = objc_getClass("UIUserNotificationSettings") != nil
    
    // MARK: - Properties
    
    let alertFactory: AlertFactory
    let actionFactory: ActionFactory
    
    private var didCancelPushAccess: Bool
    private var didApprovePushAccess: Bool
    private var lastPushAccessRequestTimestamp: NSDate
    
    var isPushEnabled: Bool {
        get {
            return self.useNewApi
                ? UIApplication.sharedApplication().currentUserNotificationSettings().types != UIUserNotificationType.None
                : UIApplication.sharedApplication().enabledRemoteNotificationTypes() != UIRemoteNotificationType.None
        }
    }
    
    // MARK: - Init
    
    init(alertFactory: AlertFactory, actionFactory: ActionFactory) {
        self.alertFactory = alertFactory
        self.actionFactory = actionFactory
        
        let defaults = NSUserDefaults.standardUserDefaults()

        self.didCancelPushAccess = defaults.boolForKey(keyDidCancelPushAccess)
        self.didApprovePushAccess = defaults.boolForKey(keyDidApprovePushAccess)
        
        let timestamp = defaults.objectForKey(keyLastPushAccessRequestTimestamp) as? NSDate
        self.lastPushAccessRequestTimestamp = timestamp != nil ? timestamp! : NSDate.distantPast() as NSDate
    }

    
    // MARK: - Requesting access
    
    func shouldRequestPushAccess() -> Bool {
        if self.isPushEnabled {
            // Push is already enabled, no need to request access
            return false
        }
        
        if self.didApprovePushAccess {
            // User already approved push access, no need to ask again
            return false
        }
        
        if self.didCancelPushAccess {
            // User canceled the push access prompt, check if enough time passed to ask again
            let secondsSinceLastRequest = NSDate().timeIntervalSinceDate(self.lastPushAccessRequestTimestamp)
            if secondsSinceLastRequest < pushAccessRequestRetryInterval {
                return false
            }
        }
        
        return true
    }
    
    func requestPushAccess(#viewController: UIViewController) {
        let alert = self.alertFactory.createAlert(viewController, title: self.requestPushTitle, message: self.requestPushMessage, buttons:
            (style: .Cancel, title: "No", handler: {
                // User decided not to grant push access. Set a flag so the app can ask again at a later time
                self.didCancelPushAccess = true
                self.lastPushAccessRequestTimestamp = NSDate()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: keyDidCancelPushAccess)
                NSUserDefaults.standardUserDefaults().setObject(self.lastPushAccessRequestTimestamp, forKey: keyLastPushAccessRequestTimestamp)
                NSUserDefaults.standardUserDefaults().synchronize()

            }),
            (style: .Default, title: "Yes", handler: {
                // User agreed to grant push access. Set a flag and register for push
                self.didApprovePushAccess = true
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: keyDidApprovePushAccess)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.registerForPush()
            })
        )
        alert.show()
    }
    
    // MARK: - Registering
    
    func registerForPush() {
        let application = UIApplication.sharedApplication()
        
        if self.useNewApi {
            // iOS 8+
            let types: UIUserNotificationType = .Alert | .Badge | .Sound
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // iOS 7
            let types: UIRemoteNotificationType = .Alert | .Badge | .Sound
            application.registerForRemoteNotificationTypes(types)
        }
    }
    
    func registerDeviceToken(deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"];
        currentInstallation.saveInBackground()
    }
    
    // MARK: - Notification handling
    
    func handleRemoteNotification(#applicationState: UIApplicationState, userInfo: [NSObject : AnyObject]) {
        var result = false
        // Try to perform an action
        if let action = self.actionFactory.create(userInfo: userInfo) {
            result = action.perform(userInfo, isForeground: applicationState == .Active)
        }
        
        self.resetBadge()
        
        if !result {
#if !TEST
            // If performing an action failed, fallback to default Parse handling
            PFPush.handlePush(userInfo)
#endif
        }
    }
    
    func resetBadge() {
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge > 0 {
            currentInstallation.badge = 0
            currentInstallation.saveInBackground()
        }
    }
    
}
