//
//  PushManager.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

class PushManager {
    
    // MARK: - Constants
    
    let keyDidCancelPushAccess = "pushDidCancelPushAccess"
    let keyLastPushAccessRequestTimestamp = "pushLastPushAccessRequestTimestamp"
    
    let pushAccessRequestRetryInterval: NSTimeInterval = 5*24*60*60 // 5 days
    
    private let requestPushTitle = "Notifications"
    private let requestPushMessage = "Hey, is it cool if we send you a notification from time to time?"
    
    // MARK: - Properties
    
    private var didCancelPushAccess: Bool
    private var lastPushAccessRequestTimestamp: NSDate
    
    // MARK: - Init
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.didCancelPushAccess = defaults.boolForKey(self.keyDidCancelPushAccess)
        
        let timestamp = defaults.objectForKey(self.keyLastPushAccessRequestTimestamp) as? NSDate
        self.lastPushAccessRequestTimestamp = timestamp != nil ? timestamp! : NSDate.distantPast() as NSDate
    }

    
    // MARK: - Push access
    
    func shouldRequestPushAccess() -> Bool {
        if self.isPushEnabled() {
            // Push is already enabled, no need to request access
            return false
        }
        
        if self.didCancelPushAccess {
            // User canceled the push access prompt, check if enough time passed to ask again
            let secondsSinceLastRequest = NSDate().timeIntervalSinceDate(self.lastPushAccessRequestTimestamp)
            if secondsSinceLastRequest < self.pushAccessRequestRetryInterval {
                return false
            }
        }
        
        return true
    }
    
    func requestPushAccess(#viewController: UIViewController) {
        showAlert(viewController, style: .Alert, title: self.requestPushTitle, message: self.requestPushMessage, sourceView: nil, completion: nil,
            (.Cancel, "No", {
                self.didCancelPushAccess = true
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: self.keyDidCancelPushAccess)
                NSUserDefaults.standardUserDefaults().synchronize()
            }),
            (.Default, "Yes", {
                // TODO: Request push access here
            })
        )
    }
    
    // MARK: - Private methods
    
    private func isPushEnabled() -> Bool {
        let app = UIApplication.sharedApplication()
        var pushEnabled = false
        
        if objc_getClass("UIUserNotificationSettings") != nil {
            // iOS 8+
            pushEnabled = app.currentUserNotificationSettings().types != UIUserNotificationType.None
        } else {
            // iOS 7
            pushEnabled = app.enabledRemoteNotificationTypes() != UIRemoteNotificationType.None
        }
        
        return pushEnabled
    }
    
}
