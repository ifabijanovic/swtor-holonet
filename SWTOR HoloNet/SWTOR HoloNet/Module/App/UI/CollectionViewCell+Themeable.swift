//
//  CollectionViewCell+Themeable.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

// This extension should be implemented so it extends the UITableViewCell
// with the Themeable protocol, but extended methods still cannot be
// overriden in Swift, so this is a temporary solution until later version of Swift
extension UICollectionViewCell {
    
    func applyThemeEx(theme: Theme) {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
    
}
