//
//  ForumCategory.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumCategory: Entity {
    
    // MARK: - Properties
    
    var iconUrl: String?
    var title: String
    var description: String?
    var stats: String?
    var lastPost: String?
    
    // MARK: - Init
    
    init(id: Int, title: String) {
        self.title = title
        super.init(id: id)
    }
    
}
