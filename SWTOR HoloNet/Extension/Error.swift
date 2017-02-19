//
//  Error.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension Error {
    var isMaintenance: Bool {
        return (self as? ForumError) == .maintenance
    }
}
