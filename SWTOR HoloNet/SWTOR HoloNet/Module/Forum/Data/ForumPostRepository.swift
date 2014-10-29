//
//  ForumPostRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumPostRepository {
    
    // MARK: - Properties
    
    private let settings: Settings
    private let parser: ForumParser
    
    // MARK: - Init
    
    init(settings: Settings) {
        self.settings = settings
        self.parser = ForumParser()
    }
    
    // MARK: - Public methods
    
    func get(#thread: ForumThread, page: Int, success: ((Array<ForumPost>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: thread.id, page: page, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(#id: Int, page: Int, success: ((Array<ForumPost>) -> Void), failure: ((NSError) -> Void)) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let url = "\(self.settings.threadDisplayUrl)?\(self.settings.threadQueryParam)=\(id)&\(self.settings.pageQueryParam)=\(page)"
        manager.GET(url, parameters: nil, success: { (operation, response) in
            let html = operation.responseString
            let items = self.parseHtml(html)
            success(items)
        }) { (operation, error) in
                failure(error)
        }
    }
    
    // MARK: - Parsing
    
    private func parseHtml(html: String) -> Array<ForumPost> {
        var items = Array<ForumPost>()
        
        let document = HTMLDocument(string: html)
        let threadNodes = document.nodesMatchingSelector("#posts > div") as Array<HTMLElement>
        
        for node in threadNodes {
            let thread = self.parsePost(node)
            if thread != nil {
                items.append(thread!)
            }
        }
        
        return items
    }
    
    private func parsePost(element: HTMLElement) -> ForumPost? {
        // Id
        let id = self.parser.linkParameter(linkElement: element.firstNodeMatchingSelector(".tinySubmitBtn"), name: "p")?.toInt()
        
        // Avatar url
        var avatarUrl: String? = nil
        if let avatarElement = element.firstNodeMatchingSelector(".avatar img") {
            avatarUrl = avatarElement.objectForKeyedSubscript("src") as? String
        }
        
        // Username
        let username = element.firstNodeMatchingSelector(".avatar > .resultCategory > a")?.textContent
        
        // Date & Post number
        let dateElement = (element.nodesMatchingSelector(".post .threadDate") as Array<HTMLElement>).last
        let date = self.parser.postDate(element: dateElement)
        let postNumber = self.parser.postNumber(element: dateElement)
        
        // Is Bioware post
        let isBiowarePost = element.firstNodeMatchingSelector(".post .forumPadding > .resultText > font") != nil
        
        // Text
        let text = element.firstNodeMatchingSelector(".post .forumPadding > .resultText")?.textContent
        
        // Signature
        let lastPostRow = (element.nodesMatchingSelector(".post tr") as Array<HTMLElement>).last
        let signature = lastPostRow?.firstNodeMatchingSelector(".resultText")?.textContent
        
        if id == nil { return nil }
        if username == nil { return nil }
        if date == nil { return nil }
        if postNumber == nil { return nil }
        if text == nil { return nil }
        
        let post = ForumPost(id: id!, username: username!, date: date!, postNumber: postNumber!, isBiowarePost: isBiowarePost, text: text!)
        post.avatarUrl = avatarUrl
        post.signature = signature
        
        return post
    }

    
}
