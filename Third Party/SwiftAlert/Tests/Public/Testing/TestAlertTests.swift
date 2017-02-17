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
        let expectCall = expectation(description: "")
        let button: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .default, title: "Default", handler: { expectCall.fulfill() })
        let alert = factory.createActionSheet(presenter: presenter, title: "Title", buttons: button) as! TestAlert
        
        alert.tapDefault()
        waitForExpectations(timeout: 3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }
    
    func testTapCancel() {
        let expectCall = expectation(description: "")
        let button: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .cancel, title: "Cancel", handler: { expectCall.fulfill() })
        let alert = factory.createActionSheet(presenter: presenter, title: "Title", buttons: button) as! TestAlert
        
        alert.tapCancel()
        waitForExpectations(timeout: 3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }
    
    func testTapDestructive() {
        let expectCall = expectation(description: "")
        let button: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .destructive, title: "Destructive", handler: { expectCall.fulfill() })
        let alert = factory.createActionSheet(presenter: presenter, title: "Title", buttons: button) as! TestAlert
        
        alert.tapDestructive()
        waitForExpectations(timeout: 3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }
    
    func testTapButtonAtIndex() {
        let expectCall1 = expectation(description: "")
        let expectCall2 = expectation(description: "")
        
        let button1: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .default, title: "Default", handler: { expectCall1.fulfill() })
        let button2: (style: UIAlertActionStyle, title: String, handler: (() -> ())?) = (style: .cancel, title: "Cancel", handler: { expectCall2.fulfill() })
        
        let alert = factory.createActionSheet(presenter: presenter, title: "Title", buttons: button1, button2) as! TestAlert
        
        alert.tapButtonAtIndex(index: 0)
        alert.tapButtonAtIndex(index: 1)
        waitForExpectations(timeout: 3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }

}
