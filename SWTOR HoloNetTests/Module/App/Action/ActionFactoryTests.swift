//
//  ActionFactoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 11/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

//class ActionFactoryTests: XCTestCase {
//    fileprivate var factory: ActionFactory!
//    
//    override func setUp() {
//        super.setUp()
//        
//        let navigator = TestNavigator()
//        self.factory = ActionFactory(navigator: navigator)
//    }
//}
//
//extension ActionFactoryTests {
//    func testCreate_InvalidType() {
//        let action = self.factory.create(type: "invalid_type")
//        
//        XCTAssertNil(action, "")
//    }
//    
//    func testCreate_InvalidType_UserInfo() {
//        let userInfo = [Constants.Actions.UserInfo.type: "invalid_type"]
//        let action = self.factory.create(userInfo: userInfo)
//        
//        XCTAssertNil(action, "")
//    }
//    
//    func testCreate_InvalidUserInfo() {
//        let userInfo = ["key":"value"]
//        let action = self.factory.create(userInfo: userInfo)
//        
//        XCTAssertNil(action, "")
//    }
//    
//    func testCreate_DulfyAction() {
//        let action = self.factory.create(type: Constants.Actions.dulfy)
//        
//        XCTAssertNotNil(action, "")
//        XCTAssertTrue(action is DulfyAction, "")
//    }
//    
//    func testCreate_DulfyAction_UserInfo() {
//        let userInfo = [Constants.Actions.UserInfo.type: Constants.Actions.dulfy]
//        _ = self.factory.create(userInfo: userInfo)
//    }
//}
