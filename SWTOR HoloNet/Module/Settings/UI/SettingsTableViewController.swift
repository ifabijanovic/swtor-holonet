//
//  SettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: BaseTableViewController, MFMailComposeViewControllerDelegate {
   
    // MARK: - Constants
    
    private let DisclaimerSegue = "DisclaimerSegue"
    private let PrivacyPolicySegue = "PrivacyPolicySegue"
    private let LicenseSegue = "LicenseSegue"
    private let NotificationSettingsSegue = "NotificationSettingsSegue"
    
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
        self.themeStatusLabel.text = self.theme.type.toString()
        self.textSizeStatusLabel.text = self.theme.textSize.toString()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell == self.contactCell {
            self.contact()
        }
        if cell == self.reportBugCell {
            self.reportBug()
        }
        if cell == self.notificationSettingsCell && isIOS8OrLater() {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
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
        let alert = UIAlertView(title: "Error", message: "It seems email is not configured on this device.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == NotificationSettingsSegue && isIOS8OrLater() {
            return false
        }
        return true
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
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
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}