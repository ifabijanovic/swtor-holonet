//
//  BaseTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 15/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseTableViewController: UITableViewController, Themeable {
    let services: StandardServices
    
    private(set) var theme: Theme?
    private(set) var disposeBag: DisposeBag
    
    init(services: StandardServices, style: UITableViewStyle) {
        self.services = services
        self.disposeBag = DisposeBag()
        super.init(style: style)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.services
            .theme
            .drive(onNext: self.apply(theme:))
            .addDisposableTo(self.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme?.statusBarStyle ?? .default
    }
    
    func apply(theme: Theme) {
        guard self.theme != theme else { return }
        
        self.theme = theme
        self.setNeedsStatusBarAppearanceUpdate()
        self.tableView.reloadData()
    }
}
