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

    @IBOutlet weak var tblMain: UITableView!
    let kReuseIdentifier = "SDScheduleViewControllerCell"
    lazy var selectedConference : Conference? = DataManager.sharedInstance.currentlySelectedConference
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNavigationBarItem()
        self.title = NSLocalizedString("schedule", comment: "Schedule")
        
        /*if let scheduleDates = scheduledDates() {
            println(scheduledDates)
        }*/
    }
    
    // MARK: UITableViewDataSource implementation

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        
    }
        //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Data handling
    
    /*func scheduledDates() -> Array<String>? {
        if let conference = selectedConference {
            let dates = conference.schedule.reduce([String](), combine: {
                var temp = $0
                let date = $1.date
                
                let count: Int = temp.filter({
                    $0 == date
                }).count
                
                return temp
            })
        }
        return nil
    }*/
}
