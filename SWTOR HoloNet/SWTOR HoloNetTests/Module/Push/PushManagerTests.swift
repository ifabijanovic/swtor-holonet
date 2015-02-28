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
        
        var isPushEnabledValue = false
        override var isPushEnabled: Bool {
            get {
                return self.isPushEnabledValue
            }
        }
        
        override init() {
            super.init()
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

}
