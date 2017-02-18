//
//  LoadMoreCollectionReusableView.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class LoadMoreCollectionReusableView: UICollectionReusableView, Themeable {
    
    // MARK: - Outlets
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Themeable
    
    func applyTheme(_ theme: Theme) {
        self.activityIndicator.activityIndicatorViewStyle = theme.activityIndicatorStyle
        self.activityIndicator.tintColor = theme.contentText
    }
    
}
