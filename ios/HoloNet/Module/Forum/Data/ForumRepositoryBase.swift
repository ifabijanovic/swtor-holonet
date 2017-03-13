//
//  ForumRepositoryBase.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Alamofire
import HTMLReader

enum ForumError: Error {
    case maintenance
}

class ForumRepositoryBase {
    let parser: ForumParser
    let settings: Settings
    
    let manager: Alamofire.SessionManager
    
    init(parser: ForumParser, settings: Settings) {
        self.parser = parser
        self.settings = settings
        
        self.manager = Alamofire.SessionManager.default
    }
    
    func localizedSettings(language: ForumLanguage) -> LocalizedSettings {
        let localizedSettings = self.settings.localized[language.rawValue]
        assert(localizedSettings != nil)
        return localizedSettings!
    }
}

extension ForumRepositoryBase {
    func isMaintenanceResponse(_ html: String) -> Bool {
        let document = HTMLDocument(string: html)
        let errorNodes = document.nodes(matchingSelector: "#mainContent > #errorPage #errorBody p")
        
        if let englishNode = errorNodes.first {
            return englishNode.textContent.range(of: "scheduled maintenance") != nil
        }
        
        return false
    }
}
