//
//  ESTAppDelegate.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/14/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class ESTAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainNavigation: UINavigationController?
    var cloudManager: ESTCloudManager?

    var enterSwitchOn: Bool = true
    var exitSwitchOn: Bool = true
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // App ID and App Token should be provided using method below
        // to allow beacons connection and Estimote Cloud requests possible.
        // Both values can be found in Estimote Cloud ( http://cloud.estimote.com )
        // in Account Settings tab.
        print("ESTAppDelegate: APP ID and APP TOKEN are required to connect to your beacons and make Estimote API calls.")
        ESTCloudManager.setupAppID("shopeasy", andAppToken:"ec93ddaef9aef7a66fc01524be4199ff")
        
        // Estimote Analytics allows you to log activity related to monitoring mechanism.
        // At the current stage it is possible to log all enter/exit events when monitoring
        // Particular beacons (Proximity UUID, Major, Minor values needs to be provided).
        
        print("ESTAppDelegate: Analytics are turned OFF by defaults. You can enable them changing flag")
        ESTCloudManager.enableMonitoringAnalytics(false)
        ESTCloudManager.enableGPSPositioningForAnalytics(false)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        
        let demoListVC: ESTViewController = ESTViewController(style: .Grouped)
        
        self.mainNavigation = UINavigationController(rootViewController: demoListVC)

        self.window!.rootViewController = self.mainNavigation
        self.window!.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor.init(red:0.490, green:0.631, blue:0.549, alpha:1.000)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(18), NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        // Register for remote notificatons related to Estimote Remote Beacon Management.
        if #available(iOS 8.0, *) {
            // iOS 8 or greater
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let userNotificationTypes: UIUserNotificationType = .None
            let settings: UIUserNotificationSettings = UIUserNotificationSettings.init(forTypes: userNotificationTypes, categories:nil)
            application.registerUserNotificationSettings(settings)
        } else {
            // iOS 7x or earlier
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(.None)
        }
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

