//
//  DulfyActionTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 11/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class DulfyActionTests: XCTestCase {

    var alertFactory: TestAlertFactory!
    var action: DulfyAction!
    
    var callback: NSObjectProtocol?
    
    override func setUp() {
        super.setUp()
        
        self.alertFactory = TestAlertFactory()
        self.action = DulfyAction(alertFactory: self.alertFactory)
    }
    
    override func tearDown() {
        super.tearDown()
        
        if let callback = self.callback {
            NSNotificationCenter.defaultCenter().removeObserver(callback)
            self.callback = nil
        }
    }
    
    func testPerform_MissingUserInfo() {
        let result = self.action.perform(nil, isForeground: false)
        XCTAssertFalse(result, "")
    }
    
    func testPerform_MissingMessage() {
        let url = "http://www.test.com"
        let userInfo = ["url":url]
        
        let result = self.action.perform(userInfo, isForeground: false)
        XCTAssertFalse(result, "")
    }
    
    func testPerform_MissingUrl() {
        let message = "test"
        let userInfo = ["aps":["alert":message]]
        let result = self.action.perform(userInfo, isForeground: false)
        XCTAssertFalse(result, "")
    }
    
    func testPerform_Background_Works() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [NSObject : AnyObject] = ["aps":["alert":message],"url":url]
        let expectation = expectationWithDescription("")
        
        self.callback = NSNotificationCenter.defaultCenter().addObserverForName(SwitchToTabNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            XCTAssertNotNil(notification.userInfo, "")
            XCTAssertNotNil(notification.userInfo!["index"], "")
            XCTAssertNotNil(notification.userInfo!["url"], "")
            expectation.fulfill()
        }
        
        let result = self.action.perform(userInfo, isForeground: false)
        XCTAssertTrue(result, "")
        
        waitForExpectationsWithTimeout(3) { error in
            if error != nil {
                XCTFail(error.description)
            }
        }
    }
    
    func testPerform_Foreground_RaisesAlert() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [NSObject : AnyObject] = ["aps":["alert":message],"url":url]
        let expectation = expectationWithDescription("")
        
        self.callback = NSNotificationCenter.defaultCenter().addObserverForName(ShowAlertNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            XCTAssertNotNil(notification.userInfo, "")
            XCTAssertNotNil(notification.userInfo!["alert"], "")
            XCTAssertNotNil(self.alertFactory.lastAlert)
            XCTAssertEqual(ObjectIdentifier(notification.userInfo!["alert"]!), ObjectIdentifier(self.alertFactory.lastAlert!), "")
            expectation.fulfill()
        }
        
        let result = self.action.perform(userInfo, isForeground: true)
        XCTAssertTrue(result, "")
        
        waitForExpectationsWithTimeout(3) { error in
            if error != nil {
                XCTFail(error.description)
            }
        }
    }
    
    func testPerform_Foreground_Cancel() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [NSObject : AnyObject] = ["aps":["alert":message],"url":url]
        
        self.callback = NSNotificationCenter.defaultCenter().addObserverForName(SwitchToTabNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            XCTFail("")
        }
        
        let result = self.action.perform(userInfo, isForeground: true)
        XCTAssertTrue(result, "")
        
        XCTAssertNotNil(self.alertFactory.lastAlert, "")
        self.alertFactory.lastAlert!.tapCancel()
    }
    
    func testPerform_Foreground_View() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [NSObject : AnyObject] = ["aps":["alert":message],"url":url]
        let expectation = expectationWithDescription("")
        
        self.callback = NSNotificationCenter.defaultCenter().addObserverForName(SwitchToTabNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            XCTAssertNotNil(notification.userInfo, "")
            XCTAssertNotNil(notification.userInfo!["index"], "")
            XCTAssertNotNil(notification.userInfo!["url"], "")
            expectation.fulfill()
        }
        
        let result = self.action.perform(userInfo, isForeground: true)
        XCTAssertTrue(result, "")
        
        XCTAssertNotNil(self.alertFactory.lastAlert, "")
        self.alertFactory.lastAlert!.tapDefault()
        
        waitForExpectationsWithTimeout(3) { error in
            if error != nil {
                XCTFail(error.description)
            }
        }
    }

}
