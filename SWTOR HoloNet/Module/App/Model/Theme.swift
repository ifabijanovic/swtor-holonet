//
//  Theme.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

enum ThemeType: String, CustomStringConvertible {
    case dark = "DarkTheme"
    case light = "LightTheme"
    
    var description: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}

enum TextSize: CGFloat, CustomStringConvertible {
    case small = 14.0
    case medium = 16.0
    case large = 18.0
    
    var description: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
}

class Theme: NSObject {
    fileprivate let bundle: Bundle
    
    fileprivate(set) var type: ThemeType
    
    fileprivate(set) var navBackground: UIColor!
    fileprivate(set) var navText: UIColor!
    fileprivate(set) var contentBackground: UIColor!
    fileprivate(set) var contentHighlightBackground: UIColor!
    fileprivate(set) var contentTitle: UIColor!
    fileprivate(set) var contentText: UIColor!
    fileprivate(set) var contentHighlightText: UIColor!
    
    fileprivate(set) var headerHeight: CGFloat!
    fileprivate(set) var headerText: UIColor!
    fileprivate(set) var headerBackground: UIColor!
    
    fileprivate(set) var instructionsIcon: UIColor!
    fileprivate(set) var instructionsIconBackground: UIColor!
    fileprivate(set) var instructionsFrame: UIColor!
    
    fileprivate(set) var activityIndicatorStyle: UIActivityIndicatorViewStyle!
    fileprivate(set) var scrollViewIndicatorStyle: UIScrollViewIndicatorStyle!
    fileprivate(set) var statusBarStyle: UIStatusBarStyle!
    
    convenience override init() {
        self.init(bundle: Bundle.main)
    }
    
    init(bundle: Bundle) {
        self.bundle = bundle
        
        // Load the theme type from user settings
        let userDefaults = UserDefaults.standard
        if let savedThemeType = userDefaults.string(forKey: Keys.themeType) {
            self.type = ThemeType(rawValue: savedThemeType) ?? .dark
        } else {
            self.type = .dark
        }
        super.init()
        self.changeTheme(type: self.type)
    }
}

extension Theme {
    var textSize: TextSize {
        get {
            let userDefaults = UserDefaults.standard
            let savedValue = userDefaults.float(forKey: Keys.textSize)
            
            if savedValue > 0 {
                if let value = TextSize(rawValue: CGFloat(savedValue)) {
                    return value
                }
            } else {
                userDefaults.set(Float(TextSize.small.rawValue), forKey: Keys.textSize)
                userDefaults.synchronize()
            }
            
            return .small
        }
        set(newSize) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(Float(newSize.rawValue), forKey: Keys.textSize)
            userDefaults.synchronize()
        }
    }
    
    func changeTheme(type: ThemeType) {
        let url = self.bundle.url(forResource: type.rawValue, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [AnyHashable: Any]
        
        // Load theme data
        self.navBackground = self.color(forKey: Keys.navBackground, data: plist)
        self.navText = self.color(forKey: Keys.navText, data: plist)
        self.contentBackground = self.color(forKey: Keys.contentBackground, data: plist)
        self.contentHighlightBackground = self.color(forKey: Keys.contentHighlightBackground, data: plist)
        self.contentTitle = self.color(forKey: Keys.contentTitle, data: plist)
        self.contentText = self.color(forKey: Keys.contentText, data: plist)
        self.contentHighlightText = self.color(forKey: Keys.contentHighlightText, data: plist)
        
        self.headerHeight = CGFloat(self.number(forKey: Keys.headerHeight, data: plist).floatValue)
        self.headerText = self.color(forKey: Keys.headerText, data: plist)
        self.headerBackground = self.color(forKey: Keys.headerBackground, data: plist)
        
        self.instructionsIcon = self.color(forKey: Keys.instructionsIcon, data: plist)
        self.instructionsIconBackground = self.color(forKey: Keys.instructionsIconBackground, data: plist)
        self.instructionsFrame = self.color(forKey: Keys.instructionsFrame, data: plist)
        
        self.activityIndicatorStyle = UIActivityIndicatorViewStyle(rawValue: self.number(forKey: Keys.activityIndicatorStyle, data: plist).intValue)!
        self.scrollViewIndicatorStyle = UIScrollViewIndicatorStyle(rawValue: self.number(forKey: Keys.scrollViewIndicatorStyle, data: plist).intValue)!
        self.statusBarStyle = UIStatusBarStyle(rawValue: self.number(forKey: Keys.statusBarStyle, data: plist).intValue)!
        
        // Apply the new theme
        self.apply()
        
        // Save the new theme type into user settings
        self.type = type
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(type.rawValue, forKey: Keys.themeType)
        userDefaults.synchronize()
    }
    
    func apply(navigationBar: UINavigationBar, animate: Bool) {
        if !animate {
            navigationBar.barTintColor = nil
            navigationBar.tintColor = nil
        }
        
        navigationBar.barTintColor = self.navBackground
        navigationBar.tintColor = self.navText
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: self.navText]
    }
    
    func apply(tabBar: UITabBar, animate: Bool) {
        if !animate {
            tabBar.barTintColor = nil
            tabBar.tintColor = nil
        }
        
        tabBar.barTintColor = self.navBackground
        tabBar.tintColor = self.navText
    }
    
    func apply(toolbar: UIToolbar, animate: Bool) {
        if !animate {
            toolbar.barTintColor = nil
            toolbar.tintColor = nil
        }
        
        toolbar.barTintColor = self.navBackground
        toolbar.tintColor = self.navText
    }
    
    func fireThemeChanged() {
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.themeChanged), object: self, userInfo: [Constants.Notifications.UserInfo.theme: self])
    }
}

extension Theme {
    fileprivate func color(forKey key: String, data: [AnyHashable: Any]) -> UIColor {
        guard let string = data[key] as? String,
            let color = UIColor(string: string)
        else {
            assert(false, "color(forKey:data:) failed")
            return .white
        }
        return color
    }
    
    fileprivate func number(forKey key: String, data: [AnyHashable: Any]) -> NSNumber {
        guard let value = data[key] as? NSNumber
        else {
            assert(false, "number(forKey:data:) failed")
            return NSNumber(value: 0)
        }
        return value
    }
    
    fileprivate func apply() {
        UINavigationBar.appearance().barTintColor = self.navBackground
        UINavigationBar.appearance().tintColor = self.navText
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: self.navText]
        
        UITabBar.appearance().barTintColor = self.navBackground
        UITabBar.appearance().tintColor = self.navText
        
        UIToolbar.appearance().barTintColor = self.navBackground
        UIToolbar.appearance().tintColor = self.navText
    }
}

fileprivate struct Keys {
    static let themeType = "themeType"
    static let textSize = "textSize"
    
    static let navBackground = "navBackground"
    static let navText = "navText"
    static let contentBackground = "contentBackground"
    static let contentHighlightBackground = "contentHighlightBackground"
    static let contentTitle = "contentTitle"
    static let contentText = "contentText"
    static let contentHighlightText = "contentHighlightText"
    static let headerHeight = "headerHeight"
    static let headerText = "headerText"
    static let headerBackground = "headerBackground"
    static let instructionsIcon = "instructionsIcon"
    static let instructionsIconBackground = "instructionsIconBackground"
    static let instructionsFrame = "instructionsFrame"
    static let activityIndicatorStyle = "activityIndicatorStyle"
    static let scrollViewIndicatorStyle = "scrollViewIndicatorStyle"
    static let statusBarStyle = "statusBarStyle"
}
