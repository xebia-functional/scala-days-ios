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
import SVProgressHUD

class SDSponsorViewController: GAITrackedViewController, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {

    @IBOutlet weak var tblSponsors: UITableView!
    
    var errorPlaceholderView : SDErrorPlaceholderView!
    
    let kReuseIdentifier = "SDSponsorViewControllerCell"
    let kHeaderHeight : CGFloat = 40.0
    let kRowHeight : CGFloat = 100.0
    
    var sponsors : [SponsorType]!
    var filteredSponsorTypes : [String]? = nil
    var filteredSponsors : [[Sponsor]]? = nil
    
    var isDataLoaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("sponsors", comment: "Sponsors")
        
        tblSponsors?.register(UINib(nibName: "SDSponsorsTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        self.screenName = kGAScreenNameSponsors
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isDataLoaded {
            loadData()
        }
    }
    
    // MARK: - Data loading
    
    func loadData() {
        SVProgressHUD.show()
        DataManager.sharedInstance.loadDataJson() {
            (bool, error) -> () in
            
            if let badError = error {
                self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                SVProgressHUD.dismiss()
            } else {
                self.sponsors = DataManager.sharedInstance.currentlySelectedConference?.sponsors
                SVProgressHUD.dismiss()
                
                if let result = self.filterSponsors() {
                    self.filteredSponsorTypes = result.types
                    self.filteredSponsors = result.sponsors
                    self.tblSponsors?.reloadData()
                    
                    if result.sponsors.count == 0 {
                        self.errorPlaceholderView.show(NSLocalizedString("error_insufficient_content", comment: ""), isGeneralMessage: true)
                    } else {
                        self.errorPlaceholderView.hide()
                    }
                } else {
                    self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                }
                
                self.tblSponsors?.reloadData()
                self.showTableView()
                self.isDataLoaded = true
            }
        }
    }
    
    // MARK: UITableViewDataSource implementation
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        if let types = filteredSponsorTypes {
            return types.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sponsors = filteredSponsors {
            return sponsors[section].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell : SDSponsorsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: kReuseIdentifier) as? SDSponsorsTableViewCell
        switch cell {
        case let(.some(cell)):
            configureCell(cell, indexPath: indexPath)
            return cell
        default:
            let cell = SDSponsorsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: kReuseIdentifier)
            configureCell(cell, indexPath: indexPath)
            return cell
        }
    }
    
    func configureCell(_ cell: SDSponsorsTableViewCell, indexPath: IndexPath) {
        if let sponsors = filteredSponsors?[indexPath.section] {
            cell.drawSponsorData(sponsors[indexPath.row])
        }
        cell.frame = CGRect(x: 0, y: 0, width: tblSponsors.bounds.size.width, height: cell.frame.size.height);
        cell.layoutIfNeeded()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let sponsors = filteredSponsors?[indexPath.section] {
            if let url = URL(string: sponsors[indexPath.row].url) {
                SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSponsors, category: kGACategoryNavigate, action: kGAActionSponsorsGoToSponsor, label: nil)
                launchSafariToUrl(url)
            }
        }        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return kRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // It seems that there are problems trying to use NIB files to instantiate table view headers in iOS7
        // (the run-time asks for a call to super.layoutSubviews() even if it's specifically overriden in the header subclass).
        // We need to do it by hand in this case...
        if let types = filteredSponsorTypes {
            let headerView = SDTableHeaderView(frame: CGRect(x: 0, y: 0, width: tblSponsors.frame.size.width, height: kHeaderHeight))
            headerView.lblDate.text = types[section]
            headerView.lblDate.sizeToFit()
            return headerView
        }
        return nil
    }
    
    // MARK: - Filtering sponsors
    
    func filterSponsors() -> (types: [String], sponsors: [[Sponsor]])? {
        if let _sponsors = sponsors {
            return _sponsors.reduce((types: [String](), sponsors: [[Sponsor]]()), {
                var tempTypes = $0.types
                var tempSponsors = $0.sponsors
                tempTypes.append($1.type)
                tempSponsors.append($1.items)
                
                return (tempTypes, tempSponsors)
            })
        }
        return nil
    }
    
    // MARK: SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
    // Animations
    
    func showTableView() {
        if self.tblSponsors.isHidden {
            SDAnimationHelper.showViewWithFadeInAnimation(self.tblSponsors)
        }
    }
    
}
