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

class SDSlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var titleConference: UILabel!
    @IBOutlet weak var heigthTable: NSLayoutConstraint!
    @IBOutlet weak var heightConferenceTable: NSLayoutConstraint!
    @IBOutlet weak var heigthHeader: NSLayoutConstraint!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var tblConferences: UITableView!
    let kConferenceReuseIdentifier = "ConferencesListCell"


    enum Menu: Int {
        case Schedule = 0
        case Social
        case Contact
        case Tickets
        case Sponsors
        case Places
        case Speakers
        case About
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

    var scheduleViewController: UIViewController!
    var socialViewController: UIViewController!
    var contactViewController: UIViewController!
    var sponsorsViewController: UIViewController!
    var placesViewController: UIViewController!
    var aboutViewController: UIViewController!
    var speakersViewController: UIViewController!
    
    var infoSelected: Information?
    
    var currentConferences: Conferences?

    override func viewDidLoad() {
        super.viewDidLoad()

        if (IS_IPHONE5) {
            heigthHeader.constant = Height_Header_Menu
        }
        
        //Conferences aparence table
        self.tblConferences.scrollEnabled = false
        self.tblConferences.separatorColor = UIColor(white: 1, alpha: 0.1)
        self.tblConferences.registerNib(UINib(nibName: "SDConferenceTableViewCell", bundle: nil), forCellReuseIdentifier: kConferenceReuseIdentifier)
        self.tblConferences.alpha = 0
        
        //Init aparence table
        self.heigthTable.constant = CGFloat(menus.count * Int(Height_Row_Menu))
        self.tblMenu.scrollEnabled = false
        self.tblMenu.separatorColor = UIColor(white: 1, alpha: 0.1)
        self.titleConference.setCustomFont(UIFont.fontHelveticaNeue(17), colorFont: UIColor.whiteColor())

        // Do any additional setup after loading the view.
        let socialViewController = SDSocialViewController(nibName: "SDSocialViewController", bundle: nil)
        self.socialViewController = UINavigationController(rootViewController: socialViewController)

        let contactViewController = SDContactViewController(nibName: "SDContactViewController", bundle: nil)
        self.contactViewController = UINavigationController(rootViewController: contactViewController)

        let sponsorsViewController = SDSponsorViewController(nibName: "SDSponsorViewController", bundle: nil)
        self.sponsorsViewController = UINavigationController(rootViewController: sponsorsViewController)

        let placesViewController = SDPlacesViewController(nibName: "SDPlacesViewController", bundle: nil)
        self.placesViewController = UINavigationController(rootViewController: placesViewController)

        let aboutViewController = SDAboutViewController(nibName: "SDAboutViewController", bundle: nil)
        self.aboutViewController = UINavigationController(rootViewController: aboutViewController)
        
        let speakersViewController = SDSpeakersListViewController(nibName: "SDSpeakersListViewController", bundle: nil)
        self.speakersViewController = UINavigationController(rootViewController: speakersViewController)
       
    }
    
    override func  viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        componeConferenceTable()
        drawSelectedConference()
    }
    
    func componeConferenceTable(){
        if let conferences = DataManager.sharedInstance.conferences?{
            self.currentConferences = conferences
            self.tblConferences.reloadData()
        }
    }
    
    func drawSelectedConference(){
        if let  info = DataManager.sharedInstance.currentlySelectedConference?.info{
            self.infoSelected = info
            self.titleConference.text = info.longName
            let image = info.pictures[2]
            let imageUrl = NSURL(string: image.url)
            if let infoImageUrl = imageUrl {
                self.imgHeader.sd_setImageWithURL(infoImageUrl, placeholderImage: UIImage(named: ""))
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (tableView, self.currentConferences) {
            case (self.tblConferences, .Some(let x)):
                self.heightConferenceTable.constant = CGFloat(x.conferences.count * Int(Height_Row_Menu))
                return x.conferences.count
            case (self.tblConferences, .None): return 0
            default: return menus.count
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (tableView, self.currentConferences) {
            case (self.tblConferences, .Some(let x)):
                var cell : SDConferenceTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kConferenceReuseIdentifier) as? SDConferenceTableViewCell
                
                switch cell {
                    case let(.Some(cell)): return configureConferenceCell(cell, indexPath: indexPath)
                    default:
                        let cell = SDConferenceTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kConferenceReuseIdentifier)
                        return configureConferenceCell(cell, indexPath: indexPath)
                }
            default :
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellMenu")
                cell.textLabel?.setCustomFont(UIFont.fontHelveticaNeue(15), colorFont: UIColor(white: 1, alpha: 0.8))
                cell.backgroundColor = UIColor.appColor()
                var bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.selectedCellMenu()
                cell.selectedBackgroundView = bgColorView
                cell.textLabel?.text = menus[indexPath.row]
                cell.imageView?.image = UIImage(named: menusImage[indexPath.row] as NSString)
                cell.layoutIfNeeded()
                return cell
        }
        
    }
    
    func configureConferenceCell(cell: SDConferenceTableViewCell, indexPath: NSIndexPath) -> SDConferenceTableViewCell {
       if let listOfConferences = self.currentConferences {
            if(listOfConferences.conferences.count > indexPath.row) {
                let conferenceCell = cell as SDConferenceTableViewCell
                conferenceCell.drawConferenceData(listOfConferences.conferences[indexPath.row])
                conferenceCell.layoutSubviews()
            }
        }
        cell.frame = CGRectMake(0, 0, tblConferences.bounds.size.width, cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }


    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        return Height_Row_Menu
    }

    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
   
        switch (tableView, Menu(rawValue: indexPath.item)) {
            case (self.tblConferences, _) :
                DataManager.sharedInstance.selectedConferenceIndex = indexPath.row
                drawSelectedConference()
                toggleTblConference()
            case (self.tblMenu, .Some(.Schedule)): self.slideMenuController()?.changeMainViewController(self.scheduleViewController, close: true)
            case (self.tblMenu, .Some(.Social)): self.slideMenuController()?.changeMainViewController(self.socialViewController, close: true)
            case (self.tblMenu, .Some(.Contact)): self.slideMenuController()?.changeMainViewController(self.contactViewController, close: true)
            case (self.tblMenu, .Some(.Sponsors)): self.slideMenuController()?.changeMainViewController(self.sponsorsViewController, close: true)
            case (self.tblMenu, .Some(.Places)): self.slideMenuController()?.changeMainViewController(self.placesViewController, close: true)
            case (self.tblMenu, .Some(.About)): self.slideMenuController()?.changeMainViewController(self.aboutViewController, close: true)
            case (self.tblMenu, .Some(.Speakers)): self.slideMenuController()?.changeMainViewController(self.speakersViewController, close: true)
            case (self.tblMenu, .Some(.Tickets)):
                if let registration = self.infoSelected?.registrationSite {
                    UIApplication.sharedApplication().openURL(NSURL(string:registration)!)
                }
            default: break
        }

    }

    @IBAction func selectedConference(sender: AnyObject) {
        toggleTblConference()
    }
    
    func toggleTblConference() {
        if (self.tblConferences.alpha == 0.0) {
            UIView.animateWithDuration(0.5, animations: {
                self.tblConferences.alpha = 1.0
                self.tblMenu.alpha = 0.0
                return
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.tblConferences.alpha = 0.0
                self.tblMenu.alpha = 1.0
                return
            })
            
        }
    }


}
