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
    let kHeaderTextPadding : CGPoint = CGPointMake(15, 13)
    let kHeaderTextInitialWidth : CGFloat = 300.0
    let kHeaderTextInitialHeight : CGFloat = 15.0
    
    lazy var selectedConference : Conference? = DataManager.sharedInstance.currentlySelectedConference
    
    var dates: [String]?
    var events: [[Event]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("schedule", comment: "Schedule")
        let barButtonOptions = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_options"), style: .Plain, target: self, action: "didTapOptionsButton")
        self.navigationItem.rightBarButtonItem = barButtonOptions
        
        tblSchedule?.registerNib(UINib(nibName: "SDScheduleListTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
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
            self.view.backgroundColor = UIColor.appScheduleTimeBlueBackgroundColor()
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
    
    func configureCell(cell: SDScheduleListTableViewCell, indexPath: NSIndexPath) {
        if let events = events {
            let event = events[indexPath.section][indexPath.row]
            cell.drawEventData(event)
        }
        cell.frame = CGRectMake(0, 0, tblSchedule.bounds.size.width, cell.frame.size.height);
        cell.layoutIfNeeded()
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
        // It seems that there are problems trying to use NIB files to instantiate table view headers in iOS7 (the run-time asks for a call to super.layoutSubviews() even if it's specifically overriden in the header subclass). We need to do it by hand in this case...
        
        if let _dates = dates {
            let headerView = UIView(frame: CGRectMake(0, 0, tblSchedule.frame.size.width, kHeaderHeight))
            headerView.backgroundColor = UIColor.appScheduleTimeBlueBackgroundColor()
            let lblDate = UILabel(frame: CGRectMake(kHeaderTextPadding.x, kHeaderTextPadding.y, kHeaderTextInitialWidth, kHeaderTextInitialHeight))
            lblDate.backgroundColor = UIColor.clearColor()
            lblDate.setCustomFont(UIFont.fontHelveticaNeue(13), colorFont: UIColor.whiteColor())
            lblDate.text = _dates[section]
            lblDate.sizeToFit()
            headerView.addSubview(lblDate)
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
    
    // MARK: - Button handling
    
    func didTapOptionsButton() {
        
    }
    
}

