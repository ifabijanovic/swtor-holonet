//
//  Analytics.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation

protocol Analytics {
    func track(event: String)
    func track(event: String, properties: [AnyHashable: Any])
}

struct DefaultAnalytics: Analytics {
    func track(event: String) {
        #if !DEBUG && !TEST
        
        #endif
    }
    
    func track(event: String, properties: [AnyHashable : Any]) {
        #if !DEBUG && !TEST
            
        #endif
    }
}
