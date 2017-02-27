//
//  TextSizeSettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TextSizeSettingsTableViewController: BaseTableViewController {
    private let themeManager: ThemeManager
    private var pickerDelegate: SettingPickerDelegate<TextSize>!
    
    init(themeManager: ThemeManager, services: StandardServices) {
        self.themeManager = themeManager
        super.init(services: services, style: .plain)
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Text Size"
        
        self.pickerDelegate = SettingPickerDelegate<TextSize>(map: [
            (index: 0, value: TextSize.small),
            (index: 1, value: TextSize.medium),
            (index: 2, value: TextSize.large)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.themeManager.set(textSize: self.pickerDelegate.currentValue, bundle: Bundle.main)
    }

    // MARK: -

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
    }
    
    // MARK: -
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = theme.contentBackground
        self.pickerDelegate.select(item: theme.textSize, in: self.tableView)
    }
}
