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
    case forumCategory(item: ForumCategory)
    case forumThread(item: ForumThread)
    case forumPost(item: ForumPost)
    case themeSettings
    case textSizeSettings
    case text(title: String, path: String)
}

protocol Navigator {
    func showAlert(title: String?, message: String?, actions: [(title: String?, style: UIAlertActionStyle, handler: AlertActionHandler?)])
    func showNetworkErrorAlert(cancelHandler: AlertActionHandler?, retryHandler: AlertActionHandler?)
    func showMaintenanceAlert(handler: AlertActionHandler?)
    
    func navigate(from: UIViewController, to: NavigationState, animated: Bool)
    func open(url: URL)
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
        switch to {
        case .forumCategory(let item):
            self.navigate(from: from, to: item, animated: animated)
            break
        case .forumThread(let item):
            self.navigate(from: from, to: item, animated: animated)
            break
        case .forumPost(let item):
            self.navigate(from: from, to: item, animated: animated)
            break
        case .themeSettings:
            self.navigateToThemeSettings(from: from, animated: animated)
            break
        case .textSizeSettings:
            self.navigateToTextSizeSettings(from: from, animated: animated)
            break
        case .text(let title, let path):
            self.navigate(from: from, textTitle: title, textPath: path, animated: animated)
            break
        }
    }
    
    func open(url: URL) {
        UIApplication.shared.openURL(url)
    }
    
    private func navigate(from: UIViewController, to forumCategory: ForumCategory, animated: Bool) {
        guard from is ForumListCollectionViewController else {
            assert(false, "Navigating to forumCategory from invalid predecessor")
            return
        }
        
        let categoryRepository = DefaultForumCategoryRepository(settings: InstanceHolder.sharedInstance.settings)
        let threadRepository = DefaultForumThreadRepository(settings: InstanceHolder.sharedInstance.settings)
        let successor = ForumListCollectionViewController(category: forumCategory, categoryRepository: categoryRepository, threadRepository: threadRepository, services: StandardServices.instance)
        from.navigationController?.pushViewController(successor, animated: animated)
    }
    
    private func navigate(from: UIViewController, to forumThread: ForumThread, animated: Bool) {
        guard from is ForumListCollectionViewController else {
            assert(false, "Navigating to forumThread from invalid predecessor")
            return
        }
        
        let postRepository = DefaultForumPostRepository(settings: InstanceHolder.sharedInstance.settings)
        let successor = ForumThreadCollectionViewController(thread: forumThread, postRepository: postRepository, services: StandardServices.instance)
        from.navigationController?.pushViewController(successor, animated: animated)
    }
    
    private func navigate(from: UIViewController, to forumPost: ForumPost, animated: Bool) {
        guard from is ForumThreadCollectionViewController else {
            assert(false, "Navigating to forumPost from invalid predecessor")
            return
        }
        
        let successor = ForumPostViewController(post: forumPost)
        from.navigationController?.pushViewController(successor, animated: animated)
    }
    
    private func navigateToThemeSettings(from: UIViewController, animated: Bool) {
        guard from is SettingsTableViewController else {
            assert(false, "Navigating to themeSettings from invalid predecessor")
            return
        }
        
        let successor = ThemeSettingsTableViewController(themeManager: DefaultThemeManager.instance, services: StandardServices.instance)
        from.navigationController?.pushViewController(successor, animated: animated)
    }
    
    private func navigateToTextSizeSettings(from: UIViewController, animated: Bool) {
        guard from is SettingsTableViewController else {
            assert(false, "Navigating to textSizeSettings from invalid predecessor")
            return
        }
        
        let successor = TextSizeSettingsTableViewController(themeManager: DefaultThemeManager.instance, services: StandardServices.instance)
        from.navigationController?.pushViewController(successor, animated: animated)
    }
    
    private func navigate(from: UIViewController, textTitle: String, textPath: String, animated: Bool) {
        let successor = TextViewController()
        successor.title = textTitle
        successor.file = textPath
        from.navigationController?.pushViewController(successor, animated: animated)
    }
}
