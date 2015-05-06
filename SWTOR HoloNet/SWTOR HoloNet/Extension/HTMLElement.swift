//
//  HTMLElement.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 05/05/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

extension HTMLElement {
    
    func hasAttribute(name: String) -> Bool {
        return self.attributes[name] != nil
    }
    
    func hasAttribute(name: String, ofValue value: String) -> Bool {
        if let attributeValue = self.attributes[name] as? String {
            return attributeValue == value
        }
        return false
    }
    
    func hasAttribute(name: String, containingValue value: String) -> Bool {
        if let attributeValue = self.attributes[name] as? String {
            return attributeValue.rangeOfString(value, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil
        }
        return false
    }
    
}
