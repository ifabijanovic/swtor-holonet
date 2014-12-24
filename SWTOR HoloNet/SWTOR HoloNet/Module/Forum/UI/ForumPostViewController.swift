//
//  ForumPostViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 03/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumPostViewController: UIViewController, Injectable, Themeable {

    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var post: ForumPost!
    
    // MARK: - Outlets
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var devImageView: UIImageView!
    @IBOutlet var textTextView: UITextView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        self.textTextView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        
        // Set user avatar image if URL is defined in the model
        if let url = self.post.avatarUrl {
            self.avatarImageView.hidden = false
            self.avatarImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "Avatar"))
        } else {
            self.avatarImageView.hidden = true
        }
        
        // Set dev icon if post is marked as Bioware post
        if self.post.isBiowarePost {
            self.devImageView.hidden = false
            self.devImageView.sd_setImageWithURL(NSURL(string: self.settings.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            self.devImageView.hidden = true
        }
        
        self.dateLabel.text = self.post.postNumber != nil ? "\(self.post.date) | #\(self.post.postNumber!)" : self.post.date
        self.usernameLabel.text = post.username
        self.textTextView.text = post.text
        
        // UITextView sometimes scrolls down when view gets loaded
        self.textTextView.setContentOffset(CGPointMake(0, -145), animated: false)
        
        self.applyTheme(self.theme)
        
        // Analytics
        PFAnalytics.trackEvent("forum", dimensions: ["type": "post"])
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        self.dateLabel.textColor = theme.contentText
        self.usernameLabel.textColor = theme.contentText
        self.textTextView.textColor = post.isBiowarePost ? self.theme.contentHighlightText : self.theme.contentText
    }

}
