//
//  AppAction.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 12/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

enum AppAction {
    case dulfy(message: String, url: URL, applicationState: UIApplicationState)
    case setUrl(url: URL)
    case switchTab(index: Int)
    
    init?(applicationState: UIApplicationState, userInfo: [AnyHashable : Any]) {
        let parser = AppActionParser(userInfo: userInfo)
        
        guard let type = parser.type else { return nil }
        switch type {
        case Constants.AppActions.dulfy:
            guard let message = parser.alert, let url = parser.url else { return nil }
            self = .dulfy(message: message, url: url, applicationState: applicationState)
        default:
            return nil
        }
    }
}
