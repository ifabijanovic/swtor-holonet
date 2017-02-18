//
//  ForumRepositoryTestsBase.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

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
    
}
