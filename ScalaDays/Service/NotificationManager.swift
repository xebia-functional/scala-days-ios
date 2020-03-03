import Foundation
import Alamofire

enum NotificationManagerError: Error {
    case invalidEndpoint
    case empty
}

class NotificationManager {
    private let endpoint = "https://scaladays-backend.herokuapp.com/notifications"
    private var cached: [SDNotification] = []
    
    func notifications(conference: Conference, callback: @escaping (Result<[SDNotification], NotificationManagerError>) -> Void) {
        guard let endpoint = endpoint(conferenceId: conference.info.id) else {
            callback(.failure(.invalidEndpoint)); return
        }
        
        if cached.count > 0 { callback(.success(cached)) }
        reloadNotifications(endpoint: endpoint, callback: callback)
    }
    
    func reset() {
        self.cached = []
    }
    
    // MARK: GET
    private func reloadNotifications(endpoint: URL, callback: @escaping (Result<[SDNotification], NotificationManagerError>) -> Void) {
        AF.request(endpoint).responseJSON  { response in
            guard let data = response.data,
                  let res = try? JSONDecoder.using(.notificationsDateFormatter).decode(SDNotifications.self, from: data) else {
                    callback(.failure(.empty)); return
            }
            
            let notifications = res.notifications.filter { $0.iosDelivered }
                                                 .sorted { notification1, notification2 in  notification1.date > notification2.date }

            self.cached = notifications
            callback(notifications.count == 0 ? .failure(.empty) : .success(notifications))
        }
    }
    
    // MARK: helpers
    private func endpoint(conferenceId: Int) -> URL? {
        URL(string: "\(endpoint)?conferenceId=\(conferenceId)")
    }
}
