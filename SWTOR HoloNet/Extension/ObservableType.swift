//
//  ObservableType.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 12/03/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

#if !TEST
import Firebase
#endif

extension ObservableType {
    func asDriverIgnoringErrors() -> Driver<E> {
        return asDriver(onErrorRecover: { error in
            #if !TEST
            FIRCrashMessage("\(error)")
            #endif
            
            #if DEBUG
                fatalError("\(error)")
            #else
                return Driver.empty()
            #endif
        })
    }
}
