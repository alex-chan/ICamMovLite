//
//  AppDelegate.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/4.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        ShareSDK.registerApp("5b09c977b07c")
//        
//        ShareSDK.connectSinaWeiboWithAppKey("1646769844", appSecret: "057deedfe77f7bea1a7c19f345e3318e", redirectUri: "https://icammov.parseapp.com/wb_oauthcallback", weiboSDKCls: WeiboSDK.self)
//        
//        ShareSDK.connectWeChatSessionWithAppId("wx9c1cecdd1a83f239", appSecret: "68f9a0608ccaaac148c9a5456989c2d4", wechatCls: WXApi.self)
//        ShareSDK.connectWeChatTimelineWithAppId("wx9c1cecdd1a83f239", appSecret: "68f9a0608ccaaac148c9a5456989c2d4", wechatCls: WXApi.self)
//        

        LPVideo.registerSubclass()
        LPUser.registerSubclass()
        LPComment.registerSubclass()
        AVOSCloud.setApplicationId("xkjj8zwzxiyouqo4m3war047dy40nfw0axxr10s0d85e6a9d", clientKey: "20toct9i8jnyl7eperpl7o66puy9s2bzr70h2dq0rkoqvgt7")
        
        //        AVOSCloud.setenv("LOG_CURL", "YES", 0)
        
        AVCloud.setProductionMode(IS_PRODUCTION_ENV)
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

