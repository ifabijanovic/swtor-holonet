//
//  TabViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    private let analytics: Analytics = DefaultAnalytics()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.switchToTab(notification:)), name: NSNotification.Name(rawValue: SwitchToTabNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.themeChanged(notification:)), name: NSNotification.Name(rawValue: ThemeChangedNotification), object: nil)
    }
    
    func switchToTab(notification: NSNotification) {
        // If there is no userInfo, return
        if notification.userInfo == nil { return }
        let userInfo = notification.userInfo!
        
        // If there is no index to switch to, or the index is invalid, return
        guard let index = userInfo["index"] as? Int else { return }
        if index < 0 { return }
        if index >= self.viewControllers?.count ?? -1 { return }
        
        // Get the view controller, it might be embedded inside a navigation controller
        var controller = self.viewControllers?[index]
        if let navController = controller as? UINavigationController {
            controller = navController.topViewController
        }
        
        // Perform the action
        if let actionPerformer = controller as? ActionPerformer {
            actionPerformer.perform(userInfo)
        }
        
        // Finally, select the tab
        self.selectedIndex = index
    }
    
    func themeChanged(notification: NSNotification) {
        if let theme = notification.userInfo?["theme"] as? Theme {
            theme.apply(tabBar: self.tabBar, animate: true)
        }
    }
    
    // MARK: - UITabBarDelegate
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
#if !DEBUG && !TEST
    self.analytics.track(event: Constants.Analytics.Event.tab, properties: [Constants.Analytics.Property.type: item.title!])
#endif
    }

}
