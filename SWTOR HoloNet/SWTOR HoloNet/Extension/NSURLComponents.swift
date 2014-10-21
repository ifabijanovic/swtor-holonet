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
        if let items = self.queryItems as? Array<NSURLQueryItem> {
            for item in items {
                if item.name == name {
                    return item.value
                }
            }
        }
        return nil
    }
    
}
