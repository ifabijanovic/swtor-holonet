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
   
    // MARK: - Constants
    
    private let DisclaimerSegue = "DisclaimerSegue"
    private let PrivacyPolicySegue = "PrivacyPolicySegue"
    private let LicenseSegue = "LicenseSegue"
    
    // MARK: - Outlets
    
    @IBOutlet var contactCell: UITableViewCell!
    @IBOutlet var reportBugCell: UITableViewCell!
    @IBOutlet var notificationSettingsCell: UITableViewCell!
    
    @IBOutlet var notificationSettingsStatusLabel: UILabel!
    @IBOutlet var themeStatusLabel: UILabel!
    @IBOutlet var textSizeStatusLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.applyTheme(self.theme)
        
#if !DEBUG && !TEST
        self.analytics.track(event: Constants.Analytics.Event.settings)
#endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notificationSettingsStatusLabel.text = InstanceHolder.sharedInstance.pushManager.isPushEnabled ? "Enabled" : "Disabled"
        self.themeStatusLabel.text = String(describing: self.theme.type)
        self.textSizeStatusLabel.text = String(describing: self.theme.textSize)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (Section.messages, Row.notifications):
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        case (Section.display, Row.theme):
            self.navigationController?.pushViewController(ThemeSettingsTableViewController(), animated: true)
        case (Section.display, Row.textSize):
            self.navigationController?.pushViewController(TextSizeSettingsTableViewController(), animated: true)
        case (Section.feedback, Row.contact):
            self.contact()
        case (Section.feedback, Row.reportBug):
            self.reportBug()
        default: break
        }
    }
    
    // MARK: - Actions
    
    private func contact() {
        if !MFMailComposeViewController.canSendMail() {
            self.emailNotAvailable()
            return
        }
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([self.settings.appEmail])
        
        self.present(controller, animated: true, completion: nil)
    }
    
    private func reportBug() {
        if !MFMailComposeViewController.canSendMail() {
            self.emailNotAvailable()
            return
        }
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([self.settings.appEmail])
        controller.setSubject("[Bug]")
        
        self.present(controller, animated: true, completion: nil)
    }
    
    private func emailNotAvailable() {
        let alertController = DefaultUIAlertFactory().alert(title: "Error", message: "It seems email is not configured on this device.", actions: [
            (title: "OK", style: .default, handler: nil)
            ]
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case DisclaimerSegue:
            let controller = segue.destination as! TextViewController
            controller.title = "Disclaimer"
            controller.file = "Disclaimer"
        case PrivacyPolicySegue:
            let controller = segue.destination as! TextViewController
            controller.title = "Privacy Policy"
            controller.file = "PrivacyPolicy"
        case LicenseSegue:
            let controller = segue.destination as! TextViewController
            controller.title = "License"
            controller.file = "License"
        default:
            break
        }
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
        
        for section in 0..<self.tableView.numberOfSections {
            if let section = self.tableView.headerView(forSection: section) {
                section.contentView.backgroundColor = theme.contentBackground
            }
            
            for row in 0..<self.tableView.numberOfRows(inSection: section) {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                    cell.applyThemeEx(theme)
                    cell.setDisclosureIndicator(theme)
                }
            }
        }
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

fileprivate struct Section {
    static let messages = 0
    static let display = 1
    static let feedback = 2
    static let legal = 3
}

fileprivate struct Row {
    static let notifications = 0
    static let theme = 0
    static let textSize = 1
    static let contact = 0
    static let reportBug = 1
    static let disclaimer = 0
    static let privacyPolicy = 1
    static let license = 2
}
