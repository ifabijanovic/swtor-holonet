//
//  ThemeManager.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ThemeManager {
    var theme: Driver<Theme> { get }
    var currentTheme: Theme { get }
    func set(themeType: ThemeType, bundle: Bundle)
    func set(textSize: TextSize, bundle: Bundle)
}

class DefaultThemeManager: ThemeManager {
    private let themeSubject: BehaviorSubject<Theme>
    
    let theme: Driver<Theme>
    private(set) var currentTheme: Theme
    
    init(bundle: Bundle) {
        let currentTheme = Theme(type: currentThemeType, textSize: currentTextSize, bundle: bundle)
        
        self.themeSubject = BehaviorSubject<Theme>(value: currentTheme)
        self.theme = self.themeSubject.distinctUntilChanged().asDriverIgnoringErrors()
        self.currentTheme = currentTheme
        
        apply(theme: currentTheme)
    }
    
    func set(themeType: ThemeType, bundle: Bundle) {
        let theme = Theme(type: themeType, textSize: currentTextSize, bundle: bundle)
        self.currentTheme = theme
        self.themeSubject.onNext(theme)
        apply(theme: theme)
        
        UserDefaults.standard.set(themeType.rawValue, forKey: Keys.themeType)
        UserDefaults.standard.synchronize()
    }
    
    func set(textSize: TextSize, bundle: Bundle) {
        let theme = Theme(type: currentThemeType, textSize: textSize, bundle: bundle)
        self.currentTheme = theme
        self.themeSubject.onNext(theme)
        
        UserDefaults.standard.set(textSize.rawValue, forKey: Keys.textSize)
        UserDefaults.standard.synchronize()
    }
}

fileprivate var currentThemeType: ThemeType {
    if let value = UserDefaults.standard.string(forKey: Keys.themeType) {
        return ThemeType(rawValue: value) ?? .dark
    }
    return .dark
}

fileprivate var currentTextSize: TextSize {
    let value = UserDefaults.standard.float(forKey: Keys.textSize)
    return TextSize(rawValue: CGFloat(value)) ?? .small
}

fileprivate func apply(theme: Theme) {
    UINavigationBar.appearance().barTintColor = theme.navBackground
    UINavigationBar.appearance().tintColor = theme.navText
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: theme.navText]
    
    UITabBar.appearance().barTintColor = theme.navBackground
    UITabBar.appearance().tintColor = theme.navText
    
    UIToolbar.appearance().barTintColor = theme.navBackground
    UIToolbar.appearance().tintColor = theme.navText
}

fileprivate struct Keys {
    static let themeType = "themeType"
    static let textSize = "textSize"
}
