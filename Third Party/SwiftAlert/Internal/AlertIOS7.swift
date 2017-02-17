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
        case .actionSheet:
            self.showActionSheet()
        case .alert:
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
            actionSheet.addButton(withTitle: button.title)
            switch button.style {
            case .default:
                break
            case .cancel:
                actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1
            case .destructive:
                actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1
            }
        }
        
        _ = ActionSheetDelegate(actionSheet: actionSheet) { (index: Int) in
            if let completion = self.completion { completion() }
            if let handler = self.buttons[index].handler { handler() }
        }
        
        if let sourceView = self.sourceView {
            actionSheet.show(from: sourceView.bounds, in: sourceView, animated: true)
        } else {
            actionSheet.show(in: self.presenter.view)
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
            alertView.addButton(withTitle: button.title)
            switch button.style {
            case .cancel:
                alertView.cancelButtonIndex = alertView.numberOfButtons - 1
            default:
                break
            }
        }
        
        _ = AlertDelegate(alertView: alertView) { (index: Int) in
            if let completion = self.completion { completion() }
            if let handler = self.buttons[index].handler { handler() }
        }
        
        alertView.show()
    }
    
}
