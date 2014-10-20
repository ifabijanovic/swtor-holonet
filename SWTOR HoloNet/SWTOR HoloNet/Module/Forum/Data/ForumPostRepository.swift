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
    
    private let rootUrl: String
    private var cache: Dictionary<Int, Array<ForumPost>>
    private let parser: ForumParser
    
    var useCache: Bool
    
    // MARK: - Init
    
    init(rootUrl: String) {
        self.rootUrl = rootUrl
        self.cache = Dictionary<Int, Array<ForumPost>>()
        self.parser = ForumParser()
        
        self.useCache = true
    }
    
    // MARK: - Public methods
    
    func get(#thread: ForumThread, success: ((Array<ForumPost>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: thread.id, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(#id: Int, success: ((Array<ForumPost>) -> Void), failure: ((NSError) -> Void)) {
        // Cache
        if useCache {
            if let data = self.cache[id] {
                success(data)
                return
            }
        }
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let url = "\(self.rootUrl)?t=\(id)"
        manager.GET(url, parameters: nil, success: { (operation, response) in
            let html = operation.responseString
            let items = self.parseHtml(html)
            if self.useCache {
                self.cache[id] = items
            }
            
            success(items)
            }) { (operation, error) in
                failure(error)
        }
    }
    
    // MARK: - Caching
    
    func clear() {
        self.cache.removeAll(keepCapacity: false)
    }
    
    func clear(#category: ForumCategory) {
        self.cache[category.id] = nil
    }
    
    // MARK: - Parsing
    
    private func parseHtml(html: String) -> Array<ForumPost> {
        var items = Array<ForumPost>()
        
        let document = HTMLDocument(string: html)
        let threadNodes = document.nodesMatchingSelector("#posts > div") as Array<HTMLElement>
        
        for node in threadNodes {
            let thread = self.parseThread(node)
            if thread != nil {
                items.append(thread!)
            }
        }
        
        return items
    }
    
    private func parseThread(element: HTMLElement) -> ForumPost? {
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
