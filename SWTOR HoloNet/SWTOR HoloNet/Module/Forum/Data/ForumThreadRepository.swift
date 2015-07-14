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
    
    func get(#category: ForumCategory, page: Int, success: ((Array<ForumThread>) -> Void), failure: ((NSError) -> Void)) {
        self.get(id: category.id, page: page, success: success, failure: failure)
    }
    
    // MARK: - Network
    
    private func get(#id: Int, page: Int, success: ((Array<ForumThread>) -> Void), failure: ((NSError) -> Void)) {
        let url = "\(self.settings.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(id)&\(self.settings.pageQueryParam)=\(page)"
        self.manager.GET(url, parameters: nil, success: { (operation, response) in
            let html = operation.responseString
            let items = self.parseHtml(html)
            success(items)
        }) { (operation, error) in
                failure(error)
        }
    }
    
    // MARK: - Parsing
    
    private func parseHtml(html: String) -> Array<ForumThread> {
        var items = Array<ForumThread>()
        
        let document = HTMLDocument(string: html)
        let threadNodes = document.nodesMatchingSelector("table#threadslist tr") as! Array<HTMLElement>
        
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
        let id = self.parser.linkParameter(linkElement: titleElement, name: self.settings.threadQueryParam)?.toInt()
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
        let imageElements = element.nodesMatchingSelector(".threadLeft img.inlineimg") as! Array<HTMLElement>
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
