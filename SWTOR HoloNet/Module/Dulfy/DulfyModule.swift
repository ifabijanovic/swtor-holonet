//
//  DulfyModule.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Cleanse

struct DulfyModule: Cleanse.Module {
    static func configure<B: Binder>(binder: B) {
        binder
            .bind(DulfyViewController.self)
            .to(factory: DulfyViewController.init)
        
        binder
            .bind(RootTabBarItem.self)
            .intoCollection()
            .to { (viewController: DulfyViewController) -> RootTabBarItem in
                viewController.tabBarItem = UITabBarItem(title: "Dulfy", image: UIImage(named: Constants.Images.Tabs.dulfy), selectedImage: nil)
                let navigationController = UINavigationController(rootViewController: viewController)
                return RootTabBarItem(viewController: navigationController, index: 1)
            }
    }
}
