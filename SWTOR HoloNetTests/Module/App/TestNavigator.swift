//
//  TestNavigator.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 27/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import UIKit

class TestNavigator: Navigator {
    private(set) var didShowAlert = false
    private(set) var navigatedFrom: UIViewController?
    private(set) var navigatedTo: NavigationState?
    private(set) var openedUrl: URL?
    
    fileprivate var alertActions: [UIAlertActionStyle: AlertActionHandler] = [:]
    
    func showAlert(title: String?, message: String?, actions: [(title: String?, style: UIAlertActionStyle, handler: AlertActionHandler?)]) {
        self.didShowAlert = true
        self.alertActions = [:]
        actions.forEach { self.alertActions[$0.style] = $0.handler }
    }
    
    func showNotification(userInfo: [AnyHashable : Any]) {
        guard ActionParser(userInfo: userInfo).alert != nil else { return }
        self.didShowAlert = true
    }
    
    func showNetworkErrorAlert(cancelHandler: AlertActionHandler?, retryHandler: AlertActionHandler?) {
        self.showAlert(title: nil, message: nil, actions: [
            (title: "", style: .cancel, handler: cancelHandler),
            (title: "", style: .default, handler: retryHandler)
            ]
        )
    }
    
    func showMaintenanceAlert(handler: AlertActionHandler?) {
        self.showAlert(title: nil, message: nil, actions: [
            (title: "", style: .default, handler: handler)
            ]
        )
    }
    
    func navigate(from: UIViewController, to: NavigationState, animated: Bool) {
        self.navigatedFrom = from
        self.navigatedTo = to
    }
    
    func open(url: URL) {
        self.openedUrl = url
    }
}

extension TestNavigator {
    func tap(style: UIAlertActionStyle) {
        self.alertActions[style]?(UIAlertAction(title: "", style: style, handler: nil))
    }
}
