//
//  ActionFactory.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 09/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation
import Cleanse

class ActionFactory {
    fileprivate let navigator: Navigator
    
    init(navigator: Navigator) {
        self.navigator = navigator
    }

    func create(type: String) -> Action? {
        switch type {
        case Constants.Actions.dulfy: return DulfyAction(navigator: self.navigator)
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

extension ActionFactory {
    struct Module: Cleanse.Module {
        static func configure<B: Binder>(binder: B) {
            binder
                .bind(ActionFactory.self)
                .asSingleton()
                .to(factory: ActionFactory.init)
        }
    }
}
