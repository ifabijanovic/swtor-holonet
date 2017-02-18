//
//  ForumPostRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Alamofire
import HTMLReader

protocol ForumPostRepository {
    func url(thread: ForumThread, page: Int) -> URL
    func get(thread: ForumThread, page: Int, success: @escaping (([ForumPost]) -> Void), failure: @escaping ((Error) -> Void))
}

class DefaultForumPostRepository: ForumRepositoryBase, ForumPostRepository {
    func url(thread: ForumThread, page: Int) -> URL {
        let string = thread.isDevTracker
            ? "\(self.settings.devTrackerUrl)?\(self.settings.pageQueryParam)=\(page)"
            : "\(self.settings.threadDisplayUrl)?\(self.settings.threadQueryParam)=\(thread.id)&\(self.settings.pageQueryParam)=\(page)"
        let url = URL(string: string)
        assert(url != nil)
        return url!
    }
    
    func get(thread: ForumThread, page: Int, success: @escaping (([ForumPost]) -> Void), failure: @escaping ((Error) -> Void)) {
        let url = self.url(thread: thread, page: page)
        
        self.manager
            .request(url)
            .responseString { response in
                if let error = response.error {
                    return failure(error)
                }
                
                guard let html = response.result.value else {
                    return failure(ForumError.noResponse)
                }
                
                let posts = self.parse(html: html)
                if posts.isEmpty && self.isMaintenanceResponse(html) {
                    return failure(maintenanceError())
                }
                
                success(posts)
            }
    }
}

extension DefaultForumPostRepository {
    fileprivate func parse(html: String) -> [ForumPost] {
        var items = [ForumPost]()
        
        let document = HTMLDocument(string: html)
        let postNodes = document.nodes(matchingSelector: "#posts table.threadPost")
        
        for node in postNodes {
            if let post = self.parsePost(element: node) {
                items.append(post)
            }
        }
        
        return items
    }
    
    private func parsePost(element: HTMLElement) -> ForumPost? {
        // Id
        let idString = self.parser.linkParameter(linkElement: element.firstNode(matchingSelector: ".post .threadDate a"), name: self.settings.postQueryParam)
        let id = idString != nil ? Int(idString!) : nil
        
        // Avatar url
        var avatarUrl: String? = nil
        if let avatarElement = element.firstNode(matchingSelector: ".avatar img") {
            avatarUrl = avatarElement["src"]
        }
        
        // Username
        let username = element.firstNode(matchingSelector: ".avatar > .resultCategory > a")?.textContent
        
        // Date & Post number
        let dateElement = (element.nodes(matchingSelector: ".post .threadDate")).last
        let date = self.parser.postDate(element: dateElement)
        let postNumber = self.parser.postNumber(element: dateElement)
        
        // Is Bioware post
        var isBiowarePost = false
        let imageElements = element.nodes(matchingSelector: ".post img.inlineimg")
        for image in imageElements {
            let src = image["src"]
            if src == nil {
                continue
            }
            
            if src == self.settings.devTrackerIconUrl {
                isBiowarePost = true
                break
            }
        }
        // Additional check for Dev Avatar (used on Dev Tracker)
        if !isBiowarePost {
            isBiowarePost = avatarUrl != nil && avatarUrl! == self.settings.devAvatarUrl
        }
        
        // Text
        let text = self.parser.postText(node: element.firstNode(matchingSelector: ".post .forumPadding > .resultText"))
        
        // Signature
        let lastPostRow = (element.nodes(matchingSelector: ".post tr")).last
        let signature = lastPostRow?.firstNode(matchingSelector: ".resultText")?.textContent
        
        if id == nil { return nil }
        if username == nil { return nil }
        if date == nil { return nil }
        if text == nil { return nil }
        
        let finalUsername = username!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        
        var post = ForumPost(id: id!, username: finalUsername, date: date!, postNumber: postNumber, isBiowarePost: isBiowarePost, text: text!)
        post.avatarUrl = avatarUrl
        post.signature = signature
        
        return post
    }
}
