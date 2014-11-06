//
//  ForumParserTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 05/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ForumParserTests: XCTestCase {

    // MARK: - Properties
    
    var parser: ForumParser?
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        self.parser = ForumParser()
    }
    
    override func tearDown() {
        self.parser = nil
        
        super.tearDown()
    }
    
    // MARK: - linkParameter()

    func testLinkParameter_Success() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test?param=value"])
        let param = self.parser!.linkParameter(linkElement: link, name: "param")!
        
        XCTAssertEqual(param, "value", "")
    }
    
    func testLinkParameter_ElementNil() {
        let param = self.parser!.linkParameter(linkElement: nil, name: "param")
        
        XCTAssertNil(param, "")
    }
    
    func testLinkParameter_NoParameters() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test"])
        let param = self.parser!.linkParameter(linkElement: link, name: "param")
        
        XCTAssertNil(param, "")
    }
    
    func testLinkParameter_MissingParameter() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test?param=value"])
        let param = self.parser!.linkParameter(linkElement: link, name: "otherParam")
        
        XCTAssertNil(param, "")
    }
    
    func testLinkParameter_MultipleParameters() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test?param1=value1&param2=value2"])
        let param = self.parser!.linkParameter(linkElement: link, name: "param1")!
        
        XCTAssertEqual(param, "value1", "")
    }
    
    // MARK: - integerContent()
    
    func testIntegerContent_Success() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "123"
        let value = self.parser!.integerContent(element: html)!
        
        XCTAssertEqual(value, 123, "")
    }
    
    func testIntegerContent_Nested() {
        let parent = HTMLElement(tagName: "div", attributes: nil)
        let child = HTMLElement(tagName: "div", attributes: nil)
        child.parentElement = parent
        child.textContent = "123"
        let value = self.parser!.integerContent(element: parent)!
        
        XCTAssertEqual(value, 123, "")
    }
    
    func testIntegerContent_ElementNil() {
        let value = self.parser!.integerContent(element: nil)
        
        XCTAssertNil(value, "")
    }
    
    func testIntegerContent_NoInteger() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "some text"
        let value = self.parser!.integerContent(element: html)
        
        XCTAssertNil(value, "")
    }
    
    func testIntegetContent_MixedContent() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "some text with 123 numbers 456"
        let value = self.parser!.integerContent(element: html)
        
        XCTAssertNil(value, "")
    }
    
    // MARK: - postDate()
    
    func testPostDate_Success() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postDate(element: html)!
        
        XCTAssertEqual(value, "10.10.2014, 10:10AM", "")
    }
    
    func testPostDate_Nested() {
        let parent = HTMLElement(tagName: "div", attributes: nil)
        let child = HTMLElement(tagName: "div", attributes: nil)
        child.parentElement = parent
        child.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postDate(element: parent)!
        
        XCTAssertEqual(value, "10.10.2014, 10:10AM", "")
    }
    
    func testPostDate_ElementNil() {
        let value = self.parser!.postDate(element: nil)
        
        XCTAssertNil(value, "")
    }
    
    // MARK: - postNumber()
    
    func testPostNumber_Success() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postNumber(element: html)!
        
        XCTAssertEqual(value, 1, "")
    }
    
    func testPostNumber_Nested() {
        let parent = HTMLElement(tagName: "div", attributes: nil)
        let child = HTMLElement(tagName: "div", attributes: nil)
        child.parentElement = parent
        child.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postNumber(element: parent)!
        
        XCTAssertEqual(value, 1, "")
    }
    
    func testPostNumber_ElementNil() {
        let value = self.parser!.postNumber(element: nil)
        
        XCTAssertNil(value, "")
    }

}
