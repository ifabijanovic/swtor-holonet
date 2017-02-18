//
//  ForumBaseCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumBaseCollectionViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    
    let InfiniteScrollOffset: CGFloat = 50.0
    let ScreenHeight = UIScreen.main.bounds.height
    
    private let FooterIdentifier = "footer"
    
    // MARK: - Properties
    
    internal var refreshControl: UIRefreshControl?
    
    internal var canLoadMore = false
    internal var showLoadMore = false
    internal var loadedPage = 1
    internal var isPad = false
    
    private var needsContentLoad = true
    private var needsLayout = false
    
    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        if self.needsLayout {
            self.needsLayout = false
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
            self.onRefresh()
            self.needsLayout = true
            self.needsContentLoad = false
        }
    }
    
    func willEnterForeground(notification: NSNotification) {
        self.loadContent()
    }
    
    // MARK: - Orientation change
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // If transitioning to Landscape invalidate CollectionView layout after a short delay
        // to avoid a FlowLayout warning. It seems CollectionView size isn't yet correctly set
        // when orientation occurs.
        self.signalOrientationChange(self.collectionView!.collectionViewLayout, shouldDelay: size.width > size.height)
    }
    
    private func signalOrientationChange(_ layout: UICollectionViewLayout, shouldDelay: Bool) {
        if shouldDelay {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                layout.invalidateLayout()
            }
        } else {
            layout.invalidateLayout()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
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
    
    // MARK: - Scroll
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    
    override func applyTheme(_ theme: Theme) {
        // Scroll view indicator style
        self.collectionView!.indicatorStyle = theme.scrollViewIndicatorStyle
        
        // Refresh control tint
        self.refreshControl?.tintColor = theme.contentText
    }

}
