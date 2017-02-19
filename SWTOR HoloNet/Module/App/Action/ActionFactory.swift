//
//  ActionFactory.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 09/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

class ActionFactory {
    fileprivate let alertFactory: UIAlertFactory
    
    init(alertFactory: UIAlertFactory) {
        self.alertFactory = alertFactory
    }

    func create(type: String) -> Action? {
        switch type {
        case Constants.Actions.dulfy: return DulfyAction(alertFactory: self.alertFactory)
        default: return nil
        }
    }
    
    func create(userInfo: [AnyHashable : Any]) -> Action? {
        if let actionType = userInfo[Constants.Actions.UserInfo.type] as? String {
            return self.create(type: actionType)
        }
        return nil
    }
}
