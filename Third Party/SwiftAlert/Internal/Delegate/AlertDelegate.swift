//
//  AlertDelegate.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 15/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

internal class AlertDelegate : DelegateBase, UIAlertViewDelegate {
    
    // MARK: - Init
    
    init(alertView: UIAlertView, cb: @escaping (Int) -> ()) {
        super.init(cb: cb)
        alertView.delegate = self
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        alertView.delegate = nil
        self.finish(index: buttonIndex)
    }
    
}
