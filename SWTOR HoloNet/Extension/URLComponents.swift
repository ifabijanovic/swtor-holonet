//
//  URLComponents.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension URLComponents {
    func queryValue(name: String) -> String? {
        if let items = self.queryItems {
            for item in items {
                if item.name == name {
                    return item.value
                }
            }
        }
        return nil
    }
}
