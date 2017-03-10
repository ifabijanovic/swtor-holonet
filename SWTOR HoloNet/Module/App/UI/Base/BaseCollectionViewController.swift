//
//  BaseCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 15/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseCollectionViewController: UICollectionViewController, Themeable {
    let toolbox: Toolbox
    
    private(set) var theme: Theme?
    private(set) var disposeBag: DisposeBag
    
    init(toolbox: Toolbox, collectionViewLayout: UICollectionViewLayout) {
        self.toolbox = toolbox
        self.disposeBag = DisposeBag()
        super.init(collectionViewLayout: collectionViewLayout)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme?.statusBarStyle ?? .default
    }
    
    func apply(theme: Theme) {
        guard self.theme != theme else { return }
        
        self.theme = theme
        self.setNeedsStatusBarAppearanceUpdate()
        self.collectionView?.reloadData()
    }
}
