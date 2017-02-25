//
//  InstanceHolder.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//
//  Singleton class holding dependencies which should be injected
//  but Apple and Swift are making that part extra hard :) Remove
//  after introducing proper dependency injection.
//

import UIKit

class InstanceHolder {
    var alertFactory: UIAlertFactory
    
    let settings: Settings
    let theme: Theme
    let pushManager: PushManager
    let analytics: Analytics
    
    static let sharedInstance = InstanceHolder()
    
    init() {
        let bundle = Bundle(for: InstanceHolder.self)
        
        self.settings = Settings(bundle: bundle)
        self.theme = Theme(bundle: bundle)
        self.alertFactory = DefaultUIAlertFactory()
        let actionFactory = ActionFactory(alertFactory: self.alertFactory)
        self.pushManager = DefaultPushManager(alertFactory: self.alertFactory, actionFactory: actionFactory)
        self.analytics = DefaultAnalytics()
    }
    
    func inject(handler: (Settings, Theme, UIAlertFactory, Analytics) -> Void) {
        handler(self.settings, self.theme, self.alertFactory, self.analytics)
    }
}
