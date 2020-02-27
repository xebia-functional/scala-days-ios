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
import SVProgressHUD

import UserNotifications
import Localytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var menuViewController: SDSlideMenuViewController!
    private var analytics: FirebaseScalaDays!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupThirdParties(application: application, launchOptions: launchOptions)
        initAppearence()
        createMenuView()

        return true
    }

    // MARK: setup
    private func createMenuView() {
        let scheduleViewController = SDScheduleViewController(analytics: self.analytics)
        menuViewController = SDSlideMenuViewController(analytics: analytics)
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
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "navigation_bar_icon_arrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "navigation_bar_icon_arrow")
        SVProgressHUD.setBackgroundColor(UIColor.clear)
    }

    // MARK: life cycle
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Localytics.dismissCurrentInAppMessage()
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

    // MARK: deep link
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey:Any] = [:]) -> Bool {
        Localytics.handleTestModeURL(url)
        return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
    }
}

// MARK: Localytics - Push Notifications
fileprivate let DEBUG_PUSH_NOTIFICATIONS = false

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Localytics.setPushToken(deviceToken)
        if DEBUG_PUSH_NOTIFICATIONS {
            print("@@@@@@@@@@@ TOKEN: \(deviceToken.hexString)")
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration for Remote Notifications failed with error: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        defer {
            Localytics.handleNotificationReceived(userInfo)
            completionHandler(.noData)
        }

        guard let jsonReload = userInfo["jsonReload"] as? String,
              jsonReload.lowercased() == "true" else { return }

        DataManager.sharedInstance.lastConnectionAttemptDate = nil
        self.menuViewController.askControllersToReload()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Localytics.didReceiveNotificationResponse(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
}

// MARK: Third parties
extension AppDelegate {
    private static var externalKeys = AppDelegate.loadExternalKeys()

    private func setupThirdParties(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        localyticsPushNotifications(application: application, launchOptions: launchOptions)
        localytics(application: application, launchOptions: launchOptions)
        firebase(application: application)
        twitter(application: application)
    }

    private func localyticsPushNotifications(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            Localytics.didRequestUserNotificationAuthorization(withOptions: options.rawValue, granted: granted)
        }
        application.registerForRemoteNotifications()

        if let notificationInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            Localytics.handleNotification(notificationInfo, withActionIdentifier: "")
        }
    }

    private func localytics(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let localyticsKey = AppDelegate.externalKeys.localyticsKey else { return }

        Localytics.autoIntegrate(localyticsKey, withLocalyticsOptions:[
            LOCALYTICS_WIFI_UPLOAD_INTERVAL_SECONDS: 5,
            LOCALYTICS_GREAT_NETWORK_UPLOAD_INTERVAL_SECONDS: 10,
            LOCALYTICS_DECENT_NETWORK_UPLOAD_INTERVAL_SECONDS: 30,
            LOCALYTICS_BAD_NETWORK_UPLOAD_INTERVAL_SECONDS: 90
            ], launchOptions: launchOptions)

        Localytics.setLoggingEnabled(DEBUG_PUSH_NOTIFICATIONS)

        if application.applicationState != .background {
            Localytics.openSession()
        }
    }

    private func firebase(application: UIApplication) {
        self.analytics = FirebaseScalaDays()
    }

    private func twitter(application: UIApplication) {
        guard let twitterConsumerKey = AppDelegate.externalKeys.twitterConsumerKey,
              let twitterConsumerSecret = AppDelegate.externalKeys.twitterConsumerSecret else { return }

        TWTRTwitter.sharedInstance().start(withConsumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
    }
}

// MARK: helpers
// <configuration>
extension AppDelegate {
    class func loadExternalKeys() -> (localyticsKey: String?, twitterConsumerKey: String?, twitterConsumerSecret: String?) {
        guard let path = Bundle.main.path(forResource: kExternalKeysPlistFilename, ofType: "plist"),
              let keysDict = NSDictionary(contentsOfFile: path) else { return (nil, nil, nil) }

        return (keysDict[kExternalKeysDKLocalytics] as? String,
                keysDict[kExternalKeysDKTwitterConsumerKey] as? String,
                keysDict[kExternalKeysDKTwitterConsumerSecret] as? String)
    }
}

// <notifications>
private extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
