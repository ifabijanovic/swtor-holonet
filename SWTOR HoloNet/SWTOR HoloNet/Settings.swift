//
//  Settings.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ParseSettings {
    
    // MARK: - Properties
    
    let applicationId: String
    let clientId: String
    
    // MARK: - Init
    
    convenience init() {
        self.init(bundle: NSBundle.mainBundle())
    }
    
    init(bundle: NSBundle) {
        let path = bundle.pathForResource("Parse", ofType: "plist")
        if path == nil {
            println("Parse.plist does not exist. Make a copy of Parse-Template.plist named Parse.plist and fill it with correct vaues")
        }
        let settings = NSDictionary(contentsOfFile: path!)
        
        self.applicationId = settings?.objectForKey("ApplicationId") as? String ?? ""
        self.clientId = settings?.objectForKey("ClientId") as? String ?? ""
    }
    
}

class Settings {
    
    // MARK: - Properties
    
    let appEmail: String
    
    let forumDisplayUrl: String
    let threadDisplayUrl: String
    let devTrackerUrl: String
    let devTrackerId: Int
    let categoryQueryParam: String
    let threadQueryParam: String
    let postQueryParam: String
    let pageQueryParam: String
    let devTrackerIconUrl: String
    let devAvatarUrl: String
    let stickyIconUrl: String
    let dulfyNetUrl: String
    let requestTimeout: NSTimeInterval
    
    var forumLanguage: ForumLanguage
    
    let parse: ParseSettings
    
    // MARK: - Init
    
    convenience init() {
        self.init(bundle: NSBundle.mainBundle())
    }
    
    init(bundle: NSBundle) {
        let path = bundle.pathForResource("Settings", ofType: "plist")!
        let settings = NSDictionary(contentsOfFile: path)
        
        self.appEmail = settings?.objectForKey("App Email") as? String ?? ""
        
        self.forumDisplayUrl = settings?.objectForKey("Forum Display URL") as? String ?? ""
        self.threadDisplayUrl = settings?.objectForKey("Thread Display URL") as? String ?? ""
        self.devTrackerUrl = settings?.objectForKey("Developer Tracker URL") as? String ?? ""
        self.devTrackerId = settings?.objectForKey("Developer Tracker ID") as? Int ?? 0
        self.categoryQueryParam = settings?.objectForKey("Category Query Param") as? String ?? ""
        self.threadQueryParam = settings?.objectForKey("Thread Query Param") as? String ?? ""
        self.postQueryParam = settings?.objectForKey("Post Query Param") as? String ?? ""
        self.pageQueryParam = settings?.objectForKey("Paging Query Param") as? String ?? ""
        self.devTrackerIconUrl = settings?.objectForKey("Dev Tracker Icon URL") as? String ?? ""
        self.devAvatarUrl = settings?.objectForKey("Dev Avatar URL") as? String ?? ""
        self.stickyIconUrl = settings?.objectForKey("Sticky Icon URL") as? String ?? ""
        self.dulfyNetUrl = settings?.objectForKey("Dulfy.net URL") as? String ?? ""
        self.requestTimeout = settings?.objectForKey("Request Timeout") as? NSTimeInterval ?? 60.0
        
        self.forumLanguage = ForumLanguage.English
        
        self.parse = ParseSettings(bundle: bundle)
    }
    
}
