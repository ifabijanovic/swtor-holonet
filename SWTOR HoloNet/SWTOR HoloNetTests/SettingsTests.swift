//
//  SettingsTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class SettingsTests: XCTestCase {

    // MARK: - Properties
    
    var settings: Settings?
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        let bundle = NSBundle(forClass: SettingsTests.self)
        self.settings = Settings(bundle: bundle)
    }
    
    override func tearDown() {
        self.settings = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testForumDisplayUrl() {
        XCTAssertEqual(self.settings!.forumDisplayUrl, "http://www.holonet.test/forum", "")
    }
    
    func testThreadDisplayUrl() {
        XCTAssertEqual(self.settings!.threadDisplayUrl, "http://www.holonet.test/thread", "")
    }
    
    func testDevTrackerUrl() {
        XCTAssertEqual(self.settings!.devTrackerUrl, "http://www.holonet.test/dev", "")
    }
    
    func testCategoryQueryParam() {
        XCTAssertEqual(self.settings!.categoryQueryParam, "category", "")
    }
    
    func testThreadQueryParam() {
        XCTAssertEqual(self.settings!.threadQueryParam, "thread", "")
    }
    
    func testPostQueryParam() {
        XCTAssertEqual(self.settings!.postQueryParam, "post", "")
    }
    
    func testPagingQueryParam() {
        XCTAssertEqual(self.settings!.pageQueryParam, "page", "")
    }
    
    func testDevTrackerIconUrl() {
        XCTAssertEqual(self.settings!.devTrackerIconUrl, "http://www.holonet.test/devIcon.png", "")
    }
    
    func testStickyIconUrl() {
        XCTAssertEqual(self.settings!.stickyIconUrl, "http://www.holonet.test/stickyIcon.png", "")
    }

}
