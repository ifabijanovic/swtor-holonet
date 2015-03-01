//
//  AlertIOS7.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 15/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

internal class AlertIOS7: Alert {
    
    // MARK: - Public methods
    
    override func show() {
        switch self.style {
        case .ActionSheet:
            self.showActionSheet()
        case .Alert:
            self.showAlert()
        }
    }
    
    // MARK: - Private methods
    
    private func showActionSheet() {
        let actionSheet = UIActionSheet()
        
        if let title = self.title {
            actionSheet.title = title
        }
        
        for button in self.buttons {
            actionSheet.addButtonWithTitle(button.title)
            switch button.style {
            case .Default:
                break
            case .Cancel:
                actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1
            case .Destructive:
                actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1
            }
        }
        
        ActionSheetDelegate(actionSheet: actionSheet) { (index: Int) in
            if let completion = self.completion { completion() }
            if let handler = self.buttons[index].handler { handler() }
        }
        
        if let sourceView = self.sourceView {
            actionSheet.showFromRect(sourceView.bounds, inView: sourceView, animated: true)
        } else {
            actionSheet.showInView(self.presenter.view)
        }
    }
    
    private func showAlert() {
        let alertView = UIAlertView()
        
        if let title = self.title {
            alertView.title = title
        }
        
        if let message = self.message {
            alertView.message = message
        }
        
        for button in self.buttons {
            alertView.addButtonWithTitle(button.title)
            switch button.style {
            case .Cancel:
                alertView.cancelButtonIndex = alertView.numberOfButtons - 1
            default:
                break
            }
        }
        
        AlertDelegate(alertView: alertView) { (index: Int) in
            if let completion = self.completion { completion() }
            if let handler = self.buttons[index].handler { handler() }
        }
        
        alertView.show()
    }
    
}
