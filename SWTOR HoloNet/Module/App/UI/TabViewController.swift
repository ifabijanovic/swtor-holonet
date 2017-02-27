//
//  TabViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    private let services: StandardServices
    private let pushManager: PushManager
    
    required init(services: StandardServices, pushManager: PushManager) {
        self.services = services
        self.pushManager = pushManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupTabs()
        self.registerForNotifications()
    }
    
    @available(*, unavailable)
    init() { fatalError() }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { fatalError() }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: -
    
    private func setupTabs() {
        // Forum
        let forumCategoryRepository = DefaultForumCategoryRepository(settings: self.services.settings)
        let forumViewController = NavigationViewController(rootViewController: ForumListCollectionViewController(categoryRepository: forumCategoryRepository, services: self.services))
        forumViewController.tabBarItem = UITabBarItem(title: "Forum", image: UIImage(named: Constants.Images.Tabs.forum), selectedImage: nil)
        
        // Dulfy
        let dulfyViewController = NavigationViewController(rootViewController: DulfyViewController(services: self.services))
        dulfyViewController.tabBarItem = UITabBarItem(title: "Dulfy", image: UIImage(named: Constants.Images.Tabs.dulfy), selectedImage: nil)
        
        // Settings
        let settingsViewController = NavigationViewController(rootViewController: SettingsTableViewController(pushManager: self.pushManager, services: self.services, style: .grouped))
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: Constants.Images.Tabs.settings), selectedImage: nil)
        
        self.viewControllers = [forumViewController, dulfyViewController, settingsViewController]
    }
    
    // MARK: -
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.switchToTab(notification:)), name: NSNotification.Name(Constants.Notifications.switchToTab), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.themeChanged(notification:)), name: NSNotification.Name(Constants.Notifications.themeChanged), object: nil)
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
            actionPerformer.perform(userInfo: userInfo)
        }
        
        // Finally, select the tab
        self.selectedIndex = index
    }
    
    func themeChanged(notification: NSNotification) {
        if let theme = notification.userInfo?[Constants.Notifications.UserInfo.theme] as? Theme {
            theme.apply(tabBar: self.tabBar, animate: true)
        }
    }
    
    // MARK: -
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.services.analytics.track(event: Constants.Analytics.Event.tab, properties: [Constants.Analytics.Property.type: item.title!])
    }
}
