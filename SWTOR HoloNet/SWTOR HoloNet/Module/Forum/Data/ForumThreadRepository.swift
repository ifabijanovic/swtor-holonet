//
//  ForumThreadRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadRepository: NSObject {
    
    // MARK: - Properties
    
    private let rootUrl: String
    private var cache: Dictionary<Int, Array<ForumThread>>
    private let parser: ForumParser
    
    var useCache: Bool
    
    // MARK: - Init
    
    init(rootUrl: String) {
        self.rootUrl = rootUrl
        self.cache = Dictionary<Int, Array<ForumThread>>()
        self.parser = ForumParser()
        
        self.useCache = true
    }
    
    // MARK: - Public methods
    
    func get(#category: ForumCategory, success: ((Array<ForumThread>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: category.id, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(#id: Int, success: ((Array<ForumThread>) -> Void), failure: ((NSError) -> Void)) {
        // Cache
        if useCache {
            if let data = self.cache[id] {
                success(data)
                return
            }
        }
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let url = "\(self.rootUrl)?f=\(id)"
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
    
    private func parseHtml(html: String) -> Array<ForumThread> {
        var items = Array<ForumThread>()
        
        let document = HTMLDocument(string: html)
        let threadNodes = document.nodesMatchingSelector("table#threadslist tr") as Array<HTMLElement>
        
        for node in threadNodes {
            let thread = self.parseThread(node)
            if thread != nil {
                items.append(thread!)
            }
        }
        
        return items
    }
    
    private func parseThread(element: HTMLElement) -> ForumThread? {
        // Id & Title
        let titleElement = element.firstNodeMatchingSelector(".threadTitle")
        let id = self.parser.linkParameter(linkElement: titleElement, name: "t")?.toInt()
        let title = titleElement?.textContent

        // Last post date
        let lastPostDate = element.firstNodeMatchingSelector(".lastpostdate")?.textContent
        
        // Author
        let author = element.firstNodeMatchingSelector(".author")?.textContent
        
        // Replies
        let replies = self.parser.integerContent(element: element.firstNodeMatchingSelector(".resultReplies"))
        
        // Views
        let views = self.parser.integerContent(element: element.firstNodeMatchingSelector(".resultViews"))
        
        // Has Bioware reply & sticky
        var hasBiowareReply = false
        var isSticky = false
        let imageElements = element.nodesMatchingSelector(".threadLeft img.inlineimg") as Array<HTMLElement>
        for image in imageElements {
            let src = image.objectForKeyedSubscript("src") as? String
            if src == nil {
                continue
            }
            
            if src!.hasSuffix("devtracker_icon.png") {
                hasBiowareReply = true
            } else if src!.hasSuffix("sticky.gif") {
                isSticky = true
            }
        }
        
        if id == nil { return nil }
        if title == nil { return nil }
        if lastPostDate == nil { return nil }
        if author == nil { return nil }
        if replies == nil { return nil }
        if views == nil { return nil }
        
        let thread = ForumThread(id: id!, title: title!, lastPostDate: lastPostDate!, author: author!, replies: replies!, views: views!, hasBiowareReply: hasBiowareReply, isSticky: isSticky)
        
        return thread
    }
    
}
