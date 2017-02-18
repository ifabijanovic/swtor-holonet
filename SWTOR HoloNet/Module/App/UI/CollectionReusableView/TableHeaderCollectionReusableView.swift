//
//  TableHeaderCollectionReusableView.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TableHeaderCollectionReusableView: UICollectionReusableView, Themeable {

    // MARK: - Outlets
    
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: - Themeable
    
    func applyTheme(_ theme: Theme) {
        self.titleLabel.textColor = theme.headerText
        self.backgroundColor = theme.headerBackground
    }
    
}
