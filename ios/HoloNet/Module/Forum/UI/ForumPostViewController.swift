//
//  ForumPostViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 03/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import AlamofireImage

class ForumPostViewController: BaseViewController {
    fileprivate let post: ForumPost
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var devImageView: UIImageView!
    @IBOutlet var textTextView: UITextView!
    
    // MARK: -
    
    init(post: ForumPost, toolbox: Toolbox) {
        self.post = post
        super.init(toolbox: toolbox, nibName: "ForumPostViewController", bundle: Bundle.main)
    }
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("forum_post_title", comment: "")
        self.edgesForExtendedLayout = []
        
        // Set user avatar image if URL is defined in the model
        if let avatarUrl = self.post.avatarUrl, let url = URL(string: avatarUrl) {
            self.avatarImageView.isHidden = false
            self.avatarImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: Constants.Images.Placeholders.avatar))
        } else {
            self.avatarImageView.isHidden = true
        }
        
        // Set dev icon if post is marked as Bioware post
        if self.post.isBiowarePost, let url = URL(string: self.toolbox.settings.devTrackerIconUrl) {
            self.devImageView.isHidden = false
            self.devImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: Constants.Images.Placeholders.devTrackerIcon))
        } else {
            self.devImageView.isHidden = true
        }
        
        self.dateLabel.text = self.post.postNumber != nil ? "\(self.post.date) | #\(self.post.postNumber!)" : self.post.date
        self.usernameLabel.text = post.username
        self.textTextView.text = post.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.toolbox.analytics.track(event: Constants.Analytics.Event.forum, properties: [Constants.Analytics.Property.type: "post"])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.textTextView.textContainerInset = UIEdgeInsetsMake(8, 8, self.bottomLayoutGuide.length + 8, 8)
        self.textTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.dateLabel.textColor = theme.contentText
        self.usernameLabel.textColor = theme.contentText
        self.textTextView.textColor = post.isBiowarePost ? theme.contentHighlightText : theme.contentText
        self.textTextView.font = UIFont.systemFont(ofSize: theme.textSize.rawValue)
        self.textTextView.indicatorStyle = theme.scrollViewIndicatorStyle
    }
}
