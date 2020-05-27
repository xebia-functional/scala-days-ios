import Foundation
import Firebase
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    private static let SHOW_DEVICE_TOKEN = false
    
    // MARK: Registration
    func initializeNotifications(application: UIApplication) {
        registerPushNotifications(application: application)
        registerMessaging()
    }
    
    private func registerPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in }
        application.registerForRemoteNotifications()
    }
    
    private func registerMessaging() {
        Messaging.messaging().delegate = self
    }
    
    // MARK: Push Notifications <delegate>
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        show(userInfo: userInfo)
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        show(userInfo: userInfo)
        didTapOnNotification(userInfo: userInfo)
        completionHandler()
    }
    
    private func didTapOnNotification(userInfo: [AnyHashable: Any]) {
        guard let conferenceId = userInfo["conferenceId"] as? String else { return }
        
        if let jsonReload = userInfo["jsonReload"] as? String, jsonReload.lowercased() == "true" {
            DataManager.sharedInstance.lastConnectionAttemptDate = nil
            menuViewController.askControllersToReload()
        }
        
        menuViewController.showNotifications(conferenceId: conferenceId)
    }
    
    // MARK: Messaging
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if AppDelegate.SHOW_DEVICE_TOKEN {
            showDeviceToken()
            showRegistrationToken()
        }
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: ["token": fcmToken])
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        //       If necessary send token to application server.
    }
    
    // MARK: - Helpers
    private func show(userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[UserInfo.gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print("User Info: \(userInfo)")
    }
    
    private func showRegistrationToken() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Firebase registration token: \(result.token)")
            }
        }
    }
    
    private func showDeviceToken() {
        guard let deviceToken = Messaging.messaging().apnsToken else { return }
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("DEVICE TOKEN\n------------------\n\(deviceTokenString)\n------------------")
    }
    
    // MARK: - Constants
    enum UserInfo {
        static let gcmMessageIDKey = "gcm.message_id"
    }
}
