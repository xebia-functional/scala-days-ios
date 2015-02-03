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

class SDSlideMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var titleConference: UILabel!
    
    @IBOutlet weak var heigthTable: NSLayoutConstraint!
    @IBOutlet weak var heigthHeader: NSLayoutConstraint!
    
    @IBOutlet var viewSelectedConference: UIView!
    
    enum Menu: Int {
        case Schedule = 0
        case Social
        case Contact
        case Tickets
        case Sponsors
        case Places
        case About
    }

    var menus = [NSLocalizedString("schedule", comment: "Schedule"),
        NSLocalizedString("social", comment: "Social"),
        NSLocalizedString("contacts", comment: "Contacts"),
        NSLocalizedString("tickets", comment: "Tickets"),
        NSLocalizedString("sponsors", comment: "Sponsors"),
        NSLocalizedString("places", comment: "Places"),
        NSLocalizedString("about", comment: "About")]
    
    var menusImage = [icon_menu_schedule,icon_menu_social,icon_menu_contact,icon_menu_ticket,icon_menu_sponsors,icon_menu_places,icon_menu_about]
    
    var scheduleViewController: UIViewController!
    var socialViewController: UIViewController!
    var contactViewController: UIViewController!
    var sponsorsViewController: UIViewController!
    var placesViewController: UIViewController!
    var aboutViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("SDSlideMenuViewController")
        
        if(IS_IPHONE5){
            heigthHeader.constant = Height_Header_Menu
        }
        
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
        
        self.viewSelectedConference.hidden = true
        
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
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = menus[indexPath.row]
        cell.textLabel?.setCustomFont(UIFont.fontHelveticaNeue(15), colorFont: UIColor(white: 1, alpha: 0.8))
        cell.imageView?.image = UIImage(named: menusImage[indexPath.row] as NSString)
        cell.backgroundColor = UIColor.appColor()
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.selectedCellMenu()
        cell.selectedBackgroundView = bgColorView
               
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return Height_Row_Menu
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let menu = Menu(rawValue: indexPath.item) {
            
            switch menu {
            case .Schedule:
                self.slideMenuController()?.changeMainViewController(self.scheduleViewController, close: true)
                break
            case .Social:
                self.slideMenuController()?.changeMainViewController(self.socialViewController, close: true)
                break
            case .Contact:
                self.slideMenuController()?.changeMainViewController(self.contactViewController, close: true)
                break
            case .Sponsors:
                self.slideMenuController()?.changeMainViewController(self.sponsorsViewController, close: true)
                break
            case .Places:
                self.slideMenuController()?.changeMainViewController(self.placesViewController, close: true)
                break
            case .About:
                self.slideMenuController()?.changeMainViewController(self.aboutViewController, close: true)
                break
            default:
                break
            }
        }
 
    }
    
    @IBAction func selectedConference(sender: AnyObject) {
        
        if( self.viewSelectedConference.hidden){
            self.viewSelectedConference.hidden = false
        }else{
            self.viewSelectedConference.hidden = true
        }
    }
    
    
}