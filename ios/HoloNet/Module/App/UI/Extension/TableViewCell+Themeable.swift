//
//  TableViewCell+Themeable.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension UITableViewCell: Themeable {
    func apply(theme: Theme) {
        self.textLabel?.textColor = theme.contentTitle
        self.detailTextLabel?.textColor = theme.contentText
        self.backgroundColor = UIColor.clear
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    func setDisclosureIndicator(theme: Theme) {
        if self.accessoryView == nil {
            let image = UIImage(named: "Forward")?.withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            imageView.contentMode = .center
            self.accessoryView = imageView
        }
        
        self.accessoryView!.tintColor = theme.contentTitle
    }
}
