//
//  AppActionQueue.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 12/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct AppActionQueue {
    private let publishSubject: PublishSubject<AppAction>
    let queue: Driver<AppAction>
    
    init() {
        self.publishSubject = PublishSubject<AppAction>()
        self.queue = self.publishSubject.asDriverIgnoringErrors()
    }
    
    func enqueue(action: AppAction) {
        self.publishSubject.onNext(action)
    }
    
    func enqueueRemoteNotification(applicationState: UIApplicationState, userInfo: [AnyHashable : Any]) {
        guard let action = AppAction(applicationState: applicationState, userInfo: userInfo) else { return }
        self.enqueue(action: action)
    }
}
