//
//  ThemeSettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 03/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ThemeSettingsTableViewController: BaseTableViewController {
    private var pickerDelegate: SettingPickerDelegate<ThemeType>!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Theme"
        
        self.pickerDelegate = SettingPickerDelegate<ThemeType>(initialValue: self.theme.type, map: [
            (index: 0, value: ThemeType.dark),
            (index: 1, value: ThemeType.light)
        ])
        
        self.applyTheme(self.theme)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let newValue = self.pickerDelegate.currentValue
        if (newValue != self.pickerDelegate.initialValue) {
            self.theme.changeTheme(type: newValue)
            self.theme.fireThemeChanged()
        }
    }
    
    // MARK: -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.pickerDelegate.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.applyThemeEx(self.theme)
        cell.textLabel?.textColor = theme.contentText
        cell.tintColor = theme.contentTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pickerDelegate.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    // MARK: -
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = theme.contentBackground
    }
}
