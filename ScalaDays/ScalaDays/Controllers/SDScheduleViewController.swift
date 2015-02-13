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

class SDScheduleViewController: UIViewController {

    @IBOutlet weak var tblSchedule: UITableView!
    
    let kReuseIdentifier = "SDScheduleViewControllerCell"
    let kHeaderHeight : CGFloat = 40.0
    
    lazy var selectedConference : Conference? = DataManager.sharedInstance.currentlySelectedConference
    
    var dates: [String]?
    var events: [[Event]]?
    var favorites: [[Event]]?
    var selectedDataSource : SDScheduleSelectedDataSource = .All
    var eventsToShow : [[Event]]? {
        get {
            switch(selectedDataSource) {
            case .All:
                return events
            case .Favorites:
                if let _favoritesIndexes = DataManager.sharedInstance.favoritedEvents {
                    return _favoritesIndexes.count == 0 ? events : favorites
                }
                return events
            default:
                return nil
            }
         }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNavigationBarItem()
        self.title = NSLocalizedString("schedule", comment: "Schedule")
        self.loadData()

        tblSchedule?.registerNib(UINib(nibName: "SDSocialTableViewCell", bundle: nil), forCellReuseIdentifier: "socialViewControllerCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadData() {
        SVProgressHUD.show()
        DataManager.sharedInstance.loadDataJson() {
            (bool, error) -> () in
            if(bool){
                println ("Json modified, reload data")
            }
            SVProgressHUD.dismiss()
        }
    }


//MARK: UITableViewDataSource


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : SDScheduleListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDScheduleListTableViewCell
        switch cell {
        case let(.Some(cell)):
            configureCell(cell, indexPath: indexPath)
            return cell
        default:
            let cell = SDScheduleListTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
            configureCell(cell, indexPath: indexPath)
            return cell
        }
    }
    
    func configureCell(cell: SDScheduleListTableViewCell, indexPath: NSIndexPath) -> SDScheduleListTableViewCell {
        if let events = eventsToShow {
            let event = events[indexPath.section][indexPath.row]
            cell.drawEventData(event)
        }
        cell.frame = CGRectMake(0, 0, tblSchedule.bounds.size.width, cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let dates = dates {
            return dates[section]
        }
        return nil
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as SDScheduleListTableViewCell
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // It seems that there are problems trying to use NIB files to instantiate table view headers in iOS7
        // (the run-time asks for a call to super.layoutSubviews() even if it's specifically overriden in the header subclass).
        // We need to do it by hand in this case...
        if let _dates = dates {
            let headerView = SDTableHeaderView(frame: CGRectMake(0, 0, tblSchedule.frame.size.width, kHeaderHeight))
            headerView.lblDate.text = _dates[section]
            headerView.lblDate.sizeToFit()
            return headerView
        }
        return nil
    }
    
    // MARK: - Data handling
    
    func scheduledDates() -> [String]? {
        if let schedule = selectedConference?.schedule {
            let result = schedule.reduce([String](), {
                var temp = $0
                
                if $0.count == 0 {
                    return [$1.date]
                } else if $1.date != $0.last {
                    temp.append($1.date)
                }
                return temp
            })
            return result
        }
        return nil
    }
    
    func listOfEventsSortedByDates() -> [[Event]]? {
        var temp = [[Event]]()

//MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}