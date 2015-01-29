//
//  ViewController.swift
//  ScalaDays
//
//  Created by Ana on 15/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

//import Alamofire

class ViewController: UIViewController, NSURLConnectionDelegate {

    var data = NSMutableData()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var data = DataManager()
        data.startConnection()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTest(sender: AnyObject) {
        var menu:SDMenuViewController = SDMenuViewController(nibName: "SDMenuViewController", bundle: nil)
        self.navigationController?.pushViewController(menu, animated:true)
    }

}

