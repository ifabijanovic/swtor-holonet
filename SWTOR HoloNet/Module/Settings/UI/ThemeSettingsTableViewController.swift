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
    
    private var pickerDelegate: SettingPickerDelegate<ThemeType>!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerDelegate = SettingPickerDelegate<ThemeType>(initialValue: self.theme.type, tableView: self.tableView, map: [
            (index: 0, value: ThemeType.dark),
            (index: 1, value: ThemeType.light)
        ])
        
        self.applyTheme(self.theme)
        
        self.pickerDelegate.markInitialValue()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let newValue = self.pickerDelegate.getCurrentValue()
        if (newValue != self.pickerDelegate.initialValue) {
            self.theme.changeTheme(type: newValue)
            self.theme.fireThemeChanged()
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pickerDelegate.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.pickerDelegate.applyTheme(theme)
    }

}
