//
//  ActionParser.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

struct ActionParser {
    fileprivate let userInfo: [AnyHashable: Any]
    
    init(userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
    }

    var alert: String? {
        guard let aps = self.userInfo[Constants.Actions.UserInfo.aps] as? [AnyHashable: Any],
            let alert = aps[Constants.Actions.UserInfo.alert] as? String
            else { return nil }
        
        return alert
    }
    
    func string(key: String) -> String? {
        return self.userInfo[key] as? String
    }
}
