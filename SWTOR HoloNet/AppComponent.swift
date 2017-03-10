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
        
        binder.include(module: DefaultAnalytics.Module.self)
        binder.include(module: Settings.Module.self)
        binder.include(module: DefaultThemeManager.Module.self)
        
        binder.include(module: DefaultNavigator.Module.self)
        binder.include(module: ActionFactory.Module.self)
        
        binder.include(module: DefaultPushManager.Module.self)
        binder.include(module: Toolbox.Module.self)
        
        binder.include(module: TabViewController.Module.self)
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
                .to { (rootViewController: Provider<TabViewController>) -> UIWindow in
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.rootViewController = rootViewController.get()
                    return window
                }
        }
    }
}
