//
//  Navigator.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit

typealias AlertActionHandler = (UIAlertAction) -> Void

enum NavigationState {
}

protocol Navigator {
    func showAlert(title: String?, message: String?, actions: [(title: String?, style: UIAlertActionStyle, handler: AlertActionHandler?)])
    func showNetworkErrorAlert(cancelHandler: AlertActionHandler?, retryHandler: AlertActionHandler?)
    func showMaintenanceAlert(handler: AlertActionHandler?)
    
    func navigate(from: UIViewController, to: NavigationState, animated: Bool)
}

struct DefaultNavigator: Navigator {}

extension DefaultNavigator {
    func showAlert(title: String?, message: String?, actions: [(title: String?, style: UIAlertActionStyle, handler: AlertActionHandler?)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction(UIAlertAction(title: $0.title, style: $0.style, handler: $0.handler)) }
        
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let tabViewController = rootViewController as? UITabBarController {
            rootViewController = tabViewController.selectedViewController
        }
        if let navigationViewController = rootViewController as? UINavigationController {
            rootViewController = navigationViewController.visibleViewController
        }
        rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showNetworkErrorAlert(cancelHandler: AlertActionHandler?, retryHandler: AlertActionHandler?) {
        self.showAlert(title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", actions: [
            (title: "No", style: .cancel, handler: cancelHandler),
            (title: "Yes", style: .default, handler: retryHandler)
            ]
        )
    }
    
    func showMaintenanceAlert(handler: AlertActionHandler?) {
        self.showAlert(title: "Maintenance", message: "SWTOR.com is currently unavailable while scheduled maintenance is being performed.", actions: [
            (title: "OK", style: .default, handler: handler)
            ]
        )
    }
}

extension DefaultNavigator {
    func navigate(from: UIViewController, to: NavigationState, animated: Bool) {
        
    }
}
