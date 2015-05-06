//
//  ForumCategoryRepositoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 06/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ForumCategoryRepositoryTests: ForumRepositoryTestsBase {

    // MARK: - Properties
    
    var repo: ForumCategoryRepository?
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        self.repo = ForumCategoryRepository(settings: self.settings!)
    }
    
    override func tearDown() {
        self.repo = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGetForLanguage_RequestsCorrectUrl() {
        let requestedLanguage = ForumLanguage.English
        let expectedUrl = "\(self.settings!.forumDisplayUrl)?\(self.settings!.categoryQueryParam)=\(requestedLanguage.rawValue)"
        let expectation = expectationWithDescription("")
        
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.URL!.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            expectation.fulfill()
            return OHHTTPStubsResponse()
        }
        
        OHHTTPStubs.stubRequestsPassingTest(testBlock, withStubResponse: responseBlock)
        self.repo!.get(language: requestedLanguage, success: { (items) in }, failure: {(error) in })
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGetForCategory_RequestsCorrectUrl() {
        let category = ForumCategory(id: 17, title: "Test")
        let expectedUrl = "\(self.settings!.forumDisplayUrl)?\(self.settings!.categoryQueryParam)=\(category.id)"
        let expectation = expectationWithDescription("")
        
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.URL!.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            expectation.fulfill()
            return OHHTTPStubsResponse()
        }
        
        OHHTTPStubs.stubRequestsPassingTest(testBlock, withStubResponse: responseBlock)
        self.repo!.get(category: category, success: { (items) in }, failure: {(error) in })
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_EmptyHtml() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-empty", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-single-valid", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
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
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Invalid_Id() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-single-invalid-id", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_MissingOptionals() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-single-missing-optionals", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
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
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Valid() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-multiple-valid", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
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
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_MultipleItems_Invalid_Id() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-multiple-missing-id", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
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
    
    func testGet_MultipleItems_MissingOptionals() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-multiple-missing-optionals", ofType: "html")
            XCTAssertNotNil(path, "")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
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
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }

}
