//
//  ForumThreadRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxAlamofire
import HTMLReader

protocol ForumThreadRepository {
    func threads(category: ForumCategory, page: Int) -> Observable<[ForumThread]>
    
    func get(category: ForumCategory, page: Int, success: @escaping (([ForumThread]) -> Void), failure: @escaping ((Error) -> Void))
}

class DefaultForumThreadRepository: ForumRepositoryBase, ForumThreadRepository {
    func threads(category: ForumCategory, page: Int) -> Observable<[ForumThread]> {
        return self.threads(id: category.id, page: page)
    }
    
    func get(category: ForumCategory, page: Int, success: @escaping (([ForumThread]) -> Void), failure: @escaping ((Error) -> Void)) {
        self.get(id: category.id, page: page, success: success, failure: failure)
    }
}

extension DefaultForumThreadRepository {
    fileprivate func threads(id: Int, page: Int) -> Observable<[ForumThread]> {
        return self.manager.rx
            .string(.get, self.url(id: id, page: page))
            .map {
                let items = self.parse(html: $0)
                if items.isEmpty && self.isMaintenanceResponse($0) {
                    throw ForumError.maintenance
                }
                return items
            }
    }
    
    fileprivate func get(id: Int, page: Int, success: @escaping (([ForumThread]) -> Void), failure: @escaping ((Error) -> Void)) {
        let url = self.url(id: id, page: page)
        self.manager
            .request(url)
            .responseString { response in
                if let error = response.error {
                    return failure(error)
                }
                
                guard let html = response.result.value else {
                    return failure(ForumError.noResponse)
                }
                
                let items = self.parse(html: html)
                if items.isEmpty && self.isMaintenanceResponse(html) {
                    return failure(maintenanceError())
                }
                
                success(items)
            }
    }
    
    private func url(id: Int, page: Int) -> URL {
        let string = "\(self.settings.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(id)&\(self.settings.pageQueryParam)=\(page)"
        let url = URL(string: string)
        assert(url != nil)
        return url!
    }
    
    private func parse(html: String) -> [ForumThread] {
        var items = [ForumThread]()
        
        let document = HTMLDocument(string: html)
        let threadNodes = document.nodes(matchingSelector: "table#threadslist tr")
        
        for node in threadNodes {
            if let thread = self.parseThread(element: node) {
                items.append(thread)
            }
        }
        
        return items
    }
    
    private func parseThread(element: HTMLElement) -> ForumThread? {
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
        let imageElements = element.nodes(matchingSelector: ".threadLeft img.inlineimg")
        for image in imageElements {
            let src = image["src"]
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
