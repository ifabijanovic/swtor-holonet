//
//  ForumCategoryRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumCategoryRepository: ForumRepositoryBase {
    
    // MARK: - Public methods
    
    func get(language: ForumLanguage, success: @escaping ((Array<ForumCategory>) -> Void), failure: @escaping ((Error) -> Void)) {
        self.get(id: language.rawValue, success: success, failure: failure)
    }
    
    func get(category: ForumCategory, success: @escaping ((Array<ForumCategory>) -> Void), failure: @escaping ((Error) -> Void)) {
        self.get(id: category.id, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(id: Int, success: @escaping ((Array<ForumCategory>) -> Void), failure: @escaping ((Error) -> Void)) {
        let url = "\(self.settings.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(id)"
        self.manager.get(url, parameters: nil, success: { (operation, response) in
            let html = operation!.responseString!
            let items = self.parseHtml(html)
            
            if items.isEmpty && self.isMaintenanceResponse(html) {
                return failure(maintenanceError())
            }
            
            success(items)
        }) { (operation, error) in
            if !operation!.isCancelled {
                failure(error!)
            }
        }
    }
    
    // MARK: - Parsing
    
    private func parseHtml(_ html: String) -> Array<ForumCategory> {
        var items = Array<ForumCategory>()
        
        let document = HTMLDocument(string: html)
        let categoryNodes = document!.nodes(matchingSelector: ".forumCategory > .subForum") as! Array<HTMLElement>
        
        for node in categoryNodes {
            let category = self.parseCategory(node)
            if category != nil {
                items.append(category!)
            }
        }
        
        return items
    }
    
    private func parseCategory(_ element: HTMLElement) -> ForumCategory? {
        // Id & Title
        let titleElement = element.firstNode(matchingSelector: ".resultTitle > a")
        let idString = self.parser.linkParameter(linkElement: titleElement, name: self.settings.categoryQueryParam)
        let id = idString != nil ? Int(idString!) : nil
        let title = titleElement?.textContent
        
        // Icon
        var iconUrl: String? = nil
        if let thumbElement = element.firstNode(matchingSelector: ".thumbBackground") {
            if let iconStyle = thumbElement.objectForKeyedSubscript("style") as? String {
                let start = iconStyle.range(of: "url(", options: .literal, range: nil, locale: nil)
                let end = iconStyle.range(of: ")", options: .literal, range: nil, locale: nil)
                iconUrl = iconStyle.substring(with: Range(uncheckedBounds: (lower: start!.upperBound, upper: end!.lowerBound)))
            }
        }
        
        // Description
        let description = element.firstNode(matchingSelector: ".resultText")?.textContent
        
        // Stats & Last post
        var stats: String? = nil
        var lastPost: String? = nil
        let subTextElements = element.nodes(matchingSelector: ".resultSubText") as! Array<HTMLElement>

        if subTextElements.count > 0 {
            stats = subTextElements[0].textContent
        }
        if subTextElements.count > 1 {
            lastPost = subTextElements[1].textContent
        }
        
        if id == nil { return nil }
        if title == nil { return nil }
        
        let finalTitle = title!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        let finalDescription = description?.trimSpaces()
        let finalStats = stats?.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        let finalLastPost = lastPost?.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        
        let category = ForumCategory(id: id!, title: finalTitle)
        category.iconUrl = iconUrl
        category.desc = finalDescription
        category.stats = finalStats
        category.lastPost = finalLastPost
        
        return category
    }
    
}
