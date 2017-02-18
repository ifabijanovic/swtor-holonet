//
//  DulfyAction.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 09/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

let keyDulfyUrl = "url"

class DulfyAction: Action {
    fileprivate let alertFactory: UIAlertFactory
    
    var type: String { return ActionTypeDulfy }
    
    init(alertFactory: UIAlertFactory) {
        self.alertFactory = alertFactory
    }
}

extension DulfyAction {
    func perform(userInfo: [AnyHashable : Any]?, isForeground: Bool) -> Bool {
        if let userInfo = userInfo {
            let parser = ActionParser(userInfo: userInfo)
            if let message = parser.getAlert() {
                if let urlString = parser.getString(key: keyDulfyUrl) {
                    if let url = NSURL(string: urlString) {
                        self.perform(message: message, url: url, isForeground: isForeground)
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    private func perform(message: String, url: NSURL, isForeground: Bool) {
        let payload: [AnyHashable: Any] = [
            Constants.Notifications.UserInfo.index: 1,
            Constants.Notifications.UserInfo.url: url
        ]
        
        if isForeground {
            // If in foreground ask the user if he wants to navigate
            let alertController = self.alertFactory.alert(title: "Dulfy", message: message, actions: [
                (title: "Hide", style: .cancel, handler: nil),
                (title: "View", style: .default, handler: { _ in
                    NotificationCenter.default.post(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
                })
            ])
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notifications.showAlert), object: self, userInfo: [Constants.Notifications.UserInfo.alert: alertController])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        }
    }
}
