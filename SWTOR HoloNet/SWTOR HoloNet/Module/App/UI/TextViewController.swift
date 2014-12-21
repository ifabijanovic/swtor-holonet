//
//  TextViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TextViewController: UIViewController, Injectable, Themeable {

    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    
    var text: String?
    var analyticsName: String?
    var analyticsDimensions: Dictionary<String, String>?
    
    // MARK: - Outlets
    
    @IBOutlet var textView: UITextView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        if self.text != nil {
            self.textView.text = self.text!
        }
        
        self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        // UITextView sometimes scrolls down when view gets loaded
        self.textView.setContentOffset(CGPointMake(0, -142.5), animated: false)
        
        self.applyTheme(self.theme)
        
        // Analytics
        if let name = self.analyticsName {
            if let dimensions = self.analyticsDimensions {
                PFAnalytics.trackEvent(name, dimensions: dimensions)
            } else {
                PFAnalytics.trackEvent(name)
            }
        }
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        self.textView.textColor = theme.contentText
    }

}
