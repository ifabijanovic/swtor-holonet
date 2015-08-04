//
//  ThemeSettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 03/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ThemeSettingsTableViewController: BaseTableViewController {
    
    // MARK: - Properties
    
    private var initialValue: ThemeType!
    
    var checkedRow: NSIndexPath!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialValue = self.theme.type
        
        self.applyTheme(self.theme)
        
        self.checkedRow = NSIndexPath(forRow: self.indexForThemeType(self.theme.type), inSection: 0)
        
        if let cell = self.tableView.cellForRowAtIndexPath(self.checkedRow) {
            cell.accessoryType = .Checkmark
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let newValue = self.themeTypeForIndex(self.checkedRow.row)
        if (newValue != self.initialValue) {
            self.theme.changeTheme(newValue)
            self.theme.fireThemeChanged()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
    
    private func indexForThemeType(themeType: ThemeType) -> Int {
        switch self.theme.type {
        case .Light:
            return 1
        default:
            return 0
        }
    }
    
    private func themeTypeForIndex(index: Int) -> ThemeType {
        switch self.checkedRow.row {
        case 1:
            return .Light
        default:
            return .Dark
        }
    }
    
    // MARK: - Themeable
    
    override func applyTheme(theme: Theme) {
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
