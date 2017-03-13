//
//  ForumListCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift

private let CategorySection = 0
private let ThreadSection = 1
private let CategoriesSectionTitle = "Categories"
private let ThreadsSectionTitle = "Threads"
private let CategoryCellIdentifier = "categoryCell"
private let ThreadCellIdentifier = "threadCell"
private let HeaderIdentifier = "header"

class ForumListCollectionViewController: ForumBaseCollectionViewController {
    fileprivate let category: ForumCategory?
    fileprivate let categoryRepository: ForumCategoryRepository
    fileprivate let threadRepository: ForumThreadRepository?
    
    fileprivate var categories: [ForumCategory] = []
    fileprivate var threads: [ForumThread] = []
    
    // MARK: -
    
    init(categoryRepository: ForumCategoryRepository, toolbox: Toolbox) {
        self.category = nil
        self.categoryRepository = categoryRepository
        self.threadRepository = nil
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(toolbox: toolbox, collectionViewLayout: layout)
    }
    
    init(category: ForumCategory, categoryRepository: ForumCategoryRepository, threadRepository: ForumThreadRepository, toolbox: Toolbox) {
        self.category = category
        self.categoryRepository = categoryRepository
        self.threadRepository = threadRepository
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(toolbox: toolbox, collectionViewLayout: layout)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.categories = []
        self.threads = []
        self.collectionView?.reloadData()
    }
    
    // MARK: -

    override func viewDidLoad() {        
        super.viewDidLoad()
        
        self.title = self.category?.title ?? "Forum"
        
        let bundle = Bundle.main
        self.collectionView!.register(UINib(nibName: "ForumCategoryCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: CategoryCellIdentifier)
        self.collectionView!.register(UINib(nibName: "ForumThreadCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: ThreadCellIdentifier)
        self.collectionView!.register(UINib(nibName: "TableHeaderCollectionReusableView", bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.toolbox.analytics.track(event: Constants.Analytics.Event.forum, properties: [Constants.Analytics.Property.type: "list"])
    }
    
    // MARK: -

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.category != nil ? 2 : 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == CategorySection {
            return self.categories.count
        } else if section == ThreadSection {
            return self.threads.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let theme = self.theme else { return CGSize.zero }
        
        // This value represents the difference from currently selected text size and
        // the smallest (default) value. It is added to the cell height for each label
        let textSizeDiff = theme.textSize.rawValue - TextSize.small.rawValue
        let width: CGFloat
        let height: CGFloat
            
        if indexPath.section == CategorySection {
            width = self.isWideScreen ? floor(collectionView.frame.width / 2.0) : collectionView.frame.width
            height = 104.0 + (3 * textSizeDiff)
        } else {
            width = collectionView.frame.width
            height = 64.0 + (2 * textSizeDiff)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == CategorySection && self.categories.isEmpty {
            return CGSize.zero
        }
        return CGSize(width: 0, height: 22.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == CategorySection && self.category != nil { return CGSize.zero }
        return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if indexPath.section == CategorySection {
            let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCellIdentifier, for: indexPath) as! ForumCategoryCollectionViewCell
            self.setup(cell: categoryCell, indexPath: indexPath)
            cell = categoryCell
        } else if indexPath.section == ThreadSection {
            let threadCell = collectionView.dequeueReusableCell(withReuseIdentifier: ThreadCellIdentifier, for: indexPath) as! ForumThreadCollectionViewCell
            self.setup(cell: threadCell, indexPath: indexPath)
            cell = threadCell
        } else {
            // Safeguard, should not happen
            cell = UICollectionViewCell()
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderIdentifier, for: indexPath) as! TableHeaderCollectionReusableView
            view.titleLabel.text = indexPath.section == CategorySection ? CategoriesSectionTitle : ThreadsSectionTitle
            if let theme = self.theme {
                view.apply(theme: theme)
            }
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath)
        if indexPath.section == CategorySection {
            // Category
            let category = self.categories[cell!.tag]
            
            guard let language = self.language,
                let localizedSettings = self.toolbox.settings.localized[language.rawValue]
                else { return }
            
            // Special case for Developer Tracker, treat this sub category as a thread
            if category.id == localizedSettings.devTrackerId {
                let thread = ForumThread.devTracker()
                self.navigate(thread: thread)
            } else {
                self.navigate(category: category)
            }
        } else {
            // Thread
            let thread = self.threads[cell!.tag]
            self.navigate(thread: thread)
        }
    }
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.collectionView!.backgroundColor = theme.contentBackground
    }
    
    override func onRefresh() {
        guard let language = self.language else { return }
        
        // Reloading content, set loaded page back to the first page
        self.loadedPage = 1
        // Disable infinite scroll while loading
        self.canLoadMore = false
        // Show loading indicator
        self.showLoader()
        
        let categories: Observable<[ForumCategory]>
        let threads: Observable<[ForumThread]>
        
        if let category = self.category {
            // Load subcategories and threads for the current category
            categories = self.categoryRepository.categories(language: language, parent: category)
            threads = self.threadRepository!.threads(language: language, category: category, page: 1)
        } else {
            // Forum root, only load categories
            categories = self.categoryRepository.categories(language: language)
            threads = Observable.just([])
        }
        
        Observable
            .combineLatest(categories, threads) { (categories: [ForumCategory], threads: [ForumThread]) -> DataResult in
                return DataResult(categories: categories, threads: threads)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { result in
                    self.categories = result.categories
                    self.collectionView!.reloadSections(IndexSet(integer: CategorySection))
                    
                    self.threads = result.threads
                    if !result.threads.isEmpty {
                        self.collectionView!.reloadSections(IndexSet(integer: ThreadSection))
                    }
                    
                    self.refreshControl?.endRefreshing()
                    
                    if self.category != nil {
                        // Enable infinite scrolling only if inside a category
                        // because forum root does not contain any threads
                        self.canLoadMore = true
                    } else {
                        self.hideLoader()
                    }
                },
                onError: { error in
                    self.refreshControl?.endRefreshing()
                    
                    if error.isMaintenance {
                        self.toolbox.navigator.showMaintenanceAlert { [weak self] _ in
                            self?.hideLoader()
                        }
                    } else {
                        self.toolbox.navigator.showNetworkErrorAlert(
                            cancelHandler: { [weak self] _ in
                                self?.hideLoader()
                            },
                            retryHandler: { [weak self] _ in
                                self?.onRefresh()
                            }
                        )
                    }
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    override func onLoadMore() {
        guard let language = self.language else { return }
        // Only applicable in categories, forum root does not contain threads
        guard let category = self.category else { return }
        
        // Disable infinite scroll while loading
        self.canLoadMore = false
        
        self.threadRepository!
            .threads(language: language, category: category, page: self.loadedPage + 1)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { threads in
                    let threadsSet = Set(threads)
                    let loadedThreads = Set(self.threads)
                    let newThreads = threadsSet.subtracting(loadedThreads)
                    
                    if newThreads.isEmpty {
                        // No new threads, disable infinite scrolling
                        self.canLoadMore = false
                        self.hideLoader()
                        return
                    }
                    
                    // Append the new threads and prepare indexes for table update
                    var indexes = [IndexPath]()
                    for thread in newThreads.sorted(by: { $0.loadIndex < $1.loadIndex }) {
                        indexes.append(IndexPath(row: self.threads.count, section: ThreadSection))
                        self.threads.append(thread)
                    }
                    
                    // Smoothly update the table by just inserting the new indexes
                    self.collectionView!.insertItems(at: indexes)
                    
                    // Mark this page as loaded and enable infinite scroll again
                    self.loadedPage += 1
                    self.canLoadMore = true
                },
                onError: { error in
                    self.toolbox.navigator.showNetworkErrorAlert(
                        cancelHandler: { [weak self] _ in
                            self?.hideLoader()
                        },
                        retryHandler: { [weak self] _ in
                            self?.onRefresh()
                        }
                    )
                }
            )
            .disposed(by: self.disposeBag)
    }
}

extension ForumListCollectionViewController {
    fileprivate func navigate(category: ForumCategory) {
        self.toolbox.navigator.navigate(from: self, to: .forumCategory(item: category), animated: true)
    }
    
    fileprivate func navigate(thread: ForumThread) {
        self.toolbox.navigator.navigate(from: self, to: .forumThread(item: thread), animated: true)
    }
    
    fileprivate func hasCategories() -> Bool {
        return categories.count > 0
    }
    
    fileprivate func hasThreads() -> Bool {
        return threads.count > 0
    }
    
    fileprivate func setup(cell: ForumCategoryCollectionViewCell, indexPath: IndexPath) {
        let category = self.categories[indexPath.row]
        
        // Set category icon if URL is defined in the model
        if let iconUrl = category.iconUrl, let url = URL(string: iconUrl) {
            cell.iconImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: Constants.Images.Placeholders.categoryIcon))
        }
        
        cell.titleLabel.text = category.title
        cell.statsLabel.text = category.stats
        cell.lastPostLabel.text = category.lastPost
        
        if let theme = self.theme {
            cell.apply(theme: theme)
        }
        
        cell.tag = indexPath.row
    }
    
    fileprivate func setup(cell: ForumThreadCollectionViewCell, indexPath: IndexPath) {
        let thread = self.threads[indexPath.row]
        
        // Set dev icon if thread is marked as having Bioware reply
        if thread.hasBiowareReply, let url = URL(string: self.toolbox.settings.devTrackerIconUrl) {
            cell.devImageView.isHidden = false
            cell.devImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: Constants.Images.Placeholders.devTrackerIcon))
        } else {
            cell.devImageView.isHidden = true
        }
        
        // Set sticky icon if thread is marked with sticky
        if thread.isSticky, let url = URL(string: self.toolbox.settings.stickyIconUrl) {
            cell.stickyImageView.isHidden = false
            cell.stickyImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: Constants.Images.Placeholders.stickyIcon))
        } else {
            cell.stickyImageView.isHidden = true
        }
        
        cell.titleLabel.text = thread.title
        cell.authorLabel.text = thread.author
        cell.repliesViewsLabel.text = "R: \(thread.replies), V: \(thread.views)"
        
        if let theme = self.theme {
            cell.apply(theme: theme)
        }
        
        cell.tag = indexPath.row
    }
}

fileprivate struct DataResult {
    let categories: [ForumCategory]
    let threads: [ForumThread]
}
