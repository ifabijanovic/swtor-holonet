//
//  ForumThread.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThread: Entity {
    
    // MARK: - Properties
    
    var title: String
    var lastPostDate: String
    var author: String
    var replies: Int
    var views: Int
    var hasBiowareReply: Bool
    var isSticky: Bool
    
    // MARK: - Init
    
    init(id: Int, title: String, lastPostDate: String, author: String, replies: Int, views: Int, hasBiowareReply: Bool, isSticky: Bool) {
        self.title = title
        self.lastPostDate = lastPostDate
        self.author = author
        self.replies = replies
        self.views = views
        self.hasBiowareReply = hasBiowareReply
        self.isSticky = isSticky
        super.init(id: id)
    }
    
    convenience init(id: Int, title: String, lastPostDate: String, author: String, replies: Int, views: Int) {
        self.init(id: id, title: title, lastPostDate: lastPostDate, author: author, replies: replies, views: views, hasBiowareReply: false, isSticky: false)
    }
   
}
