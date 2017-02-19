//
//  ForumBaseCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

private let InfiniteScrollOffset: CGFloat = 50.0
private let ScreenHeight = UIScreen.main.bounds.height
private let FooterIdentifier = "footer"

class ForumBaseCollectionViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    var refreshControl: UIRefreshControl?
    
    var canLoadMore = false
    var showLoadMore = false
    var loadedPage = 1
    var isPad = false
    
    fileprivate var needsContentLoad = true
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.needsContentLoad = true
    }
}

extension ForumBaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the pull to refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ForumBaseCollectionViewController.onRefresh), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        self.collectionView!.addSubview(refreshControl)
        
        self.isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        
        self.collectionView!.register(UINib(nibName: "LoadMoreCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FooterIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForumBaseCollectionViewController.willEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.applyTheme(self.theme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadContent()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    func willEnterForeground(notification: NSNotification) {
        self.loadContent()
    }
}

extension ForumBaseCollectionViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self.showLoadMore ? CGSize(width: 0, height: 64.0) : CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FooterIdentifier, for: indexPath) as! LoadMoreCollectionReusableView
            footer.applyTheme(self.theme)
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
    
    override func applyTheme(_ theme: Theme) {
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
