//
//  TestNavigator.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 12/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TestNavigator: Navigator {
    var didShowAlert = false
    var alertTitle: String?
    var alertMessage: String?
    var alertActions: [UIAlertAction]?
    
    var didNavigate = false
    var navigatedFrom: UIViewController?
    var navigatedTo: AppScreen?
    
    var didOpenUrl = false
    var openedUrl: URL?
    
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        self.didShowAlert = true
        self.alertTitle = title
        self.alertMessage = message
        self.alertActions = actions
    }
    
    func showNetworkErrorAlert(cancelHandler: AlertActionHandler?, retryHandler: AlertActionHandler?) {
        self.didShowAlert = true
    }
    
    func showMaintenanceAlert(handler: AlertActionHandler?) {
        self.didShowAlert = true
    }
    
    func navigate(from: UIViewController, to: AppScreen, animated: Bool) {
        self.didNavigate = true
        self.navigatedFrom = from
        self.navigatedTo = to
    }
    
    func open(url: URL) {
        self.didOpenUrl = true
        self.openedUrl = url
    }
}

extension TestNavigator {
    typealias UIAlertHandler = @convention(block) (UIAlertAction) -> Void
    
    func tap(style: UIAlertActionStyle) {
        guard let action = self.alertActions?.filter({ $0.style == style }).first else { return }
        
        if let block = action.value(forKey: "handler") {
            let pointer = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(block as AnyObject).toOpaque())
            let handler = unsafeBitCast(pointer, to: UIAlertHandler.self)
            handler(action)
        }
    }
}
