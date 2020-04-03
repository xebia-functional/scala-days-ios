import Foundation
import Firebase

protocol SubscriberNotification {
    func subscribe(conferences: Conferences)
}

class FirebaseSubscriber: SubscriberNotification {
    func subscribe(conferences: Conferences) {
        conferences.conferences.map(\.info.id).forEach { conferenceId in
            Messaging.messaging().subscribe(toTopic: "\(conferenceId)_\(environment)_ios".lowercased())
        }
    }
    
    private var environment: String {
        #if DEBUG
        return "debug"
        #else
        return "release"
        #endif
    }
}
