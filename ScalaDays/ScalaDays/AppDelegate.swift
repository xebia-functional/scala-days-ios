/*
* Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        Localytics.integrate("f03c22cb2db72bc6c180ece-0741609a-b833-11e4-2cc5-004a77f8b47f")

        UIApplication.sharedApplication().registerForRemoteNotifications()

        let settings = UIUserNotificationSettings(forTypes: .Alert | .Sound | .Badge, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)

        Crashlytics.startWithAPIKey("650c56fa5bc6a759a4802ae63f430cfaf6c8158a")
        self.initAppearence()
        self.createMenuView()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Localytics.closeSession()
        Localytics.upload()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Localytics.closeSession()
        Localytics.upload()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Localytics.openSession()
        Localytics.upload()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Localytics.openSession()
        Localytics.upload()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Localytics.closeSession()
        Localytics.upload()
    }

    private func createMenuView() {

        let scheduleViewController = SDScheduleViewController(nibName: "SDScheduleViewController", bundle: nil)
        let menuViewController = SDSlideMenuViewController(nibName: "SDSlideMenuViewController", bundle: nil)
        let nvc: UINavigationController = UINavigationController(rootViewController: scheduleViewController)

        menuViewController.scheduleViewController = nvc
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: menuViewController)

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let window = window {
            window.backgroundColor = UIColor.appColor()
            window.rootViewController = slideMenuController
            window.makeKeyAndVisible()
        }
    }

    func initAppearence() {
        UINavigationBar.appearance().barTintColor = UIColor.appColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "navigation_bar_icon_arrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "navigation_bar_icon_arrow")
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }



    //MARK: Remote Notifications

    // Move this line somewhere where your app starts
//    UIApplication.sharedApplication().registerForRemoteNotifications()

    // Ask user for allowed notification types
//    let settings = UIUserNotificationSettings(forTypes: .Alert | .Sound | .Badge, categories: nil)
//    UIApplication.sharedApplication().registerUserNotificationSettings(settings)

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
        println("Successfully egistered for Remote Notifications with token: \(deviceToken)")
        Localytics.setPushToken(deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError!) {
        println("Registration for Remote Notifications failed with error: \(error)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject:AnyObject]) {
        Localytics.handlePushNotificationOpened(userInfo)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject:AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

    }

}

