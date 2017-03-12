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
    func showAlert(title: String?, message: String?, actions: [UIAlertAction])
    func showNotification(userInfo: [AnyHashable: Any])
    func showNetworkErrorAlert(cancelHandler: AlertActionHandler?, retryHandler: AlertActionHandler?)
    func showMaintenanceAlert(handler: AlertActionHandler?)
    
    func navigate(from: UIViewController, to: NavigationState, animated: Bool)
    func open(url: URL)
}
