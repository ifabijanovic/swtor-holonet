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
        binder.bind(PushManager.self).asSingleton().to(factory: DefaultPushManager.init)
        
        binder.bind(Navigator.self).asSingleton().to(factory: RootViewController.init)
        
        binder.include(module: ForumModule.self)
        binder.include(module: DulfyModule.self)
        binder.include(module: SettingsModule.self)
        
        binder.bind(AppUIFactory.self).to(factory: AppUIFactory.init)
    }
    
    static func configureAppDelegateInjector(binder bind: PropertyInjectionReceiptBinder<AppDelegate>) -> BindingReceipt<PropertyInjector<AppDelegate>> {
        return bind.to(injector: AppDelegate.injectProperties)
    }
}

struct AppUIFactory {
    let forumFactory: ForumUIFactory
    let dulfyFactory: DulfyUIFactory
    let settingsFactory: SettingsUIFactory
    
    func textViewController(title: String, path: String, toolbox: Toolbox) -> UIViewController {
        let viewController = TextViewController(toolbox: toolbox)
        viewController.title = title
        viewController.file = path
        return viewController
    }
}

extension UIWindow {
    struct Module: Cleanse.Module {
        static func configure<B: Binder>(binder: B) {
            binder
                .bind(UIWindow.self)
                .asSingleton()
                .to { (navigator: Navigator) -> UIWindow in
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.rootViewController = navigator as? UIViewController
                    return window
                }
        }
    }
}
