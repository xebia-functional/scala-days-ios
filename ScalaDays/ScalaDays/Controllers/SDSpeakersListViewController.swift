//
//  SDSpeakersListViewController.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 05/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDSpeakersListViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    lazy var speakers : Array<Speaker>? = DataManager.sharedInstance.currentlySelectedConference?.speakers
    let kReuseIdentifier = "SpeakersListCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.reloadData()
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource implementation
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as SDSpeakersTableViewCell
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listOfSpeakers = speakers {
            return listOfSpeakers.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDSpeakersTableViewCell
        switch cell {
        case let(.Some(cell)):
            configureCell(cell, forRowAtIndexPath: indexPath)
            cell.frame = CGRectMake(0, 0, tableView.bounds.size.width, cell.frame.size.height);
            cell.layoutIfNeeded()
            cell.layoutSubviews()
            return cell
        default:
            return SDSpeakersTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
        }
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        if let listOfSpeakers = speakers {
            if(listOfSpeakers.count > forRowAtIndexPath.row) {
                let currentSpeaker : Speaker = listOfSpeakers[forRowAtIndexPath.row]
                let speakerCell = cell as SDSpeakersTableViewCell
                
                // TODO: test, change with real views after layout is done
                speakerCell.textLabel?.text = currentSpeaker.name
                
                speakerCell.layoutSubviews()
            }
        }
    }
    
    
}
