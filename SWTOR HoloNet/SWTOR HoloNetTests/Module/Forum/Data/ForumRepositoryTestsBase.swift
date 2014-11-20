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
    
    var bundle: NSBundle?
    var settings: Settings?
    
    let timeout: NSTimeInterval = 3
    let headers = ["Content-Type": "text/html"]
    let passAll: OHHTTPStubsTestBlock = { (request) in
        return true
    }
    let defaultFailure: (NSError) -> Void = { (error) in
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
        
        self.bundle = NSBundle(forClass: SettingsTests.self)
        let path = self.bundle!.pathForResource("Settings", ofType: "plist")!
        self.settings = Settings(path: path)
    }
    
    override func tearDown() {
        self.settings = nil
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
}
