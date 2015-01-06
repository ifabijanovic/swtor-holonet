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
    
    // MARK: - substringToIndex()
    
    func testSubstringToIndex_Success() {
        let string = "some text, nothing special here"
        let output = string.substringToIndex(9)
        
        XCTAssertEqual(output, "some text", "")
    }
    
    func testSubstringToIndex_OutOfBounds() {
        let string = "short string"
        let output = string.substringToIndex(100)
        
        XCTAssertEqual(string, output, "")
    }
    
    func testSubstringToIndex_NegativeIndex() {
        let string = "some text, nothing special here"
        let output = string.substringToIndex(-5)
        
        XCTAssertEqual(output, "", "")
    }
    
    func testSubstringToIndex_EmptyString() {
        let string = ""
        let output = string.substringToIndex(5)
        
        XCTAssertEqual(output, string, "")
    }
    
    // MARK: - substringFromIndex()
    
    func testSubstringFromIndex_Success() {
        let string = "some text, nothing special here"
        let output = string.substringFromIndex(11)
        
        XCTAssertEqual(output, "nothing special here", "")
    }
    
    func testSubstringFromIndex_OutOfBounds() {
        let string = "short string"
        let output = string.substringFromIndex(100)
        
        XCTAssertEqual(output, "", "")
    }
    
    func testSubstringFromIndex_NegativeIndex() {
        let string = "some text, nothing special here"
        let output = string.substringFromIndex(-5)
        
        XCTAssertEqual(output, "", "")
    }
    
    func testSubstringFromIndex_EmptyString() {
        let string = ""
        let output = string.substringFromIndex(5)
        
        XCTAssertEqual(output, string, "")
    }
    
    // MARK: - substringWithRange()
    
    func testSubstringWithRange_Success() {
        let string = "some text, nothing special here"
        let range = Range<Int>(start: 5, end: 18)
        let output = string.substringWithRange(range)
        
        XCTAssertEqual(output, "text, nothing", "")
    }
    
    func testSubstringWithRange_StartOutOfBounds() {
        let string = "some text, nothing special here"
        let range = Range<Int>(start: 100, end: 18)
        let output = string.substringWithRange(range)
        
        XCTAssertEqual(output, "", "")
    }
    
    func testSubstringWithRange_EndOutOfBounds() {
        let string = "some text, nothing special here"
        let range = Range<Int>(start: 5, end: 100)
        let output = string.substringWithRange(range)
        
        XCTAssertEqual(output, "text, nothing special here", "")
    }
    
    func testSubstringWithRange_NegativeStartIndex() {
        let string = "some text, nothing special here"
        let range = Range<Int>(start: -5, end: 18)
        let output = string.substringWithRange(range)
        
        XCTAssertEqual(output, "", "")
    }
    
    func testSubstringWithRange_NegativeEndIndex() {
        let string = "some text, nothing special here"
        let range = Range<Int>(start: 5, end: -18)
        let output = string.substringWithRange(range)
        
        XCTAssertEqual(output, "", "")
    }
    
    func testSubstringWithRange_EmptyString() {
        let string = ""
        let range = Range<Int>(start: 5, end: 18)
        let output = string.substringWithRange(range)
        
        XCTAssertEqual(output, string, "")
    }

}
