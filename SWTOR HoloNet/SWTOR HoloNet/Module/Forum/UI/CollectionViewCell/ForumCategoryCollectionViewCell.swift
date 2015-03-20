//
//  ForumCategoryCollectionViewCell.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumCategoryCollectionViewCell: UICollectionViewCell, Themeable {

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
