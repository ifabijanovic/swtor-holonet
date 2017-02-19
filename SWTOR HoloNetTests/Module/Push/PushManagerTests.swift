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
    override func setUp() {
        super.setUp()
        
        self.set(didCancel: nil)
        self.set(didApprove: nil)
        self.set(timestamp: nil)
    }
}

extension PushManagerTests {
    fileprivate func set(didCancel value: Bool?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: keyDidCancelPushAccess)
        } else {
            UserDefaults.standard.removeObject(forKey: keyDidCancelPushAccess)
        }
    }
    
    fileprivate func set(didApprove value: Bool?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: keyDidApprovePushAccess)
        } else {
            UserDefaults.standard.removeObject(forKey: keyDidApprovePushAccess)
        }
    }
    
    fileprivate func set(timestamp date: Date?) {
        if let date = date {
            UserDefaults.standard.set(date, forKey: keyLastPushAccessRequestTimestamp)
        } else {
            UserDefaults.standard.removeObject(forKey: keyLastPushAccessRequestTimestamp)
        }
    }
}

extension PushManagerTests {
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
        self.set(didApprove: true)
        let manager = PushManagerMock()
        
        XCTAssertFalse(manager.shouldRequestPushAccess(), "")
    }
    
    func testShouldRequestPushAccess_CanceledRecently() {
        self.set(didCancel: true)
        self.set(timestamp: Date())
        let manager = PushManagerMock()
        
        XCTAssertFalse(manager.shouldRequestPushAccess(), "")
    }
    
    func testShouldRequestPushAccess_CanceledSomeTimeAgo() {
        self.set(didCancel: true)
        self.set(timestamp: Date(timeIntervalSinceNow: -pushAccessRequestRetryInterval))
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
        alertFactory.tapCancel()
        
        XCTAssertFalse(manager.didRegisterForPush, "")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: keyDidCancelPushAccess), "")
        let date = UserDefaults.standard.object(forKey: keyLastPushAccessRequestTimestamp) as? Date
        XCTAssertNotNil(date, "")
        let diff = NSDate().timeIntervalSince(date!)
        XCTAssertLessThanOrEqual(diff, 3, "")
    }
    
    func testRequestPushAccess_Accepted() {
        let alertFactory = TestAlertFactory()
        let manager = PushManagerMock(alertFactory: alertFactory)
        let presenter = UIViewController()
        
        manager.requestPushAccess(viewController: presenter)
        
        XCTAssertNotNil(alertFactory.lastAlert, "")
        alertFactory.tapDefault()
        
        XCTAssertTrue(manager.didRegisterForPush, "")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: keyDidApprovePushAccess), "")
    }
    
    // MARK: - handleRemoteNotification
    
    func testHandleRemoteNotification_PerformsForegroundAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.active
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(actionFactory.action!.didPerform, "")
        XCTAssertNotNil(actionFactory.action!.userInfo, "")
        XCTAssertEqual(actionFactory.action!.userInfo!.count, userInfo.count, "")
        XCTAssertEqual(actionFactory.action!.userInfo!["action"] as! String, userInfo["action"]!, "")
        XCTAssertTrue(actionFactory.action!.isForeground, "")
        XCTAssertTrue(manager.didResetBadge, "")
    }
    
    func testHandleRemoteNotification_PerformsBackgroundAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.inactive
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(actionFactory.action!.didPerform, "")
        XCTAssertNotNil(actionFactory.action!.userInfo, "")
        XCTAssertEqual(actionFactory.action!.userInfo!.count, userInfo.count, "")
        XCTAssertEqual(actionFactory.action!.userInfo!["action"] as! String, userInfo["action"]!, "")
        XCTAssertFalse(actionFactory.action!.isForeground, "")
        XCTAssertTrue(manager.didResetBadge, "")
    }
    
    func testHandleRemoteNotification_InvalidAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.active
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        actionFactory.action = nil
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(manager.didResetBadge, "")
    }
    
    func testHandleRemoteNotification_ActionFailed() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.active
        let alertFactory = TestAlertFactory()
        let actionFactory = TestActionFactory(alertFactory: alertFactory)
        actionFactory.action!.returnValue = false
        let manager = PushManagerMock(alertFactory: alertFactory, actionFactory: actionFactory)
        
        manager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(manager.didResetBadge, "")
    }

}

fileprivate class TestAction: Action {
    var type: String { get { return "test" } }
    
    var didPerform = false
    var userInfo: [AnyHashable : Any]?
    var isForeground = false
    var returnValue = true
    
    func perform(userInfo: [AnyHashable : Any]?, isForeground: Bool) -> Bool {
        self.didPerform = true
        self.userInfo = userInfo
        self.isForeground = isForeground
        return self.returnValue
    }
}

fileprivate class TestActionFactory: ActionFactory {
    var action: TestAction? = TestAction()
    
    override func create(userInfo: [AnyHashable : Any]) -> Action? {
        return self.action
    }
}

fileprivate class PushManagerMock: PushManager {
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
    
    convenience init(alertFactory: UIAlertFactory) {
        self.init(alertFactory: alertFactory, actionFactory: TestActionFactory(alertFactory: alertFactory))
    }
    
    override init(alertFactory: UIAlertFactory, actionFactory: ActionFactory) {
        super.init(alertFactory: alertFactory, actionFactory: actionFactory)
    }
    
    override func registerForPush() {
        self.didRegisterForPush = true
    }
    
    override func resetBadge() {
        self.didResetBadge = true
    }
}
