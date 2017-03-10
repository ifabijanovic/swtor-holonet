//
//  SettingsModule.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Cleanse

struct SettingsModule: Cleanse.Module {
    static func configure<B: Binder>(binder: B) {
        binder
            .bind(SettingsTableViewController.self)
            .to(factory: SettingsTableViewController.init)
        
        binder
            .bind(RootTabBarItem.self)
            .intoCollection()
            .to { (viewController: SettingsTableViewController) -> RootTabBarItem in
                viewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: Constants.Images.Tabs.settings), selectedImage: nil)
                let navigationController = UINavigationController(rootViewController: viewController)
                return RootTabBarItem(viewController: navigationController, index: 2)
            }
    }
}
