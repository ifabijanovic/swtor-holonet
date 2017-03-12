//
//  Constants.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let wideScreenThreshold: CGFloat = 640.0
    
    struct AppActions {
        static let dulfy = "dulfy"
        
        struct UserInfo {
            static let aps = "aps"
            static let alert = "alert"
            static let type = "type"
            static let url = "url"
        }
    }
    
    struct Analytics {
        struct Event {
            static let dulfy = "dulfy"
            static let forum = "forum"
            static let settings = "settings"
            static let tab = "tab"
        }
        
        struct Property {
            static let type = "type"
            static let page = "page"
        }
    }
    
    struct Animation {
        static let defaultDuration = 0.3
    }
    
    struct Images {
        struct Icons {
            static let back = "Back"
            static let forward = "Forward"
            static let home = "Home"
            static let reload = "Reload"
            static let safari = "Safari"
            static let stop = "Stop"
        }
        
        struct Placeholders {
            static let avatar = "Avatar"
            static let categoryIcon = "CategoryIcon"
            static let devTrackerIcon = "DevTrackerIcon"
            static let stickyIcon = "StickyIcon"
        }
        
        struct Tabs {
            static let dulfy = "Dulfy"
            static let forum = "Forum"
            static let settings = "Settings"
        }
    }
    
    struct Notifications {
        static let switchToTab = "SwitchToTabNotification"
        
        struct UserInfo {
            static let index = "index"
            static let url = "url"
        }
    }
    
    struct Push {
        struct UserDefaults {
            static let didCancelPushAccess = "pushDidCancelPushAccess"
            static let didApprovePushAccess = "pushDidApprovePushAccess"
            static let lastPushAccessRequestTimestamp = "pushLastPushAccessRequestTimestamp"
        }
        
        struct UI {
            static let requestAccessTitle = "Notifications"
            static let requestAccessMessage = "Hey, would you like to receive notifications from HoloNet and Dulfy?"
        }
        
        static let accessRequestRetryInterval: TimeInterval = 5*24*60*60 // 5 days
    }
}
