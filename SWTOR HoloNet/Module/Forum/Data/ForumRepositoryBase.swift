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
    let settings: Settings
    let parser: ForumParser
    
    let manager: Alamofire.SessionManager
    
    init(settings: Settings, parser: ForumParser) {
        self.settings = settings
        self.parser = parser
        
        self.manager = Alamofire.SessionManager.default
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
