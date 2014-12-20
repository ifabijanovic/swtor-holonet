//
//  SettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, Injectable, Themeable {
   
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    
    // MARK: - Outlets
    
    @IBOutlet var disclaimerCell: UITableViewCell!
    @IBOutlet var privacyPolicyCell: UITableViewCell!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()

        self.applyTheme(self.theme)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        self.disclaimerCell.applyThemeEx(theme)
        self.privacyPolicyCell.applyThemeEx(theme)
    }

}
