//
//  ForumPostTableViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 29/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumPostTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var devImageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    
    // MARK: - Public methods
    
    func applyTheme(theme: Theme) {
        self.dateLabel.textColor = theme.contentText
        self.usernameLabel.textColor = theme.contentText
        self.textView.textColor = theme.contentText
        
        if (!self.devImageView.hidden) {
            self.textView.textColor = theme.contentHighlightText
        }
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
