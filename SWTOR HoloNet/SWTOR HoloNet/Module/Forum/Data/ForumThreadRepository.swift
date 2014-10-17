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
    
    var useCache: Bool
    
    // MARK: - Init
    
    init(rootUrl: String) {
        self.rootUrl = rootUrl
        self.cache = Dictionary<Int, Array<ForumThread>>()
        
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
        
        let titleElement = element.firstNodeMatchingSelector(".threadTitle")
        if titleElement == nil {
            // No title element, skip
            return nil
        }
        
        // Id
        let link = titleElement.objectForKeyedSubscript("href") as? String
        if link == nil {
            // Link href missing, skip
            return nil
        }
        let id = NSURLComponents(string: link!).queryValueForName("t")
        if id == nil || id!.toInt() == nil {
            // Id cannot be parsed, skip
            return nil
        }
        
        // Title
        let title = titleElement.textContent
        
        // Last post date
        let lastPostDateElement = element.firstNodeMatchingSelector(".lastpostdate")
        if lastPostDateElement == nil {
            // Last post date missing, skip
            return nil
        }
        let lastPostDate = lastPostDateElement.textContent
        
        // Author
        let authorElement = element.firstNodeMatchingSelector(".author")
        if authorElement == nil {
            // Author missing, skip
            return nil
        }
        let author = authorElement.textContent
        
        let formatter = NSNumberFormatter()
        formatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        // Replies
        let repliesElement = element.firstNodeMatchingSelector(".resultReplies")
        if repliesElement == nil {
            // Replies missing, skip
            return nil
        }
        let replies = formatter.numberFromString(repliesElement.textContent)
        
        // Views
        let viewsElement = element.firstNodeMatchingSelector(".resultViews")
        if viewsElement == nil {
            // Views missing, skip
            return nil
        }
        let views = formatter.numberFromString(viewsElement.textContent)
        
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
        
        let thread = ForumThread(id: id!.toInt()!, title: title, lastPostDate: lastPostDate, author: author, replies: replies!.integerValue, views: views!.integerValue, hasBiowareReply: hasBiowareReply, isSticky: isSticky)
        
        return thread
    }
    
}
