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

class SDScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblSchedule: UITableView!
    
    let kReuseIdentifier = "SDScheduleViewControllerCell"
    let kHeaderHeight : CGFloat = 40.0
    lazy var selectedConference : Conference? = DataManager.sharedInstance.currentlySelectedConference
    
    var dates: [String]?
    var events: [[Event]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("schedule", comment: "Schedule")
        tblSchedule?.registerNib(UINib(nibName: "SDScheduleListTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        tblSchedule?.registerNib(UINib(nibName: "SDScheduleListTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: kReuseIdentifier)
        tblSchedule?.separatorStyle = .None
        
        self.loadData()
    }
    
    // MARK: - Data loading
    
    func loadData() {
        SVProgressHUD.show()
        DataManager.sharedInstance.loadDataJson() {
            (bool, error) -> () in
            if(bool){
                println ("Json modified, reload data")
            }
            SVProgressHUD.dismiss()
            
            self.dates = self.scheduledDates()
            self.events = self.listOfEventsSortedByDates()
            self.tblSchedule.reloadData()
            
            let test = self.selectedConference?.schedule.filter({ $0.location != nil })
            println("lel")
        }
    }
    
    // MARK: UITableViewDataSource implementation

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let scheduledDates = dates {
            return scheduledDates.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = events {
            return events[section].count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier, forIndexPath: indexPath) as SDScheduleListTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: SDScheduleListTableViewCell, indexPath: NSIndexPath) {
        if let events = events {
            let event = events[indexPath.section][indexPath.row]
            cell.drawEventData(event)
        }
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
        switch(tableView.dequeueReusableHeaderFooterViewWithIdentifier(kReuseIdentifier), dates) {
        case let (.Some(headerView as SDScheduleListTableViewHeader), .Some(dates)):
            headerView.lblDate.text = dates[section]
            return headerView
        default:
            break
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

        switch(dates, selectedConference?.schedule) {
            case let (.Some(_dates), .Some(_schedule)):
            for date in _dates {
                let filteredEvents = _schedule.filter { $0.date == date}
                temp.append(filteredEvents)
            }
            return temp
            default:
                break;
        }

        return nil
    }
    
}

