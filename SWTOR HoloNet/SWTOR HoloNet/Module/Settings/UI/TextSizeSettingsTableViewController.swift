//
//  TextSizeSettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TextSizeSettingsTableViewController: BaseTableViewController {
    
    // MARK: - Properties
    
    private var pickerDelegate: SettingPickerDelegate<TextSize>!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerDelegate = SettingPickerDelegate<TextSize>(initialValue: self.theme.textSize, tableView: self.tableView, map: [
            (index: 0, value: .Small),
            (index: 1, value: .Medium),
            (index: 2, value: .Large)
        ])
        
        self.applyTheme(self.theme)
        
        self.pickerDelegate.markInitialValue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let newValue = self.pickerDelegate.getCurrentValue()
        if (newValue != self.pickerDelegate.initialValue) {
            self.theme.textSize = newValue
            self.theme.fireThemeChanged()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.pickerDelegate.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
        self.pickerDelegate.applyTheme(theme)
    }

}
