import Foundation

struct SDNotifications: Codable {
    let conferenceId: Int
    let notifications: [SDNotification]
}

struct SDNotification: Codable {
    let date: Date
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
