//
//  ForumBaseCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let InfiniteScrollOffset: CGFloat = 50.0
private let ScreenHeight = UIScreen.main.bounds.height
private let FooterIdentifier = "footer"

class ForumBaseCollectionViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    private let language: Driver<ForumLanguage>
    
    var refreshControl: UIRefreshControl?
    private(set) var currentLanguage: ForumLanguage?
    
    var canLoadMore = false
    var showLoadMore = false
    var loadedPage = 1
    private(set) var isWideScreen = false
    
    fileprivate var needsContentLoad = true
    
    init(language: Driver<ForumLanguage>, toolbox: Toolbox, collectionViewLayout: UICollectionViewLayout) {
        self.language = language
        super.init(toolbox: toolbox, collectionViewLayout: collectionViewLayout)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.needsContentLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the pull to refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ForumBaseCollectionViewController.onRefresh), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        self.collectionView!.addSubview(refreshControl)
        
        self.isWideScreen = UIScreen.main.bounds.width > Constants.wideScreenThreshold
        
        self.collectionView!.register(UINib(nibName: "LoadMoreCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FooterIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForumBaseCollectionViewController.willEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.language
            .drive(onNext: { [unowned self] language in
                guard self.currentLanguage != language else { return }
                self.currentLanguage = language
                self.needsContentLoad = true
                self.loadContent()
            })
            .disposed(by: self.disposeBag)
        
        self.loadContent()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.isWideScreen = size.width > Constants.wideScreenThreshold
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    func willEnterForeground(notification: NSNotification) {
        self.loadContent()
    }
    
    // MARK: -

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self.showLoadMore ? CGSize(width: 0, height: 64.0) : CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FooterIdentifier, for: indexPath) as! LoadMoreCollectionReusableView
            if let theme = self.theme {
                footer.apply(theme: theme)
            }
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !canLoadMore { return }
        
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - ScreenHeight - InfiniteScrollOffset
        if actualPosition >= contentHeight {
            self.onLoadMore()
        }
    }
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        // Scroll view indicator style
        self.collectionView!.indicatorStyle = theme.scrollViewIndicatorStyle
        
        // Refresh control tint
        self.refreshControl?.tintColor = theme.contentText
    }
}

extension ForumBaseCollectionViewController {
    func loadContent() {
        if self.needsContentLoad {
            self.onRefresh()
            self.needsContentLoad = false
        }
    }
    
    func showLoader() {
        self.showLoadMore = true
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    func hideLoader() {
        self.showLoadMore = false
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    func onRefresh() {
        assert(false, "base onRefresh called")
    }
    
    func onLoadMore() {
        assert(false, "base onLoadMore")
    }
}
