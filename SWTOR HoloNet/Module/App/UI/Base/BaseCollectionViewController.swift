//
//  BaseCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 15/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class BaseCollectionViewController: UICollectionViewController, Themeable {

    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    var analytics: Analytics!
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.inject()
        self.registerThemeChangedCallback()
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        self.inject()
        self.registerThemeChangedCallback()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.inject()
        self.registerThemeChangedCallback()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.inject()
        self.registerThemeChangedCallback()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func inject() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance.inject { settings, theme, alertFactory, analytics in
            self.settings = settings
            self.theme = theme
            self.alertFactory = alertFactory
            self.analytics = analytics
        }
    }
    
    // MARK: - Themeable
    
    func applyTheme(_ theme: Theme) {}
    
    func themeChanged(_ theme: Theme) {
        self.applyTheme(theme)
        self.collectionView!.reloadData()
    }
    
    func themeChanged(notification: NSNotification) {
        self.themeChanged(self.theme)
    }
    
    private func registerThemeChangedCallback() {
        NotificationCenter.default.addObserver(self, selector: #selector(BaseCollectionViewController.themeChanged(notification:)), name: Notification.Name(ThemeChangedNotification), object: nil)
    }

}
