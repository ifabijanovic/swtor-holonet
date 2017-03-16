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
        case .english: return NSLocalizedString("forum_language_english_name", comment: "")
        case .french: return NSLocalizedString("forum_language_french_name", comment: "")
        case .german: return NSLocalizedString("forum_language_german_name", comment: "")
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
