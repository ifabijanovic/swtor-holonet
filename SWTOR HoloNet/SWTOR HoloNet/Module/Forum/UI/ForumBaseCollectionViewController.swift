//
//  ForumBaseCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumBaseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, Injectable, Themeable {

    // MARK: - Constants
    
    let InfiniteScrollOffset: CGFloat = 50.0
    let ScreenHeight = UIScreen.mainScreen().bounds.height
    
    private let FooterIdentifier = "footer"
    
    // MARK: - Injectable
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    
    // MARK: - Properties
    
    internal var refreshControl: UIRefreshControl?
    
    internal var canLoadMore = false
    internal var showLoadMore = false
    internal var loadedPage = 1
    internal var isPad = false
    
    private var needsContentLoad = true
    
    // MARK: - Lifecycle
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the pull to refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        self.collectionView!.addSubview(refreshControl)
        
        self.isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        
        self.collectionView!.registerNib(UINib(nibName: "LoadMoreCollectionReusableView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FooterIdentifier)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        self.applyTheme(self.theme)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isIOS7() {
            self.signalOrientationChange(self.collectionView!.collectionViewLayout, shouldDelay: UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        }
        self.loadContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.needsContentLoad = true
    }
    
    // MARK: - Content loading
    
    internal func loadContent() {
        if self.needsContentLoad {
            self.collectionView?.reloadData()
            self.onRefresh()
            self.needsContentLoad = false
        }
    }
    
    func willEnterForeground(notification: NSNotification) {
        self.loadContent()
    }
    
    // MARK: - Orientation change
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // If transitioning to Landscape invalidate CollectionView layout after a short delay
        // to avoid a FlowLayout warning. It seems CollectionView size isn't yet correctly set
        // when orientation occurs.
        self.signalOrientationChange(self.collectionView!.collectionViewLayout, shouldDelay: size.width > size.height)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        
        // If transitioning to Landscape invalidate CollectionView layout after a short delay
        // to avoid a FlowLayout warning. It seems CollectionView size isn't yet correctly set
        // when orientation occurs.
        self.signalOrientationChange(self.collectionView!.collectionViewLayout, shouldDelay: UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    }
    
    private func signalOrientationChange(layout: UICollectionViewLayout, shouldDelay: Bool) {
        if shouldDelay {
            var delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC))
            dispatch_after(delay, dispatch_get_main_queue()) {
                layout.invalidateLayout()
            }
        } else {
            layout.invalidateLayout()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self.showLoadMore ? CGSizeMake(0, 64.0) : CGSizeZero
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: FooterIdentifier, forIndexPath: indexPath) as! LoadMoreCollectionReusableView
            footer.applyTheme(self.theme)
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: - Scroll
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if !canLoadMore { return }
        
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - ScreenHeight - InfiniteScrollOffset
        if actualPosition >= contentHeight {
            self.onLoadMore()
        }
    }
    
    // MARK: - Activity indicator
    
    internal func showLoader() {
        self.showLoadMore = true
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    internal func hideLoader() {
        self.showLoadMore = false
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Abstract methods
    
    internal func onRefresh() {
        // Implement in derived classes
    }
    
    internal func onLoadMore() {
        // Implement in derived classes
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        // Scroll view indicator style
        self.collectionView!.indicatorStyle = theme.scrollViewIndicatorStyle
        
        // Refresh control tint
        self.refreshControl?.tintColor = theme.contentText
    }

}
