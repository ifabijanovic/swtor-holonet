//
//  LoadMoreCollectionReusableView.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class LoadMoreCollectionReusableView: UICollectionReusableView, Themeable {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    func apply(theme: Theme) {
        self.activityIndicator.activityIndicatorViewStyle = theme.activityIndicatorStyle
        self.activityIndicator.tintColor = theme.contentText
    }
}
