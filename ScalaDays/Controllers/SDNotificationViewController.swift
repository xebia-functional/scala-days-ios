import UIKit
import SVProgressHUD

class SDNotificationViewController: UIViewController {
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var emptyMessage: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let analytics: Analytics
    private let manager: NotificationManager
    private var state: NotificationViewState = .loading { didSet { reloadView() }}
    private var notifications: [SDNotification] = [] { didSet { tableView.reloadData() }}
    
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
        reloadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = i18n.title
        analytics.logScreenName(.notification, class: SDNotificationViewController.self)
        
        setupCells()
        setupAppareance()
    }
    
    // MARK: appareance
    private func setupCells() {
        tableView.registerCell(SDNotificationTableViewCell.self)
        tableView.tableFooterView = UIView()
    }
    
    private func setupAppareance() {
        emptyMessage.text = i18n.emptyMessage
    }
    
    private func reloadView() {
        switch state {
        case .empty:
            emptyView.isHidden   = false
            loadingView.isHidden = true
            notificationsView.isHidden = true
        case .loading:
            emptyView.isHidden   = true
            loadingView.isHidden = false
            notificationsView.isHidden = true
            loadNotifications()
        case .notifications(let notifications):
            emptyView.isHidden   = true
            loadingView.isHidden = true
            notificationsView.isHidden = false
            self.notifications = notifications
        }
    }
    
    // MARK: actions
    private var currentConference: Conference? { DataManager.sharedInstance.currentlySelectedConference }
    
    private func loadNotifications() {
        guard let conference = currentConference else {
            state = .empty
            return
        }
        
        manager.notifications(conference: conference) { result in
            switch result {
            case .success(let response):
                self.state = .notifications(response)
            case .failure:
                self.state = .empty
            }
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
        case notifications([SDNotification])
    }
}

// MARK: TableView <datasource>
extension SDNotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = self.notifications[indexPath.item]
        let position: CellPosition = notifications.count == 1 ? .only : indexPath.item == 0 ? .top : indexPath.item == (notifications.count - 1) ? .bottom : .middle
        
        let cell: SDNotificationTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.draw(notification: notification, position: position)
        
        return cell
    }
}
