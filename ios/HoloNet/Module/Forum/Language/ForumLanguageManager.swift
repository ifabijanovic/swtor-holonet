//
//  ForumLanguageManager.swift
//  HoloNet
//
//  Created by Ivan Fabijanovic on 15/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ForumLanguageManager {
    var language: Driver<ForumLanguage> { get }
    func set(language: ForumLanguage)
}

struct DefaultForumLanguageManager: ForumLanguageManager {
    let language: Driver<ForumLanguage>
    
    init() {
        self.language = UserDefaults.standard
            .rx
            .observe(String.self, Keys.forumLanguage)
            .map { ForumLanguage(rawValue: $0 ?? "") ?? .english }
            .distinctUntilChanged()
            .asDriverIgnoringErrors()
    }
    
    func set(language: ForumLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: Keys.forumLanguage)
    }
}

fileprivate struct Keys {
    static let forumLanguage = "forumLanguage"
}
