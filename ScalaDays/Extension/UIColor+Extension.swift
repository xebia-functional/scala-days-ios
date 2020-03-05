import Foundation

extension UIColor {
    
    var hex: String? {
        guard let components = cgColor.components,
              let r = components[safe: 0],
              let g = components[safe: 1],
              let b = components[safe: 2] else { return nil }
        
        let a = components[safe: 3] ?? 1.0
        
        return String(format: "%02X%02X%02X%02X",
                      lroundf(Float(r) * 255.0),
                      lroundf(Float(g) * 255.0),
                      lroundf(Float(b) * 255.0),
                      lroundf(Float(a) * 255.0))
    }
}
