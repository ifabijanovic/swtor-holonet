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
    private let parser: ForumParser
    
    var useCache: Bool
    
    // MARK: - Init
    
    init(rootUrl: String) {
        self.rootUrl = rootUrl
        self.cache = Dictionary<Int, Array<ForumCategory>>()
        self.parser = ForumParser()
        
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
        // Id & Title
        let titleElement = element.firstNodeMatchingSelector(".resultTitle > a")
        let id = self.parser.linkParameter(linkElement: titleElement, name: "f")?.toInt()
        let title = titleElement?.textContent
        
        // Icon
        var iconUrl: String? = nil
        if let thumbElement = element.firstNodeMatchingSelector(".thumbBackground") {
            if let iconStyle = thumbElement.objectForKeyedSubscript("style") as? String {
                let start = iconStyle.rangeOfString("url(", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
                let end = iconStyle.rangeOfString(")", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
                let range = Range<String.Index>(start: start!.endIndex, end: end!.startIndex)
                iconUrl = iconStyle.substringWithRange(range)
            }
        }
        
        // Description
        let description = element.firstNodeMatchingSelector(".resultText")?.textContent
        
        // Stats & Last post
        var stats: String? = nil
        var lastPost: String? = nil
        let subTextElements = element.nodesMatchingSelector(".resultSubText") as Array<HTMLElement>

        if subTextElements.count > 0 {
            stats = subTextElements[0].textContent
        }
        if subTextElements.count > 1 {
            lastPost = subTextElements[1].textContent
        }
        
        if id == nil { return nil }
        if title == nil { return nil }
        
        let category = ForumCategory(id: id!, title: title!)
        category.iconUrl = iconUrl
        category.description = description
        category.stats = stats
        category.lastPost = lastPost
        
        return category
    }
    
}
