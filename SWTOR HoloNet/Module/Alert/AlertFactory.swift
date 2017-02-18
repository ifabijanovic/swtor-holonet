//
//  AlertFactory.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 18/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit

protocol UIAlertFactory {
    func alert(title: String?, message: String?, actions: [(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?)]) -> UIAlertController
}

extension UIAlertFactory {
    func errorNetwork(cancelHandler: ((UIAlertAction) -> Void)?, retryHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        return self.alert(title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", actions: [
            (title: "No", style: .cancel, handler: cancelHandler),
            (title: "Yes", style: .default, handler: retryHandler)
            ]
        )
    }
    
    func infoMaintenance(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        return self.alert(title: "Maintenance", message: "SWTOR.com is currently unavailable while scheduled maintenance is being performed.", actions: [
            (title: "OK", style: .default, handler: handler)
            ]
        )
    }
}

struct DefaultUIAlertFactory: UIAlertFactory {
    func alert(title: String?, message: String?, actions: [(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?)]) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { controller.addAction(UIAlertAction(title: $0.title, style: $0.style, handler: $0.handler)) }
        return controller
    }
}
