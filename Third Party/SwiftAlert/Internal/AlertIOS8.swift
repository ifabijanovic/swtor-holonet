//
//  AlertIOS8.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 15/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

internal class AlertIOS8: Alert {
    
    // MARK: - Public methods
    
    override func show() {
        let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: self.style)
        for button in self.buttons {
            let action = UIAlertAction(title: button.title, style: button.style) { (this: UIAlertAction!) in
                if let completion = self.completion { completion() }
                if let handler = button.handler { handler() }
            }
            alertController.addAction(action)
        }
        if let sourceView = sourceView {
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.sourceView = sourceView
                popoverPresentationController.sourceRect = sourceView.bounds
            }
        }
        
        self.presenter.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
