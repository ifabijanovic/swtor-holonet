//
//  ForumThreadTableViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 29/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var devImageView: UIImageView!
    @IBOutlet weak var stickyImageView: UIImageView!
    @IBOutlet weak var repliesViewsLabel: UILabel!
    
    // MARK: - Public methods
    
    func applyTheme(theme: Theme) {
        self.titleLabel.textColor = theme.contentTitle
        self.authorLabel.textColor = theme.contentText
        self.repliesViewsLabel.textColor = theme.contentText
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
