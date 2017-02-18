//
//  ForumRepositoryBase.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Alamofire

enum ForumError: Error {
    case noResponse
}

class ForumRepositoryBase {
   
    // MARK: - Properties
    
    internal let settings: Settings
    internal let parser: ForumParser
    
    internal let manager: Alamofire.SessionManager
    
    // MARK: - Init
    
    convenience init(settings: Settings) {
        self.init(settings: settings, parser: ForumParser())
    }
    
    init(settings: Settings, parser: ForumParser) {
        self.settings = settings
        self.parser = parser
        
        self.manager = Alamofire.SessionManager.default
    }
    
    // MARK: - Public methods
    
    func cancelAllOperations() {
        
    }
    
    // MARK: - Internal methods
    
    internal func isMaintenanceResponse(_ html: String) -> Bool {
        let document = HTMLDocument(string: html)
        let errorNodes = document!.nodes(matchingSelector: "#mainContent > #errorPage #errorBody p") as! Array<HTMLElement>
        
        if !errorNodes.isEmpty {
            let englishNode = errorNodes.first!
            return englishNode.textContent.range(of: "scheduled maintenance") != nil
        }
        
        return false
    }
    
}
