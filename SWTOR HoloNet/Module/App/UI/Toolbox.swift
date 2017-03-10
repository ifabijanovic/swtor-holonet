//
//  Toolbox.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Toolbox {
    let analytics: Analytics
    let navigator: Navigator
    let theme: Driver<Theme>
    let settings: Settings
    
    init(themeManager: ThemeManager) {
        let analytics = DefaultAnalytics()
        let settings = Settings()
        let navigator = DefaultNavigator(settings: settings)
        let theme = themeManager.theme.asDriver(onErrorJustReturn: themeManager.currentTheme)
        
        self.init(analytics: analytics, navigator: navigator, theme: theme, settings: settings)
    }
    
    init(analytics: Analytics, navigator: Navigator, theme: Driver<Theme>, settings: Settings) {
        self.analytics = analytics
        self.navigator = navigator
        self.theme = theme
        self.settings = settings
    }
}

// Temporary until DI introduction
extension Toolbox {
    static let instance = Toolbox(themeManager: DefaultThemeManager.instance)
}
