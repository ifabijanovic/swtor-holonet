//
//  ForumThread.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

struct ForumThread: Entity {
    let id: Int
    var title: String
    var lastPostDate: String
    var author: String
    var replies: Int
    var views: Int
    var hasBiowareReply: Bool
    var isSticky: Bool
    
    var isDevTracker: Bool
    
    var hashValue: Int { return self.id.hashValue }
    
    init(id: Int, title: String, lastPostDate: String, author: String, replies: Int, views: Int, hasBiowareReply: Bool, isSticky: Bool) {
        self.id = id
        self.title = title
        self.lastPostDate = lastPostDate
        self.author = author
        self.replies = replies
        self.views = views
        self.hasBiowareReply = hasBiowareReply
        self.isSticky = isSticky
        self.isDevTracker = false
    }
    
    init(id: Int, title: String, lastPostDate: String, author: String, replies: Int, views: Int) {
        self.init(id: id, title: title, lastPostDate: lastPostDate, author: author, replies: replies, views: views, hasBiowareReply: false, isSticky: false)
    }
    
    static func devTracker() -> ForumThread {
        var thread = ForumThread(id: 0, title: "Developer Tracker", lastPostDate: "", author: "", replies: 0, views: 0)
        thread.isDevTracker = true
        return thread
    }
}
