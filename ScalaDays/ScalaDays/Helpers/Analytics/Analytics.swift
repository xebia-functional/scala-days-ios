import UIKit

enum AnalyticEvent {
    enum ScreenName: String {
        case slideMenu = "Slide Menu"
        case schedule = "Schedule"
        case social = "Social"
        case speakers = "Speakers"
        case tickets = "Tickets"
        case contact = "Contact"
        case sponsors = "Sponsors"
        case places = "Places"
        case about = "About"
        case menu = "Menu"
        case votes = "Votes"
        case webView = "Web View"
    }

    enum Category: String {
        case filter = "Filter"
        case favorites = "Favorites"
        case navigate = "Navigate"
        case vote = "Vote"
    }

    enum Action: String {
        case filterAll = "All"
        case filterFavorites = "Favorites"
        case goToDetail = "Go to Detail"
        case addToFavorite = "Add"
        case removeToFavorite = "Remove"
        case goToTweet = "Go to Tweet"
        case postTweet = "Post Tweet"
        case cancelTweet = "Cancel Tweet"
        case goToUser = "Go to User"
        case goToTicket = "Go to Ticket"
        case scanContact = "Scan Contact"
        case goToSponsor = "Go to Sponsor"
        case goToMap = "Go to Map"
        case goToSite = "Go to 47Deg Website"
        case menuChangeConference = "Change Conference"
        case showVotingDialog = "Show Voting Dialog"
        case sendVote = "Send Vote"
    }
}


protocol Analytics {
    func logScreenName(_ screen: AnalyticEvent.ScreenName, class: UIViewController.Type)
    func logEvent(screenName: AnalyticEvent.ScreenName, category: AnalyticEvent.Category, action: AnalyticEvent.Action)
    func logEvent(screenName: AnalyticEvent.ScreenName, category: AnalyticEvent.Category, action: AnalyticEvent.Action, label: String)
}
