//
//  ForumLanguage.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

enum ForumLanguage: String {
    case english = "en"
    case french = "fr"
    case german = "de"
    
    var next: String {
        switch self {
        case .english: return "Next"
        case .french: return "Suivante"
        case .german: return "Nächste"
        }
    }
}
