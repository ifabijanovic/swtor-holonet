//
//  ForumPost.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumPost {
    
    // MARK: - Properties
    
    var id: Int
    var avatarUrl: String?
    var username: String
    var date: String
    var isBiowarePost: Bool
    var text: String
    var signature: String?
    
    // MARK: - Init
    
    init(id: Int, username: String, date: String, isBiowarePost: Bool, text: String) {
        self.id = id
        self.username = username
        self.date = date
        self.isBiowarePost = isBiowarePost
        self.text = text
    }
   
}
