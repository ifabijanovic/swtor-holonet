//
//  ForumThreadHeaderCollectionReusableView.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadHeaderCollectionReusableView: UICollectionReusableView, Themeable {
    @IBOutlet weak var textLabel: UILabel!
    
    func applyTheme(_ theme: Theme) {
        self.backgroundColor = theme.contentBackground
        self.textLabel.textColor = theme.contentTitle
    }
}
