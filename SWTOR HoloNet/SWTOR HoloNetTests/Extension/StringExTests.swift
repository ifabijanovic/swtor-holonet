//
//  StringExTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class StringExTests: XCTestCase {

    // MARK: - stripNewLinesAndTabs()
    
    func testStripNewLinesAndTabs_Success() {
        let string = "some text\nwith new lines\tand tabs\n\t\n"
        let output = string.stripNewLinesAndTabs()
        
        XCTAssertEqual(output, "some textwith new linesand tabs", "")
    }
    
    func testStripNewLinesAndTabs_NoSpecialCharacters() {
        let string = "some text without new lines and tabs"
        let output = string.stripNewLinesAndTabs()
        
        XCTAssertEqual(output, string, "")
    }
    
    func testStripNewLinesAndTabs_EmptyString() {
        let string = ""
        let output = string.stripNewLinesAndTabs()
        
        XCTAssertEqual(output, string, "")
    }
    
    // MARK: - trimSpaces()
    
    func testTrimSpaces_Success() {
        let string = "     some   text with spaces   "
        let output = string.trimSpaces()
        
        XCTAssertEqual(output, "some   text with spaces", "")
    }
    
    func testTrimSpaces_NoSpacesToTrim() {
        let string = "some   text with spaces"
        let output = string.trimSpaces()
        
        XCTAssertEqual(output, string, "")
    }
    
    func testTrimSpaces_EmptyString() {
        let string = ""
        let output = string.trimSpaces()
        
        XCTAssertEqual(output, string, "")
    }
    
    // MARK: - stripSpaces()
    
    func testStripSpaces_Success() {
        let string = "     some   text with spaces"
        let output = string.stripSpaces()
        
        XCTAssertEqual(output, "sometextwithspaces", "")
    }
    
    func testStripSpaces_NoSpaces() {
        let string = "sometextwithoutspaces"
        let output = string.stripSpaces()
        
        XCTAssertEqual(output, string, "")
    }
    
    func testStripSpaces_EmptyString() {
        let string = ""
        let output = string.stripSpaces()
        
        XCTAssertEqual(output, string, "")
    }
    
    // MARK: - collapseMultipleSpaces()
    
    func testCollapseMultipleSpaces_Success() {
        let string = "     some    text with    a    lot of spaces     "
        let output = string.collapseMultipleSpaces()
        
        XCTAssertEqual(output, " some text with a lot of spaces ", "")
    }
    
    func testCollapseMultipleSpaces_NoSpaces() {
        let string = "sometextwithoutanyspaces"
        let output = string.collapseMultipleSpaces()
        
        XCTAssertEqual(output, string, "")
    }
    
    func testCollapseMultipleSpaces_EmptyString() {
        let string = ""
        let output = string.collapseMultipleSpaces()
        
        XCTAssertEqual(output, string, "")
    }
    
    // MARK: - formatPostDate()
    
    func testFormatPostDate_Success() {
        let string = "10.10.2014 , 10:10 AM | #1"
        let output = string.formatPostDate()
        
        XCTAssertEqual(output, "10.10.2014, 10:10 AM", "")
    }
    
    func testFormatPostDate_EmptyString() {
        let string = ""
        let output = string.formatPostDate()
        
        XCTAssertEqual(output, string, "")
    }

}
