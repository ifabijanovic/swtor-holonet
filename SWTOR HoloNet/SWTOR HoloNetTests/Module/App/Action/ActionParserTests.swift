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
        let result = parser.getAlert()
        
        XCTAssertNotNil(result, "")
        XCTAssertEqual(result!, "test", "")
    }
    
    func testGetAlert_MisingAlert() {
        let userInfo = ["aps":["sound":"default"]]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.getAlert()
        
        XCTAssertNil(result, "")
    }
    
    func testGetAlert_MisingAps() {
        let userInfo = ["alert":"test"]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.getAlert()
        
        XCTAssertNil(result, "")
    }
    
    func testGetString_Works() {
        let userInfo = ["key":"value"]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.getString(key: "key")
        
        XCTAssertNotNil(result, "")
        XCTAssertEqual(result!, "value", "")
    }
    
    func testGetString_MissingKey() {
        let userInfo = ["key":"value"]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.getString(key: "other_key")
        
        XCTAssertNil(result, "")
    }
    
    func testGetString_WrongType() {
        let userInfo = ["key":NSDate()]
        let parser = ActionParser(userInfo: userInfo)
        let result = parser.getString(key: "key")
        
        XCTAssertNil(result, "")
    }

}
