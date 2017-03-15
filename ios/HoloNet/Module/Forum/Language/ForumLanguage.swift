//
//  ForumLanguage.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

enum ForumLanguage: String, CustomStringConvertible {
    case english = "en"
    case french = "fr"
    case german = "de"
    
    var description: String {
        switch self {
        case .english: return "English"
        case .french: return "French"
        case .german: return "German"
        }
    }
    
    var next: String {
        switch self {
        case .english: return "Next"
        case .french: return "Suivante"
        case .german: return "Nächste"
        }
    }
}
