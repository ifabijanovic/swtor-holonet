//
//  NSURLComponents.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension URLComponents {
    
    func queryValueForName(_ name: String) -> String? {
        if objc_getClass("URLQueryItem") != nil {
            if let items = self.queryItems {
                for item in items {
                    if item.name == name {
                        return item.value
                    }
                }
            }
        } else {
            if let query = self.query {
                for param in query.components(separatedBy: "&") {
                    let components = param.components(separatedBy: "=")
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
