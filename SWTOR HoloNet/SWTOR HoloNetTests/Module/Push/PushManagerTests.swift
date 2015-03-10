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
    
    class TestAction: Action {
        
        var type: String { get { return "test" } }
        
        var didPerform = false
        var userInfo: [NSObject : AnyObject]?
        var isForeground = false
        var returnValue = true
        
        func perform(userInfo: [NSObject : AnyObject]?, isForeground: Bool) -> Bool {
            self.didPerform = true
            self.userInfo = userInfo
            self.isForeground = isForeground
            return self.returnValue
        }
        
    }
    
    class TestActionFactory: ActionFactory {
        
        var action: TestAction? = TestAction()
        
        override func create(userInfo: [NSObject : AnyObject]) -> Action? {
            return self.action
        }
        
    }
    
    class PushManagerMock: PushManager {
        
        var didRegisterForPush = false
        var didResetBadge = false
        
        var isPushEnabledValue = false
        override var isPushEnabled: Bool {
            get {
                return self.isPushEnabledValue
            }
        }
        
        init() {
            let alertFactory = TestAlertFactory()
            super.init(alertFactory: alertFactory, actionFactory: TestActionFactory(alertFactory: alertFactory))
        }
        
        convenience init(alertFactory: AlertFactory) {
            self.init(alertFactory: alertFactory, actionFactory: TestActionFactory(alertFactory: alertFactory))
        }
        
        override init(alertFactory: AlertFactory, actionFactory: ActionFactory) {
            super.init(alertFactory: alertFactory, actionFactory: actionFactory)
        }
        
        override func registerForPush() {
            self.didRegisterForPush = true
        }
        
        override func resetBadge() {
            self.didResetBadge = true
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
    
    // MARK: - handleRemoteNotification
    
    func testHandleRemoteNotification_PerformsForegroundAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.Active
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(actionFactory.action!.didPerform, "")
        XCTAssertNotNil(actionFactory.action!.userInfo, "")
        XCTAssertEqual(actionFactory.action!.userInfo!.count, userInfo.count, "")
        XCTAssertEqual(actionFactory.action!.userInfo!["action"] as String, userInfo["action"]!, "")
        XCTAssertTrue(actionFactory.action!.isForeground, "")
        XCTAssertTrue(manager.didResetBadge, "")
    }
    
    func testHandleRemoteNotification_PerformsBackgroundAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.Inactive
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(actionFactory.action!.didPerform, "")
        XCTAssertNotNil(actionFactory.action!.userInfo, "")
        XCTAssertEqual(actionFactory.action!.userInfo!.count, userInfo.count, "")
        XCTAssertEqual(actionFactory.action!.userInfo!["action"] as String, userInfo["action"]!, "")
        XCTAssertFalse(actionFactory.action!.isForeground, "")
        XCTAssertTrue(manager.didResetBadge, "")
    }
    
    func testHandleRemoteNotification_InvalidAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.Active
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        actionFactory.action = nil
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertFalse(manager.didResetBadge, "")
    }
    
    func testHandleRemoteNotification_ActionFailed() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.Active
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        actionFactory.action!.returnValue = false
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertFalse(manager.didResetBadge, "")
    }

}
