//
//  ForumPostRepositoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import OHHTTPStubs
import RxSwift

class ForumPostRepositoryTests: ForumRepositoryTestsBase {
    let testThread = ForumThread(id: 5, title: "Test", lastPostDate: "Today", author: "Test user", replies: 5, views: 7)
    var repo: ForumPostRepository?
    var disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        self.repo = DefaultForumPostRepository(settings: self.settings!)
        self.disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        self.repo = nil
        super.tearDown()
    }
    
    // MARK: - Helper methods
    
    private func posts(assert: @escaping (([ForumPost]) -> Void)) {
        self.posts(thread: self.testThread, page: 1, assert: assert)
    }
    
    private func posts(thread: ForumThread, page: Int, assert: @escaping (([ForumPost]) -> Void)) {
        let ex = self.expectation(description: "posts(thread:page:assert:)")
        self.repo!
            .posts(thread: thread, page: page)
            .subscribe(
                onNext: { posts in
                    ex.fulfill()
                    assert(posts)
                },
                onError: { error in
                    ex.fulfill()
                    XCTFail(error.localizedDescription)
                }
            )
            .addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Tests
    
    func testUrl_ReturnsCorrectUrl() {
        let page = 7
        let expectedUrl = URL(string: "\(self.settings!.threadDisplayUrl)?\(self.settings!.threadQueryParam)=\(self.testThread.id)&\(self.settings!.pageQueryParam)=\(page)")!
        let url = self.repo!.url(thread: self.testThread, page: page)
        
        XCTAssertEqual(url, expectedUrl, "")
    }
    
    func testUrl_ReturnsCorrectDevTrackerUrl() {
        let page = 7
        let thread = ForumThread.devTracker()
        let expectedUrl = URL(string: "\(self.settings!.devTrackerUrl)?\(self.settings!.pageQueryParam)=\(page)")!
        let url = self.repo!.url(thread: thread, page: page)
        
        XCTAssertEqual(url, expectedUrl, "")
    }
    
    func testGet_RequestsCorrectUrl() {
        let page = 7
        let expectedUrl = "\(self.settings!.threadDisplayUrl)?\(self.settings!.threadQueryParam)=\(self.testThread.id)&\(self.settings!.pageQueryParam)=\(page)"
        self.stubUrlTest(expectedUrl: expectedUrl)
        self.posts(thread: self.testThread, page: page, assert: { _ in })
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_DevTrackerRequestsCorrectUrl() {
        let page = 7
        let expectedUrl = "\(self.settings!.devTrackerUrl)?\(self.settings!.pageQueryParam)=\(page)"
        self.stubUrlTest(expectedUrl: expectedUrl)
        
        let thread = ForumThread.devTracker()
        self.posts(thread: thread, page: page, assert: { _ in })
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_EmptyHtml() {
        self.stubHtmlResource(name: "forum-empty")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid() {
        self.stubHtmlResource(name: "forum-post-single-valid")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[0].avatarUrl!, "http://www.holonet.test/avatar.png", "")
            XCTAssertEqual(items[0].username, "User name 5", "")
            XCTAssertEqual(items[0].date, "1.1.2014, 08:22 AM", "")
            XCTAssertEqual(items[0].postNumber!, 1, "")
            XCTAssertTrue(items[0].isBiowarePost, "")
            XCTAssertGreaterThan(items[0].text.characters.count, 0, "")
            XCTAssertGreaterThan(items[0].signature!.characters.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid_NotDev() {
        self.stubHtmlResource(name: "forum-post-single-valid-not-dev")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertFalse(items[0].isBiowarePost, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Id() {
        self.stubHtmlResource(name: "forum-post-single-invalid-id")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Username() {
        self.stubHtmlResource(name: "forum-post-single-invalid-username")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Date() {
        self.stubHtmlResource(name: "forum-post-single-invalid-date")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_MissingOptionals() {
        self.stubHtmlResource(name: "forum-post-single-missing-optionals")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertNil(items[0].avatarUrl, "")
            XCTAssertNil(items[0].postNumber, "")
            XCTAssertNil(items[0].signature, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Valid() {
        self.stubHtmlResource(name: "forum-post-multiple-valid")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 3, "")
            
            // Exception safeguard
            if items.count != 3 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[0].avatarUrl!, "http://www.holonet.test/avatar.png", "")
            XCTAssertEqual(items[0].username, "User name 5", "")
            XCTAssertEqual(items[0].date, "1.1.2014, 08:22 AM", "")
            XCTAssertEqual(items[0].postNumber!, 1, "")
            XCTAssertTrue(items[0].isBiowarePost, "")
            XCTAssertGreaterThan(items[0].text.characters.count, 0, "")
            XCTAssertGreaterThan(items[0].signature!.characters.count, 0, "")
            
            XCTAssertEqual(items[1].id, 6, "")
            XCTAssertEqual(items[1].avatarUrl!, "http://www.holonet.test/avatar.png", "")
            XCTAssertEqual(items[1].username, "User name 6", "")
            XCTAssertEqual(items[1].date, "2.2.2014, 09:22 AM", "")
            XCTAssertEqual(items[1].postNumber!, 2, "")
            XCTAssertFalse(items[1].isBiowarePost, "")
            XCTAssertGreaterThan(items[1].text.characters.count, 0, "")
            XCTAssertGreaterThan(items[1].signature!.characters.count, 0, "")
            
            XCTAssertEqual(items[2].id, 7, "")
            XCTAssertEqual(items[2].avatarUrl!, "http://www.holonet.test/avatar.png", "")
            XCTAssertEqual(items[2].username, "User name 7", "")
            XCTAssertEqual(items[2].date, "3.3.2014, 10:22 AM", "")
            XCTAssertEqual(items[2].postNumber!, 3, "")
            XCTAssertTrue(items[2].isBiowarePost, "")
            XCTAssertGreaterThan(items[2].text.characters.count, 0, "")
            XCTAssertGreaterThan(items[2].signature!.characters.count, 0, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Invalid_Id() {
        self.stubHtmlResource(name: "forum-post-multiple-invalid-id")
        
        self.posts() { items in
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 2, "")
            
            // Exception safeguard
            if items.count != 2 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[1].id, 7, "")
        }
        
        waitForExpectations(timeout: self.timeout, handler: self.defaultExpectationHandler)
    }
}
