//
//  AlertFactory.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 15/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

protocol AlertFactory {
    
    // MARK: - Methods
    
    func createActionSheet(presenter: UIViewController, title: String, buttons: (style: UIAlertActionStyle, title: String, handler:(() -> ())?)...) -> Alert
    
    func createAlert(presenter: UIViewController, title: String, message: String, buttons: (style: UIAlertActionStyle, title: String, handler:(() -> ())?)...) -> Alert
    
}
