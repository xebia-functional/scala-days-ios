import Foundation
import Social

enum TwitterSocialController {
    static func present(in vc: UIViewController, text: String) {
        guard TwitterSocialController.installed,
              let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
        
        composeViewController.title = "Scala Days"
        composeViewController.setInitialText("\(text) ")
        
        vc.present(composeViewController, animated: true)
    }
    
    static var installed: Bool {
        guard let url = URL(string: "twitter://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
