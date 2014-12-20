//
//  ForumCategoryTableViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 29/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumCategoryTableViewCell: UITableViewCell, Themeable {

    // MARK: - Outlets
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var lastPostLabel: UILabel!
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.titleLabel.textColor = theme.contentTitle
        self.statsLabel.textColor = theme.contentText
        self.lastPostLabel.textColor = theme.contentText
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
