//
//  TestAlertFactory.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 16/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TestAlertFactory: AlertFactory {

    var lastAlert: TestAlert? = nil
    
    // MARK: - Public methods
    
    func createActionSheet(presenter: UIViewController, title: String, buttons: (style: UIAlertActionStyle, title: String, handler: (() -> ())?)...) -> Alert {
        let alert = TestAlert(presenter: presenter, title: title, buttons: buttons)
        self.lastAlert = alert
        return alert
    }
    
    func createAlert(presenter: UIViewController, title: String, message: String, buttons: (style: UIAlertActionStyle, title: String, handler: (() -> ())?)...) -> Alert {
        let alert = TestAlert(presenter: presenter, title: title, message: message, buttons: buttons)
        self.lastAlert = alert
        return alert
    }
    
}
