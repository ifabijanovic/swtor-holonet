//
//  ForumThreadCollectionViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadCollectionViewCell: UICollectionViewCell, Themeable {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var devImageView: UIImageView!
    @IBOutlet weak var stickyImageView: UIImageView!
    @IBOutlet weak var repliesViewsLabel: UILabel!
    @IBOutlet var accessoryView: UIImageView!
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.titleLabel.textColor = theme.contentTitle
        self.authorLabel.textColor = theme.contentText
        self.repliesViewsLabel.textColor = theme.contentText
        if self.accessoryView.image == nil {
            self.accessoryView.image = UIImage(named: "Forward")?.imageWithRenderingMode(.AlwaysTemplate)
            self.accessoryView.tintColor = theme.contentTitle
        }
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }


}
