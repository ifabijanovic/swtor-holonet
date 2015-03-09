//
//  DulfyAction.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 09/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

let keyDulfyUrl = "url"
let keyDulfyMessage = "alert"

class DulfyAction: Action {
    
    // MARK: - Constants
    
    private let alertFactory: AlertFactory
    
    // MARK: - Properties
    
    var type: String {
        get {
            return keyDulfyAction
        }
    }
    
    // MARK: - Init
    
    init(alertFactory: AlertFactory) {
        self.alertFactory = alertFactory
    }
    
    // MARK: - Public methods
    
    func perform(userInfo: [NSObject : AnyObject]?, isForeground: Bool) -> Bool {
        if let userInfo = userInfo {
            if let message = userInfo[keyDulfyMessage] as? String {
                if let urlString = userInfo[keyDulfyUrl] as? String {
                    if let url = NSURL(string: urlString) {
                        self.perform(message, url: url, isForeground: isForeground)
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: - Private methods
    
    private func perform(message: String, url: NSURL, isForeground: Bool) {
        let payload = [
            "index": 1,
            "url": url
        ]
        
        if isForeground {
            // If in foreground ask the user if he wants to navigate
            let alert = self.alertFactory.createAlert(UIViewController(), title: "Dulfy", message: message, buttons:
                (style: .Cancel, title: "Hide", handler: {}),
                (style: .Default, title: "View", handler: {
                    NSNotificationCenter.defaultCenter().postNotificationName(SwitchToTabNotification, object: self, userInfo: payload)
                })
            )
            NSNotificationCenter.defaultCenter().postNotificationName(ShowAlertNotification, object: self, userInfo: ["alert": alert])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(SwitchToTabNotification, object: self, userInfo: payload)
        }
    }
    
}
