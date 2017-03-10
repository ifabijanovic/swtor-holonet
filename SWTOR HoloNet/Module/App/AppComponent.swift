//
//  AppComponent.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 09/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit
import Cleanse

struct AppComponent: Cleanse.RootComponent {
    typealias Root = PropertyInjector<AppDelegate>
    typealias Scope = Singleton
    
    static func configure<B: Binder>(binder: B) {
        binder.include(module: AppModule.self)
    }
    
    static func configureRoot(binder bind: ReceiptBinder<PropertyInjector<AppDelegate>>) -> BindingReceipt<PropertyInjector<AppDelegate>> {
        return bind.propertyInjector(configuredWith: AppModule.configureAppDelegateInjector)
    }
}

struct AppModule: Cleanse.Module {
    static func configure<B: Binder>(binder: B) {
        binder.include(module: UIWindow.Module.self)
        
        binder.bind(Analytics.self).asSingleton().to(value: DefaultAnalytics())
        binder.bind(Settings.self).asSingleton().to(value: Settings(bundle: Bundle.main))
        binder.bind(ThemeManager.self).asSingleton().to(value: DefaultThemeManager(bundle: Bundle.main))
        
        binder.bind(Navigator.self).asSingleton().to(factory: DefaultNavigator.init)
        binder.bind(ActionFactory.self).asSingleton().to(factory: ActionFactory.init)
        
        binder.bind(PushManager.self).asSingleton().to(factory: DefaultPushManager.init)
        binder.bind(Toolbox.self).asSingleton().to(factory: Toolbox.init)
        
        binder.bind(TabViewController.self).to(factory: TabViewController.init)
        
        binder.include(module: ForumModule.self)
        binder.include(module: DulfyModule.self)
        binder.include(module: SettingsModule.self)
    }
    
    static func configureAppDelegateInjector(binder bind: PropertyInjectionReceiptBinder<AppDelegate>) -> BindingReceipt<PropertyInjector<AppDelegate>> {
        return bind.to(injector: AppDelegate.injectProperties)
    }
}

extension UIWindow {
    struct Module: Cleanse.Module {
        static func configure<B: Binder>(binder: B) {
            binder
                .bind(UIWindow.self)
                .asSingleton()
                .to { (rootViewController: TabViewController) -> UIWindow in
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.rootViewController = rootViewController
                    return window
                }
        }
    }
}
