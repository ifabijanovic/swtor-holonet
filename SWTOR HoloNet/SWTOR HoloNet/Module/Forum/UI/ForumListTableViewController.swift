//
//  ForumListTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 22/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumListTableViewController: UITableViewController {
    
    // MARK: - Constants
    
    private let CategorySection = 0
    private let ThreadSection = 1
    private let CategoriesSectionTitle = "Categories"
    private let ThreadsSectionTitle = "Threads"
    private let CategoryCellIdentifier = "categoryCell"
    private let ThreadCellIdentifier = "threadCell"
    private let SubCategorySegue = "category"
    
    // MARK: - Properties
    
    private var settings: Settings?
    private var category: ForumCategory?
    
    private var categoryRepo: ForumCategoryRepository?
    private var threadRepo: ForumThreadRepository?
    
    private var categories: Array<ForumCategory>?
    private var threads: Array<ForumThread>?
    
    private var threadPage = 1
    
    // MARK: - Public methods
    
    func setup(#settings: Settings) {
        self.setup(settings: settings, category: nil)
    }
    
    func setup(#settings: Settings, category: ForumCategory?) {
        self.settings = settings
        self.category = category
        self.categoryRepo = ForumCategoryRepository(settings: settings)
        
        if category != nil {
            // Threads exist only inside categories, not in forum root
            self.threadRepo = ForumThreadRepository(settings: settings)
            self.navigationItem.title = category!.title
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        func categorySuccess(categories: Array<ForumCategory>) {
            self.categories = categories
            self.tableView.reloadSections(NSIndexSet(index: CategorySection), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        func threadSuccess(threads: Array<ForumThread>) {
            self.threads = threads
            self.tableView.reloadSections(NSIndexSet(index: ThreadSection), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        func failure(error: NSError) {
            println(error)
        }
        
        if let category = self.category {
            // Load subcategories and threads for the current category
            self.categoryRepo!.get(category: category, success: categorySuccess, failure: failure)
            self.threadRepo!.get(category: category, page: 1, success: threadSuccess, failure: failure)
        } else {
            // Forum root, only load categories
            self.categoryRepo!.get(language: self.settings!.forumLanguage, success: categorySuccess, failure: failure)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.categories?.removeAll(keepCapacity: false)
        self.categories = nil
        self.threads?.removeAll(keepCapacity: false)
        self.threads = nil
    }

    // MARK: - Table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.threadRepo != nil {
            return 2
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CategorySection {
            return self.categories?.count ?? 0
        } else if section == ThreadSection {
            return self.threads?.count ?? 0
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == CategorySection && self.hasCategories() {
            return CategoriesSectionTitle
        } else if section == ThreadSection && self.hasThreads() {
            return ThreadsSectionTitle
        }
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        if indexPath.section == CategorySection {
            // Category
            cell = tableView.dequeueReusableCellWithIdentifier(CategoryCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let category = self.categories![indexPath.row]
            cell.textLabel.text = category.title
            cell.tag = indexPath.row
        } else if indexPath.section == ThreadSection {
            cell = tableView.dequeueReusableCellWithIdentifier(ThreadCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let thread = self.threads![indexPath.row]
            cell.textLabel.text = thread.title
            cell.detailTextLabel?.text = thread.author
            cell.tag = indexPath.row
        } else {
            cell = UITableViewCell()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SubCategorySegue {
            let controller = segue.destinationViewController as ForumListTableViewController
            let cell = sender as UITableViewCell
            let category = self.categories![cell.tag]
            controller.setup(settings: self.settings!, category: category)
        }
    }
    
    // MARK: - Helper methods
    
    private func hasCategories() -> Bool {
        return self.categories?.count > 0 ?? false
    }
    
    private func hasThreads() -> Bool {
        return self.threads?.count > 0 ?? false
    }

}
