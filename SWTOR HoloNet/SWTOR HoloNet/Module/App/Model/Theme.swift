//
//  Theme.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit



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

class Theme {
    
    // MARK: - Constants
    
    private let keyTextSize = "textSize"
    
    // MARK: - Properties
    
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
    
    var textSize: TextSize {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let savedValue = userDefaults.floatForKey(keyTextSize)
            
            if savedValue > 0 {
                if let value = TextSize(rawValue: CGFloat(savedValue)) {
                    return value
                }
            } else {
                userDefaults.setFloat(Float(TextSize.Small.rawValue), forKey: keyTextSize)
                userDefaults.synchronize()
            }
            
            return .Small
        }
        set(newSize) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setFloat(Float(newSize.rawValue), forKey: keyTextSize)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Init
    
    init() {
        self.navBackground = UIColor(red: 19.0/255.0, green: 19.0/255.0, blue: 19.0/255.0, alpha: 1.0) //#131313 (dark)
        self.navText = UIColor(red: 204.0/255.0, green: 158.0/255.0, blue: 66.0/255.0, alpha: 1.0) // #CC9E42 (gold)
        self.contentBackground = UIColor(red: 19.0/255.0, green: 19.0/255.0, blue: 19.0/255.0, alpha: 1.0) // #131313 (dark)
        self.contentHighlightBackground = UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 1.0) // #131313 (dark)
        self.contentTitle = UIColor(red: 204.0/255.0, green: 158.0/255.0, blue: 66.0/255.0, alpha: 1.0) // #CC9E42 (gold)
        self.contentText = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0) // D1D1D1 (gray)
        self.contentHighlightText = UIColor(red: 249.0/255.0, green: 214.0/255.0, blue: 72.0/255.0, alpha: 1.0)
        
        self.headerHeight = 22.0
        self.headerText = UIColor.blackColor()
        self.headerBackground = UIColor(red: 77.0/255.0, green: 77.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        
        self.instructionsIcon = UIColor.blackColor()
        self.instructionsIconBackground = UIColor.whiteColor()
        self.instructionsFrame = UIColor.grayColor()
        
        self.activityIndicatorStyle = UIActivityIndicatorViewStyle.White
        self.scrollViewIndicatorStyle = UIScrollViewIndicatorStyle.White
        
        self.apply()
    }
    
    // MARK: - Private methods
    
    func apply() {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        UINavigationBar.appearance().barTintColor = self.navBackground
        UINavigationBar.appearance().tintColor = self.navText
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: self.navText]
        
        UITabBar.appearance().barTintColor = self.navBackground
        UITabBar.appearance().tintColor = self.navText
        
        UIToolbar.appearance().barTintColor = self.navBackground
        UIToolbar.appearance().tintColor = self.navText
    }
}
