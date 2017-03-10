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
import Cleanse

struct Toolbox {
    let analytics: Analytics
    let navigator: Navigator
    let theme: Driver<Theme>
    let settings: Settings
    
    init(analytics: Analytics, navigator: Navigator, themeManager: ThemeManager, settings: Settings) {
        self.analytics = analytics
        self.navigator = navigator
        self.theme = themeManager.theme.asDriver(onErrorJustReturn: themeManager.currentTheme)
        self.settings = settings
    }
}

extension Toolbox {
    struct Module: Cleanse.Module {
        static func configure<B: Binder>(binder: B) {
            binder
                .bind(Toolbox.self)
                .asSingleton()
                .to(factory: Toolbox.init)
        }
    }
}
