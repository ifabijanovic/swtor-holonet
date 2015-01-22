//
//  NSURLComponents.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension NSURLComponents {
    
    func queryValueForName(name: String) -> String? {
        if objc_getClass("NSURLQueryItem") != nil {
            if let items = self.queryItems as? Array<NSURLQueryItem> {
                for item in items {
                    if item.name == name {
                        return item.value
                    }
                }
            }
        } else {
            if let query = self.query {
                for param in query.componentsSeparatedByString("&") {
                    let components = param.componentsSeparatedByString("=")
                    if components.count < 2 { continue }
                    if components[0] == name {
                        return components[1]
                    }
                }
            }
        }
        return nil
    }
    
}
