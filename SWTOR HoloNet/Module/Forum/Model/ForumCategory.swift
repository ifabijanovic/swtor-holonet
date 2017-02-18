//
//  ForumCategory.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

struct ForumCategory: Entity {
    let id: Int
    var iconUrl: String?
    var title: String
    var desc: String?
    var stats: String?
    var lastPost: String?
    
    var hashValue: Int { return self.id.hashValue }
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}
