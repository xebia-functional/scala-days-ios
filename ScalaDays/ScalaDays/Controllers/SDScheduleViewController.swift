//
//  SDScheduleViewController.swift
//  ScalaDays
//
//  Created by Ana on 29/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDScheduleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNavigationBarItem()
        self.title = NSLocalizedString("schedule", comment: "Schedule")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}
