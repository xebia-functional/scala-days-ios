import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(_: T.Type) {
        register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError()
        }
        return cell
    }
}

extension UIView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle.local)
    }
}

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableCell {}
