//
//  TestAlert.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 16/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TestAlert: Alert {
   
    // MARK: - Public methods
    
    func tapDefault() {
        self.fireButtonHandlerWithStyle(.default)
    }
    
    func tapCancel() {
        self.fireButtonHandlerWithStyle(.cancel)
    }
    
    func tapDestructive() {
        self.fireButtonHandlerWithStyle(.destructive)
    }
    
    func tapButtonAtIndex(index: Int) {
        if index < self.buttons.count {
            let button = self.buttons[index]
            if let handler = button.handler {
                handler()
            }
        }
    }
    
    // MARK: - Private methods
    
    func fireButtonHandlerWithStyle(_ style: UIAlertActionStyle) {
        for button in buttons {
            if button.style == style {
                if let handler = button.handler {
                    handler()
                }
            }
        }
    }
    
}
