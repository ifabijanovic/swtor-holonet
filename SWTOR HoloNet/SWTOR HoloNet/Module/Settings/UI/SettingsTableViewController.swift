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
   
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    
    // MARK: - Outlets
    
    @IBOutlet var contactCell: UITableViewCell!
    @IBOutlet var reportBugCell: UITableViewCell!
    @IBOutlet var disclaimerCell: UITableViewCell!
    @IBOutlet var privacyPolicyCell: UITableViewCell!
    
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
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        
        self.contactCell.applyThemeEx(theme)
        self.reportBugCell.applyThemeEx(theme)
        self.disclaimerCell.applyThemeEx(theme)
        self.privacyPolicyCell.applyThemeEx(theme)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
