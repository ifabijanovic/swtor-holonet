//
//  URLComponentsTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class URLComponentsTests: XCTestCase {
    func testQueryValueForName_Success() {
        let url = "http://www.holonet.test?param=value"
        let value = URLComponents(string: url)!.queryValue(name: "param")!
        
        XCTAssertEqual(value, "value", "")
    }
    
    func testQueryValueForName_InvalidUrl() {
        let url = "invalid url string"
        let components = URLComponents(string: url)
        
        XCTAssertNil(components, "")
    }
    
    func testQueryValueForName_NoParameters() {
        let url = "http://www.holonet.test"
        let value = URLComponents(string: url)!.queryValue(name: "param")
        
        XCTAssertNil(value, "")
    }
    
    func testQueryValueForName_MissingParameter() {
        let url = "http://www.holonet.test?param=value"
        let value = URLComponents(string: url)!.queryValue(name: "otherParam")
        
        XCTAssertNil(value, "")
    }
    
    func testQueryValueForName_MultipleParameters() {
        let url = "http://www.holonet.test?param1=value1&param2=value2"
        let value1 = URLComponents(string: url)!.queryValue(name: "param1")!
        let value2 = URLComponents(string: url)!.queryValue(name: "param2")!
        
        XCTAssertEqual(value1, "value1", "")
        XCTAssertEqual(value2, "value2", "")
    }
}
