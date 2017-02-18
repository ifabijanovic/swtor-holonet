//
//  Entity.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class Entity: Hashable, Equatable {
    
    // MARK: - Properties
    
    var id: Int
    
    // MARK: - Init
    
    init(id: Int) {
        self.id = id
    }
    
    var hashValue: Int {
        return self.id.hashValue
    }
}

func == (lhs: Entity, rhs: Entity) -> Bool {
    return lhs.id == rhs.id
}
