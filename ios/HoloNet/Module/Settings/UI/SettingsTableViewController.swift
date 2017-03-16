//
//  SettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: BaseTableViewController {
    fileprivate let forumLanguageManager: ForumLanguageManager
    fileprivate let pushManager: PushManager
    
    init(forumLanguageManager: ForumLanguageManager, pushManager: PushManager, toolbox: Toolbox) {
        self.forumLanguageManager = forumLanguageManager
        self.pushManager = pushManager
        super.init(toolbox: toolbox, style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("settings_title", comment: "")
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toolbox.analytics.track(event: Constants.Analytics.Event.settings)
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: Row.notifications, section: Section.messages)) {
            cell.detailTextLabel?.text = self.pushManager.isEnabled
                ? NSLocalizedString("settings_notifications_enabled_value", comment: "")
                : NSLocalizedString("settings_notifications_disabled_value", comment: "")
        }
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: Row.forumLanguage, section: Section.display)) {
            cell.detailTextLabel?.text = String(describing: self.forumLanguageManager.currentLanguage)
        }
    }
    
    // MARK: -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count[section] ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.messages: return NSLocalizedString("settings_section_messages_title", comment: "")
        case Section.display: return NSLocalizedString("settings_section_display_title", comment: "")
        case Section.feedback: return NSLocalizedString("settings_section_feedback_title", comment: "")
        case Section.legal: return NSLocalizedString("settings_section_legal_title", comment: "")
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == Section.legal {
            let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""
            return "\(versionNumber).\(buildNumber)"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var style = UITableViewCellStyle.default
        let text: String
        var detailText: String? = nil
        
        switch (indexPath.section, indexPath.row) {
        case (Section.messages, Row.notifications):
            style = .value1
            text = NSLocalizedString("settings_notifications_label", comment: "")
            detailText = self.pushManager.isEnabled
                ? NSLocalizedString("settings_notifications_enabled_value", comment: "")
                : NSLocalizedString("settings_notifications_disabled_value", comment: "")
        case (Section.display, Row.forumLanguage):
            style = .value1
            text = NSLocalizedString("settings_forum_language_label", comment: "")
            detailText = String(describing: self.forumLanguageManager.currentLanguage)
        case (Section.display, Row.theme):
            style = .value1
            text = NSLocalizedString("settings_theme_label", comment: "")
            detailText = self.theme != nil ? String(describing: self.theme!.type) : ""
        case (Section.display, Row.textSize):
            style = .value1
            text = NSLocalizedString("settings_text_size_label", comment: "")
            detailText = self.theme != nil ? String(describing: self.theme!.textSize) : ""
        case (Section.feedback, Row.contact):
            text = NSLocalizedString("settings_contact_label", comment: "")
        case (Section.feedback, Row.reportBug):
            text = NSLocalizedString("settings_report_bug_label", comment: "")
        case (Section.legal, Row.disclaimer):
            text = NSLocalizedString("settings_disclaimer_label", comment: "")
        case (Section.legal, Row.privacyPolicy):
            text = NSLocalizedString("settings_privacy_policy_label", comment: "")
        case (Section.legal, Row.license):
            text = NSLocalizedString("settings_license_label", comment: "")
        default:
            text = ""
        }
        
        let cell = UITableViewCell(style: style, reuseIdentifier: nil)
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        if let theme = self.theme {
            headerView.contentView.backgroundColor = theme.contentBackground
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        footerView.textLabel?.textAlignment = .center
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let theme = self.theme else { return }
        
        cell.apply(theme: theme)
        cell.setDisclosureIndicator(theme: theme)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (Section.messages, Row.notifications):
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
            self.toolbox.navigator.open(url: url)
        case (Section.display, Row.forumLanguage):
            self.toolbox.navigator.navigate(from: self, to: .forumLanguageSettings, animated: true)
        case (Section.display, Row.theme):
            self.toolbox.navigator.navigate(from: self, to: .themeSettings, animated: true)
        case (Section.display, Row.textSize):
            self.toolbox.navigator.navigate(from: self, to: .textSizeSettings, animated: true)
        case (Section.feedback, Row.contact):
            self.contact()
        case (Section.feedback, Row.reportBug):
            self.reportBug()
        case (Section.legal, Row.disclaimer):
            self.toolbox.navigator.navigate(from: self, to: .text(title: NSLocalizedString("settings_disclaimer_label", comment: ""), path: "Disclaimer"), animated: true)
        case (Section.legal, Row.privacyPolicy):
            self.toolbox.navigator.navigate(from: self, to: .text(title: NSLocalizedString("settings_privacy_policy_label", comment: ""), path: "PrivacyPolicy"), animated: true)
        case (Section.legal, Row.license):
            self.toolbox.navigator.navigate(from: self, to: .text(title: NSLocalizedString("settings_license_label", comment: ""), path: "License"), animated: true)
        default: break
        }
    }
    
    // MARK: -
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        self.view.backgroundColor = theme.contentBackground
    }
}

extension SettingsTableViewController {
    fileprivate func contact() {
        if !MFMailComposeViewController.canSendMail() {
            self.emailNotAvailable()
            return
        }
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([self.toolbox.settings.appEmail])
        
        self.present(controller, animated: true, completion: nil)
    }
    
    fileprivate func reportBug() {
        if !MFMailComposeViewController.canSendMail() {
            self.emailNotAvailable()
            return
        }
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([self.toolbox.settings.appEmail])
        controller.setSubject("[Bug]")
        
        self.present(controller, animated: true, completion: nil)
    }
    
    fileprivate func emailNotAvailable() {
        self.toolbox.navigator.showAlert(title: NSLocalizedString("alert_email_not_available_title", comment: ""), message: NSLocalizedString("alert_email_not_available_body", comment: ""), actions: [UIAlertAction(title: NSLocalizedString("alert_email_not_available_confirm", comment: ""), style: .default, handler: nil)])
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

fileprivate struct Section {
    static let count = 4
    
    static let messages = 0
    static let display = 1
    static let feedback = 2
    static let legal = 3
}

fileprivate struct Row {
    static let count: [Int: Int] = [
        Section.messages: 1,
        Section.display: 3,
        Section.feedback: 2,
        Section.legal: 3
    ]
    
    static let notifications = 0
    static let forumLanguage = 0
    static let theme = 1
    static let textSize = 2
    static let contact = 0
    static let reportBug = 1
    static let disclaimer = 0
    static let privacyPolicy = 1
    static let license = 2
}
