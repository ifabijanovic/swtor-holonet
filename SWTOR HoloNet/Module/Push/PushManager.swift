//
//  PushManager.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

let keyDidCancelPushAccess = "pushDidCancelPushAccess"
let keyDidApprovePushAccess = "pushDidApprovePushAccess"
let keyLastPushAccessRequestTimestamp = "pushLastPushAccessRequestTimestamp"

let pushAccessRequestRetryInterval: TimeInterval = 5*24*60*60 // 5 days

class PushManager {
    
    // MARK: - Constants
    
    private let requestPushTitle = "Notifications"
    private let requestPushMessage = "Hey, would you like to receive notifications from HoloNet and Dulfy?"
    
    // MARK: - Properties
    
    let alertFactory: AlertFactory
    let actionFactory: ActionFactory
    
    private var didCancelPushAccess: Bool
    private var didApprovePushAccess: Bool
    private var lastPushAccessRequestTimestamp: Date
    
    var isPushEnabled: Bool {
        return UIApplication.shared.currentUserNotificationSettings?.types != []
    }
    
    // MARK: - Init
    
    init(alertFactory: AlertFactory, actionFactory: ActionFactory) {
        self.alertFactory = alertFactory
        self.actionFactory = actionFactory
        
        let defaults = UserDefaults.standard

        self.didCancelPushAccess = defaults.bool(forKey: keyDidCancelPushAccess)
        self.didApprovePushAccess = defaults.bool(forKey: keyDidApprovePushAccess)
        
        let timestamp = defaults.object(forKey: keyLastPushAccessRequestTimestamp) as? Date
        self.lastPushAccessRequestTimestamp = timestamp != nil ? timestamp! : Date.distantPast
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
            let secondsSinceLastRequest = Date().timeIntervalSince(self.lastPushAccessRequestTimestamp)
            if secondsSinceLastRequest < pushAccessRequestRetryInterval {
                return false
            }
        }
        
        return true
    }
    
    func requestPushAccess(viewController: UIViewController) {
        let alert = self.alertFactory.createAlert(presenter: viewController, title: self.requestPushTitle, message: self.requestPushMessage, buttons:
            (style: .cancel, title: "No", handler: {
                // User decided not to grant push access. Set a flag so the app can ask again at a later time
                self.didCancelPushAccess = true
                self.lastPushAccessRequestTimestamp = Date()
                UserDefaults.standard.set(true, forKey: keyDidCancelPushAccess)
                UserDefaults.standard.set(self.lastPushAccessRequestTimestamp, forKey: keyLastPushAccessRequestTimestamp)
                UserDefaults.standard.synchronize()

            }),
            (style: .default, title: "Yes", handler: {
                // User agreed to grant push access. Set a flag and register for push
                self.didApprovePushAccess = true
                UserDefaults.standard.set(true, forKey: keyDidApprovePushAccess)
                UserDefaults.standard.synchronize()
                
                self.registerForPush()
            })
        )
        alert.show()
    }
    
    // MARK: - Registering
    
    func registerForPush() {
        let application = UIApplication.shared
        
        let types: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func registerDeviceToken(_ deviceToken: Data) {
        
    }
    
    // MARK: - Notification handling
    
    func handleRemoteNotification(applicationState: UIApplicationState, userInfo: [AnyHashable : Any]) {
        var result = false
        // Try to perform an action
        if let action = self.actionFactory.create(userInfo: userInfo) {
            result = action.perform(userInfo: userInfo, isForeground: applicationState == .active)
        }
        
        self.resetBadge()
        
        if !result {
#if !TEST
            // If performing an action failed, fallback to default Parse handling
#endif
        }
    }
    
    func resetBadge() {
        
    }
    
}
