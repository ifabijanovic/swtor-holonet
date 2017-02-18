//
//  ActionFactoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 11/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ActionFactoryTests: XCTestCase {

    var factory: ActionFactory!
    
    override func setUp() {
        super.setUp()
        
        let alertFactory = TestAlertFactory()
        self.factory = ActionFactory(alertFactory: alertFactory)
    }
    
    func testCreate_InvalidType() {
        let action = self.factory.create(type: "invalid_type")
        
        XCTAssertNil(action, "")
    }
    
    func testCreate_InvalidType_UserInfo() {
        let userInfo = [keyActionType:"invalid_type"]
        let action = self.factory.create(userInfo: userInfo)
        
        XCTAssertNil(action, "")
    }
    
    func testCreate_InvalidUserInfo() {
        let userInfo = ["key":"value"]
        let action = self.factory.create(userInfo: userInfo)
        
        XCTAssertNil(action, "")
    }
    
    func testCreate_DulfyAction() {
        let action = self.factory.create(type: ActionTypeDulfy)
        
        XCTAssertNotNil(action, "")
        XCTAssertTrue(action is DulfyAction, "")
    }
    
    func testCreate_DulfyAction_UserInfo() {
        let userInfo = [keyActionType:ActionTypeDulfy]
        let action = self.factory.create(userInfo: userInfo)
    }

}
