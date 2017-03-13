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
    var settings: Settings!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: SettingsTests.self)
        self.settings = Settings(bundle: bundle)
    }
    
    func testAppEmail() {
        XCTAssertEqual(self.settings.appEmail, "holonet.swtor@gmail.com")
    }
    
    func testCategoryQueryParam() {
        XCTAssertEqual(self.settings.categoryQueryParam, "category")
    }
    
    func testThreadQueryParam() {
        XCTAssertEqual(self.settings.threadQueryParam, "thread")
    }
    
    func testPostQueryParam() {
        XCTAssertEqual(self.settings.postQueryParam, "post")
    }
    
    func testPagingQueryParam() {
        XCTAssertEqual(self.settings.pageQueryParam, "page")
    }
    
    func testDevTrackerIconUrl() {
        XCTAssertEqual(self.settings.devTrackerIconUrl, "http://www.holonet.test/devIcon.png")
    }
    
    func testDevAvatarUrl() {
        XCTAssertEqual(self.settings.devAvatarUrl, "http://www.holonet.test/devAvatar.png")
    }
    
    func testStickyIconUrl() {
        XCTAssertEqual(self.settings.stickyIconUrl, "http://www.holonet.test/stickyIcon.png")
    }
    
    func testDulfyNetUrl() {
        XCTAssertEqual(self.settings.dulfyNetUrl, "http://dulfy.test")
    }
    
    func testRequestTimeout() {
        XCTAssertEqual(self.settings.requestTimeout, 10)
    }
    
    func testLocalized() {
        XCTAssertEqual(self.settings.localized.count, 3)
        
        let en = self.settings.localized[ForumLanguage.english.rawValue]
        XCTAssertNotNil(en)
        XCTAssertEqual(en!.forumDisplayUrl, "http://www.holonet.test/forum")
        XCTAssertEqual(en!.threadDisplayUrl, "http://www.holonet.test/thread")
        XCTAssertEqual(en!.rootCategoryId, 100)
        XCTAssertEqual(en!.devTrackerId, 1000)
        XCTAssertEqual(en!.devTrackerUrl, "http://www.holonet.test/dev")
        
        let fr = self.settings.localized[ForumLanguage.french.rawValue]
        XCTAssertNotNil(fr)
        XCTAssertEqual(fr!.forumDisplayUrl, "http://www.holonet.test/fr/forum")
        XCTAssertEqual(fr!.threadDisplayUrl, "http://www.holonet.test/fr/thread")
        XCTAssertEqual(fr!.rootCategoryId, 200)
        XCTAssertEqual(fr!.devTrackerId, 2000)
        XCTAssertEqual(fr!.devTrackerUrl, "http://www.holonet.test/fr/dev")
        
        let de = self.settings.localized[ForumLanguage.german.rawValue]
        XCTAssertNotNil(de)
        XCTAssertEqual(de!.forumDisplayUrl, "http://www.holonet.test/de/forum")
        XCTAssertEqual(de!.threadDisplayUrl, "http://www.holonet.test/de/thread")
        XCTAssertEqual(de!.rootCategoryId, 300)
        XCTAssertEqual(de!.devTrackerId, 3000)
        XCTAssertEqual(de!.devTrackerUrl, "http://www.holonet.test/de/dev")
    }
}
