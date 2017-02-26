//
//  Theme.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

class Theme: NSObject {
    let type: ThemeType
    let textSize: TextSize
    
    let navBackground: UIColor
    let navText: UIColor
    let contentBackground: UIColor
    let contentHighlightBackground: UIColor
    let contentTitle: UIColor
    let contentText: UIColor
    let contentHighlightText: UIColor
    
    let headerHeight: CGFloat
    let headerText: UIColor
    let headerBackground: UIColor
    
    let instructionsIcon: UIColor
    let instructionsIconBackground: UIColor
    let instructionsFrame: UIColor
    
    let activityIndicatorStyle: UIActivityIndicatorViewStyle
    let scrollViewIndicatorStyle: UIScrollViewIndicatorStyle
    let statusBarStyle: UIStatusBarStyle
    
    // Temporary before refactoring
    convenience init(bundle: Bundle) {
        var type: ThemeType = .dark
        if let value = UserDefaults.standard.string(forKey: "themeType") {
            type = ThemeType(rawValue: value) ?? .dark
        }
        let textSize = TextSize(rawValue: CGFloat(UserDefaults.standard.float(forKey: "textSize"))) ?? .small
        self.init(type: type, textSize: textSize, bundle: bundle)
    }
    
    init(type: ThemeType, textSize: TextSize, bundle: Bundle) {
        let url = bundle.url(forResource: type.rawValue, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [AnyHashable: Any]
        
        self.type = type
        self.textSize = textSize
        
        // Load theme data
        self.navBackground = color(forKey: Keys.navBackground, data: plist)
        self.navText = color(forKey: Keys.navText, data: plist)
        self.contentBackground = color(forKey: Keys.contentBackground, data: plist)
        self.contentHighlightBackground = color(forKey: Keys.contentHighlightBackground, data: plist)
        self.contentTitle = color(forKey: Keys.contentTitle, data: plist)
        self.contentText = color(forKey: Keys.contentText, data: plist)
        self.contentHighlightText = color(forKey: Keys.contentHighlightText, data: plist)
        
        self.headerHeight = CGFloat(number(forKey: Keys.headerHeight, data: plist).floatValue)
        self.headerText = color(forKey: Keys.headerText, data: plist)
        self.headerBackground = color(forKey: Keys.headerBackground, data: plist)
        
        self.instructionsIcon = color(forKey: Keys.instructionsIcon, data: plist)
        self.instructionsIconBackground = color(forKey: Keys.instructionsIconBackground, data: plist)
        self.instructionsFrame = color(forKey: Keys.instructionsFrame, data: plist)
        
        self.activityIndicatorStyle = UIActivityIndicatorViewStyle(rawValue: number(forKey: Keys.activityIndicatorStyle, data: plist).intValue)!
        self.scrollViewIndicatorStyle = UIScrollViewIndicatorStyle(rawValue: number(forKey: Keys.scrollViewIndicatorStyle, data: plist).intValue)!
        self.statusBarStyle = UIStatusBarStyle(rawValue: number(forKey: Keys.statusBarStyle, data: plist).intValue)!
        
        super.init()
    }
}

extension Theme {
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
}

func ==(lhs: Theme, rhs: Theme) -> Bool {
    return lhs.type == rhs.type && lhs.textSize == rhs.textSize
}

// MARK: -

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

fileprivate struct Keys {
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
