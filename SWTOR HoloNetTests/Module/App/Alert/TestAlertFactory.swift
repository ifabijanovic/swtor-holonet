//
//  TestFactoryMock.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TestAlertFactory {
    fileprivate(set) var lastAlert: UIAlertController? = nil
    fileprivate(set) var lastAlertActions: [(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?)] = []
    
    func tapCancel() {
        self.tap(style: .cancel)
    }
    
    func tapDefault() {
        self.tap(style: .default)
    }
    
    func tapDestructive() {
        self.tap(style: .destructive)
    }
    
    private func tap(style: UIAlertActionStyle) {
        guard let action = self.lastAlertActions.filter({ $0.style == style }).first else { return }
        action.handler?(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
    }
}

extension TestAlertFactory: UIAlertFactory {
    func alert(title: String?, message: String?, actions: [(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?)]) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        self.lastAlert = alertController
        self.lastAlertActions = actions
        return alertController
    }
}
