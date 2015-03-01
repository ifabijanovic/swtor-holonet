//
//  TestAlertFactoryTests.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 01/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class TestAlertFactoryTests: XCTestCase {
    
    let presenter = UIViewController()
    
    func testCreateAlert() {
        let factory = TestAlertFactory()
        let title = "Title"
        let message = "Message"
        
        let alert = factory.createAlert(presenter, title: title, message: message, buttons: (style: .Cancel, title: "Cancel", handler: {}), (style: .Default, title: "Default", handler: {}))
        
        XCTAssertTrue(alert is TestAlert, "")
        XCTAssertEqual(alert.buttons.count, 2, "")
    }
    
    func testCreateActionSheet() {
        let factory = TestAlertFactory()
        let title = "Title"
        
        let actionSheet = factory.createActionSheet(presenter, title: title, buttons: (style: .Cancel, title: "Cancel", handler: {}), (style: .Default, title: "Default", handler: {}))
        
        XCTAssertTrue(actionSheet is TestAlert, "")
        XCTAssertEqual(actionSheet.buttons.count, 2, "")
    }

}
