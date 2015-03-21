//
//  ForumThreadHeaderCollectionReusableView.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadHeaderCollectionReusableView: UICollectionReusableView, Themeable {

    // MARK: - Outlets
    
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.backgroundColor = theme.contentBackground
        self.textLabel.textColor = theme.contentTitle
    }
    
}
