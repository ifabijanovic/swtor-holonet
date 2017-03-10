//
//  PushManager.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import Cleanse

#if !TEST
import Firebase
#endif

protocol PushManager {
    var isEnabled: Bool { get }
    var shouldRequestAccess: Bool { get }
    
    func requestAccess(navigator: Navigator)
    func register()
    func register(deviceToken: Data)
    func handleRemoteNotification(applicationState: UIApplicationState, userInfo: [AnyHashable : Any])
    func resetBadge()
}

class DefaultPushManager: NSObject, PushManager {
    fileprivate let actionFactory: ActionFactory
    fileprivate let navigator: Navigator
    
    fileprivate var didCancelPushAccess: Bool
    fileprivate var didApprovePushAccess: Bool
    fileprivate var lastPushAccessRequestTimestamp: Date
    
    init(actionFactory: ActionFactory, navigator: Navigator) {
        self.actionFactory = actionFactory
        self.navigator = navigator
        
        let defaults = UserDefaults.standard
        
        self.didCancelPushAccess = defaults.bool(forKey: Constants.Push.UserDefaults.didCancelPushAccess)
        self.didApprovePushAccess = defaults.bool(forKey: Constants.Push.UserDefaults.didApprovePushAccess)
        
        let timestamp = defaults.object(forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp) as? Date
        self.lastPushAccessRequestTimestamp = timestamp != nil ? timestamp! : Date.distantPast
        
        super.init()
        
        #if !TEST
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        #endif
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
    
    func requestAccess(navigator: Navigator) {
        navigator.showAlert(title: Constants.Push.UI.requestAccessTitle, message: Constants.Push.UI.requestAccessMessage, actions: [
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
    }
    
    func register() {
        let application = UIApplication.shared
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { _,_ in })
            
            #if !TEST
            FIRMessaging.messaging().remoteMessageDelegate = self
            #endif
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
    
    func register(deviceToken: Data) {
        #if !TEST
            #if DEBUG
                let type = FIRInstanceIDAPNSTokenType.sandbox
            #else
                let type = FIRInstanceIDAPNSTokenType.prod
            #endif
            FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: type)
            
            // Topics
            // Performed with delay because of Firebase bug
            // https://github.com/firebase/quickstart-ios/issues/146
            DispatchQueue.main.async { FIRMessaging.messaging().subscribe(toTopic: "/topics/general") }
            DispatchQueue.main.async { FIRMessaging.messaging().subscribe(toTopic: "/topics/dulfy") }
            #if DEBUG
            DispatchQueue.main.async { FIRMessaging.messaging().subscribe(toTopic: "/topics/debug") }
            #endif
        #endif
    }
    
    func handleRemoteNotification(applicationState: UIApplicationState, userInfo: [AnyHashable : Any]) {
        let result = self.actionFactory
            .create(userInfo: userInfo)?
            .perform(userInfo: userInfo, isForeground: applicationState == .active)
            ?? false
        
        self.resetBadge()
        
        if #available(iOS 10.0, *) {
            // Do nothing, handled by the UNUserNotificationCenterDelegate
        } else {
            if !result {
                self.navigator.showNotification(userInfo: userInfo)
            }
        }
        
        #if !TEST
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        #endif
    }
    
    func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension DefaultPushManager {
    struct Module: Cleanse.Module {
        static func configure<B: Binder>(binder: B) {
            binder
                .bind(PushManager.self)
                .asSingleton()
                .to(factory: DefaultPushManager.init)
        }
    }
}

@available(iOS 10.0, *)
extension DefaultPushManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.handleRemoteNotification(applicationState: .background, userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
}

#if !TEST
extension DefaultPushManager: FIRMessagingDelegate {
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        
    }
}
#endif
