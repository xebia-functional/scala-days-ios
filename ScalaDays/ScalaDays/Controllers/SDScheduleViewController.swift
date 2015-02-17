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

enum SDScheduleActionSheetButtons: Int {
    case Cancel = 0
    case All = 1
    case Favorites = 2
}

enum SDScheduleSelectedDataSource {
    case All
    case Favorites
}

enum SDScheduleEventType: Int {
    case Courses = 1
    case Keynotes = 2
    case Others = 3
}

class SDScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {

    @IBOutlet weak var tblSchedule: UITableView!

    let kReuseIdentifier = "SDScheduleViewControllerCell"
    let kHeaderHeight: CGFloat = 40.0

    lazy var selectedConference: Conference? = DataManager.sharedInstance.currentlySelectedConference

    var dates: [String]?
    var events: [[Event]]?
    var favorites: [[Event]]?
    var selectedDataSource: SDScheduleSelectedDataSource = .All
    var eventsToShow: [[Event]]? {
        get {
            switch (selectedDataSource) {
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
    var isDataLoaded : Bool = false

    override func viewWillAppear(animated: Bool) {
        self.title = NSLocalizedString("schedule", comment: "Schedule")
        self.tblSchedule.reloadData()
        if isDataLoaded {
            self.loadFavorites()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
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
            if (bool) {
                println("Json modified, reload data")
            }
            self.isDataLoaded = true
            
            SVProgressHUD.dismiss()

            self.dates = self.scheduledDates()
            self.events = self.listOfEventsSortedByDates()
            self.tblSchedule.reloadData()
            self.view.backgroundColor = UIColor.appScheduleTimeBlueBackgroundColor()

            self.loadFavorites()
        }
    }
    
    func loadFavorites() {
        if let favs = self.favoritedEvents() {
            self.favorites = favs
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
        if let events = eventsToShow {
            return events[section].count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SDScheduleListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDScheduleListTableViewCell
        switch cell {
        case let (.Some(cell)):
            return configureCell(cell, indexPath: indexPath)
        default:
            let cell = SDScheduleListTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
            return configureCell(cell, indexPath: indexPath)
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
        let scheduleDetailViewController = SDScheduleDetailViewController(nibName: "SDScheduleDetailViewController", bundle: nil)
        if let events = eventsToShow {
            let event: Event = events[indexPath.section][indexPath.row]
            if (event.type == SDScheduleEventType.Keynotes.rawValue || event.type == SDScheduleEventType.Courses.rawValue) {
                self.title = ""
                scheduleDetailViewController.event = event
                self.navigationController?.pushViewController(scheduleDetailViewController, animated: true)
            }
        }
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

        switch (dates, selectedConference?.schedule) {
        case let (.Some(_dates), .Some(_schedule)):
            for date in _dates {
                let filteredEvents = _schedule.filter {
                    $0.date == date
                }
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
        launchFilterSheet()
    }

// MARK: - Favorites handling

    func favoritedEvents() -> [[Event]]? {
        if let _conference = selectedConference {
            if let _events = events {
                return _events.map({
                    $0.filter({
                        if let favoritesDict = DataManager.sharedInstance.favoritedEvents {
                            if let favoritedEvents = favoritesDict[_conference.info.id] {
                                let event = $0
                                return favoritedEvents.reduce(false, {
                                    return $0 ? $0 : event.id == $1
                                })
                            }
                        }
                        return false
                    })
                })
            }
        }
        return nil
    }

    func launchFilterSheet() {
        let title = NSLocalizedString("schedule_action_sheet_filter_title", comment: "")
        let actionTitleAll = NSLocalizedString("schedule_action_sheet_filter_message_all", comment: "")
        let actionTitleFavorites = NSLocalizedString("schedule_action_sheet_filter_message_favorites", comment: "")
        let actionTitleCancel = NSLocalizedString("common_cancel", comment: "")

        if (isIOS8OrLater()) {
            let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
            actionSheet.addAction(UIAlertAction(title: actionTitleAll, style: .Default, handler: {
                (alertAction) -> Void in
                self.reloadTableDataWithFilter(.All)
            }))
            actionSheet.addAction(UIAlertAction(title: actionTitleFavorites, style: .Default, handler: {
                (alertAction) -> Void in
                self.reloadTableDataWithFilter(.Favorites)
            }))
            actionSheet.addAction(UIAlertAction(title: actionTitleCancel, style: .Cancel, handler: {
                (alertAction) -> Void in

            }))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        } else {
            let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: actionTitleCancel, destructiveButtonTitle: nil, otherButtonTitles: actionTitleAll, actionTitleFavorites)
            actionSheet.showInView(self.view)
        }
    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch (buttonIndex) {
        case actionSheet.cancelButtonIndex:
            return
        case SDScheduleActionSheetButtons.All.rawValue:
            self.reloadTableDataWithFilter(.All)
        case SDScheduleActionSheetButtons.Favorites.rawValue:
            self.reloadTableDataWithFilter(.Favorites)
        default:
            break
        }
    }

    func reloadTableDataWithFilter(filter: SDScheduleSelectedDataSource) {
        selectedDataSource = filter
        tblSchedule.reloadData()
    }

}

