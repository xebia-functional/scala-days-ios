import Foundation

extension DateFormatter {
    
    static let notificationsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}


// MARK - Decoders <JSONDecoder>

extension JSONDecoder {
    
    static func using(_ dateFormatter: DateFormatter) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }
}
