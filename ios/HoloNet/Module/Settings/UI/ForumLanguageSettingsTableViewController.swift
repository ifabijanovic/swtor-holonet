//
//  ForumLanguageSettingsTableViewController.swift
//  HoloNet
//
//  Created by Ivan Fabijanovic on 15/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumLanguageSettingsTableViewController: BaseTableViewController {
    private let forumLanguageManager: ForumLanguageManager
    private let pickerDelegate: SettingPickerDelegate<ForumLanguage>
    
    init(forumLanguageManager: ForumLanguageManager, toolbox: Toolbox) {
        self.forumLanguageManager = forumLanguageManager
        
        let options: [SettingPickerOption<ForumLanguage>] = [
            SettingPickerOption(index: 0, value: .english),
            SettingPickerOption(index: 1, value: .french),
            SettingPickerOption(index: 2, value: .german)
            ]
        self.pickerDelegate = SettingPickerDelegate(options: options)
        
        super.init(toolbox: toolbox, style: .plain)
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forum language"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pickerDelegate.select(item: self.forumLanguageManager.currentLanguage, in: self.tableView)
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
        self.forumLanguageManager.set(language: self.pickerDelegate.currentValue)
    }
    
    // MARK: -
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = theme.contentBackground
    }
}
