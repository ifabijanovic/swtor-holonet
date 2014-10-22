//
//  Settings.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class Settings {
    
    // MARK: - Properties
    
    let forumDisplayUrl: String
    let threadDisplayUrl: String
    let categoryQueryParam: String
    let threadQueryParam: String
    let pageQueryParam: String
    
    // MARK: - Init
    
    init() {
        let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!
        let settings = NSDictionary(contentsOfFile: path)
        
        self.forumDisplayUrl = settings?.objectForKey("Forum Display URL") as? String ?? ""
        self.threadDisplayUrl = settings?.objectForKey("Thread Display URL") as? String ?? ""
        self.categoryQueryParam = settings?.objectForKey("Category Query Param") as? String ?? ""
        self.threadQueryParam = settings?.objectForKey("Thread Param Name") as? String ?? ""
        self.pageQueryParam = settings?.objectForKey("Paging Query Param") as? String ?? ""
    }
    
}
