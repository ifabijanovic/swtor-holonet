//
//  ThemeEnums.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

enum ThemeType: String, CustomStringConvertible {
    case dark = "DarkTheme"
    case light = "LightTheme"
    
    var description: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}

enum TextSize: CGFloat, CustomStringConvertible {
    case small = 14.0
    case medium = 16.0
    case large = 18.0
    
    var description: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
}
