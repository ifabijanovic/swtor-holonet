//
//  NavigationViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/08/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NavigationViewController: UINavigationController, Themeable {
    private let toolbox: Toolbox
    private var disposeBag: DisposeBag
    
    init(toolbox: Toolbox, rootViewController: UIViewController) {
        self.toolbox = toolbox
        self.disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
        self.pushViewController(rootViewController, animated: false)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toolbox
            .theme
            .drive(onNext: self.apply(theme:))
            .addDisposableTo(self.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    func apply(theme: Theme) {
        theme.apply(navigationBar: self.navigationBar, animate: true)
    }
}
