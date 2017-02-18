//
//  ForumCategoryRepository.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxAlamofire
import HTMLReader

protocol ForumCategoryRepository {
    func categories(language: ForumLanguage) -> Observable<[ForumCategory]>
    func categories(parent: ForumCategory) -> Observable<[ForumCategory]>
}

class DefaultForumCategoryRepository: ForumRepositoryBase, ForumCategoryRepository {
    func categories(language: ForumLanguage) -> Observable<[ForumCategory]> {
        return self.categories(id: language.rawValue)
    }
    
    func categories(parent: ForumCategory) -> Observable<[ForumCategory]> {
        return self.categories(id: parent.id)
    }
}

extension DefaultForumCategoryRepository {
    fileprivate func categories(id: Int) -> Observable<[ForumCategory]> {
        return self.manager.rx
            .string(.get, self.url(id: id))
            .map {
                let items = self.parse(html: $0)
                if items.isEmpty && self.isMaintenanceResponse($0) {
                    throw ForumError.maintenance
                }
                return items
            }
    }
    
    private func url(id: Int) -> URL {
        let string = "\(self.settings.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(id)"
        let url = URL(string: string)
        assert(url != nil)
        return url!
    }
    
    private func parse(html: String) -> [ForumCategory] {
        var items = [ForumCategory]()
        
        let document = HTMLDocument(string: html)
        let categoryNodes = document.nodes(matchingSelector: ".forumCategory > .subForum")
        
        for node in categoryNodes {
            if let category = self.parseCategory(element: node) {
                items.append(category)
            }
        }
        
        return items
    }
    
    private func parseCategory(element: HTMLElement) -> ForumCategory? {
        // Id & Title
        let titleElement = element.firstNode(matchingSelector: ".resultTitle > a")
        let idString = self.parser.linkParameter(linkElement: titleElement, name: self.settings.categoryQueryParam)
        let id = idString != nil ? Int(idString!) : nil
        let title = titleElement?.textContent
        
        // Icon
        var iconUrl: String? = nil
        if let thumbElement = element.firstNode(matchingSelector: ".thumbBackground") {
            if let iconStyle = thumbElement["style"] {
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
        let subTextElements = element.nodes(matchingSelector: ".resultSubText")

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
        
        var category = ForumCategory(id: id!, title: finalTitle)
        category.iconUrl = iconUrl
        category.desc = finalDescription
        category.stats = finalStats
        category.lastPost = finalLastPost
        
        return category
    }
}
