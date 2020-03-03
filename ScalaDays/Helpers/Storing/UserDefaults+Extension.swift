import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let raw = UserDefaults.standard.data(forKey: key),
                  let value = try? PropertyListDecoder().decode(T.self, from: raw) else { return defaultValue }
            return value
        }
        set {
            let valueRaw = try? PropertyListEncoder().encode(newValue)
            UserDefaults.standard.set(valueRaw, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}
