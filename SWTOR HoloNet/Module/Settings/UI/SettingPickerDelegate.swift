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
    private var checkedRow: IndexPath!
    
    // MARK: - Init
    
    init(initialValue: SettingType, tableView: UITableView, map: Array<(index: Int, value: SettingType)>) {
        self.initialValue = initialValue
        self.tableView = tableView
        self.map = map
        
        self.checkedRow = IndexPath(row: self.indexForSettingType(self.initialValue), section: 0)
    }
    
    // MARK: - Public methods
    
    func markInitialValue() {
        let initialValueRow = IndexPath(row: self.indexForSettingType(self.initialValue), section: 0)
        if let cell = self.tableView.cellForRow(at: initialValueRow) {
            cell.accessoryType = .checkmark
        }
        self.checkedRow = initialValueRow
    }
    
    func getCurrentValue() -> SettingType {
        return self.settingTypeForIndex(self.checkedRow.row)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath != self.checkedRow {
            if let cell = tableView.cellForRow(at: self.checkedRow) {
                cell.accessoryType = .none
            }
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }
        
        self.checkedRow = indexPath
    }
    
    func applyTheme(_ theme: Theme) {
        self.tableView.backgroundColor = theme.contentBackground
        
        for row in 0..<self.tableView.numberOfRows(inSection: 0) {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                cell.applyThemeEx(theme)
                cell.textLabel?.textColor = theme.contentText
                cell.tintColor = theme.contentTitle
            }
        }
    }
    
    // MARK: - Private methods
    
    private func indexForSettingType(_ settingType: SettingType) -> Int {
        for item in self.map {
            if item.value == settingType {
                return item.index
            }
        }
        
        return 0
    }
    
    private func settingTypeForIndex(_ index: Int) -> SettingType? {
        for item in self.map {
            if item.index == index {
                return item.value
            }
        }
        return nil
    }
    
}
