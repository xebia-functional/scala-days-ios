import Foundation

struct SDNotifications: Codable {
    let conferenceId: Int
    let notifications: [SDNotification]
}

struct SDNotification: Codable {
    let date: Date //"timestamp":"2019-07-08T18:40:25.842Z",
    let title: String
    let message: String
    let iosDelivered: Bool
    
    enum CodingKeys: String, CodingKey {
        case date = "timestamp"
        case title
        case message
        case iosDelivered
    }
}
