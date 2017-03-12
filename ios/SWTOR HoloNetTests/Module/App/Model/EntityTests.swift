//
//  EntityTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 05/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

struct TestEntity: Entity {
    let id: Int
    
    var hashValue: Int { return self.id.hashValue }
}

class EntityTests: XCTestCase {
    func testEntityIsEqual() {
        let entity1 = TestEntity(id: 5)
        let entity2 = TestEntity(id: 5)
        
        XCTAssertEqual(entity1, entity2, "")
    }
    
    func testEntityNotEqual() {
        let entity1 = TestEntity(id: 5)
        let entity2 = TestEntity(id: 7)
        
        XCTAssertNotEqual(entity1, entity2, "")
    }
}
