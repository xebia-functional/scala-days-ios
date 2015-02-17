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

class SDSponsorViewController: UIViewController {

    @IBOutlet weak var tblSponsors: UITableView!
    
    let kReuseIdentifier = "SDSponsorViewControllerCell"
    let kHeaderHeight : CGFloat = 40.0
    
    lazy var sponsors : [SponsorType]? = DataManager.sharedInstance.currentlySelectedConference?.sponsors
    var filteredSponsorTypes : [String]? = nil
    var filteredSponsors : [[Sponsor]]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("sponsors", comment: "Sponsors")
        
        tblSponsors?.registerNib(UINib(nibName: "SDSponsorsTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        
        if let result = filterSponsors() {
            filteredSponsorTypes = result.types
            filteredSponsors = result.sponsors
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tblSponsors.reloadData()
    }
    
    // MARK: UITableViewDataSource implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let types = filteredSponsorTypes {
            return types.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sponsors = filteredSponsors {
            return sponsors[section].count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : SDSponsorsTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDSponsorsTableViewCell
        switch cell {
        case let(.Some(cell)):
            configureCell(cell, indexPath: indexPath)
            return cell
        default:
            let cell = SDSponsorsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
            configureCell(cell, indexPath: indexPath)
            return cell
        }
    }
    
    func configureCell(cell: SDSponsorsTableViewCell, indexPath: NSIndexPath) {
        if let sponsors = filteredSponsors?[indexPath.section] {
            cell.drawSponsorData(sponsors[indexPath.row])
        }
        cell.frame = CGRectMake(0, 0, tblSponsors.bounds.size.width, cell.frame.size.height);
        cell.layoutIfNeeded()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let sponsors = filteredSponsors?[indexPath.section] {
            if let url = NSURL(string: sponsors[indexPath.row].url) {
                launchSafariToUrl(url)
            }
        }        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as SDSponsorsTableViewCell
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // It seems that there are problems trying to use NIB files to instantiate table view headers in iOS7
        // (the run-time asks for a call to super.layoutSubviews() even if it's specifically overriden in the header subclass).
        // We need to do it by hand in this case...
        if let types = filteredSponsorTypes {
            let headerView = SDTableHeaderView(frame: CGRectMake(0, 0, tblSponsors.frame.size.width, kHeaderHeight))
            headerView.lblDate.text = types[section]
            headerView.lblDate.sizeToFit()
            return headerView
        }
        return nil
    }
    
    // MARK: - Filtering sponsors
    
    func filterSponsors() -> (types: [String], sponsors: [[Sponsor]])? {
        if let _sponsors = sponsors {
            return _sponsors.reduce((types: [String](), sponsors: [[Sponsor]]()), combine: {
                var tempTypes = $0.types
                var tempSponsors = $0.sponsors
                tempTypes.append($1.type)
                tempSponsors.append($1.items)
                
                return (tempTypes, tempSponsors)
            })
        }
        return nil
    }
}
