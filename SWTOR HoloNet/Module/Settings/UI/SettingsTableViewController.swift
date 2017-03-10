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
    fileprivate let pushManager: PushManager
    
    init(pushManager: PushManager, toolbox: Toolbox, style: UITableViewStyle) {
        self.pushManager = pushManager
        super.init(toolbox: toolbox, style: style)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toolbox.analytics.track(event: Constants.Analytics.Event.settings)
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: Row.notifications, section: Section.messages)) {
            cell.detailTextLabel?.text = self.pushManager.isEnabled ? "Enabled" : "Disabled"
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
        case Section.messages: return "MESSAGES"
        case Section.display: return "DISPLAY"
        case Section.feedback: return "FEEDBACK"
        case Section.legal: return "LEGAL"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var style = UITableViewCellStyle.default
        let text: String
        var detailText: String? = nil
        
        switch (indexPath.section, indexPath.row) {
        case (Section.messages, Row.notifications):
            style = .value1
            text = "Notifications"
            detailText = self.pushManager.isEnabled ? "Enabled" : "Disabled"
        case (Section.display, Row.theme):
            style = .value1
            text = "Theme"
            detailText = self.theme != nil ? String(describing: self.theme!.type) : ""
        case (Section.display, Row.textSize):
            style = .value1
            text = "Text size"
            detailText = self.theme != nil ? String(describing: self.theme!.textSize) : ""
        case (Section.feedback, Row.contact):
            text = "Contact"
        case (Section.feedback, Row.reportBug):
            text = "Report bug"
        case (Section.legal, Row.disclaimer):
            text = "Disclaimer"
        case (Section.legal, Row.privacyPolicy):
            text = "Privacy policy"
        case (Section.legal, Row.license):
            text = "License"
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
        case (Section.display, Row.theme):
            self.toolbox.navigator.navigate(from: self, to: .themeSettings, animated: true)
        case (Section.display, Row.textSize):
            self.toolbox.navigator.navigate(from: self, to: .textSizeSettings, animated: true)
        case (Section.feedback, Row.contact):
            self.contact()
        case (Section.feedback, Row.reportBug):
            self.reportBug()
        case (Section.legal, Row.disclaimer):
            self.toolbox.navigator.navigate(from: self, to: .text(title: "Disclaimer", path: "Disclaimer"), animated: true)
        case (Section.legal, Row.privacyPolicy):
            self.toolbox.navigator.navigate(from: self, to: .text(title: "Privacy Policy", path: "PrivacyPolicy"), animated: true)
        case (Section.legal, Row.license):
            self.toolbox.navigator.navigate(from: self, to: .text(title: "License", path: "License"), animated: true)
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
        self.toolbox.navigator.showAlert(title: "Error", message: "It seems email is not configured on this device.", actions: [(title: "OK", style: .default, handler: nil)])
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
        Section.display: 2,
        Section.feedback: 2,
        Section.legal: 3
    ]
    
    static let notifications = 0
    static let theme = 0
    static let textSize = 1
    static let contact = 0
    static let reportBug = 1
    static let disclaimer = 0
    static let privacyPolicy = 1
    static let license = 2
}
