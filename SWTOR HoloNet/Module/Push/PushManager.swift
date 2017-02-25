//
//  PushManager.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

protocol PushManager {
    var isEnabled: Bool { get }
    var shouldRequestAccess: Bool { get }
    
    func requestAccess(presenter: UIViewController)
    func register()
    func register(deviceToken: Data)
    func handleRemoteNotification(applicationState: UIApplicationState, userInfo: [AnyHashable : Any])
    func resetBadge()
}

class DefaultPushManager: PushManager {
    fileprivate let alertFactory: UIAlertFactory
    fileprivate let actionFactory: ActionFactory
    
    fileprivate var didCancelPushAccess: Bool
    fileprivate var didApprovePushAccess: Bool
    fileprivate var lastPushAccessRequestTimestamp: Date
    
    init(alertFactory: UIAlertFactory, actionFactory: ActionFactory) {
        self.alertFactory = alertFactory
        self.actionFactory = actionFactory
        
        let defaults = UserDefaults.standard
        
        self.didCancelPushAccess = defaults.bool(forKey: Constants.Push.UserDefaults.didCancelPushAccess)
        self.didApprovePushAccess = defaults.bool(forKey: Constants.Push.UserDefaults.didApprovePushAccess)
        
        let timestamp = defaults.object(forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp) as? Date
        self.lastPushAccessRequestTimestamp = timestamp != nil ? timestamp! : Date.distantPast
    }
    
    // MARK: -

    var isEnabled: Bool {
        return UIApplication.shared.currentUserNotificationSettings?.types != []
    }
    
    var shouldRequestAccess: Bool {
        if self.isEnabled {
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
            if secondsSinceLastRequest < Constants.Push.accessRequestRetryInterval {
                return false
            }
        }
        
        return true
    }
    
    func requestAccess(presenter: UIViewController) {
        let alertController = self.alertFactory.alert(title: Constants.Push.UI.requestAccessTitle, message: Constants.Push.UI.requestAccessMessage, actions: [
            (title: "No", style: .cancel, handler: { [unowned self] _ in
                // User decided not to grant push access. Set a flag so the app can ask again at a later time
                self.didCancelPushAccess = true
                self.lastPushAccessRequestTimestamp = Date()
                UserDefaults.standard.set(true, forKey: Constants.Push.UserDefaults.didCancelPushAccess)
                UserDefaults.standard.set(self.lastPushAccessRequestTimestamp, forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp)
                UserDefaults.standard.synchronize()

            }),
            (title: "Yes", style: .default, handler: { [unowned self] _ in
                // User agreed to grant push access. Set a flag and register for push
                self.didApprovePushAccess = true
                UserDefaults.standard.set(true, forKey: Constants.Push.UserDefaults.didApprovePushAccess)
                UserDefaults.standard.synchronize()
                
                self.register()
            })
        ])
        presenter.present(alertController, animated: true, completion: nil)
    }
    
    func register() {
        let application = UIApplication.shared
        
        let types: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func register(deviceToken: Data) {
        
    }
    
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
