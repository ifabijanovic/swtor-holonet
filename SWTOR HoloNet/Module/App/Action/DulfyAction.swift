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
    fileprivate let navigator: Navigator
    
    var type: String { return Constants.Actions.dulfy }
    
    init(navigator: Navigator) {
        self.navigator = navigator
    }
}

extension DulfyAction {
    func perform(userInfo: [AnyHashable : Any]?, isForeground: Bool) -> Bool {
        guard let userInfo = userInfo else { return false }
        
        let parser = ActionParser(userInfo: userInfo)
        guard let message = parser.alert,
            let urlString = parser.string(key: Constants.Actions.UserInfo.url),
            let url = URL(string: urlString)
            else { return false }
        
        self.perform(message: message, url: url, isForeground: isForeground)
        return true
    }
    
    private func perform(message: String, url: URL, isForeground: Bool) {
        let payload: [AnyHashable: Any] = [
            Constants.Notifications.UserInfo.index: 1,
            Constants.Notifications.UserInfo.url: url
        ]
        
        if isForeground {
            // If in foreground ask the user if he wants to navigate
            self.navigator.showAlert(title: "Dulfy", message: message, actions: [
                UIAlertAction(title: "Hide", style: .cancel, handler: nil),
                UIAlertAction(title: "View", style: .default, handler: { _ in
                    NotificationCenter.default.post(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
                })
            ])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        }
    }
}
