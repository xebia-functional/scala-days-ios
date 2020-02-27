import UIKit
import SVProgressHUD

class SDNotificationViewController: UIViewController {
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var emptyMessage: UILabel!
    
    private let analytics: Analytics
    private let manager: NotificationManager
    private var state: NotificationViewState = .loading { didSet { reloadView() }}
    
    init(analytics: Analytics, manager: NotificationManager) {
        self.analytics = analytics
        self.manager = manager
        super.init(nibName: String(describing: SDNotificationViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppareance()
        reloadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = i18n.title
        analytics.logScreenName(.notification, class: SDNotificationViewController.self)
    }
    
    private func setupAppareance() {
        setupEmptyView()
    }
    
    private func setupEmptyView() {
        emptyMessage.text = i18n.emptyMessage
    }
    
    private func reloadView() {
        switch state {
        case .empty:
            emptyView.isHidden = false
            loadingView.isHidden = true
        case .loading:
            emptyView.isHidden = true
            loadingView.isHidden = false
            loadNotifications()
        case .notifications(let notifications):
            fatalError()
        }
    }
    
    private func loadNotifications() {
        guard let conference = DataManager.sharedInstance.currentlySelectedConference else {
            state = .empty; return
        }
        
        manager.notifications(conference: conference) { result in
            let b = 0
        }
    }

    // MARK: - Constants
    enum i18n {
        static let title = NSLocalizedString("notification", comment: "Notification section")
        static let emptyMessage = NSLocalizedString("empty_notification_message", comment: "")
    }
    
    enum Image {
        static let iconNamed = "menu_icon_notification"
        static let icon = UIImage(named: iconNamed)
    }
    
    // MARK: - State
    enum NotificationViewState {
        case loading
        case empty
        case notifications([Notification])
    }
}
