import UIKit
import SVProgressHUD

class SDNotificationViewController: UIViewController {
    private let analytics: Analytics
    private let manager: NotificationManager
    
    init(analytics: Analytics, manager: NotificationManager) {
        self.analytics = analytics
        self.manager = manager
        super.init(nibName: String(describing: SDAboutViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = i18n.title
        analytics.logScreenName(.notification, class: SDNotificationViewController.self)
    }

    // MARK: - Constants
    enum i18n {
        static let title = NSLocalizedString("notification", comment: "Notification section")
    }
    
    enum Image {
        static let iconNamed = "menu_icon_notification"
        static let icon = UIImage(named: iconNamed)
    }
}

