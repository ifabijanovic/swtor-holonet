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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the pull to refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        self.collectionView!.addSubview(refreshControl)
        
        self.collectionView!.registerNib(UINib(nibName: "LoadMoreCollectionReusableView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FooterIdentifier)
        
        self.applyTheme(self.theme)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self.showLoadMore ? CGSizeMake(0, 64.0) : CGSizeZero
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: FooterIdentifier, forIndexPath: indexPath) as LoadMoreCollectionReusableView
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
