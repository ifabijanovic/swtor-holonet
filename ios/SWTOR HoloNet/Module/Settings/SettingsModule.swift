//
//  SettingsModule.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Cleanse

struct SettingsModule: Cleanse.Module {
    static func configure<B: Binder>(binder: B) {
        binder.bind(SettingsUIFactory.self).to(factory: DefaultSettingsUIFactory.init)
    }
}

protocol SettingsUIFactory {
    func settingsViewController(toolbox: Toolbox) -> UIViewController
    func themeSettingsViewController(toolbox: Toolbox) -> UIViewController
    func textSizeSettingsViewController(toolbox: Toolbox) -> UIViewController
}

fileprivate struct DefaultSettingsUIFactory: SettingsUIFactory {
    private let pushManager: PushManager
    private let themeManager: ThemeManager
    
    init(pushManager: PushManager, themeManager: ThemeManager) {
        self.pushManager = pushManager
        self.themeManager = themeManager
    }
    
    func settingsViewController(toolbox: Toolbox) -> UIViewController {
        return SettingsTableViewController(pushManager: self.pushManager, toolbox: toolbox)
    }
    
    func themeSettingsViewController(toolbox: Toolbox) -> UIViewController {
        return ThemeSettingsTableViewController(themeManager: self.themeManager, toolbox: toolbox)
    }
    
    func textSizeSettingsViewController(toolbox: Toolbox) -> UIViewController {
        return TextSizeSettingsTableViewController(themeManager: self.themeManager, toolbox: toolbox)
    }
}
