//
//  TabViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    // MARK: - Init
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        self.registerForNotifications()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.registerForNotifications()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.registerForNotifications()
    }
    
    // MARK: - Action dispatching
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchToTab:", name: SwitchToTabNotification, object: nil)
    }
    
    func switchToTab(notification: NSNotification) {
        // If there is no userInfo, return
        if notification.userInfo == nil { return }
        let userInfo = notification.userInfo!
        
        // If there is no index to switch to, or the index is invalid, return
        let index = userInfo["index"] as? Int
        if index == nil { return }
        if index < 0 { return }
        if index >= self.viewControllers?.count { return }
        
        // Get the view controller, it might be embedded inside a navigation controller
        var controller = self.viewControllers?[index!] as? UIViewController
        if let navController = controller as? UINavigationController {
            controller = navController.topViewController
        }
        
        // Perform the action
        if let actionPerformer = controller as? ActionPerformer {
            actionPerformer.perform(userInfo)
        }
        
        // Finally, select the tab
        self.selectedIndex = index!
    }
    
    // MARK: - UITabBarDelegate
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
#if !DEBUG && !TEST
        PFAnalytics.trackEvent("tab", dimensions: ["type": item.title!])
#endif
    }

}
