import Foundation
import Alamofire

enum NotificationError: Error {
    case invalidEndpoint
    case empty
}

class NotificationManager {
    private let endpoint = "https://scaladays-backend.herokuapp.com/notifications"
    
    func notifications(conference: Conference, callback: @escaping (Result<[SDNotification], NotificationError>) -> Void) {
        guard let url = endpoint(conferenceId: conference.info.id) else {
            callback(.failure(.invalidEndpoint)); return
        }
        
        AF.request(url).responseJSON  { response in
            guard let data = response.data,
                  let res = try? JSONDecoder.using(.notificationsDateFormatter).decode(SDNotifications.self, from: data) else {
                    callback(.failure(.empty)); return
            }
            
            callback(.success(res.notifications))
        }
    }
    
    // MARK: helpers
    private func endpoint(conferenceId: Int) -> URL? {
        URL(string: "\(endpoint)?conferenceId=\(conferenceId)")
    }
}
