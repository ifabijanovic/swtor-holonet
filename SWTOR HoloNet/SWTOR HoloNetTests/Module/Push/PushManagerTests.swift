//
//  PushManagerTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class PushManagerTests: XCTestCase {
    
    class PushManagerMock: PushManager {
        
        var didRegisterForPush = false
        
        var isPushEnabledValue = false
        override var isPushEnabled: Bool {
            get {
                return self.isPushEnabledValue
            }
        }
        
        init() {
            super.init(alertFactory: TestAlertFactory())
        }
        
        override init(alertFactory: AlertFactory) {
            super.init(alertFactory: alertFactory)
        }
        
        override func registerForPush() {
            self.didRegisterForPush = true
        }
        
    }
    
    func setDidCancel(value: Bool?) {
        if let value = value {
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: keyDidCancelPushAccess)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(keyDidCancelPushAccess)
        }
    }
    
    func setDidApprove(value: Bool?) {
        if let value = value {
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: keyDidApprovePushAccess)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(keyDidApprovePushAccess)
        }
    }
    
    func setTimestamp(date: NSDate?) {
        if let date = date {
            NSUserDefaults.standardUserDefaults().setObject(date, forKey: keyLastPushAccessRequestTimestamp)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(keyLastPushAccessRequestTimestamp)
        }
    }
    
    override func setUp() {
        super.setUp()
        
        self.setDidCancel(nil)
        self.setDidApprove(nil)
        self.setTimestamp(nil)
    }
    
    // MARK: - shouldRequestPushAccess
    
    func testShouldRequestPushAccess_FirstStart() {
        let manager = PushManagerMock()
        
        XCTAssertTrue(manager.shouldRequestPushAccess(), "")
    }

    func testShouldRequestPushAccess_PushEnabled() {
        let manager = PushManagerMock()
        manager.isPushEnabledValue = true
        
        XCTAssertFalse(manager.shouldRequestPushAccess(), "")
    }
    
    func testShouldRequestPushAccess_ApprovedButPushDisabled() {
        self.setDidApprove(true)
        let manager = PushManagerMock()
        
        XCTAssertFalse(manager.shouldRequestPushAccess(), "")
    }
    
    func testShouldRequestPushAccess_CanceledRecently() {
        self.setDidCancel(true)
        self.setTimestamp(NSDate())
        let manager = PushManagerMock()
        
        XCTAssertFalse(manager.shouldRequestPushAccess(), "")
    }
    
    func testShouldRequestPushAccess_CanceledSomeTimeAgo() {
        self.setDidCancel(true)
        self.setTimestamp(NSDate(timeIntervalSinceNow: -pushAccessRequestRetryInterval as NSTimeInterval))
        let manager = PushManagerMock()
        
        XCTAssertTrue(manager.shouldRequestPushAccess(), "")
    }
    
    // MARK: - requestPushAccess
    
    func testRequestPushAccess_Canceled() {
        let alertFactory = TestAlertFactory()
        let manager = PushManagerMock(alertFactory: alertFactory)
        let presenter = UIViewController()
        
        manager.requestPushAccess(viewController: presenter)
        
        XCTAssertNotNil(alertFactory.lastAlert, "")
        alertFactory.lastAlert!.tapCancel()
        
        XCTAssertFalse(manager.didRegisterForPush, "")
        XCTAssertTrue(NSUserDefaults.standardUserDefaults().boolForKey(keyDidCancelPushAccess), "")
        let date = NSUserDefaults.standardUserDefaults().objectForKey(keyLastPushAccessRequestTimestamp) as? NSDate
        XCTAssertNotNil(date, "")
        let diff = NSDate().timeIntervalSinceDate(date!)
        XCTAssertLessThanOrEqual(diff, 3, "")
    }
    
    func testRequestPushAccess_Accepted() {
        let alertFactory = TestAlertFactory()
        let manager = PushManagerMock(alertFactory: alertFactory)
        let presenter = UIViewController()
        
        manager.requestPushAccess(viewController: presenter)
        
        XCTAssertNotNil(alertFactory.lastAlert, "")
        alertFactory.lastAlert!.tapDefault()
        
        XCTAssertTrue(manager.didRegisterForPush, "")
        XCTAssertTrue(NSUserDefaults.standardUserDefaults().boolForKey(keyDidApprovePushAccess), "")
    }

}
