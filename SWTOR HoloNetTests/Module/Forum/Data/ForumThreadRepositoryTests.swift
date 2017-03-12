//
//  ForumThreadRepositoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import OHHTTPStubs

class ForumThreadRepositoryTests: ForumRepositoryTestsBase {
    fileprivate let testCategory = ForumCategory(id: 17, title: "Test")
    fileprivate var repo: ForumThreadRepository!
    
    override func setUp() {
        super.setUp()
        self.repo = DefaultForumThreadRepository(settings: self.settings!, parser: ForumParser())
    }
}

extension ForumThreadRepositoryTests {
    fileprivate func threads(assert: @escaping (([ForumThread]) -> Void)) {
        self.threads(category: self.testCategory, page: 1, assert: assert)
    }
    
    fileprivate func threads(category: ForumCategory, page: Int, assert: @escaping (([ForumThread]) -> Void)) {
        let ex = self.expectation(description: "threads(category:page:assert:)")
        self.repo
            .threads(category: category, page: page)
            .subscribe(
                onNext: { threads in
                    ex.fulfill()
                    assert(threads)
                },
                onError: { error in
                    ex.fulfill()
                    XCTFail(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
    }
}

extension ForumThreadRepositoryTests {
    func testGet_RequestsCorrectUrl() {
        let page = 7
        let expectedUrl = "\(self.settings!.forumDisplayUrl)?\(self.settings!.categoryQueryParam)=\(self.testCategory.id)&\(self.settings!.pageQueryParam)=\(page)"
        self.stubUrlTest(expectedUrl: expectedUrl)
        self.repo!
            .threads(category: self.testCategory, page: page)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_EmptyHtml() {
        self.stubHtmlResource(name: "forum-empty")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid() {
        self.stubHtmlResource(name: "forum-thread-single-valid")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[0].title, "Forum thread 5", "")
            XCTAssertEqual(items[0].lastPostDate, "Today 12:22 AM", "")
            XCTAssertEqual(items[0].author, "Author name 5", "")
            XCTAssertEqual(items[0].replies, 5, "")
            XCTAssertEqual(items[0].views, 7, "")
            XCTAssertTrue(items[0].hasBiowareReply, "")
            XCTAssertTrue(items[0].isSticky, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid_NotDev() {
        self.stubHtmlResource(name: "forum-thread-single-valid-not-dev")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertFalse(items[0].hasBiowareReply, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid_NotSticky() {
        self.stubHtmlResource(name: "forum-thread-single-valid-not-sticky")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertFalse(items[0].isSticky, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Id() {
        self.stubHtmlResource(name: "forum-thread-single-invalid-id")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Title() {
        self.stubHtmlResource(name: "forum-thread-single-invalid-title")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_LastPostDate() {
        self.stubHtmlResource(name: "forum-thread-single-invalid-last-post-date")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Author() {
        self.stubHtmlResource(name: "forum-thread-single-invalid-author")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Replies() {
        self.stubHtmlResource(name: "forum-thread-single-invalid-replies")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Views() {
        self.stubHtmlResource(name: "forum-thread-single-invalid-views")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Valid() {
        self.stubHtmlResource(name: "forum-thread-multiple-valid")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 3, "")
            
            // Exception safeguard
            if items.count != 3 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[0].title, "Forum thread 5", "")
            XCTAssertEqual(items[0].lastPostDate, "Today 12:22 AM", "")
            XCTAssertEqual(items[0].author, "Author name 5", "")
            XCTAssertEqual(items[0].replies, 5, "")
            XCTAssertEqual(items[0].views, 7, "")
            XCTAssertTrue(items[0].hasBiowareReply, "")
            XCTAssertTrue(items[0].isSticky, "")
            
            XCTAssertEqual(items[1].id, 6, "")
            XCTAssertEqual(items[1].title, "Forum thread 6", "")
            XCTAssertEqual(items[1].lastPostDate, "Today 09:22 AM", "")
            XCTAssertEqual(items[1].author, "Author name 6", "")
            XCTAssertEqual(items[1].replies, 6, "")
            XCTAssertEqual(items[1].views, 8, "")
            XCTAssertTrue(items[1].hasBiowareReply, "")
            XCTAssertFalse(items[1].isSticky, "")
            
            XCTAssertEqual(items[2].id, 7, "")
            XCTAssertEqual(items[2].title, "Forum thread 7", "")
            XCTAssertEqual(items[2].lastPostDate, "Today 11:22 AM", "")
            XCTAssertEqual(items[2].author, "Author name 7", "")
            XCTAssertEqual(items[2].replies, 7, "")
            XCTAssertEqual(items[2].views, 9, "")
            XCTAssertFalse(items[2].hasBiowareReply, "")
            XCTAssertTrue(items[2].isSticky, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Invalid_Id() {
        self.stubHtmlResource(name: "forum-thread-multiple-invalid-id")
        
        self.threads() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 2, "")
            
            // Exception safeguard
            if items.count != 2 { return }
            
            XCTAssertEqual(items[0].id, 6, "")
            XCTAssertEqual(items[1].id, 7, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
}
