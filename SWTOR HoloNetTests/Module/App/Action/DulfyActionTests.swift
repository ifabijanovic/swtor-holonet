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

    var navigator: TestNavigator!
    var action: DulfyAction!
    
    var callback: NSObjectProtocol?
    
    override func setUp() {
        super.setUp()
        
        self.navigator = TestNavigator()
        self.action = DulfyAction(navigator: self.navigator)
    }
    
    override func tearDown() {
        super.tearDown()
        
        if let callback = self.callback {
            NotificationCenter.default.removeObserver(callback)
            self.callback = nil
        }
    }
    
    func testPerform_MissingUserInfo() {
        let result = self.action.perform(userInfo: nil, isForeground: false)
        XCTAssertFalse(result, "")
    }
    
    func testPerform_MissingMessage() {
        let url = "http://www.test.com"
        let userInfo = ["url":url]
        
        let result = self.action.perform(userInfo: userInfo, isForeground: false)
        XCTAssertFalse(result, "")
    }
    
    func testPerform_MissingUrl() {
        let message = "test"
        let userInfo = ["aps":["alert":message]]
        let result = self.action.perform(userInfo: userInfo, isForeground: false)
        XCTAssertFalse(result, "")
    }
    
    func testPerform_Background_Works() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [AnyHashable : Any] = ["aps":["alert":message],"url":url]
        let expectation = self.expectation(description: "")
        
        self.callback = NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.Notifications.switchToTab), object: nil, queue: OperationQueue.main) { notification in
            XCTAssertNotNil(notification.userInfo, "")
            XCTAssertNotNil(notification.userInfo!["index"], "")
            XCTAssertNotNil(notification.userInfo!["url"], "")
            expectation.fulfill()
        }
        
        let result = self.action.perform(userInfo: userInfo, isForeground: false)
        XCTAssertTrue(result, "")
        
        waitForExpectations(timeout: 3) { error in
            if error != nil {
                XCTFail(error.debugDescription)
            }
        }
    }
    
    func testPerform_Foreground_RaisesAlert() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [AnyHashable : Any] = ["aps":["alert":message],"url":url]
        
        XCTAssertFalse(self.navigator.didShowAlert)
        let result = self.action.perform(userInfo: userInfo, isForeground: true)
        XCTAssertTrue(result, "")
        XCTAssertTrue(self.navigator.didShowAlert)
    }
    
    func testPerform_Foreground_Cancel() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [AnyHashable : Any] = ["aps":["alert":message],"url":url]
        
        self.callback = NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.Notifications.switchToTab), object: nil, queue: OperationQueue.main) { notification in
            XCTFail("")
        }
        
        let result = self.action.perform(userInfo: userInfo, isForeground: true)
        XCTAssertTrue(result, "")
        self.navigator.tap(style: .cancel)
    }
    
    func testPerform_Foreground_View() {
        let message = "test"
        let url = "http://www.test.com"
        let userInfo: [AnyHashable : Any] = ["aps":["alert":message],"url":url]
        let expectation = self.expectation(description: "")
        
        self.callback = NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.Notifications.switchToTab), object: nil, queue: OperationQueue.main) { notification in
            XCTAssertNotNil(notification.userInfo, "")
            XCTAssertNotNil(notification.userInfo!["index"], "")
            XCTAssertNotNil(notification.userInfo!["url"], "")
            expectation.fulfill()
        }
        
        let result = self.action.perform(userInfo: userInfo, isForeground: true)
        XCTAssertTrue(result, "")
        self.navigator.tap(style: .default)
        
        waitForExpectations(timeout: 3) { error in
            if error != nil {
                XCTFail(error.debugDescription)
            }
        }
    }
}
