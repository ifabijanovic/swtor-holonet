//
//  AlertDelegateTests.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 01/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class AlertDelegateTests: XCTestCase {

    func testSetsDelegate() {
        let alert = UIAlertView()
        XCTAssertNil(alert.delegate, "")
        
        let delegate = AlertDelegate(alertView: alert) { index in return }
        XCTAssertNotNil(alert.delegate, "")
        XCTAssertTrue(alert.delegate is AlertDelegate, "")
        XCTAssertEqual(alert.delegate! as AlertDelegate, delegate, "")
    }
    
    func testClickRemovesDelegate() {
        let alert = UIAlertView()
        let delegate = AlertDelegate(alertView: alert) { index in return }
        
        XCTAssertNotNil(alert.delegate, "")
        delegate.alertView(alert, clickedButtonAtIndex: 0)
        XCTAssertNil(alert.delegate, "")
    }
    
    func testClickFiresCallback() {
        let expectation = expectationWithDescription("")
        let random = Int(arc4random())
        let alert = UIAlertView()
        let delegate = AlertDelegate(alertView: alert) { index in
            XCTAssertEqual(index, random, "")
            expectation.fulfill()
        }
        
        delegate.alertView(alert, clickedButtonAtIndex: random)
        waitForExpectationsWithTimeout(3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }
    
}
