//
//  ActionParserTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 11/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ActionParserTests: XCTestCase {
    func testGetAlert_Works() {
        let userInfo = ["aps":["alert":"test"]]
        let parser = AppActionParser(userInfo: userInfo)
        let result = parser.alert
        
        XCTAssertNotNil(result, "")
        XCTAssertEqual(result!, "test", "")
    }
    
    func testGetAlert_MisingAlert() {
        let userInfo = ["aps":["sound":"default"]]
        let parser = AppActionParser(userInfo: userInfo)
        let result = parser.alert
        
        XCTAssertNil(result, "")
    }
    
    func testGetAlert_MisingAps() {
        let userInfo = ["alert":"test"]
        let parser = AppActionParser(userInfo: userInfo)
        let result = parser.alert
        
        XCTAssertNil(result, "")
    }
    
    func testGetType_Works() {
        let userInfo = ["type":"value"]
        let parser = AppActionParser(userInfo: userInfo)
        let result = parser.type
        
        XCTAssertNotNil(result, "")
        XCTAssertEqual(result!, "value", "")
    }
    
    func testGetUrl_Works() {
        let userInfo = ["url":"http://www.google.com"]
        let parser = AppActionParser(userInfo: userInfo)
        let result = parser.url
        
        XCTAssertNotNil(result, "")
        XCTAssertEqual(result!, URL(string: "http://www.google.com"), "")
    }
}
