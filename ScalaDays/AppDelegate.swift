import UIKit
import SVProgressHUD
import TwitterKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var menuViewController: SDSlideMenuViewController!
    private var analytics: ScalaDaysAnalytics!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupThirdParties(application: application, launchOptions: launchOptions)
        initAppearence()
        createMenuView()

        return true
    }

    // MARK: setup
    private func createMenuView() {
        let scheduleViewController = SDScheduleViewController(analytics: analytics)
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
}

// MARK: Configure 3rd-party libraries
extension AppDelegate {
    
    func setupThirdParties(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        firebase(application: application)
        twitter(application: application)
    }

    private func firebase(application: UIApplication) {
        FirebaseApp.configure()
        analytics = ScalaDaysAnalytics()
        initializeNotifications(application: application)
    }

    private func twitter(application: UIApplication) {
        guard let path = Bundle.main.path(forResource: kExternalKeysPlistFilename, ofType: "plist"),
              let keysDict = NSDictionary(contentsOfFile: path),
              let twitterConsumerKey = keysDict[kExternalKeysDKTwitterConsumerKey] as? String,
              let twitterConsumerSecret = keysDict[kExternalKeysDKTwitterConsumerSecret] as? String else { return }

        TWTRTwitter.sharedInstance().start(withConsumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
    }
}
