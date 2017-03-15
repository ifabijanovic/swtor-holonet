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
        binder.bind(ForumParser.self).to(factory: ForumParser.init)        
        binder.bind(ForumCategoryRepository.self).to(factory: DefaultForumCategoryRepository.init)
        binder.bind(ForumThreadRepository.self).to(factory: DefaultForumThreadRepository.init)
        binder.bind(ForumPostRepository.self).to(factory: DefaultForumPostRepository.init)
        
        binder.bind(ForumLanguageManager.self).asSingleton().to(factory: DefaultForumLanguageManager.init)
        
        binder.bind(ForumUIFactory.self).to(factory: DefaultForumUIFactory.init)
    }
}

protocol ForumUIFactory {
    func categoriesViewController(toolbox: Toolbox) -> UIViewController
    func subcategoryViewController(category: ForumCategory, toolbox: Toolbox) -> UIViewController
    func threadViewController(thread: ForumThread, toolbox: Toolbox) -> UIViewController
    func postViewController(post: ForumPost, toolbox: Toolbox) -> UIViewController
}

fileprivate struct DefaultForumUIFactory: ForumUIFactory {
    private let categoryRepository: ForumCategoryRepository
    private let threadRepository: ForumThreadRepository
    private let postRepository: ForumPostRepository
    
    private let languageManager: ForumLanguageManager
    
    init(categoryRepository: ForumCategoryRepository, threadRepository: ForumThreadRepository, postRepository: ForumPostRepository, languageManager: ForumLanguageManager) {
        self.categoryRepository = categoryRepository
        self.threadRepository = threadRepository
        self.postRepository = postRepository
        
        self.languageManager = languageManager
    }
    
    func categoriesViewController(toolbox: Toolbox) -> UIViewController {
        return ForumListCollectionViewController(categoryRepository: self.categoryRepository, language: self.languageManager.language, toolbox: toolbox)
    }
    
    func subcategoryViewController(category: ForumCategory, toolbox: Toolbox) -> UIViewController {
        return ForumListCollectionViewController(category: category, categoryRepository: self.categoryRepository, threadRepository: self.threadRepository, language: self.languageManager.language, toolbox: toolbox)
    }
    
    func threadViewController(thread: ForumThread, toolbox: Toolbox) -> UIViewController {
        return ForumThreadCollectionViewController(thread: thread, postRepository: self.postRepository, language: self.languageManager.language, toolbox: toolbox)
    }
    
    func postViewController(post: ForumPost, toolbox: Toolbox) -> UIViewController {
        return ForumPostViewController(post: post, toolbox: toolbox)
    }
}
