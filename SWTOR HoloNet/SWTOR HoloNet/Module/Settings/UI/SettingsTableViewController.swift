//
//  SettingsTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, Injectable, Themeable, MFMailComposeViewControllerDelegate {
   
    // MARK: - Constants
    
    private let DisclaimerSegue = "DisclaimerSegue"
    private let PrivacyPolicySegue = "PrivacyPolicySegue"
    private let LicenseSegue = "LicenseSegue"
    
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    
    // MARK: - Outlets
    
    @IBOutlet var contactCell: UITableViewCell!
    @IBOutlet var reportBugCell: UITableViewCell!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()

        self.applyTheme(self.theme)
        
        // Analytics
        PFAnalytics.trackEvent("settings")
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
            let controller = segue.destinationViewController as TextViewController
            controller.title = "Disclaimer"
            controller.file = "Disclaimer"
        case PrivacyPolicySegue:
            let controller = segue.destinationViewController as TextViewController
            controller.title = "Privacy Policy"
            controller.file = "PrivacyPolicy"
        case LicenseSegue:
            let controller = segue.destinationViewController as TextViewController
            controller.title = "License"
            controller.file = "License"
        default:
            break
        }
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
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
