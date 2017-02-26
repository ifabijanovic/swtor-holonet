//
//  TextSizeSettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TextSizeSettingsTableViewController: BaseTableViewController {
    private var pickerDelegate: SettingPickerDelegate<TextSize>!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Text Size"
        
        self.pickerDelegate = SettingPickerDelegate<TextSize>(initialValue: self.theme.textSize, map: [
            (index: 0, value: TextSize.small),
            (index: 1, value: TextSize.medium),
            (index: 2, value: TextSize.large)
        ])

        self.apply(theme: self.theme)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let newValue = self.pickerDelegate.currentValue
        if (newValue != self.pickerDelegate.initialValue) {
            self.theme.textSize = newValue
            self.theme.fireThemeChanged()
        }
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
        cell.apply(theme: self.theme)
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
    }
}
