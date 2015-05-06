//
//  TestAlertTests.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 01/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class TestAlertTests: XCTestCase {
    
    let factory = TestAlertFactory()
    let presenter = UIViewController()
    
    func testTapDefault() {
        let expectCall = expectationWithDescription("")
        let button: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .Default, title: "Default", handler: { expectCall.fulfill() })
        let alert = factory.createActionSheet(presenter, title: "Title", buttons: button) as! TestAlert
        
        alert.tapDefault()
        waitForExpectationsWithTimeout(3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }
    
    func testTapCancel() {
        let expectCall = expectationWithDescription("")
        let button: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .Cancel, title: "Cancel", handler: { expectCall.fulfill() })
        let alert = factory.createActionSheet(presenter, title: "Title", buttons: button) as! TestAlert
        
        alert.tapCancel()
        waitForExpectationsWithTimeout(3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }
    
    func testTapDestructive() {
        let expectCall = expectationWithDescription("")
        let button: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .Destructive, title: "Destructive", handler: { expectCall.fulfill() })
        let alert = factory.createActionSheet(presenter, title: "Title", buttons: button) as! TestAlert
        
        alert.tapDestructive()
        waitForExpectationsWithTimeout(3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }
    
    func testTapButtonAtIndex() {
        let expectCall1 = expectationWithDescription("")
        let expectCall2 = expectationWithDescription("")
        
        let button1: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .Default, title: "Default", handler: { expectCall1.fulfill() })
        let button2: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .Cancel, title: "Cancel", handler: { expectCall2.fulfill() })
        
        let alert = factory.createActionSheet(presenter, title: "Title", buttons: button1, button2) as! TestAlert
        
        alert.tapButtonAtIndex(0)
        alert.tapButtonAtIndex(1)
        waitForExpectationsWithTimeout(3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }

}
