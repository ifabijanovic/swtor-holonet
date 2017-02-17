//
//  ForumThreadCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadCollectionViewController: ForumBaseCollectionViewController {

    // MARK: - Constants
    
    private let PostCellIdentifier = "postCell"
    private let PostSegue = "postSegue"
    private let HeaderIdentifier = "header"
    private var PostsPerPage = 10
    
    // MARK: - Properties
    
    var thread: ForumThread!
    
    private var postRepo: ForumPostRepository!
    private var posts: Array<ForumPost>?
    
    private var sizingCell: ForumPostCollectionViewCell!
    
    // MARK: - Outlets
    
    @IBAction func safariTapped(sender: AnyObject) {
        let urlString = self.postRepo.url(thread: self.thread, page: 0)
        if let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postRepo = ForumPostRepository(settings: self.settings)
        
        let bundle = Bundle.main
        let cellNib = UINib(nibName: "ForumPostCollectionViewCell", bundle: bundle)
        self.sizingCell = cellNib.instantiate(withOwner: nil, options: nil).first as! ForumPostCollectionViewCell
        
        self.collectionView!.register(cellNib, forCellWithReuseIdentifier: PostCellIdentifier)
        self.collectionView!.register(UINib(nibName: "ForumThreadHeaderCollectionReusableView", bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
        
        if thread.isDevTracker {
            self.PostsPerPage = 20
        }
        
#if !DEBUG && !TEST
    self.analytics.track(event: Constants.Analytics.Event.forum, properties: [Constants.Analytics.Property.type: "thread"])
#endif

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Controller is being popped from the navigation stack
        if self.isMovingFromParentViewController {
            // Cancel any pending requests to prevent wasted processing
            self.postRepo.cancelAllOperations()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.posts?.removeAll(keepingCapacity: false)
        self.posts = nil
        self.collectionView?.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return self.calculateSizeForItemAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Calculate height of title text
        let largeSize = CGSize(width: UIScreen.main.bounds.size.width - 30, height: 9999)
        let font = UIFont.systemFont(ofSize: 17.0)
        let attributes = [NSFontAttributeName: font]
        let titleSize = (self.thread.title as NSString).boundingRect(with: largeSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        let titleHeight = ceil(titleSize.height)

        return CGSize(width: 0, height: titleHeight + 16.0)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCellIdentifier, for: indexPath) as! ForumPostCollectionViewCell
        
        self.fillCell(cell, atIndexPath: indexPath)
        
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
        
        let cell = collectionView.cellForItem(at: indexPath)
        self.performSegue(withIdentifier: PostSegue, sender: cell)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PostSegue {
            let controller = segue.destination as! ForumPostViewController
            let cell = sender as! UICollectionViewCell
            let post = self.posts![cell.tag]
            controller.post = post
        }
    }
    
    // MARK: - Helper methods
    
    override func onRefresh() {
        // Reloading content, set loaded page back to the first page
        self.loadedPage = 1
        // Disable infinite scroll while loading
        self.canLoadMore = false
        // Show loading indicator
        self.showLoader()
        
        func success(posts: Array<ForumPost>) {
            // Set retrieved posts and reload table
            self.posts = posts
            self.collectionView!.reloadData()
            self.refreshControl?.endRefreshing()
            // Enable infinite scroll if initial page is full
            if posts.count == PostsPerPage {
                self.canLoadMore = true
            } else {
                self.canLoadMore = false
                self.hideLoader()
            }
        }
        func failure(error: Error) {
            self.refreshControl?.endRefreshing()
            
            let alert: Alert!
            
            if (error.isMaintenanceError()) {
                alert = self.alertFactory.createAlert(presenter: self, title: "Maintenance", message: "SWTOR.com is currently unavailable while scheduled maintenance is being performed.", buttons: (style: .default, title: "OK", { self.hideLoader() })
                )
            } else {
                alert = self.alertFactory.createAlert(presenter: self, title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", buttons:
                    (style: .cancel, title: "No", { self.hideLoader() }),
                    (style: .default, title: "Yes", { self.onRefresh() })
                )
            }
            alert.show()
        }
        
        self.postRepo.get(thread: self.thread, page: 1, success: success, failure: failure)
    }
    
    override func onLoadMore() {
        // Disable infinite scroll while loading
        self.canLoadMore = false
        
        func success(posts: Array<ForumPost>) {
            // Get a difference of freshly loaded posts with the ones already loaded before
            let postsSet = Set(posts)
            let cachedPostsSet = Set(self.posts!)
            let newPosts = postsSet.subtracting(cachedPostsSet)
            
            if newPosts.isEmpty {
                // No new posts, disable infinite scrolling
                self.canLoadMore = false
                self.hideLoader()
                return
            }
            
            // Append the new posts and prepare indexes for table update
            var indexes = Array<IndexPath>()
            for post in newPosts {
                indexes.append(IndexPath(row: self.posts!.count, section: 0))
                self.posts!.append(post)
            }
            
            // Smoothly update the table by just inserting the new indexes
            self.collectionView!.insertItems(at: indexes)
            
            // Mark this page as loaded and enable infinite scroll again
            self.loadedPage += 1
            self.canLoadMore = true
        }
        func failure(error: Error) {
            let alert = self.alertFactory.createAlert(presenter: self, title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", buttons:
                (style: .cancel, title: "No", { self.hideLoader() }),
                (style: .default, title: "Yes", { self.onRefresh() })
            )
            alert.show()
        }
        
        self.postRepo.get(thread: self.thread, page: self.loadedPage + 1, success: success, failure: failure)
    }
    
    func fillCell(_ cell: ForumPostCollectionViewCell, atIndexPath indexPath: IndexPath) {
        let post = self.posts![indexPath.row]
        
        // Set user avatar image if URL is defined in the model
        if let url = post.avatarUrl {
            cell.avatarImageView.isHidden = false
            cell.avatarImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "Avatar"))
        } else {
            cell.avatarImageView.isHidden = true
        }
        
        // Set dev icon if post is marked as Bioware post
        if post.isBiowarePost {
            cell.devImageView.isHidden = false
            cell.devImageView.sd_setImage(with: URL(string: self.settings.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            cell.devImageView.isHidden = true
        }
        
        cell.dateLabel.text = post.postNumber != nil ? "\(post.date) | #\(post.postNumber!)" : post.date
        cell.usernameLabel.text = post.username
        cell.textView.text = post.text
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row
    }
    
    func calculateSizeForItemAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        if let cell = self.sizingCell {
            // Fill it with data
            self.fillCell(cell, atIndexPath: indexPath)
            cell.textView.preferredMaxLayoutWidth = self.collectionView!.frame.width - 30.0
            // Now that it has data tell it to size itself
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

            return CGSize(width: self.collectionView!.frame.size.width, height: size.height)
        }
        return CGSize.zero
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.collectionView!.backgroundColor = theme.contentBackground
    }

}
