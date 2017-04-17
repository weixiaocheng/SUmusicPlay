//
//  AppDelegate.swift
//  SUMusic-swift
//
//  Created by user on 17/4/11.
//  Copyright © 2017年 loda. All rights reserved.
//

import UIKit
import AVFoundation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds);
        self.window?.backgroundColor = UIColor.white;
        let playVC : PlayListViewController = PlayListViewController();
        let navC : UINavigationController = UINavigationController(rootViewController: playVC);
        
        self.window?.rootViewController = navC;
        self.window?.makeKeyAndVisible();
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            
            try session.setActive(true)
        } catch {
            print(error)
            
        }
        
        
    }
    
    
    
}

