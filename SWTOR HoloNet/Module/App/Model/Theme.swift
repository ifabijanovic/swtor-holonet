//
//  Theme.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

enum ThemeType: String {
    case Dark = "DarkTheme"
    case Light = "LightTheme"
    
    func toString() -> String {
        switch self {
        case .Dark: return "Dark"
        case .Light: return "Light"
        }
    }
}

enum TextSize: CGFloat {
    case Small = 14.0
    case Medium = 16.0
    case Large = 18.0
    
    func toString() -> String {
        switch self {
        case .Small: return "Small"
        case .Medium: return "Medium"
        case .Large: return "Large"
        }
    }
}

class Theme: NSObject {
    
    // MARK: - Constants
    
    private let keyThemeType = "themeType"
    private let keyTextSize = "textSize"
    
    // MARK: - Properties
    
    private let bundle: Bundle
    
    private(set) var type: ThemeType
    
    private(set) var navBackground: UIColor!
    private(set) var navText: UIColor!
    private(set) var contentBackground: UIColor!
    private(set) var contentHighlightBackground: UIColor!
    private(set) var contentTitle: UIColor!
    private(set) var contentText: UIColor!
    private(set) var contentHighlightText: UIColor!
    
    private(set) var headerHeight: CGFloat!
    private(set) var headerText: UIColor!
    private(set) var headerBackground: UIColor!
    
    private(set) var instructionsIcon: UIColor!
    private(set) var instructionsIconBackground: UIColor!
    private(set) var instructionsFrame: UIColor!
    
    private(set) var activityIndicatorStyle: UIActivityIndicatorViewStyle!
    private(set) var scrollViewIndicatorStyle: UIScrollViewIndicatorStyle!
    private(set) var statusBarStyle: UIStatusBarStyle!
    
    var textSize: TextSize {
        get {
            let userDefaults = UserDefaults.standard
            let savedValue = userDefaults.float(forKey: keyTextSize)
            
            if savedValue > 0 {
                if let value = TextSize(rawValue: CGFloat(savedValue)) {
                    return value
                }
            } else {
                userDefaults.set(Float(TextSize.Small.rawValue), forKey: keyTextSize)
                userDefaults.synchronize()
            }
            
            return .Small
        }
        set(newSize) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(Float(newSize.rawValue), forKey: keyTextSize)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Init
    
    convenience override init() {
        self.init(bundle: Bundle.main)
    }
    
    init(bundle: Bundle) {
        self.bundle = bundle
        
        // Load the theme type from user settings
        let userDefaults = UserDefaults.standard
        if let savedThemeType = userDefaults.string(forKey: keyThemeType) {
            self.type = ThemeType(rawValue: savedThemeType)!
        } else {
            self.type = .Dark
        }
        super.init()
        self.changeTheme(type: self.type)
    }
    
    // MARK: - Public methods
    
    func changeTheme(type: ThemeType) {
        let path = self.bundle.path(forResource: type.rawValue, ofType: "plist")
        let data = NSDictionary(contentsOfFile: path!)!
        
        // Load theme data
        self.navBackground = self.colorForKey("navBackground", data: data)
        self.navText = self.colorForKey("navText", data: data)
        self.contentBackground = self.colorForKey("contentBackground", data: data)
        self.contentHighlightBackground = self.colorForKey("contentHighlightBackground", data: data)
        self.contentTitle = self.colorForKey("contentTitle", data: data)
        self.contentText = self.colorForKey("contentText", data: data)
        self.contentHighlightText = self.colorForKey("contentHighlightText", data: data)
        
        self.headerHeight = CGFloat(self.numberForKey("headerHeight", data: data).floatValue)
        self.headerText = self.colorForKey("headerText", data: data)
        self.headerBackground = self.colorForKey("headerBackground", data: data)
        
        self.instructionsIcon = self.colorForKey("instructionsIcon", data: data)
        self.instructionsIconBackground = self.colorForKey("instructionsIconBackground", data: data)
        self.instructionsFrame = self.colorForKey("instructionsFrame", data: data)
        
        self.activityIndicatorStyle = UIActivityIndicatorViewStyle(rawValue: self.numberForKey("activityIndicatorStyle", data: data).intValue)!
        self.scrollViewIndicatorStyle = UIScrollViewIndicatorStyle(rawValue: self.numberForKey("scrollViewIndicatorStyle", data: data).intValue)!
        self.statusBarStyle = UIStatusBarStyle(rawValue: self.numberForKey("statusBarStyle", data: data).intValue)!
        
        // Apply the new theme
        self.apply()
        
        // Save the new theme type into user settings
        self.type = type
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(type.rawValue, forKey: keyThemeType)
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
        NotificationCenter.default.post(name: Notification.Name(ThemeChangedNotification), object: self, userInfo: ["theme": self])
    }
    
    // MARK: - Private methods
    
    private func colorForKey(_ key: String, data: NSDictionary) -> UIColor {
        return UIColor.fromString(data.value(forKey: key) as! String)!
    }
    
    private func numberForKey(_ key: String, data: NSDictionary) -> NSNumber {
        return data.value(forKey: key) as! NSNumber
    }
    
    private func apply() {
        UIApplication.shared.setStatusBarStyle(self.statusBarStyle, animated: false)
        
        UINavigationBar.appearance().barTintColor = self.navBackground
        UINavigationBar.appearance().tintColor = self.navText
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: self.navText]
        
        UITabBar.appearance().barTintColor = self.navBackground
        UITabBar.appearance().tintColor = self.navText
        
        UIToolbar.appearance().barTintColor = self.navBackground
        UIToolbar.appearance().tintColor = self.navText
    }
}
