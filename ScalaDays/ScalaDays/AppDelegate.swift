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
import Localytics
import TwitterKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var menuViewController: SDSlideMenuViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let externalKeys = AppDelegate.loadExternalKeys()
        
        if isIOS8OrLater() {
            UIApplication.shared.registerForRemoteNotifications()
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        } else {
            let types: UIRemoteNotificationType = [UIRemoteNotificationType.badge, UIRemoteNotificationType.sound, UIRemoteNotificationType.alert]
            UIApplication.shared.registerForRemoteNotifications(matching: types)
        }
        
        if let localyticsKey = externalKeys.localyticsKey {
            Localytics.integrate(localyticsKey)
            Localytics.setLoggingEnabled(true)
            if application.applicationState != UIApplicationState.background {
                Localytics.openSession()
            }
        }
        
        if let googleAnalyticsKey = externalKeys.googleAnalyticsKey {
            GAI.sharedInstance().tracker(withTrackingId: googleAnalyticsKey)
        }
        if let crashlyticsKey = externalKeys.crashlyticsKey {
            Crashlytics.start(withAPIKey: crashlyticsKey)
        }
        
        if let twitterConsumerKey = externalKeys.twitterConsumerKey,
            let twitterConsumerSecret = externalKeys.twitterConsumerSecret {
            TWTRTwitter.sharedInstance().start(withConsumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }

        initAppearence()
        createMenuView()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Localytics.closeSession()
        Localytics.upload()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Localytics.openSession()
        Localytics.upload()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Localytics.openSession()
        Localytics.upload()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Localytics.dismissCurrentInAppMessage()
        Localytics.closeSession()
        Localytics.upload()
    }

    private func createMenuView() {

        let scheduleViewController = SDScheduleViewController(nibName: "SDScheduleViewController", bundle: nil)
        menuViewController = SDSlideMenuViewController(nibName: "SDSlideMenuViewController", bundle: nil)
        let nvc: UINavigationController = UINavigationController(rootViewController: scheduleViewController)

        menuViewController.scheduleViewController = nvc
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: menuViewController)

        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.appColor()
            window.rootViewController = slideMenuController
            window.makeKeyAndVisible()
        }
    }

    private func initAppearence() {
        UINavigationBar.appearance().barTintColor = UIColor.appColor()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "navigation_bar_icon_arrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "navigation_bar_icon_arrow")
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
    }

    class func loadExternalKeys() -> (googleAnalyticsKey: String?, crashlyticsKey: String?, localyticsKey: String?, twitterConsumerKey: String?, twitterConsumerSecret: String?) {
        if let path = Bundle.main.path(forResource: kExternalKeysPlistFilename, ofType: "plist") {
            if let keysDict = NSDictionary(contentsOfFile: path) {
                return (keysDict[kExternalKeysDKGoogleAnalytics] as? String,
                        keysDict[kExternalKeysDKCrashlytics] as? String,
                        keysDict[kExternalKeysDKLocalytics] as? String,
                        keysDict[kExternalKeysDKTwitterConsumerKey] as? String,
                        keysDict[kExternalKeysDKTwitterConsumerSecret] as? String)
            }
        }
        return (nil, nil, nil, nil, nil)
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey:Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Localytics.setPushToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration for Remote Notifications failed with error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        func handleReload() {
            if let jsonReload: AnyObject = userInfo["jsonReload"] as AnyObject {
                if let jsonReloadBool = jsonReload as? NSString {
                    if(jsonReloadBool .isEqual(to: "true")) {
                        DataManager.sharedInstance.lastConnectionAttemptDate = nil
                        self.menuViewController.askControllersToReload()
                    }
                }
            }
            Localytics.handleNotification(userInfo)
        }
        
        handleReload()        
        completionHandler(.noData)
    }
}

