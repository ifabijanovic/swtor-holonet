//
//  TextViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Parse

class TextViewController: BaseViewController {

    // MARK: - Properties
    
    var file: String?
    var text: String?
    var analyticsName: String?
    var analyticsDimensions: Dictionary<String, String>?
    
    // MARK: - Outlets
    
    @IBOutlet var textView: UITextView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.file != nil {
            let bundle = Bundle.main
            let path = bundle.path(forResource: file, ofType: "txt")
            if let path = path {
                let content = try? String(contentsOfFile: path, encoding: .utf8)
                self.textView.text = content
            }
        } else if self.text != nil {
            self.textView.text = self.text!
        }
        
        self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        
        self.applyTheme(self.theme)
        
#if !DEBUG && !TEST
        // Analytics
        if let name = self.analyticsName {
            if let dimensions = self.analyticsDimensions {
                PFAnalytics.trackEvent(name, dimensions: dimensions)
            } else {
                PFAnalytics.trackEvent(name)
            }
        }
#endif
    }
    
    override func viewDidLayoutSubviews() {
        self.textView.textContainerInset = UIEdgeInsetsMake(self.topLayoutGuide.length + 8, 8, self.bottomLayoutGuide.length + 8, 8)
        self.textView.setContentOffset(CGPoint.zero, animated: false)
        
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        self.textView.textColor = theme.contentText
        self.textView.font = UIFont.systemFont(ofSize: theme.textSize.rawValue)
        self.textView.indicatorStyle = theme.scrollViewIndicatorStyle
    }

}
