//
//  ForumPostCollectionViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumPostCollectionViewCell: UICollectionViewCell, Themeable {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var devImageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var accessoryView: UIImageView!
    @IBOutlet weak var separatorLine: UIView!

    func applyTheme(_ theme: Theme) {
        self.dateLabel.textColor = theme.contentText
        self.usernameLabel.textColor = theme.contentText
        self.textView.textColor = theme.contentText
        self.textView.font = UIFont.systemFont(ofSize: theme.textSize.rawValue)
        
        if (!self.devImageView.isHidden) {
            self.textView.textColor = theme.contentHighlightText
        }
        
        if self.accessoryView.image == nil {
            self.accessoryView.image = UIImage(named: "Forward")?.withRenderingMode(.alwaysTemplate)
        }
        self.accessoryView.tintColor = theme.contentTitle
        
        self.separatorLine.backgroundColor = theme.contentText
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.textView.numberOfLines = 40
        }
    }
}
