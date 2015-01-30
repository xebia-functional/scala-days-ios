//
//  SDSlideMenuViewController.swift
//  ScalaDays
//
//  Created by Ana on 29/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDSlideMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tblMenu: UITableView!
    
    @IBOutlet weak var heigthTable: NSLayoutConstraint!
    
    enum Menu: Int {
        case Schedule = 0
        case Social
        case Tickets
        case Sponsors
        case Places
        case About
    }

    var menus = [NSLocalizedString("schedule", comment: "Schedule"),
        NSLocalizedString("social", comment: "Social"),
        NSLocalizedString("tickets", comment: "Tickets"),
        NSLocalizedString("sponsors", comment: "Sponsors"),
        NSLocalizedString("places", comment: "Places"),
        NSLocalizedString("about", comment: "About")]
    
    var menusImage = [icon_menu_schedule,icon_menu_social,icon_menu_ticket,icon_menu_sponsors,icon_menu_places,icon_menu_about]
    
    var scheduleViewController: UIViewController!
    var socialViewController: UIViewController!
    var sponsorsViewController: UIViewController!
    var placesViewController: UIViewController!
    var aboutViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init aparence table
        self.tblMenu.backgroundColor = UIColor.appColor()
        self.heigthTable.constant = CGFloat(menus.count * 44)

        // Do any additional setup after loading the view.
        let socialViewController = SDSocialViewController(nibName: "SDSocialViewController", bundle: nil)
        self.socialViewController = UINavigationController(rootViewController: socialViewController)
        
        let sponsorsViewController = SDSponsorViewController(nibName: "SDSponsorViewController", bundle: nil)
        self.sponsorsViewController = UINavigationController(rootViewController: sponsorsViewController)
        
        let placesViewController = SDPlacesViewController(nibName: "SDPlacesViewController", bundle: nil)
        self.placesViewController = UINavigationController(rootViewController: placesViewController)
        
        let aboutViewController = SDAboutViewController(nibName: "SDAboutViewController", bundle: nil)
        self.aboutViewController = UINavigationController(rootViewController: aboutViewController)
        
        
        
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
        cell.imageView?.image = UIImage(named: menusImage[indexPath.row] as NSString)
        cell.backgroundColor = UIColor.appColor()
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        
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
    
    
}
