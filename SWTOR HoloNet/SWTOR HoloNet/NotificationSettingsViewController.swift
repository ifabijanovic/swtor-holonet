//
//  NotificationSettingsViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController, Injectable, Themeable {
    
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    
    // MARK: - Outlets
    
    @IBOutlet var enabledDisabledLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        self.applyTheme(self.theme)
        
        self.enabledDisabledLabel.text = InstanceHolder.sharedInstance().pushManager.isPushEnabled ? "enabled" : "disabled"
        
        // Analytics
        PFAnalytics.trackEvent("settings", dimensions: ["page":"notification"])
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        
        // Set text color for all labels
        self.setLabelTextColor(self.view, color: theme.contentText)
        self.enabledDisabledLabel.textColor = theme.contentTitle
    }
    
    func setLabelTextColor(view: UIView, color: UIColor) {
        if let label = view as? UILabel {
            label.textColor = color
        }
        if view.subviews.count > 0 {
            for subview in view.subviews {
                setLabelTextColor(subview as UIView, color: color)
            }
        }
    }
    
}
