//
//  Entity.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import Foundation

protocol Entity: Hashable, Equatable {
    var id: Int { get }
}

func ==<T: Entity>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}
