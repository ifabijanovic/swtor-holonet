//
//  BaseViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 15/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, Injectable, Themeable {

    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.inject()
        self.registerThemeChangedCallback()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.inject()
        self.registerThemeChangedCallback()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.inject()
        self.registerThemeChangedCallback()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func inject() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {}
    
    func themeChanged(theme: Theme) {
        self.applyTheme(theme)
    }
    
    func themeChanged(notification: NSNotification) {
        self.themeChanged(self.theme)
    }
    
    private func registerThemeChangedCallback() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "themeChanged:", name: ThemeChangedNotification, object: nil)
    }

}
