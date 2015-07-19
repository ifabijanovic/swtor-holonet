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
    
    var checkedRow: NSIndexPath!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        self.applyTheme(self.theme)
        
        self.checkedRow = NSIndexPath(forRow: self.indexForTextSize(self.theme.textSize), inSection: 0)
        
        if let cell = self.tableView.cellForRowAtIndexPath(self.checkedRow) {
            cell.accessoryType = .Checkmark
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.theme.textSize = self.textSizeForIndex(self.checkedRow.row)
        NSNotificationCenter.defaultCenter().postNotificationName(ThemeChangedNotification, object: self, userInfo: nil)
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
    
    // MARK: - Private methods
    
    private func indexForTextSize(textSize: TextSize) -> Int {
        switch self.theme.textSize {
        case .Medium:
            return 1
        case .Large:
            return 2
        default:
            return 0
        }
    }
    
    private func textSizeForIndex(index: Int) -> TextSize {
        switch self.checkedRow.row {
        case 1:
            return .Medium
        case 2:
            return .Large
        default:
            return .Small
        }
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
