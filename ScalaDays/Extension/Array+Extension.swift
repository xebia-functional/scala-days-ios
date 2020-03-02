import Foundation

extension Array {
    
    public subscript(safe index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
}
