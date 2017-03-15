//
//  RootViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RootViewController: UITabBarController {
    fileprivate let analytics: Analytics
    fileprivate let appActionQueue: AppActionQueue
    fileprivate let appUIFactory: AppUIFactory
    fileprivate let themeManager: ThemeManager
    fileprivate let settings: Settings
    
    fileprivate var disposeBag: DisposeBag
    
    fileprivate lazy var toolbox: Toolbox = {
        return Toolbox(analytics: self.analytics, navigator: self, themeManager: self.themeManager, settings: self.settings)
    }()
    
    required init(analytics: Analytics, appActionQueue: AppActionQueue, appUIFactory: AppUIFactory, themeManager: ThemeManager, settings: Settings) {
        self.analytics = analytics
        self.appActionQueue = appActionQueue
        self.appUIFactory = appUIFactory
        self.themeManager = themeManager
        self.settings = settings
        
        self.disposeBag = DisposeBag()
        
        super.init(nibName: nil, bundle: nil)
        
        let forumRootViewController = NavigationViewController(rootViewController: appUIFactory.forumFactory.categoriesViewController(toolbox: self.toolbox), toolbox: self.toolbox)
        forumRootViewController.tabBarItem = UITabBarItem(title: "Forum", image: UIImage(named: Constants.Images.Tabs.forum), selectedImage: nil)
        
        let dulfyRootViewController = NavigationViewController(rootViewController: appUIFactory.dulfyFactory.dulfyViewController(toolbox: self.toolbox), toolbox: self.toolbox)
        dulfyRootViewController.tabBarItem = UITabBarItem(title: "Dulfy", image: UIImage(named: Constants.Images.Tabs.dulfy), selectedImage: nil)
        
        let settingsRootViewController = NavigationViewController(rootViewController: appUIFactory.settingsFactory.settingsViewController(toolbox: self.toolbox), toolbox: self.toolbox)
        settingsRootViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: Constants.Images.Tabs.settings), selectedImage: nil)
        
        self.viewControllers = [forumRootViewController, dulfyRootViewController, settingsRootViewController]
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toolbox
            .theme
            .drive(onNext: self.apply(theme:))
            .disposed(by: self.disposeBag)
        
        self.appActionQueue
            .queue
            .drive(onNext: self.perform(appAction:))
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.analytics.track(event: Constants.Analytics.Event.tab, properties: [Constants.Analytics.Property.type: item.title!])
    }
}

// MARK: App action handling

extension RootViewController {
    func perform(appAction: AppAction) {
        switch appAction {
        case let .dulfy(message, url, applicationState):
            self.performDulfyAction(message: message, url: url, applicationState: applicationState)
        case let .switchTab(index):
            if index < 0 || index >= (self.viewControllers?.count ?? 0) { return }
            self.selectedIndex = index
        case .setUrl(_):
            break
        }
    }
    
    private func performDulfyAction(message: String, url: URL, applicationState: UIApplicationState) {
        if applicationState == .active {
            self.showAlert(title: "Dulfy", message: message, actions: [
                UIAlertAction(title: "Hide", style: .cancel, handler: nil),
                UIAlertAction(title: "View", style: .default, handler: { [unowned self] _ in
                    self.appActionQueue.enqueue(action: .switchTab(index: 1))
                    self.appActionQueue.enqueue(action: .setUrl(url: url))
                })
            ])
        } else {
            self.appActionQueue.enqueue(action: .switchTab(index: 1))
            self.appActionQueue.enqueue(action: .setUrl(url: url))
        }
    }
}

// MARK: Themeable

extension RootViewController: Themeable {
    func apply(theme: Theme) {
        theme.apply(tabBar: self.tabBar, animate: true)
    }
}

// MARK: Navigator

extension RootViewController: Navigator {
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNetworkErrorAlert(cancelHandler: AlertActionHandler?, retryHandler: AlertActionHandler?) {
        self.showAlert(title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", actions: [
            UIAlertAction(title: "No", style: .cancel, handler: cancelHandler),
            UIAlertAction(title: "Yes", style: .default, handler: retryHandler)
            ]
        )
    }
    
    func showMaintenanceAlert(handler: AlertActionHandler?) {
        self.showAlert(title: "Maintenance", message: "SWTOR.com is currently unavailable while scheduled maintenance is being performed.", actions: [
            UIAlertAction(title: "OK", style: .default, handler: handler)
            ]
        )
    }
    
    func navigate(from: UIViewController, to: AppScreen, animated: Bool) {
        switch to {
        case .forumCategory(let item):
            let successor = self.appUIFactory.forumFactory.subcategoryViewController(category: item, toolbox: self.toolbox)
            from.navigationController?.pushViewController(successor, animated: animated)
            break
        case .forumThread(let item):
            let successor = self.appUIFactory.forumFactory.threadViewController(thread: item, toolbox: self.toolbox)
            from.navigationController?.pushViewController(successor, animated: animated)
            break
        case .forumPost(let item):
            let successor = self.appUIFactory.forumFactory.postViewController(post: item, toolbox: self.toolbox)
            from.navigationController?.pushViewController(successor, animated: animated)
            break
        case .forumLanguageSettings:
            let successor = self.appUIFactory.forumFactory.forumLanguageSettingsViewController(toolbox: self.toolbox)
            from.navigationController?.pushViewController(successor, animated: animated)
            break
        case .themeSettings:
            let successor = self.appUIFactory.settingsFactory.themeSettingsViewController(toolbox: self.toolbox)
            from.navigationController?.pushViewController(successor, animated: animated)
            break
        case .textSizeSettings:
            let successor = self.appUIFactory.settingsFactory.textSizeSettingsViewController(toolbox: self.toolbox)
            from.navigationController?.pushViewController(successor, animated: animated)
            break
        case .text(let title, let path):
            let successor = self.appUIFactory.textViewController(title: title, path: path, toolbox: self.toolbox)
            from.navigationController?.pushViewController(successor, animated: animated)
            break
        }
    }
    
    func open(url: URL) {
        UIApplication.shared.openURL(url)
    }
}
