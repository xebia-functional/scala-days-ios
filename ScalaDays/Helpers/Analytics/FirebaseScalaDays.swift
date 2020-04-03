import Foundation
import Firebase

struct ScalaDaysAnalytics: Analytics {
    
    func logScreenName(_ screen: AnalyticEvent.ScreenName, class screenClass: UIViewController.Type) {
        Firebase.Analytics.setScreenName("\(screen)", screenClass: String(describing: screenClass))
    }
    
    func logEvent(screenName: AnalyticEvent.ScreenName, category: AnalyticEvent.Category, action: AnalyticEvent.Action) {
        log(screenName: screenName, category: category, action: action, label: nil)
    }
    
    func logEvent(screenName: AnalyticEvent.ScreenName, category: AnalyticEvent.Category, action: AnalyticEvent.Action, label: String) {
        log(screenName: screenName, category: category, action: action, label: label)
    }
    
    // MARK: private methods
    func log(screenName: AnalyticEvent.ScreenName, category: AnalyticEvent.Category, action: AnalyticEvent.Action, label: String?) {
        Firebase.Analytics.logEvent("\(screenName)", parameters: [
            "category": "\(category)" as NSObject,
            "action": "\(action)" as NSObject,
            "label": "\(label ?? "nil")" as NSObject
        ])
    }
}
