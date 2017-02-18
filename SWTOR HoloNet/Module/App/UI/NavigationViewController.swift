//
//  NavigationViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    // MARK: - Init
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        self.registerForNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.registerForNotifications()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.registerForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action dispatching
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(NavigationViewController.themeChanged(notification:)), name: NSNotification.Name(Constants.Notifications.themeChanged), object: nil)
    }
    
    func themeChanged(notification: NSNotification) {
        if let theme = notification.userInfo?["theme"] as? Theme {
            // Only animate the transition if current view is visible
            let animate = self.isViewLoaded && self.view.window != nil
            theme.apply(navigationBar: self.navigationBar, animate: animate)
        }
    }

}
