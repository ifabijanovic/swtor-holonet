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
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.alert
        
        XCTAssertNotNil(result, "")
        XCTAssertEqual(result!, "test", "")
    }
    
    func testGetAlert_MisingAlert() {
        let userInfo = ["aps":["sound":"default"]]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.alert
        
        XCTAssertNil(result, "")
    }
    
    func testGetAlert_MisingAps() {
        let userInfo = ["alert":"test"]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.alert
        
        XCTAssertNil(result, "")
    }
    
    func testGetString_Works() {
        let userInfo = ["key":"value"]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.string(key: "key")
        
        XCTAssertNotNil(result, "")
        XCTAssertEqual(result!, "value", "")
    }
    
    func testGetString_MissingKey() {
        let userInfo = ["key":"value"]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.string(key: "other_key")
        
        XCTAssertNil(result, "")
    }
    
    func testGetString_WrongType() {
        let userInfo = ["key":NSDate()]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.string(key: "key")
        
        XCTAssertNil(result, "")
    }
}
