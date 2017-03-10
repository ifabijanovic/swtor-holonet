//
//  ForumModule.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Cleanse

struct ForumModule: Cleanse.Module {
    static func configure<B: Binder>(binder: B) {
        binder
            .bind(ForumParser.self)
            .to(factory: ForumParser.init)
        
        binder
            .bind(ForumCategoryRepository.self)
            .to(factory: DefaultForumCategoryRepository.init)
        
        binder
            .bind(ForumThreadRepository.self)
            .to(factory: DefaultForumThreadRepository.init)
        
        binder
            .bind(ForumPostRepository.self)
            .to(factory: DefaultForumPostRepository.init)
        
        binder
            .bind(ForumListCollectionViewController.self)
            .to { (repository: ForumCategoryRepository, toolbox: Toolbox) -> ForumListCollectionViewController in
                return ForumListCollectionViewController(categoryRepository: repository, toolbox: toolbox)
            }
        
        binder
            .bind(RootTabBarItem.self)
            .intoCollection()
            .to { (viewController: ForumListCollectionViewController) -> RootTabBarItem in
                viewController.tabBarItem = UITabBarItem(title: "Forum", image: UIImage(named: Constants.Images.Tabs.forum), selectedImage: nil)
                let navigationController = UINavigationController(rootViewController: viewController)
                return RootTabBarItem(viewController: navigationController, index: 0)
            }
    }
}
