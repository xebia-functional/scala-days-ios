//
//  SDMenuViewController.swift
//  ScalaDays
//
//  Created by Ana on 28/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit


class SDMenuViewController: UIViewController {
    
    var mainViewController: UIViewController!
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

