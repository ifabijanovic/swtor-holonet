//
//  ForumThreadRepositoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ForumThreadRepositoryTests: ForumRepositoryTestsBase {

    // MARK: - Properties
    
    let testCategory = ForumCategory(id: 17, title: "Test")
    var repo: ForumThreadRepository?
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        self.repo = ForumThreadRepository(settings: self.settings!)
    }
    
    override func tearDown() {
        self.repo = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGet_RequestsCorrectUrl() {
        let page = 7
        let expectedUrl = "\(self.settings!.forumDisplayUrl)?\(self.settings!.categoryQueryParam)=\(self.testCategory.id)&\(self.settings!.pageQueryParam)=\(page)"
        let expectation = expectationWithDescription("")
        
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.URL!.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            expectation.fulfill()
            return OHHTTPStubsResponse()
        }
        
        OHHTTPStubs.stubRequestsPassingTest(testBlock, withStubResponse: responseBlock)
        self.repo!.get(category: self.testCategory, page: page, success: { (items) in }, failure: {(error) in })
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_EmptyHtml() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-empty", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-valid", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
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
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid_NotDev() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-valid-not-dev", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertFalse(items[0].hasBiowareReply, "")
            
            }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid_NotSticky() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-valid-not-sticky", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertFalse(items[0].isSticky, "")
            
            }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Id() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-invalid-id", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Title() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-invalid-title", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_LastPostDate() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-invalid-last-post-date", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Author() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-invalid-author", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Replies() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-invalid-replies", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Views() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-single-invalid-views", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Valid() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-multiple-valid", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
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
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Invalid_Id() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-thread-multiple-invalid-id", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(category: self.testCategory, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 2, "")
            
            // Exception safeguard
            if items.count != 2 { return }
            
            XCTAssertEqual(items[0].id, 6, "")
            XCTAssertEqual(items[1].id, 7, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }

}
