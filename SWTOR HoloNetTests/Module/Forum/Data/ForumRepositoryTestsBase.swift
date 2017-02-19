//
//  ForumRepositoryTestsBase.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import OHHTTPStubs

class ForumRepositoryTestsBase: XCTestCase {

    // MARK: - Properties
    
    var bundle: Bundle?
    var settings: Settings?
    
    let timeout: TimeInterval = 3
    let headers = ["Content-Type": "text/html"]
    let passAll: OHHTTPStubsTestBlock = { (request) in
        return true
    }
    let defaultFailure: (Error) -> Void = { (error) in
        XCTFail("Failed with error \(error)")
    }
    let defaultExpectationHandler: XCWaitCompletionHandler = { (error) in
        if error != nil {
            XCTFail("Failed with error \(error)")
        }
    }
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        self.bundle = Bundle(for: SettingsTests.self)
        self.settings = Settings(bundle: self.bundle!)
    }
    
    override func tearDown() {
        self.settings = nil
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
    // MARK: - Helper methods
    
    func stubUrlTest(expectedUrl: String) {
        let ex = expectation(description: "urlTest")
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.url!.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            ex.fulfill()
            let response = OHHTTPStubsResponse()
            response.statusCode = 200
            return response
        }
        
        OHHTTPStubs.stubRequests(passingTest: testBlock, withStubResponse: responseBlock)
    }
    
    func stubHtmlResource(name: String) {
        OHHTTPStubs.stubRequests(
            passingTest: { _ in true },
            withStubResponse: { request in
                guard let path = self.bundle?.path(forResource: name, ofType: "html") else {
                    XCTFail("Failed to load resource '\(name)'")
                    let response = OHHTTPStubsResponse()
                    response.statusCode = 500
                    return response
                }
                return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type": "text/html"])
            }
        )
    }
}
