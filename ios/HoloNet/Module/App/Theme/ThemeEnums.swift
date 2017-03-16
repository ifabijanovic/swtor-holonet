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
        case .dark: return NSLocalizedString("theme_dark_name", comment: "")
        case .light: return NSLocalizedString("theme_light_name", comment: "")
        }
    }
}

enum TextSize: CGFloat, CustomStringConvertible {
    case small = 14.0
    case medium = 16.0
    case large = 18.0
    
    var description: String {
        switch self {
        case .small: return NSLocalizedString("text_size_small_name", comment: "")
        case .medium: return NSLocalizedString("text_size_medium_name", comment: "")
        case .large: return NSLocalizedString("text_size_large_name", comment: "")
        }
    }
}
