//
//  SDContactViewController.swift
//  ScalaDays
//
//  Created by Ana on 2/2/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarItem()
        self.title = NSLocalizedString("contacts", comment: "Contact")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
