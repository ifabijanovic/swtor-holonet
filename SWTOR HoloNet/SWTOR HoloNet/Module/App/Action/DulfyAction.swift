//
//  DulfyAction.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 09/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

let keyDulfyUrl = "url"

class DulfyAction: Action {
    
    // MARK: - Constants
    
    private let alertFactory: AlertFactory
    
    // MARK: - Properties
    
    var type: String {
        get {
            return ActionTypeDulfy
        }
    }
    
    // MARK: - Init
    
    init(alertFactory: AlertFactory) {
        self.alertFactory = alertFactory
    }
    
    // MARK: - Public methods
    
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
    
    // MARK: - Private methods
    
    private func perform(message: String, url: NSURL, isForeground: Bool) {
        let payload: [AnyHashable: Any] = [
            "index": 1,
            "url": url
        ]
        
        if isForeground {
            // If in foreground ask the user if he wants to navigate
            let alert = self.alertFactory.createAlert(presenter: UIViewController(), title: "Dulfy", message: message, buttons:
                (style: .cancel, title: "Hide", handler: {}),
                (style: .default, title: "View", handler: {
                    NotificationCenter.default.post(name: NSNotification.Name(SwitchToTabNotification), object: self, userInfo: payload)
                })
            )
            NotificationCenter.default.post(name: NSNotification.Name(ShowAlertNotification), object: self, userInfo: ["alert": alert])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(SwitchToTabNotification), object: self, userInfo: payload)
        }
    }
    
}
