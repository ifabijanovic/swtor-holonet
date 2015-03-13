//
//  ActionFactory.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 09/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

let keyActionType = "action"
let ActionTypeDulfy = "dulfy"

class ActionFactory {
    
    // MARK: - Variables
    
    private let alertFactory: AlertFactory
    
    // MARK: - Init
    
    init(alertFactory: AlertFactory) {
        self.alertFactory = alertFactory
    }
    
    // MARK: - Public methods
    
    func create(#type: String) -> Action? {
        switch type {
        case ActionTypeDulfy: return DulfyAction(alertFactory: self.alertFactory)
        default: return nil
        }
    }
    
    func create(#userInfo: [NSObject : AnyObject]) -> Action? {
        if let actionType = userInfo[keyActionType] as? String {
            return self.create(type: actionType)
        }
        return nil
    }

}
