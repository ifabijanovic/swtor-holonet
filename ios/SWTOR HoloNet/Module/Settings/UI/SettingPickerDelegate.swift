//
//  SettingPickerDelegate
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

struct SettingPickerOption<T: Equatable> {
    let index: Int
    let value: T
}

class SettingPickerDelegate<T: Equatable> {
    fileprivate let options: [SettingPickerOption<T>]
    fileprivate var selectedIndexPath: IndexPath
    
    init(options: [SettingPickerOption<T>]) {
        self.options = options
        self.selectedIndexPath = IndexPath(row: 99, section: 99)
    }
}

extension SettingPickerDelegate {
    var currentValue: T {
        return self.settingType(index: self.selectedIndexPath.row)!
    }
    
    func select(item: T, in tableView: UITableView) {
        let index = self.index(settingType: item)
        self.tableView(tableView, didSelectRowAtIndexPath: IndexPath(row: index, section: 0))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingType = self.settingType(index: indexPath.row)
        assert(settingType != nil)
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = String(describing: settingType!)
        cell.accessoryType = indexPath == self.selectedIndexPath ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath != self.selectedIndexPath {
            if let cell = tableView.cellForRow(at: self.selectedIndexPath) {
                cell.accessoryType = .none
            }
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }
        
        self.selectedIndexPath = indexPath
    }
}

fileprivate extension SettingPickerDelegate {
    func index(settingType: T) -> Int {
        for item in self.options {
            if item.value == settingType {
                return item.index
            }
        }
        return 0
    }
    
    func settingType(index: Int) -> T? {
        for item in self.options {
            if item.index == index {
                return item.value
            }
        }
        return nil
    }
}
