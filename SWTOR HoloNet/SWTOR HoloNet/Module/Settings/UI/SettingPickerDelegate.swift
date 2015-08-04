//
//  SettingPickerDelegate
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class SettingPickerDelegate<SettingType: Equatable> {

    // MARK: - Properties
    
    let initialValue: SettingType
    
    private let tableView: UITableView
    private let map: Array<(index: Int, value: SettingType)>
    private var checkedRow: NSIndexPath!
    
    // MARK: - Init
    
    init(initialValue: SettingType, tableView: UITableView, map: Array<(index: Int, value: SettingType)>) {
        self.initialValue = initialValue
        self.tableView = tableView
        self.map = map
        
        self.checkedRow = NSIndexPath(forRow: self.indexForSettingType(self.initialValue), inSection: 0)
        if let cell = self.tableView.cellForRowAtIndexPath(self.checkedRow) {
            cell.accessoryType = .Checkmark
        }
    }
    
    // MARK: - Public methods
    
    func getCurrentValue() -> SettingType {
        return self.settingTypeForIndex(self.checkedRow.row)!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    func applyTheme(theme: Theme) {
        self.tableView.backgroundColor = theme.contentBackground
        
        for row in 0..<self.tableView.numberOfRowsInSection(0) {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) {
                cell.applyThemeEx(theme)
                cell.textLabel?.textColor = theme.contentText
                cell.tintColor = theme.contentTitle
            }
        }
    }
    
    // MARK: - Private methods
    
    private func indexForSettingType(settingType: SettingType) -> Int {
        for item in self.map {
            if item.value == settingType {
                return item.index
            }
        }
        
        return 0
    }
    
    private func settingTypeForIndex(index: Int) -> SettingType? {
        for item in self.map {
            if item.index == index {
                return item.value
            }
        }
        return nil
    }
    
}
