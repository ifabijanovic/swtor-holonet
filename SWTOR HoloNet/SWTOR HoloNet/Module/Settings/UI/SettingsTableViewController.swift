//
//  SettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Parse
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
    @IBOutlet var textSizeStatusLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.applyTheme(self.theme)
        
#if !DEBUG && !TEST
        // Analytics
        PFAnalytics.trackEvent("settings")
#endif
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.notificationSettingsStatusLabel.text = InstanceHolder.sharedInstance().pushManager.isPushEnabled ? "Enabled" : "Disabled"
        self.textSizeStatusLabel.text = self.theme.textSize.toString()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == self.contactCell {
            self.contact()
        }
        if cell == self.reportBugCell {
            self.reportBug()
        }
        if cell == self.notificationSettingsCell && isIOS8OrLater() {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
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
        
        self.presentViewController(controller, animated: true, completion: nil)
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
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func emailNotAvailable() {
        let alert = UIAlertView(title: "Error", message: "It seems email is not configured on this device.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case DisclaimerSegue:
            let controller = segue.destinationViewController as! TextViewController
            controller.title = "Disclaimer"
            controller.file = "Disclaimer"
        case PrivacyPolicySegue:
            let controller = segue.destinationViewController as! TextViewController
            controller.title = "Privacy Policy"
            controller.file = "PrivacyPolicy"
        case LicenseSegue:
            let controller = segue.destinationViewController as! TextViewController
            controller.title = "License"
            controller.file = "License"
        default:
            break
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == NotificationSettingsSegue && isIOS8OrLater() {
            return false
        }
        return true
    }
    
    // MARK: - Themeable
    
    override func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        
        for section in 0..<self.tableView.numberOfSections() {
            for row in 0..<self.tableView.numberOfRowsInSection(section) {
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
                    cell.applyThemeEx(theme)
                    cell.setDisclosureIndicator(theme)
                }
            }
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
