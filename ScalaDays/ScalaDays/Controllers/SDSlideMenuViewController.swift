/*
* Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


import UIKit

class SDSlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SDSliderMenuBar {
    
    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var titleConference: UILabel!
    @IBOutlet weak var heigthTable: NSLayoutConstraint!
    @IBOutlet weak var heightConferenceTable: NSLayoutConstraint!
    @IBOutlet weak var heigthHeader: NSLayoutConstraint!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var tblConferences: UITableView!
    let kConferenceReuseIdentifier = "ConferencesListCell"
    var controllers : [UIViewController]!
    
    
    enum Menu: Int {
        case schedule = 0
        case social
        case contact
        case tickets
        case sponsors
        case places
        case speakers
        case about
    }
    
    var menus = [NSLocalizedString("schedule", comment: "Schedule"),
                 NSLocalizedString("social", comment: "Social"),
                 NSLocalizedString("contacts", comment: "Contacts"),
                 NSLocalizedString("tickets", comment: "Tickets"),
                 NSLocalizedString("sponsors", comment: "Sponsors"),
                 NSLocalizedString("places", comment: "Places"),
                 NSLocalizedString("speakers", comment: "Speakers"),
                 NSLocalizedString("about", comment: "About")]
    
    var menusImage = [icon_menu_schedule,
                      icon_menu_social,
                      icon_menu_contact,
                      icon_menu_ticket,
                      icon_menu_sponsors,
                      icon_menu_places,
                      icon_menu_speakers,
                      icon_menu_about]
    
    var scheduleViewController: UINavigationController!
    var socialViewController: UIViewController!
    var contactViewController: UIViewController!
    var sponsorsViewController: UIViewController!
    var placesViewController: UIViewController!
    var aboutViewController: UIViewController!
    var speakersViewController: UIViewController!
    
    var infoSelected: Information?
    
    var currentConferences: Conferences?
    
    private let analytics: Analytics
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDSlideMenuViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (IS_IPHONE5) {
            heigthHeader.constant = Height_Header_Menu
        }
        
        // Conferences aparence table
        self.tblConferences.isScrollEnabled = false
        self.tblConferences.separatorColor = UIColor(white: 1, alpha: 0.1)
        self.tblConferences.register(UINib(nibName: "SDConferenceTableViewCell", bundle: nil), forCellReuseIdentifier: kConferenceReuseIdentifier)
        self.tblConferences.alpha = 0
        
        // Init aparence table
        self.heigthTable.constant = CGFloat(menus.count * Int(Height_Row_Menu))
        self.tblMenu.isScrollEnabled = IS_IPHONE5
        self.tblMenu.separatorColor = UIColor(white: 1, alpha: 0.1)
        
        self.tblMenu.scrollsToTop = false
        self.tblConferences.scrollsToTop = false
        
        self.titleConference.setCustomFont(UIFont.fontHelveticaNeue(17), colorFont: UIColor.white)
        
        let socialViewController = SDSocialViewController(analytics: analytics)
        self.socialViewController = UINavigationController(rootViewController: socialViewController)
        
        let contactViewController = SDContactViewController(analytics: analytics)
        self.contactViewController = UINavigationController(rootViewController: contactViewController)
        
        let sponsorsViewController = SDSponsorViewController(analytics: analytics)
        self.sponsorsViewController = UINavigationController(rootViewController: sponsorsViewController)
        
        let placesViewController = SDPlacesViewController(analytics: analytics)
        self.placesViewController = UINavigationController(rootViewController: placesViewController)
        
        let aboutViewController = SDAboutViewController(analytics: analytics)
        self.aboutViewController = UINavigationController(rootViewController: aboutViewController)
        
        let speakersViewController = SDSpeakersListViewController(analytics: analytics)
        self.speakersViewController = UINavigationController(rootViewController: speakersViewController)
        
        controllers = [scheduleViewController.visibleViewController!, socialViewController, contactViewController, sponsorsViewController, placesViewController, aboutViewController, speakersViewController]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        componeConferenceTable()
        drawSelectedConference()
    }
    
    func componeConferenceTable(){
        if let conferences = DataManager.sharedInstance.conferences {
            self.currentConferences = conferences
            self.tblConferences.reloadData()
        }
    }
    
    func drawSelectedConference(){
        if let  info = DataManager.sharedInstance.currentlySelectedConference?.info{
            self.infoSelected = info
            self.titleConference.text = info.longName
            let image = info.pictures[2]
            let imageUrl = URL(string: image.url)
            if let infoImageUrl = imageUrl {
                self.imgHeader.sd_setImage(with: infoImageUrl, placeholderImage: UIImage(named: "placeholder_menu"))
            }
        }
    }
    
    // MARK: - UITableViewDataSource implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (tableView, self.currentConferences) {
        case (self.tblConferences, .some(let x)):
            if IS_IPHONE5 {
                self.heightConferenceTable.constant = CGFloat(screenBounds.height - Height_Header_Menu)
                return x.conferences.count
            } else {
                self.heightConferenceTable.constant = CGFloat(x.conferences.count * Int(Height_Row_Menu))
                return x.conferences.count
            }
        case (self.tblConferences, .none): return 0
        default:
            if IS_IPHONE5 {
                self.heigthTable.constant = CGFloat(screenBounds.height - Height_Header_Menu)
            } else {
                self.heigthTable.constant = CGFloat(menus.count * Int(Height_Row_Menu))
            }
            return menus.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (tableView, self.currentConferences) {
        case (self.tblConferences, .some(_)):
            let cell : SDConferenceTableViewCell? = tableView.dequeueReusableCell(withIdentifier: kConferenceReuseIdentifier) as? SDConferenceTableViewCell
            
            switch cell {
            case let(.some(cell)): return configureConferenceCell(cell, indexPath: indexPath)
            default:
                let cell = SDConferenceTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: kConferenceReuseIdentifier)
                return configureConferenceCell(cell, indexPath: indexPath)
            }
        default :
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CellMenu")
            cell.textLabel?.setCustomFont(UIFont.fontHelveticaNeue(15), colorFont: UIColor(white: 1, alpha: 0.8))
            cell.backgroundColor = UIColor.appColor()
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.selectedCellMenu()
            cell.selectedBackgroundView = bgColorView
            cell.textLabel?.text = menus[indexPath.row]
            cell.imageView?.image = UIImage(named: menusImage[indexPath.row] as String)
            cell.layoutIfNeeded()
            return cell
        }
        
    }
    
    func configureConferenceCell(_ cell: SDConferenceTableViewCell, indexPath: IndexPath) -> SDConferenceTableViewCell {
        if let listOfConferences = self.currentConferences {
            if(listOfConferences.conferences.count > indexPath.row) {
                let conferenceCell = cell as SDConferenceTableViewCell
                conferenceCell.drawConferenceData(listOfConferences.conferences[indexPath.row])
                conferenceCell.layoutSubviews()
            }
        }
        cell.frame = CGRect(x: 0, y: 0, width: tblConferences.bounds.size.width, height: cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Height_Row_Menu
    }
    
    // MARK: - UITableViewDelegate implementation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (tableView, Menu(rawValue: indexPath.item)) {
        case (self.tblConferences, _) :
            DataManager.sharedInstance.selectConference(at: indexPath.row)
            drawSelectedConference()
            toggleTblConference()
            askControllersToReload()
            self.slideMenuController()?.closeLeft()
            
            if let selectedConference = DataManager.sharedInstance.conferences?.conferences[indexPath.row] {
                self.analytics.logEvent(screenName: .slideMenu, category: .navigate, action: .menuChangeConference, label: selectedConference.info.name)
            }
            
        case (self.tblMenu, .some(.schedule)): self.slideMenuController()?.changeMainViewController(self.scheduleViewController, close: true)
        case (self.tblMenu, .some(.social)): self.slideMenuController()?.changeMainViewController(self.socialViewController, close: true)
        case (self.tblMenu, .some(.contact)): self.slideMenuController()?.changeMainViewController(self.contactViewController, close: true)
        case (self.tblMenu, .some(.sponsors)): self.slideMenuController()?.changeMainViewController(self.sponsorsViewController, close: true)
        case (self.tblMenu, .some(.places)): self.slideMenuController()?.changeMainViewController(self.placesViewController, close: true)
        case (self.tblMenu, .some(.about)): self.slideMenuController()?.changeMainViewController(self.aboutViewController, close: true)
        case (self.tblMenu, .some(.speakers)): self.slideMenuController()?.changeMainViewController(self.speakersViewController, close: true)
        case (self.tblMenu, .some(.tickets)):
            if let registration = self.infoSelected?.registrationSite, let url = URL(string: registration) {
                self.analytics.logEvent(screenName: .slideMenu, category: .navigate, action: .goToTicket)
                _ = launchSafariToUrl(url)
            }
        default: break
        }
    }
    
    @IBAction func selectedConference(_ sender: AnyObject) {
        toggleTblConference()
    }
    
    func toggleTblConference() {
        if (self.tblConferences.alpha == 0.0) {
            UIView.animate(withDuration: 0.5, animations: {
                self.tblConferences.alpha = 1.0
                self.tblMenu.alpha = 0.0
                return
            })
        } else {
            hideTblConference()
        }
    }
    
    func hideTblConference() {
        if tblConferences.alpha > 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.tblConferences.alpha = 0.0
                self.tblMenu.alpha = 1.0
                return
            })
        }
    }
    
    // MARK: - Notify controllers of conference swapping
    
    func currentVisibleController() -> SDMenuControllerItem? {
        if let mainNavController = self.slideMenuController()?.mainViewController as? UINavigationController {
            if let currentController = mainNavController.visibleViewController as? SDMenuControllerItem {
                return currentController
            }
        }
        return nil
    }
    
    func askControllersToReload() {
        // We need to notify our main controllers that their data need to be updated, also our visible controller needs to reload ASAP:
        for controller in controllers {
            if controller is SDMenuControllerItem {
                let controllerItem = controller as! SDMenuControllerItem
                controllerItem.isDataLoaded = false
            }
        }
        
        if let currentController = currentVisibleController() {
            currentController.loadData()
        }
    }
    
    // MARK: - SDSliderMenuBar protocol implementation
    
    func didCloseMenu() {
        hideTblConference()
    }
}
