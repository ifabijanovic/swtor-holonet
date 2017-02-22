//
//  TableViewCell+Themeable.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

// This extension should be implemented so it extends the UITableViewCell
// with the Themeable protocol, but extended methods still cannot be
// overriden in Swift, so this is a temporary solution until later version of Swift
extension UITableViewCell {
    func applyThemeEx(_ theme: Theme) {
        self.textLabel?.textColor = theme.contentTitle
        self.detailTextLabel?.textColor = theme.contentText
        self.backgroundColor = UIColor.clear
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = theme.contentHighlightBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    func setDisclosureIndicator(_ theme: Theme) {
        if self.accessoryView == nil {
            let image = UIImage(named: "Forward")?.withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: image)
            self.accessoryView = imageView
        }
        
        self.accessoryView!.tintColor = theme.contentTitle
    }
}
