//
//  ForumThreadCollectionViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var devImageView: UIImageView!
    @IBOutlet weak var stickyImageView: UIImageView!
    @IBOutlet weak var repliesViewsLabel: UILabel!
    @IBOutlet weak var accessoryView: UIImageView!

    override func apply(theme: Theme) {
        self.titleLabel.textColor = theme.contentTitle
        self.titleLabel.font = UIFont.systemFont(ofSize: theme.textSize.rawValue)
        
        self.authorLabel.textColor = theme.contentText
        self.authorLabel.font = UIFont.systemFont(ofSize: theme.textSize.rawValue - 2.0)
        
        self.repliesViewsLabel.textColor = theme.contentText
        self.repliesViewsLabel.font = UIFont.systemFont(ofSize: theme.textSize.rawValue - 2.0)
        
        if self.accessoryView.image == nil {
            self.accessoryView.image = UIImage(named: "Forward")?.withRenderingMode(.alwaysTemplate)
        }
        self.accessoryView.tintColor = theme.contentTitle
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
}
