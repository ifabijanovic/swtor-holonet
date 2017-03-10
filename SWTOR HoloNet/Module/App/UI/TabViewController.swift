//
//  TabViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabViewController: UITabBarController, Themeable {
    private let toolbox: Toolbox
    private var disposeBag: DisposeBag
    private let pushManager: PushManager
    
    required init(toolbox: Toolbox, pushManager: PushManager) {
        self.toolbox = toolbox
        self.disposeBag = DisposeBag()
        self.pushManager = pushManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupTabs()
        self.registerForNotifications()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toolbox
            .theme
            .drive(onNext: self.apply(theme:))
            .addDisposableTo(self.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    // MARK: -
    
    private func setupTabs() {
        // Forum
        let forumCategoryRepository = DefaultForumCategoryRepository(settings: self.toolbox.settings)
        let forumViewController = NavigationViewController(toolbox: self.toolbox, rootViewController: ForumListCollectionViewController(categoryRepository: forumCategoryRepository, toolbox: self.toolbox))
        forumViewController.tabBarItem = UITabBarItem(title: "Forum", image: UIImage(named: Constants.Images.Tabs.forum), selectedImage: nil)
        
        // Dulfy
        let dulfyViewController = NavigationViewController(toolbox: self.toolbox, rootViewController: DulfyViewController(toolbox: self.toolbox))
        dulfyViewController.tabBarItem = UITabBarItem(title: "Dulfy", image: UIImage(named: Constants.Images.Tabs.dulfy), selectedImage: nil)
        
        // Settings
        let settingsViewController = NavigationViewController(toolbox: self.toolbox, rootViewController: SettingsTableViewController(pushManager: self.pushManager, toolbox: self.toolbox, style: .grouped))
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: Constants.Images.Tabs.settings), selectedImage: nil)
        
        self.viewControllers = [forumViewController, dulfyViewController, settingsViewController]
    }
    
    // MARK: -
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.switchToTab(notification:)), name: NSNotification.Name(Constants.Notifications.switchToTab), object: nil)
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
    
    func apply(theme: Theme) {
        theme.apply(tabBar: self.tabBar, animate: true)
    }
    
    // MARK: -
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.toolbox.analytics.track(event: Constants.Analytics.Event.tab, properties: [Constants.Analytics.Property.type: item.title!])
    }
}
