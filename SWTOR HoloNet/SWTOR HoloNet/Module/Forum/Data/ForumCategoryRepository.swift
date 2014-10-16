//
//  ForumCategoryRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumCategoryRepository {
    
    // MARK: - Properties
    
    private let rootUrl: String
    
    // MARK: - Init
    
    init(rootUrl: String) {
        self.rootUrl = rootUrl
    }
    
    // MARK: - Public methods
    
    func get(#language: ForumLanguage, success: ((Array<ForumCategory>) -> Void), error: ((NSError) -> Void)) {
        
    }
    
    func get(category: ForumCategory, success: ((Array<ForumCategory>) -> Void), error: ((NSError) -> Void)) {
        
    }
    
    // MARK: - Private methods
    
    private func parseHtml(html: String) -> Array<ForumCategory> {
        return Array<ForumCategory>()
    }
    
}
