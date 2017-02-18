//
//  ForumPostRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Alamofire

class ForumPostRepository: ForumRepositoryBase {
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

extension ForumPostRepository {
    fileprivate func parse(html: String) -> [ForumPost] {
        var items = [ForumPost]()
        
        let document = HTMLDocument(string: html)
        assert(document != nil)
        let threadNodes = document!.nodes(matchingSelector: "#posts table.threadPost") as! [HTMLElement]
        
        for node in threadNodes {
            let thread = self.parsePost(element: node)
            if thread != nil {
                items.append(thread!)
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
            avatarUrl = avatarElement.objectForKeyedSubscript("src") as? String
        }
        
        // Username
        let username = element.firstNode(matchingSelector: ".avatar > .resultCategory > a")?.textContent
        
        // Date & Post number
        let dateElement = (element.nodes(matchingSelector: ".post .threadDate") as! [HTMLElement]).last
        let date = self.parser.postDate(element: dateElement)
        let postNumber = self.parser.postNumber(element: dateElement)
        
        // Is Bioware post
        var isBiowarePost = false
        let imageElements = element.nodes(matchingSelector: ".post img.inlineimg") as! [HTMLElement]
        for image in imageElements {
            let src = image.objectForKeyedSubscript("src") as? String
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
        let lastPostRow = (element.nodes(matchingSelector: ".post tr") as! [HTMLElement]).last
        let signature = lastPostRow?.firstNode(matchingSelector: ".resultText")?.textContent
        
        if id == nil { return nil }
        if username == nil { return nil }
        if date == nil { return nil }
        if text == nil { return nil }
        
        let finalUsername = username!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
        
        let post = ForumPost(id: id!, username: finalUsername, date: date!, postNumber: postNumber, isBiowarePost: isBiowarePost, text: text!)
        post.avatarUrl = avatarUrl
        post.signature = signature
        
        return post
    }
}
