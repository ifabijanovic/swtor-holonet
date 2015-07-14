//
//  ForumRepositoryBase.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumRepositoryBase {
   
    // MARK: - Properties
    
    internal let settings: Settings
    internal let parser: ForumParser
    
    internal let manager: AFHTTPRequestOperationManager
    
    // MARK: - Init
    
    convenience init(settings: Settings) {
        self.init(settings: settings, parser: ForumParser())
    }
    
    init(settings: Settings, parser: ForumParser) {
        self.settings = settings
        self.parser = parser
        
        self.manager = AFHTTPRequestOperationManager()
        self.manager.requestSerializer.timeoutInterval = settings.requestTimeout
        self.manager.responseSerializer = AFHTTPResponseSerializer()
    }
    
    // MARK: - Public methods
    
    func cancelAllOperations() {
        self.manager.operationQueue.cancelAllOperations()
    }
    
}
