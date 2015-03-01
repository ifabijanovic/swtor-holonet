//
//  ActionSheetDelegate.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 15/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

internal class ActionSheetDelegate : DelegateBase, UIActionSheetDelegate {
    
    // MARK: - Init
    
    init(actionSheet: UIActionSheet, cb: (Int) -> ()) {
        super.init(cb: cb)
        actionSheet.delegate = self
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        actionSheet.delegate = nil
        self.finish(buttonIndex)
    }
    
}
