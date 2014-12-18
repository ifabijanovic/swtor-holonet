//
//  ForumPostViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 03/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumPostViewController: UIViewController, InjectableViewController {

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
        super.viewDidLoad()
        
        self.textTextView.textContainerInset = UIEdgeInsetsMake(0, 12, 0, 12)
        
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
        
        self.dateLabel.text = "\(self.post.date) | #\(self.post.postNumber)"
        self.usernameLabel.text = post.username
        self.textTextView.text = post.text
        
        self.view.backgroundColor = self.theme.contentBackground
        self.dateLabel.textColor = self.theme.contentText
        self.usernameLabel.textColor = self.theme.contentText
        self.textTextView.textColor = self.post.isBiowarePost ? self.theme.contentHighlightText : self.theme.contentText
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // UITextView sometimes scrolls down on load, this returns the scroll to top
        self.textTextView.setContentOffset(CGPointZero, animated: false)
    }

}
