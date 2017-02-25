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
            UserDefaults.standard.set(value, forKey: Constants.Push.UserDefaults.didCancelPushAccess)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Push.UserDefaults.didCancelPushAccess)
        }
    }
    
    fileprivate func set(didApprove value: Bool?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: Constants.Push.UserDefaults.didApprovePushAccess)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Push.UserDefaults.didApprovePushAccess)
        }
    }
    
    fileprivate func set(timestamp date: Date?) {
        if let date = date {
            UserDefaults.standard.set(date, forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp)
        }
    }
}

extension PushManagerTests {
    func testShouldRequestPushAccess_FirstStart() {
        let manager = PushManagerMock()
        
        XCTAssertTrue(manager.shouldRequestAccess, "")
    }

    func testShouldRequestPushAccess_PushEnabled() {
        let manager = PushManagerMock()
        manager.isEnabledValue = true
        
        XCTAssertFalse(manager.shouldRequestAccess, "")
    }
    
    func testShouldRequestPushAccess_ApprovedButPushDisabled() {
        self.set(didApprove: true)
        let manager = PushManagerMock()
        
        XCTAssertFalse(manager.shouldRequestAccess, "")
    }
    
    func testShouldRequestPushAccess_CanceledRecently() {
        self.set(didCancel: true)
        self.set(timestamp: Date())
        let manager = PushManagerMock()
        
        XCTAssertFalse(manager.shouldRequestAccess, "")
    }
    
    func testShouldRequestPushAccess_CanceledSomeTimeAgo() {
        self.set(didCancel: true)
        self.set(timestamp: Date(timeIntervalSinceNow: -Constants.Push.accessRequestRetryInterval))
        let manager = PushManagerMock()
        
        XCTAssertTrue(manager.shouldRequestAccess, "")
    }
    
    // MARK: - requestPushAccess
    
    func testRequestPushAccess_Canceled() {
        let alertFactory = TestAlertFactory()
        let manager = PushManagerMock(alertFactory: alertFactory)
        let presenter = UIViewController()
        
        manager.requestAccess(presenter: presenter)
        
        XCTAssertNotNil(alertFactory.lastAlert, "")
        alertFactory.tapCancel()
        
        XCTAssertFalse(manager.didRegisterForPush, "")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: Constants.Push.UserDefaults.didCancelPushAccess), "")
        let date = UserDefaults.standard.object(forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp) as? Date
        XCTAssertNotNil(date, "")
        let diff = NSDate().timeIntervalSince(date!)
        XCTAssertLessThanOrEqual(diff, 3, "")
    }
    
    func testRequestPushAccess_Accepted() {
        let alertFactory = TestAlertFactory()
        let manager = PushManagerMock(alertFactory: alertFactory)
        let presenter = UIViewController()
        
        manager.requestAccess(presenter: presenter)
        
        XCTAssertNotNil(alertFactory.lastAlert, "")
        alertFactory.tapDefault()
        
        XCTAssertTrue(manager.didRegisterForPush, "")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: Constants.Push.UserDefaults.didApprovePushAccess), "")
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

fileprivate class PushManagerMock: DefaultPushManager {
    var didRegisterForPush = false
    var didResetBadge = false
    
    var isEnabledValue = false
    override var isEnabled: Bool { return self.isEnabledValue }
    
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
    
    override func register() {
        self.didRegisterForPush = true
    }
    
    override func resetBadge() {
        self.didResetBadge = true
    }
}
