//
//  AppActionParser.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

struct AppActionParser {
    private let userInfo: [AnyHashable: Any]
    
    init(userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
    }
    
    var alert: String? {
        guard let aps = self.userInfo[Constants.AppActions.UserInfo.aps] as? [AnyHashable: Any],
            let alert = aps[Constants.AppActions.UserInfo.alert] as? String
            else { return nil }
        
        return alert
    }
    
    var type: String? {
        return self.userInfo[Constants.AppActions.UserInfo.type] as? String
    }
    
    var url: URL? {
        guard let urlString = self.userInfo[Constants.AppActions.UserInfo.url] as? String else { return nil }
        return URL(string: urlString)
    }
}
