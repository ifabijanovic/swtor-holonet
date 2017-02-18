//
//  Action.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 06/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

protocol Action: class {
    var type: String { get }
    func perform(userInfo: [AnyHashable : Any]?, isForeground: Bool) -> Bool
}
