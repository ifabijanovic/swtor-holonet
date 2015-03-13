//
//  ActionSheetDelegateTests.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 01/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ActionSheetDelegateTests: XCTestCase {

    func testSetsDelegate() {
        let actionSheet = UIActionSheet()
        XCTAssertNil(actionSheet.delegate, "")
        
        let delegate = ActionSheetDelegate(actionSheet: actionSheet) { index in return }
        XCTAssertNotNil(actionSheet.delegate, "")
        XCTAssertTrue(actionSheet.delegate is ActionSheetDelegate, "")
        XCTAssertEqual(actionSheet.delegate! as ActionSheetDelegate, delegate, "")
    }
    
    func testClickRemovesDelegate() {
        let actionSheet = UIActionSheet()
        let delegate = ActionSheetDelegate(actionSheet: actionSheet) { index in return }
        
        XCTAssertNotNil(actionSheet.delegate, "")
        delegate.actionSheet(actionSheet, clickedButtonAtIndex: 0)
        XCTAssertNil(actionSheet.delegate, "")
    }
    
    func testClickFiresCallback() {
        let expectation = expectationWithDescription("")
        let random = Int(arc4random())
        let actionSheet = UIActionSheet()
        let delegate = ActionSheetDelegate(actionSheet: actionSheet) { index in
            XCTAssertEqual(index, random, "")
            expectation.fulfill()
        }
        
        delegate.actionSheet(actionSheet, clickedButtonAtIndex: random)
        waitForExpectationsWithTimeout(3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }

}
