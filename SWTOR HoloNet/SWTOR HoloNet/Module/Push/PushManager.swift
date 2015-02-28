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
    
    init() {
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
        showAlert(viewController, style: .Alert, title: self.requestPushTitle, message: self.requestPushMessage, sourceView: nil, completion: nil,
            (.Cancel, "No", {
                // User decided not to grant push access. Set a flag so the app can ask again at a later time
                self.didCancelPushAccess = true
                self.lastPushAccessRequestTimestamp = NSDate()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: keyDidCancelPushAccess)
                NSUserDefaults.standardUserDefaults().setObject(self.lastPushAccessRequestTimestamp, forKey: keyLastPushAccessRequestTimestamp)
                NSUserDefaults.standardUserDefaults().synchronize()
            }),
            (.Default, "Yes", {
                // User agreed to grant push access. Set a flag and register for push
                self.didApprovePushAccess = true
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: keyDidApprovePushAccess)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.registerForPush()
            })
        )
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
    
    func handleRemoteNotification(#application: UIApplication, userInfo: [NSObject : AnyObject]) {
        let state = application.applicationState
        if state == .Active {
            self.handleForegroundNotification(userInfo)
        } else if state == .Inactive {
            self.handleBackgroundNotification(userInfo)
        }
    }
    
    func resetBadge() {
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge > 0 {
            currentInstallation.badge = 0
            currentInstallation.saveInBackground()
        }
    }
    
    private func handleForegroundNotification(userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
    
    private func handleBackgroundNotification(userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
    
}
