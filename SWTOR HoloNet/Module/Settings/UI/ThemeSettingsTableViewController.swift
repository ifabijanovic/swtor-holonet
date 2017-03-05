//
//  ThemeSettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 03/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ThemeSettingsTableViewController: BaseTableViewController {
    private let themeManager: ThemeManager
    private let pickerDelegate: SettingPickerDelegate<ThemeType>
    
    init(themeManager: ThemeManager, services: StandardServices) {
        self.themeManager = themeManager
        
        let options: [SettingPickerOption<ThemeType>] = [
            SettingPickerOption(index: 0, value: .dark),
            SettingPickerOption(index: 1, value: .light),
        ]
        self.pickerDelegate = SettingPickerDelegate(options: options)
        
        super.init(services: services, style: .plain)
    }
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Theme"
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
        guard let theme = self.theme else { return }
        
        cell.apply(theme: theme)
        cell.textLabel?.textColor = theme.contentText
        cell.tintColor = theme.contentTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pickerDelegate.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        self.themeManager.set(themeType: self.pickerDelegate.currentValue, bundle: Bundle.main)
    }
    
    // MARK: -
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = theme.contentBackground
        self.pickerDelegate.select(item: theme.type, in: self.tableView)
    }
}
