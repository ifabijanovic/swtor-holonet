//
//  UIColorEx.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func fromString(value: String) -> UIColor? {
        let components = value.componentsSeparatedByString(",")
        if components.count < 4 {
            return nil
        }
        
        let red = (components[0].toFloat() ?? 0.0) / 255.0
        let green = (components[1].toFloat() ?? 0.0) / 255.0
        let blue = (components[2].toFloat() ?? 0.0) / 255.0
        let alpha = components[3].toFloat() ?? 1.0
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
}
