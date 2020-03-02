import Foundation

private class DummyBundle { }

extension Bundle {
    static var local: Bundle {
        return Bundle(for: DummyBundle.self)
    }
    
    static var localModuleName: String {
        guard let dictionary = Bundle.local.infoDictionary else { return "" }
        return dictionary[kCFBundleNameKey as String] as? String ?? ""
    }

    static func loadView(nibName: String) -> UIView? {
        return Bundle.local.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView
    }
}
