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
    private var cache: Dictionary<Int, Array<ForumCategory>>
    
    var useCache: Bool
    
    // MARK: - Init
    
    init(rootUrl: String) {
        self.rootUrl = rootUrl
        self.cache = Dictionary<Int, Array<ForumCategory>>()
        
        self.useCache = true
    }
    
    // MARK: - Public methods
    
    func get(#language: ForumLanguage, success: ((Array<ForumCategory>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: language.toRaw(), success: success, failure: failure)
    }
    
    func get(#category: ForumCategory, success: ((Array<ForumCategory>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: category.id, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(#id: Int, success: ((Array<ForumCategory>) -> Void), failure: ((NSError) -> Void)) {
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
    
    func clear(#language: ForumLanguage) {
        self.cache[language.toRaw()] = nil
    }
    
    func clear(#category: ForumCategory) {
        self.cache[category.id] = nil
    }
    
    // MARK: - Parsing
    
    private func parseHtml(html: String) -> Array<ForumCategory> {
        var items = Array<ForumCategory>()
        
        let document = HTMLDocument(string: html)
        let categoryNodes = document.nodesMatchingSelector(".forumCategory > .subForum") as Array<HTMLElement>
        
        for node in categoryNodes {
            let category = self.parseCategory(node)
            if category != nil {
                items.append(category!)
            }
        }
        
        return items
    }
    
    private func parseCategory(element: HTMLElement) -> ForumCategory? {
        
        let titleElement = element.firstNodeMatchingSelector(".resultTitle > a")
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
        let id = NSURLComponents(string: link!).queryValueForName("f")
        if id == nil || id!.toInt() == nil {
            // Id cannot be parsed, skip
            return nil
        }
        
        // Title
        let title = titleElement.textContent
        
        let category = ForumCategory(id: id!.toInt()!, title: title)
        
        // Icon
        let thumbElement = element.firstNodeMatchingSelector(".thumbBackground")
        if thumbElement != nil {
            let iconStyle = thumbElement.objectForKeyedSubscript("style") as? String
            if iconStyle != nil {
                let start = iconStyle!.rangeOfString("url(", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
                let end = iconStyle!.rangeOfString(")", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
                let range = Range<String.Index>(start: start!.endIndex, end: end!.startIndex)
                category.iconUrl = iconStyle!.substringWithRange(range)
            }
        }
        
        // Description
        let textElement = element.firstNodeMatchingSelector(".resultText")
        if textElement != nil {
            let description = textElement.textContent
            category.description = description
        }
        
        let subTextElements = element.nodesMatchingSelector(".resultSubText") as Array<HTMLElement>
        
        // Stats
        if subTextElements.count > 0 {
            let statsElement = subTextElements[0]
            let stats = statsElement.textContent
            category.stats = stats.stripNewLinesAndTabs()
        }
        
        // Last post
        if subTextElements.count > 1 {
            let lastPostElement = subTextElements[1]
            let lastPost = lastPostElement.textContent
            category.lastPost = lastPost.stripNewLinesAndTabs()
        }
        
        return category
    }
    
}
