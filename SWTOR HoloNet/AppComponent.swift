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
                .to {
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    return window
                }
        }
    }
}
