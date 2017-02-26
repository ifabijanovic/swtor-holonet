//
//  ForumCategoryCollectionViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var lastPostLabel: UILabel!
    @IBOutlet weak var accessoryView: UIImageView!

    override func apply(theme: Theme) {
        self.titleLabel.textColor = theme.contentTitle
        self.titleLabel.font = UIFont.systemFont(ofSize: theme.textSize.rawValue + 4.0)
        
        self.statsLabel.textColor = theme.contentText
        self.statsLabel.font = UIFont.systemFont(ofSize: theme.textSize.rawValue - 2.0)
        
        self.lastPostLabel.textColor = theme.contentText
        self.lastPostLabel.font = UIFont.systemFont(ofSize: theme.textSize.rawValue - 2.0)
        
        if self.accessoryView.image == nil {
            self.accessoryView.image = UIImage(named: "Forward")?.withRenderingMode(.alwaysTemplate)
        }
        self.accessoryView.tintColor = theme.contentTitle
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
}
