//
//  TestAlertFactory.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 16/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TestAlertFactory: AlertFactory {

    // MARK: - Public methods
    
    func createActionSheet(presenter: UIViewController, title: String, buttons: (style: UIAlertActionStyle, title: String, handler: (() -> ())?)...) -> Alert {
        return TestAlert(presenter: presenter, title: title, buttons: buttons)
    }
    
    func createAlert(presenter: UIViewController, title: String, message: String, buttons: (style: UIAlertActionStyle, title: String, handler: (() -> ())?)...) -> Alert {
        return TestAlert(presenter: presenter, title: title, message: message, buttons: buttons)
    }
    
}
