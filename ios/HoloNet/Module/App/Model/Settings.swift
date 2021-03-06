//
//  Settings.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

struct Settings {
    let appEmail: String
    
    let categoryQueryParam: String
    let threadQueryParam: String
    let postQueryParam: String
    let pageQueryParam: String
    let devTrackerIconUrl: String
    let devAvatarUrl: String
    let stickyIconUrl: String
    let dulfyNetUrl: String
    let requestTimeout: TimeInterval
    let localized: [String: LocalizedSettings]
    
    init(bundle: Bundle) {
        let url = bundle.url(forResource: "Settings", withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [AnyHashable: Any]
        
        self.appEmail = plist[Keys.appEmail] as? String ?? ""
        
        self.categoryQueryParam = plist[Keys.categoryQueryParam] as? String ?? ""
        self.threadQueryParam = plist[Keys.threadQueryParam] as? String ?? ""
        self.postQueryParam = plist[Keys.postQueryParam] as? String ?? ""
        self.pageQueryParam = plist[Keys.pagingQueryParam] as? String ?? ""
        self.devTrackerIconUrl = plist[Keys.devTrackerIconUrl] as? String ?? ""
        self.devAvatarUrl = plist[Keys.devAvatarUrl] as? String ?? ""
        self.stickyIconUrl = plist[Keys.stickyIconUrl] as? String ?? ""
        self.dulfyNetUrl = plist[Keys.dulfyNetUrl] as? String ?? ""
        self.requestTimeout = plist[Keys.requestTimeout] as? TimeInterval ?? 60.0
        
        var localized: [String: LocalizedSettings] = [:]
        (plist[Keys.localized] as? [AnyHashable: Any])?.forEach { (key, value) in
            guard let languageCode = key as? String,
                let item = value as? [AnyHashable: Any]
                else { return }
            localized[languageCode] = LocalizedSettings(plist: item)
        }
        self.localized = localized
    }
}

struct LocalizedSettings {
    let rootCategoryId: Int
    let forumDisplayUrl: String
    let threadDisplayUrl: String
    let devTrackerUrl: String
    let devTrackerId: Int
    
    init(plist: [AnyHashable: Any]) {
        self.rootCategoryId = plist[Keys.rootCategoryId] as? Int ?? 0
        self.forumDisplayUrl = plist[Keys.forumDisplayUrl] as? String ?? ""
        self.threadDisplayUrl = plist[Keys.threadDisplayUrl] as? String ?? ""
        self.devTrackerUrl = plist[Keys.developerTrackerUrl] as? String ?? ""
        self.devTrackerId = plist[Keys.developerTrackerId] as? Int ?? 0
    }
}

fileprivate struct Keys {
    static let appEmail = "App Email"
    static let forumDisplayUrl = "Forum Display URL"
    static let threadDisplayUrl = "Thread Display URL"
    static let developerTrackerUrl = "Developer Tracker URL"
    static let developerTrackerId = "Developer Tracker ID"
    static let categoryQueryParam = "Category Query Param"
    static let threadQueryParam = "Thread Query Param"
    static let postQueryParam = "Post Query Param"
    static let pagingQueryParam = "Paging Query Param"
    static let devTrackerIconUrl = "Dev Tracker Icon URL"
    static let devAvatarUrl = "Dev Avatar URL"
    static let stickyIconUrl = "Sticky Icon URL"
    static let dulfyNetUrl = "Dulfy.net URL"
    static let requestTimeout = "Request Timeout"
    static let localized = "Localized"
    static let rootCategoryId = "Root Category ID"
}
