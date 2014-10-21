//
//  AppDelegate.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 16/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let settings = Settings()
        let catRepo = ForumCategoryRepository(settings: settings)
        let threadRepo = ForumThreadRepository(settings: settings)
        let postRepo = ForumPostRepository(settings: settings)
        
        catRepo.get(language: ForumLanguage.English, success: { (categories) -> Void in
            
            println("*** CATEGORIES ***")
            for item in categories {
                println(item.title)
            }
            
            let general = categories[9]
            threadRepo.get(category: general, page: 1, success: { (threads) -> Void in
                
                println("*** THREADS ***")
                for item in threads {
                    println(item.title)
                }
                
                postRepo.get(thread: threads.first!, page: 1, success: { (posts) -> Void in
                    
                    println("*** POSTS ***")
                    for item in posts {
                        println("Posted by \(item.username) on \(item.date)")
                    }
                    
                }, failure: { (error) -> Void in
                    println("Post error: \(error.localizedDescription)")
                })
                
            }, failure: { (error) -> Void in
                println("Thread error: \(error.localizedDescription)")
            })
            
        }) { (error) -> Void in
            println("Category error: \(error.localizedDescription)")
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

