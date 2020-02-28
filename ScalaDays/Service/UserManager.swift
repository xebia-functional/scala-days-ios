import Foundation

class UserManager {
    typealias LastVisitedConference = [Int: [String: Date]]
    
    @UserDefault("UserManager.LastVisited", defaultValue: LastVisitedConference()) var visited: LastVisitedConference
    
    func lastVisited(viewController: ScalaDayViewController.Type, conference: Conference) -> Date {
        visited[conference.info.id]?[controllerId(viewController)] ?? Date(timeIntervalSince1970: 0)
    }
    
    func updateLastVisited(viewController: ScalaDayViewController.Type, conference: Conference) {
        visited[conference.info.id] = [controllerId(viewController): Date()]
    }
    
    // MARK: helpers
    private func controllerId(_ viewController: ScalaDayViewController.Type) -> String {
        String(describing: viewController)
    }
}
