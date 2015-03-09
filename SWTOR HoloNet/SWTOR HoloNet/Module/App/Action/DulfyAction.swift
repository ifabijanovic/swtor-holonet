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
            if let urlString = userInfo[keyDulfyUrl] as? String {
                if let url = NSURL(string: urlString) {
                    self.perform(url, isForeground: isForeground)
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - Private methods
    
    private func perform(url: NSURL, isForeground: Bool) {
        let payload = [
            "index": 1,
            "url": url
        ]
        if isForeground {
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(SwitchToTabNotification, object: self, userInfo: payload)
    }
    
}
