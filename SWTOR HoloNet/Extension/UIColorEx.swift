//
//  UIColorEx.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func fromString(_ value: String) -> UIColor? {
        let components = value.components(separatedBy: ",")
        if components.count < 4 {
            return nil
        }
        
        let red = (Float(components[0]) ?? 0.0) / 255.0
        let green = (Float(components[1]) ?? 0.0) / 255.0
        let blue = (Float(components[2]) ?? 0.0) / 255.0
        let alpha = Float(components[3]) ?? 1.0
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
}
