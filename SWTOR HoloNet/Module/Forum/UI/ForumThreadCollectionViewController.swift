//
//  ForumThreadCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift

private let PostCellIdentifier = "postCell"
private let HeaderIdentifier = "header"

class ForumThreadCollectionViewController: ForumBaseCollectionViewController {
    fileprivate let thread: ForumThread
    fileprivate let postRepository: ForumPostRepository
    fileprivate var posts: [ForumPost] = []
    
    fileprivate var postsPerPage = 10
    fileprivate var sizingCell: ForumPostCollectionViewCell!

    fileprivate var disposeBag = DisposeBag()
    
    // MARK: -
    
    init(thread: ForumThread, postRepository: ForumPostRepository) {
        self.thread = thread
        self.postRepository = postRepository
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.posts = []
        self.collectionView?.reloadData()
    }
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Thread"
        
        let bundle = Bundle.main
        let cellNib = UINib(nibName: "ForumPostCollectionViewCell", bundle: bundle)
        self.sizingCell = cellNib.instantiate(withOwner: nil, options: nil).first as! ForumPostCollectionViewCell
        
        self.collectionView!.register(cellNib, forCellWithReuseIdentifier: PostCellIdentifier)
        self.collectionView!.register(UINib(nibName: "ForumThreadHeaderCollectionReusableView", bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
        
        let safariButton = UIBarButtonItem(image: UIImage(named: Constants.Images.Icons.safari), style: .plain, target: self, action: #selector(ForumThreadCollectionViewController.safariTapped))
        self.navigationItem.rightBarButtonItem = safariButton
        
        if self.thread.isDevTracker {
            self.postsPerPage = 20
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.analytics.track(event: Constants.Analytics.Event.forum, properties: [Constants.Analytics.Property.type: "thread"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    // MARK: -

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.sizeForItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Calculate height of title text
        let largeSize = CGSize(width: UIScreen.main.bounds.size.width - 30, height: 9999)
        let font = UIFont.systemFont(ofSize: 17.0)
        let attributes = [NSFontAttributeName: font]
        let titleSize = (self.thread.title as NSString).boundingRect(with: largeSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        let titleHeight = ceil(titleSize.height)

        return CGSize(width: 0, height: titleHeight + 16.0)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCellIdentifier, for: indexPath) as! ForumPostCollectionViewCell
        
        self.fill(cell: cell, at: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderIdentifier, for: indexPath) as! ForumThreadHeaderCollectionReusableView
            header.textLabel.text = self.thread.title
            header.applyTheme(self.theme)
            return header
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let post = self.posts[cell.tag]
        let viewController = ForumPostViewController(post: post)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: -
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.collectionView!.backgroundColor = theme.contentBackground
    }

    override func onRefresh() {
        // Reloading content, set loaded page back to the first page
        self.loadedPage = 1
        // Disable infinite scroll while loading
        self.canLoadMore = false
        // Show loading indicator
        self.showLoader()
        
        self.postRepository
            .posts(thread: self.thread, page: 1)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { posts in
                    // Set retrieved posts and reload table
                    self.posts = posts
                    self.collectionView!.reloadData()
                    self.refreshControl?.endRefreshing()
                    // Enable infinite scroll if initial page is full
                    if posts.count == self.postsPerPage {
                        self.canLoadMore = true
                    } else {
                        self.canLoadMore = false
                        self.hideLoader()
                    }
                },
                onError: { error in
                    self.refreshControl?.endRefreshing()
                    
                    let alertController: UIAlertController
                    if error.isMaintenance {
                        alertController = self.alertFactory.infoMaintenance { [weak self] _ in
                            self?.hideLoader()
                        }
                    } else {
                        alertController = self.alertFactory.errorNetwork(
                            cancelHandler: { [weak self] _ in
                                self?.hideLoader()
                            },
                            retryHandler: { [weak self] _ in
                                self?.onRefresh()
                            }
                        )
                    }
                    self.present(alertController, animated: true, completion: nil)
                }
            )
            .addDisposableTo(self.disposeBag)
    }
    
    override func onLoadMore() {
        // Disable infinite scroll while loading
        self.canLoadMore = false
        
        self.postRepository
            .posts(thread: self.thread, page: self.loadedPage + 1)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { posts in
                    // Get a difference of freshly loaded posts with the ones already loaded before
                    let postsSet = Set(posts)
                    let loadedPosts = Set(self.posts)
                    let newPosts = postsSet.subtracting(loadedPosts)
                    
                    if newPosts.isEmpty {
                        // No new posts, disable infinite scrolling
                        self.canLoadMore = false
                        self.hideLoader()
                        return
                    }
                    
                    // Append the new posts and prepare indexes for table update
                    var indexes = [IndexPath]()
                    for post in newPosts.sorted(by: { $0.id < $1.id }) {
                        indexes.append(IndexPath(row: self.posts.count, section: 0))
                        self.posts.append(post)
                    }
                    
                    // Smoothly update the table by just inserting the new indexes
                    self.collectionView!.insertItems(at: indexes)
                    
                    // Mark this page as loaded and enable infinite scroll again
                    self.loadedPage += 1
                    self.canLoadMore = true
                },
                onError: { error in
                    let alertController = self.alertFactory.errorNetwork(
                        cancelHandler: { [weak self] _ in
                            self?.hideLoader()
                        },
                        retryHandler: { [weak self] _ in
                            self?.onRefresh()
                        }
                    )
                    self.present(alertController, animated: true, completion: nil)
                }
            )
            .addDisposableTo(self.disposeBag)
    }
}

extension ForumThreadCollectionViewController {
    func safariTapped() {
        let url = self.postRepository.url(thread: self.thread, page: 0)
        UIApplication.shared.openURL(url)
    }
    
    fileprivate func fill(cell: ForumPostCollectionViewCell, at indexPath: IndexPath) {
        let post = self.posts[indexPath.row]
        
        // Set user avatar image if URL is defined in the model
        if let avatarUrl = post.avatarUrl, let url = URL(string: avatarUrl) {
            cell.avatarImageView.isHidden = false
            cell.avatarImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: Constants.Images.Placeholders.avatar))
        } else {
            cell.avatarImageView.isHidden = true
        }
        
        // Set dev icon if post is marked as Bioware post
        if post.isBiowarePost, let url = URL(string: self.settings.devTrackerIconUrl) {
            cell.devImageView.isHidden = false
            cell.devImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: Constants.Images.Placeholders.devTrackerIcon))
        } else {
            cell.devImageView.isHidden = true
        }
        
        cell.dateLabel.text = post.postNumber != nil ? "\(post.date) | #\(post.postNumber!)" : post.date
        cell.usernameLabel.text = post.username
        cell.textView.text = post.text
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row
    }
    
    fileprivate func sizeForItem(at indexPath: IndexPath) -> CGSize {
        if let cell = self.sizingCell {
            // Fill it with data
            self.fill(cell: cell, at: indexPath)
            cell.textView.preferredMaxLayoutWidth = self.collectionView!.frame.width - 30.0
            // Now that it has data tell it to size itself
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

            return CGSize(width: self.collectionView!.frame.size.width, height: size.height)
        }
        return CGSize.zero
    }
}
