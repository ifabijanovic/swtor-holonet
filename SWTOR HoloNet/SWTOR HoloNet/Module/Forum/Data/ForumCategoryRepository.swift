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
    
    private let settings: Settings
    private let parser: ForumParser
    
    // MARK: - Init
    
    convenience init(settings: Settings) {
        self.init(settings: settings, parser: ForumParser())
    }
    
    init(settings: Settings, parser: ForumParser) {
        self.settings = settings
        self.parser = parser
    }
    
    // MARK: - Public methods
    
    func get(#language: ForumLanguage, success: ((Array<ForumCategory>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: language.rawValue, success: success, failure: failure)
    }
    
    func get(#category: ForumCategory, success: ((Array<ForumCategory>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: category.id, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(#id: Int, success: ((Array<ForumCategory>) -> Void), failure: ((NSError) -> Void)) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let url = "\(self.settings.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(id)"
        manager.GET(url, parameters: nil, success: { (operation, response) in
            let html = operation.responseString
            let items = self.parseHtml(html)
            success(items)
        }) { (operation, error) in
            failure(error)
        }
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
        let id = self.parser.linkParameter(linkElement: titleElement, name: self.settings.categoryQueryParam)?.toInt()
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
        category.desc = description
        category.stats = stats?.stripNewLinesAndTabs()
        category.lastPost = lastPost?.stripNewLinesAndTabs()
        
        return category
    }
    
}
