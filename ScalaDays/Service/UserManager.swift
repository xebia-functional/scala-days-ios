import Foundation

class UserManager {
    @UserDefault("UserManager.SelectedConference", defaultValue: nil) private var selectedConference: Conference?
    
    var selectedConferenceId: Int { selectedConference?.info.id ?? -1 }
    
    func select(conference: Conference) {
        self.selectedConference = conference
    }
}
