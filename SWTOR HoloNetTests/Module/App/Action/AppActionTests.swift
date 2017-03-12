//
//  AppActionTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 12/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ActionFactoryTests: XCTestCase {
    func testRemoteNotification_TypeMissing() {
        let userInfo: [AnyHashable: Any] = ["aps":["alert":"test"]]
        let result = AppAction(applicationState: .active, userInfo: userInfo)
        
        XCTAssertNil(result)
    }
    
    func testRemoteNotification_UnknownType() {
        let userInfo: [AnyHashable: Any] = ["aps":["alert":"test"],"type":"unknown_value"]
        let result = AppAction(applicationState: .active, userInfo: userInfo)
        
        XCTAssertNil(result)
    }
    
    func testRemoteNotification_DulfyWorks() {
        let alertValue = "test"
        let urlValue = "http://www.test.com"
        let typeValue = "dulfy"
        
        let userInfo: [AnyHashable: Any] = ["aps":["alert":alertValue],"url":urlValue,"type":typeValue]
        let result = AppAction(applicationState: .active, userInfo: userInfo)
        
        XCTAssertNotNil(result)
        switch result! {
        case let .dulfy(message, url, appState):
            XCTAssertEqual(message, alertValue)
            XCTAssertEqual(url, URL(string: urlValue)!)
            XCTAssertEqual(appState, .active)
        default:
            XCTFail()
        }
    }
    
    func testRemoteNotification_DulfyAlertMissing() {
        let userInfo: [AnyHashable: Any] = ["type":"dulfy","url":"http://www.test.com"]
        let result = AppAction(applicationState: .active, userInfo: userInfo)
        
        XCTAssertNil(result)
    }
    
    func testRemoteNotification_DulfyUrlMissing() {
        let userInfo: [AnyHashable: Any] = ["type":"dulfy","aps":["alert":"test"]]
        let result = AppAction(applicationState: .active, userInfo: userInfo)
        
        XCTAssertNil(result)
    }
}
