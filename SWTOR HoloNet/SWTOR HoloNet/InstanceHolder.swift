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
    
    // MARK: - Properties
    
    var alertFactory: AlertFactory
    
    let settings: Settings
    let theme: Theme
    let pushManager: PushManager
    
    // MARK: - Singleton
    
    static let sharedInstance = InstanceHolder()
    
    // MARK: - Init
    
    init() {
        self.settings = Settings()
        self.theme = Theme()
        self.alertFactory = UIAlertFactory()
        let actionFactory = ActionFactory(alertFactory: self.alertFactory)
        self.pushManager = PushManager(alertFactory: self.alertFactory, actionFactory: actionFactory)
    }
    
    // MARK: - Public methods
    
    func inject(handler: (Settings, Theme, AlertFactory) -> Void) {
        handler(self.settings, self.theme, self.alertFactory)
    }
    
}
