//
//  StandardServices.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct StandardServices {
    let analytics: Analytics
    let navigator: Navigator
    let theme: Driver<Theme>
    let settings: Settings
    
    init() {
        let analytics = DefaultAnalytics()
        let navigator = DefaultNavigator()
        let settings = Settings()
        
        let startingTheme = Theme()
        let theme = NotificationCenter.default
            .rx
            .notification(Notification.Name(Constants.Notifications.themeChanged))
            .map { $0.userInfo![Constants.Notifications.UserInfo.theme] as! Theme }
            .startWith(startingTheme)
            .asDriver(onErrorJustReturn: startingTheme)
        
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
extension StandardServices {
    static let instance = StandardServices()
}
