//
//  ForumPostRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumPostRepository {
    
    // MARK: - Properties
    
    private let settings: Settings
    private let parser: ForumParser
    
    // MARK: - Init
    
    init(settings: Settings) {
        self.settings = settings
        self.parser = ForumParser()
    }
    
    // MARK: - Public methods
    
    func url(#thread: ForumThread, page: Int) -> String {
        return thread.isDevTracker
            ? "\(self.settings.devTrackerUrl)?\(self.settings.pageQueryParam)=\(page)"
            : "\(self.settings.threadDisplayUrl)?\(self.settings.threadQueryParam)=\(thread.id)&\(self.settings.pageQueryParam)=\(page)"
    }
    
    func get(#thread: ForumThread, page: Int, success: ((Array<ForumPost>) -> Void), failure: ((NSError) -> Void)) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let url = self.url(thread: thread, page: page)
        
        manager.GET(url, parameters: nil, success: { (operation, response) in
            let html = operation.responseString
            let items = self.parseHtml(html)
            success(items)
            }) { (operation, error) in
                failure(error)
        }
    }
    
    // MARK: - Parsing
    
    private func parseHtml(html: String) -> Array<ForumPost> {
        var items = Array<ForumPost>()
        
        let document = HTMLDocument(string: html)
        let threadNodes = document.nodesMatchingSelector("#posts table.threadPost") as! Array<HTMLElement>
        
        for node in threadNodes {
            let thread = self.parsePost(node)
            if thread != nil {
                items.append(thread!)
            }
        }
        
        return items
    }
    
    private func parsePost(element: HTMLElement) -> ForumPost? {
        // Id
        let id = self.parser.linkParameter(linkElement: element.firstNodeMatchingSelector(".post .threadDate a"), name: self.settings.postQueryParam)?.toInt()
        
        // Avatar url
        var avatarUrl: String? = nil
        if let avatarElement = element.firstNodeMatchingSelector(".avatar img") {
            avatarUrl = avatarElement.objectForKeyedSubscript("src") as? String
        }
        
        // Username
        let username = element.firstNodeMatchingSelector(".avatar > .resultCategory > a")?.textContent
        
        // Date & Post number
        let dateElement = (element.nodesMatchingSelector(".post .threadDate") as! Array<HTMLElement>).last
        let date = self.parser.postDate(element: dateElement)
        let postNumber = self.parser.postNumber(element: dateElement)
        
        // Is Bioware post
        var isBiowarePost = false
        let imageElements = element.nodesMatchingSelector(".post img.inlineimg") as! Array<HTMLElement>
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
        let text = self.parser.postText(node: element.firstNodeMatchingSelector(".post .forumPadding > .resultText"))
        
        // Signature
        let lastPostRow = (element.nodesMatchingSelector(".post tr") as! Array<HTMLElement>).last
        let signature = lastPostRow?.firstNodeMatchingSelector(".resultText")?.textContent
        
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
