//
//  DulfyModule.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Cleanse

struct DulfyModule: Cleanse.Module {
    static func configure<B: Binder>(binder: B) {
        binder.bind(DulfyUIFactory.self).to(factory: DulfyUIFactory.init)
    }
}

struct DulfyUIFactory {
    func dulfyViewController(toolbox: Toolbox) -> UIViewController {
        return DulfyViewController(toolbox: toolbox)
    }
}
