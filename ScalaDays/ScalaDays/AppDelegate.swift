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
import SVProgressHUD


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var menuViewController: SDSlideMenuViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        let externalKeys = AppDelegate.loadExternalKeys()
        
        if isIOS8OrLater() {
            UIApplication.sharedApplication().registerForRemoteNotifications()
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        } else {
            let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
        
        if let localyticsKey = externalKeys.localyticsKey {
            Localytics.integrate(localyticsKey)
        }

        if let googleAnalyticsKey = externalKeys.googleAnalyticsKey {
            GAI.sharedInstance().trackerWithTrackingId(googleAnalyticsKey)
        }
        if let crashlyticsKey = externalKeys.crashlyticsKey {
            Crashlytics.startWithAPIKey(crashlyticsKey)
        }

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
        menuViewController = SDSlideMenuViewController(nibName: "SDSlideMenuViewController", bundle: nil)
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
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
    }

    class func loadExternalKeys() -> (googleAnalyticsKey:String?, crashlyticsKey:String?, localyticsKey:String?) {
        if let path = NSBundle.mainBundle().pathForResource(kExternalKeysPlistFilename, ofType: "plist") {
            if let keysDict = NSDictionary(contentsOfFile: path) {
                return (keysDict[kExternalKeysDKGoogleAnalytics] as? String, keysDict[kExternalKeysDKCrashlytics] as? String, keysDict[kExternalKeysDKLocalytics] as? String)
            }
        }
        return (nil, nil, nil)
    }


    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Localytics.setPushToken(deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Registration for Remote Notifications failed with error: \(error)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject:AnyObject]) {
        if let jsonReload: AnyObject = userInfo["jsonReload"] {
            if let jsonReloadBool = jsonReload as? NSString {
                if(jsonReloadBool .isEqualToString("true")) {
                    DataManager.sharedInstance.lastConnectionAttemptDate = nil
                    self.menuViewController.askControllersToReload()                   
                }
            }
        }
        Localytics.handlePushNotificationOpened(userInfo)
    }

}

