//
//  SettingPickerDelegate
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class SettingPickerDelegate<SettingType: Equatable> {
    fileprivate let map: [(index: Int, value: SettingType)]
    fileprivate var checkedRow: IndexPath
    
    init(map: [(index: Int, value: SettingType)]) {
        self.map = map
        self.checkedRow = IndexPath(row: 99, section: 99)
    }
}

extension SettingPickerDelegate {
    var currentValue: SettingType {
        return self.settingType(index: self.checkedRow.row)!
    }
    
    func select(item: SettingType, in tableView: UITableView) {
        let index = self.index(settingType: item)
        self.tableView(tableView, didSelectRowAtIndexPath: IndexPath(row: index, section: 0))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingType = self.settingType(index: indexPath.row)
        assert(settingType != nil)
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = String(describing: settingType!)
        return cell
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
}

fileprivate extension SettingPickerDelegate {
    func index(settingType: SettingType) -> Int {
        for item in self.map {
            if item.value == settingType {
                return item.index
            }
        }
        return 0
    }
    
    func settingType(index: Int) -> SettingType? {
        for item in self.map {
            if item.index == index {
                return item.value
            }
        }
        return nil
    }
}
