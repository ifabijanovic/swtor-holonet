//
//  TextSizeSettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TextSizeSettingsTableViewController: UITableViewController, Injectable, Themeable {
    
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    
    var currentTextSize: CGFloat!
    var checkedRow: NSIndexPath!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        self.applyTheme(self.theme)
        
        self.currentTextSize = theme.textSize
        switch self.currentTextSize {
        case 16:
            self.checkedRow = NSIndexPath(forRow: 1, inSection: 0)
            break
        case 18:
            self.checkedRow = NSIndexPath(forRow: 2, inSection: 0)
            break
        default:
            self.checkedRow = NSIndexPath(forRow: 0, inSection: 0)
            break
        }
        
        if let cell = self.tableView.cellForRowAtIndexPath(self.checkedRow) {
            cell.accessoryType = .Checkmark
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if !indexPath.isEqual(self.checkedRow) {
            if let cell = tableView.cellForRowAtIndexPath(self.checkedRow) {
                cell.accessoryType = .None
            }
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.accessoryType = .Checkmark
            }
        }
        
        self.checkedRow = indexPath
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        
        for row in 0..<self.tableView.numberOfRowsInSection(0) {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) {
                cell.applyThemeEx(theme)
                cell.textLabel?.textColor = theme.contentText
                cell.tintColor = theme.contentTitle
            }
        }
    }

}
