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
        self.init(bundle: Bundle.main)
    }
    
    init(bundle: Bundle) {
        let path = bundle.path(forResource: "Parse", ofType: "plist")
        if path == nil {
            print("Parse.plist does not exist. Make a copy of Parse-Template.plist named Parse.plist and fill it with correct vaues")
        }
        let settings = NSDictionary(contentsOfFile: path!)
        
        self.applicationId = settings?.object(forKey: "ApplicationId") as? String ?? ""
        self.clientId = settings?.object(forKey: "ClientId") as? String ?? ""
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
    let requestTimeout: TimeInterval
    
    var forumLanguage: ForumLanguage
    
    let parse: ParseSettings
    
    // MARK: - Init
    
    convenience init() {
        self.init(bundle: Bundle.main)
    }
    
    init(bundle: Bundle) {
        let path = bundle.path(forResource: "Settings", ofType: "plist")!
        let settings = NSDictionary(contentsOfFile: path)
        
        self.appEmail = settings?.object(forKey: "App Email") as? String ?? ""
        
        self.forumDisplayUrl = settings?.object(forKey: "Forum Display URL") as? String ?? ""
        self.threadDisplayUrl = settings?.object(forKey: "Thread Display URL") as? String ?? ""
        self.devTrackerUrl = settings?.object(forKey: "Developer Tracker URL") as? String ?? ""
        self.devTrackerId = settings?.object(forKey: "Developer Tracker ID") as? Int ?? 0
        self.categoryQueryParam = settings?.object(forKey: "Category Query Param") as? String ?? ""
        self.threadQueryParam = settings?.object(forKey: "Thread Query Param") as? String ?? ""
        self.postQueryParam = settings?.object(forKey: "Post Query Param") as? String ?? ""
        self.pageQueryParam = settings?.object(forKey: "Paging Query Param") as? String ?? ""
        self.devTrackerIconUrl = settings?.object(forKey: "Dev Tracker Icon URL") as? String ?? ""
        self.devAvatarUrl = settings?.object(forKey: "Dev Avatar URL") as? String ?? ""
        self.stickyIconUrl = settings?.object(forKey: "Sticky Icon URL") as? String ?? ""
        self.dulfyNetUrl = settings?.object(forKey: "Dulfy.net URL") as? String ?? ""
        self.requestTimeout = settings?.object(forKey: "Request Timeout") as? TimeInterval ?? 60.0
        
        self.forumLanguage = ForumLanguage.English
        
        self.parse = ParseSettings(bundle: bundle)
    }
    
}
