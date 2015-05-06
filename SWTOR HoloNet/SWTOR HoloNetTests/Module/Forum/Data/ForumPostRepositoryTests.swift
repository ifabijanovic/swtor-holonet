//
//  ForumPostRepositoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ForumPostRepositoryTests: ForumRepositoryTestsBase {

    // MARK: - Properties
    
    let testThread = ForumThread(id: 5, title: "Test", lastPostDate: "Today", author: "Test user", replies: 5, views: 7)
    var repo: ForumPostRepository?
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        self.repo = ForumPostRepository(settings: self.settings!)
    }
    
    override func tearDown() {
        self.repo = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testUrl_ReturnsCorrectUrl() {
        let page = 7
        let expectedUrl = "\(self.settings!.threadDisplayUrl)?\(self.settings!.threadQueryParam)=\(self.testThread.id)&\(self.settings!.pageQueryParam)=\(page)"
        let url = self.repo!.url(thread: self.testThread, page: page)
        
        XCTAssertEqual(url, expectedUrl, "")
    }
    
    func testUrl_ReturnsCorrectDevTrackerUrl() {
        let page = 7
        let thread = ForumThread.devTracker()
        let expectedUrl = "\(self.settings!.devTrackerUrl)?\(self.settings!.pageQueryParam)=\(page)"
        let url = self.repo!.url(thread: thread, page: page)
        
        XCTAssertEqual(url, expectedUrl, "")
    }
    
    func testGet_RequestsCorrectUrl() {
        let page = 7
        let expectedUrl = "\(self.settings!.threadDisplayUrl)?\(self.settings!.threadQueryParam)=\(self.testThread.id)&\(self.settings!.pageQueryParam)=\(page)"
        let expectation = expectationWithDescription("")
        
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.URL!.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            expectation.fulfill()
            return nil
        }
        
        OHHTTPStubs.stubRequestsPassingTest(testBlock, withStubResponse: responseBlock)
        self.repo!.get(thread: self.testThread, page: page, success: { (items) in }, failure: {(error) in })
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_DevTrackerRequestsCorrectUrl() {
        let page = 7
        let expectedUrl = "\(self.settings!.devTrackerUrl)?\(self.settings!.pageQueryParam)=\(page)"
        let expectation = expectationWithDescription("")
        
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.URL!.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            expectation.fulfill()
            return nil
        }
        
        let thread = ForumThread.devTracker()
        
        OHHTTPStubs.stubRequestsPassingTest(testBlock, withStubResponse: responseBlock)
        self.repo!.get(thread: thread, page: page, success: { (items) in }, failure: {(error) in })
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_EmptyHtml() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-empty", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-single-valid", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
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
            XCTAssertGreaterThan(items[0].text.length, 0, "")
            XCTAssertGreaterThan(items[0].signature!.length, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid_NotDev() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-single-valid-not-dev", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertFalse(items[0].isBiowarePost, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Id() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-single-invalid-id", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Username() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-single-invalid-username", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Date() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-single-invalid-date", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_MissingOptionals() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-single-missing-optionals", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertNil(items[0].avatarUrl, "")
            XCTAssertNil(items[0].postNumber, "")
            XCTAssertNil(items[0].signature, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Valid() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-multiple-valid", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
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
            XCTAssertGreaterThan(items[0].text.length, 0, "")
            XCTAssertGreaterThan(items[0].signature!.length, 0, "")
            
            XCTAssertEqual(items[1].id, 6, "")
            XCTAssertEqual(items[1].avatarUrl!, "http://www.holonet.test/avatar.png", "")
            XCTAssertEqual(items[1].username, "User name 6", "")
            XCTAssertEqual(items[1].date, "2.2.2014, 09:22 AM", "")
            XCTAssertEqual(items[1].postNumber!, 2, "")
            XCTAssertFalse(items[1].isBiowarePost, "")
            XCTAssertGreaterThan(items[1].text.length, 0, "")
            XCTAssertGreaterThan(items[1].signature!.length, 0, "")
            
            XCTAssertEqual(items[2].id, 7, "")
            XCTAssertEqual(items[2].avatarUrl!, "http://www.holonet.test/avatar.png", "")
            XCTAssertEqual(items[2].username, "User name 7", "")
            XCTAssertEqual(items[2].date, "3.3.2014, 10:22 AM", "")
            XCTAssertEqual(items[2].postNumber!, 3, "")
            XCTAssertTrue(items[2].isBiowarePost, "")
            XCTAssertGreaterThan(items[2].text.length, 0, "")
            XCTAssertGreaterThan(items[2].signature!.length, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Invalid_Id() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-post-multiple-invalid-id", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(thread: self.testThread, page: 1, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 2, "")
            
            // Exception safeguard
            if items.count != 2 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[1].id, 7, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }

}
