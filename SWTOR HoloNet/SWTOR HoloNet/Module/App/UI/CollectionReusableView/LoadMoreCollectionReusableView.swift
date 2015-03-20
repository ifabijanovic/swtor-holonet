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
    
    func applyTheme(theme: Theme) {
        self.activityIndicator.activityIndicatorViewStyle = theme.activityIndicatorStyle
    }
    
}
