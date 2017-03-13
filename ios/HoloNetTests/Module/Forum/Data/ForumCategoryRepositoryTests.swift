//
//  ForumCategoryRepositoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 06/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import OHHTTPStubs

class ForumCategoryRepositoryTests: ForumRepositoryTestsBase {
    fileprivate var repo: ForumCategoryRepository!
    
    override func setUp() {
        super.setUp()
        self.repo = DefaultForumCategoryRepository(parser: ForumParser(), settings: self.settings)
    }
}

extension ForumCategoryRepositoryTests {
    fileprivate func categories(assert: @escaping (([ForumCategory]) -> Void)) {
        self.categories(language: .english, assert: assert)
    }
    
    fileprivate func categories(language: ForumLanguage, assert: @escaping (([ForumCategory]) -> Void)) {
        let ex = self.expectation(description: "categories(language:assert:)")
        self.repo
            .categories(language: .english)
            .subscribe(
                onNext: { categories in
                    ex.fulfill()
                    assert(categories)
                },
                onError: { error in
                    ex.fulfill()
                    XCTFail(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    fileprivate func categories(parent: ForumCategory, assert: @escaping (([ForumCategory]) -> Void)) {
        let ex = expectation(description: "categories(language:assert:)")
        self.repo
            .categories(language: self.language, parent: parent)
            .subscribe(
                onNext: { categories in
                    ex.fulfill()
                    assert(categories)
                },
                onError: { error in
                    ex.fulfill()
                    XCTFail(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
    }
}

extension ForumCategoryRepositoryTests {
    func testGetForLanguage_RequestsCorrectUrl() {
        let requestedLanguage = ForumLanguage.english
        let localizedSettings = self.settings.localized[requestedLanguage.rawValue]!
        let expectedUrl = "\(localizedSettings.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(localizedSettings.rootCategoryId)"
        self.stubUrlTest(expectedUrl: expectedUrl)
        self.categories(language: requestedLanguage, assert: { _ in })
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGetForCategory_RequestsCorrectUrl() {
        let category = ForumCategory(id: 17, title: "Test")
        let expectedUrl = "\(self.settings.localized[self.language.rawValue]!.forumDisplayUrl)?\(self.settings.categoryQueryParam)=\(category.id)"
        self.stubUrlTest(expectedUrl: expectedUrl)
        self.categories(parent: category, assert: { _ in })
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_EmptyHtml() {
        self.stubHtmlResource(name: "forum-empty")
        
        self.categories() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid() {
        self.stubHtmlResource(name: "forum-category-single-valid")
        
        self.categories() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[0].iconUrl!, "http://www.holonet.test/category_icon5.png", "")
            XCTAssertEqual(items[0].title, "Forum category 5", "")
            XCTAssertEqual(items[0].desc!, "Description 5", "")
            XCTAssertEqual(items[0].stats!, "5 Total Threads, 12 Total Posts", "")
            XCTAssertEqual(items[0].lastPost!, "Last Post: Thread 17", "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Id() {
        self.stubHtmlResource(name: "forum-category-single-invalid-id")
        
        self.categories() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_MissingOptionals() {
        self.stubHtmlResource(name: "forum-category-single-missing-optionals")
        
        self.categories() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertNil(items[0].iconUrl, "")
            XCTAssertEqual(items[0].title, "Forum category 5", "")
            XCTAssertNil(items[0].desc, "")
            XCTAssertNil(items[0].stats, "")
            XCTAssertNil(items[0].lastPost, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Valid() {
        self.stubHtmlResource(name: "forum-category-multiple-valid")
        
        self.categories() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 3, "")
            
            // Exception safeguard
            if items.count != 3 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[0].iconUrl!, "http://www.holonet.test/category_icon5.png", "")
            XCTAssertEqual(items[0].title, "Forum category 5", "")
            XCTAssertEqual(items[0].desc!, "Description 5", "")
            XCTAssertEqual(items[0].stats!, "5 Total Threads, 12 Total Posts", "")
            XCTAssertEqual(items[0].lastPost!, "Last Post: Thread 17", "")
            
            XCTAssertEqual(items[1].id, 6, "")
            XCTAssertEqual(items[1].iconUrl!, "http://www.holonet.test/category_icon6.png", "")
            XCTAssertEqual(items[1].title, "Forum category 6", "")
            XCTAssertEqual(items[1].desc!, "Description 6", "")
            XCTAssertEqual(items[1].stats!, "6 Total Threads, 13 Total Posts", "")
            XCTAssertEqual(items[1].lastPost!, "Last Post: Thread 18", "")
            
            XCTAssertEqual(items[2].id, 7, "")
            XCTAssertEqual(items[2].iconUrl!, "http://www.holonet.test/category_icon7.png", "")
            XCTAssertEqual(items[2].title, "Forum category 7", "")
            XCTAssertEqual(items[2].desc!, "Description 7", "")
            XCTAssertEqual(items[2].stats!, "7 Total Threads, 14 Total Posts", "")
            XCTAssertEqual(items[2].lastPost!, "Last Post: Thread 19", "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Invalid_Id() {
        self.stubHtmlResource(name: "forum-category-multiple-missing-id")
        
        self.categories() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 2, "")
            
            // Exception safeguard
            if items.count != 2 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[1].id, 7, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_MissingOptionals() {
        self.stubHtmlResource(name: "forum-category-multiple-missing-optionals")
        
        self.categories() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 3, "")
            
            // Exception safeguard
            if items.count != 3 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertNil(items[0].iconUrl, "")
            XCTAssertEqual(items[0].title, "Forum category 5", "")
            XCTAssertEqual(items[0].desc!, "Description 5", "")
            XCTAssertEqual(items[0].stats!, "5 Total Threads, 12 Total Posts", "")
            XCTAssertEqual(items[0].lastPost!, "Last Post: Thread 17", "")
            
            XCTAssertEqual(items[1].id, 6, "")
            XCTAssertEqual(items[1].iconUrl!, "http://www.holonet.test/category_icon6.png", "")
            XCTAssertEqual(items[1].title, "Forum category 6", "")
            XCTAssertNil(items[1].desc, "")
            XCTAssertEqual(items[1].stats!, "6 Total Threads, 13 Total Posts", "")
            XCTAssertEqual(items[1].lastPost!, "Last Post: Thread 18", "")
            
            XCTAssertEqual(items[2].id, 7, "")
            XCTAssertEqual(items[2].iconUrl!, "http://www.holonet.test/category_icon7.png", "")
            XCTAssertEqual(items[2].title, "Forum category 7", "")
            XCTAssertEqual(items[2].desc!, "Description 7", "")
            XCTAssertNil(items[2].stats, "")
            XCTAssertNil(items[2].lastPost, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
}
