//
//  Alert.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 15/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class Alert: NSObject {
    
    // MARK: - Properties
    
    var presenter: UIViewController
    var style: UIAlertControllerStyle
    var sourceView: UIView?
    
    var title: String?
    var message: String?
    
    // MARK: - Callbacks
    
    var completion: (() -> ())?
    var buttons: Array<(style: UIAlertActionStyle, title: String, handler:(() -> ())?)>
    
    // MARK: - Init
    
    init(presenter: UIViewController, buttons: Array<(style: UIAlertActionStyle, title: String, handler:(() -> ())?)>) {
        self.presenter = presenter
        self.style = .Alert
        self.buttons = buttons
    }
    
    convenience init(presenter: UIViewController, title: String, buttons: Array<(style: UIAlertActionStyle, title: String, handler:(() -> ())?)>) {
        self.init(presenter: presenter, buttons: buttons)
        
        self.style = .ActionSheet
        self.title = title
    }

    
    convenience init(presenter: UIViewController, title: String, message: String, buttons: Array<(style: UIAlertActionStyle, title: String, handler:(() -> ())?)>) {
        self.init(presenter: presenter, buttons: buttons)
        
        self.title = title
        self.message = message
    }
    
    // MARK: - Public methods
    
    func show() {}
    
}
