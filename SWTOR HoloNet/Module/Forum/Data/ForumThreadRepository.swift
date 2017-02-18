//
//  ForumThreadRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadRepository: ForumRepositoryBase {
    
    // MARK: - Public methods
    
    func get(category: ForumCategory, page: Int, success: @escaping ((Array<ForumThread>) -> Void), failure: @escaping ((Error) -> Void)) {
        self.get(id: category.id, page: page, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(id: Int, page: Int, success: @escaping ((Array<ForumThread>) -> Void), failure: @escaping ((Error) -> Void)) {
        let url = "\(self.settings.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(id)&\(self.settings.pageQueryParam)=\(page)"
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
    
    private func parseHtml(_ html: String) -> Array<ForumThread> {
        var items = Array<ForumThread>()
        
        let document = HTMLDocument(string: html)!
        let threadNodes = document.nodes(matchingSelector: "table#threadslist tr") as! Array<HTMLElement>
        
        for node in threadNodes {
            let thread = self.parseThread(node)
            if thread != nil {
                items.append(thread!)
            }
        }
        
        return items
    }
    
    private func parseThread(_ element: HTMLElement) -> ForumThread? {
        // Id & Title
        let titleElement = element.firstNode(matchingSelector: ".threadTitle")
        let idString = self.parser.linkParameter(linkElement: titleElement, name: self.settings.threadQueryParam)
        let id = idString != nil ? Int(idString!) : nil
        let title = titleElement?.textContent

        // Last post date
        let lastPostDate = element.firstNode(matchingSelector: ".lastpostdate")?.textContent
        
        // Author
        let author = element.firstNode(matchingSelector: ".author")?.textContent
        
        // Replies
        let replies = self.parser.integerContent(element: element.firstNode(matchingSelector: ".resultReplies"))
        
        // Views
        let views = self.parser.integerContent(element: element.firstNode(matchingSelector: ".resultViews"))
        
        // Has Bioware reply & sticky
        var hasBiowareReply = false
        var isSticky = false
        let imageElements = element.nodes(matchingSelector: ".threadLeft img.inlineimg") as! Array<HTMLElement>
        for image in imageElements {
            let src = image.objectForKeyedSubscript("src") as? String
            if src == nil {
                continue
            }
            
            if src == self.settings.devTrackerIconUrl {
                hasBiowareReply = true
            } else if src == self.settings.stickyIconUrl {
                isSticky = true
            }
        }
        
        if id == nil { return nil }
        if title == nil { return nil }
        if lastPostDate == nil { return nil }
        if author == nil { return nil }
        if replies == nil { return nil }
        if views == nil { return nil }
        
        let finalTitle = title!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        let finalLastPostDate = lastPostDate!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        let finalAuthor = author!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        
        let thread = ForumThread(id: id!, title: finalTitle, lastPostDate: finalLastPostDate, author: finalAuthor, replies: replies!, views: views!, hasBiowareReply: hasBiowareReply, isSticky: isSticky)
        
        return thread
    }
    
}
