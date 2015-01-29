//
//  ViewController.swift
//  ScalaDays
//
//  Created by Ana on 15/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLConnectionDelegate {

    var data = NSMutableData()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadData()
    }

    func loadData() {
        DataManager.sharedInstance.loadData() {
            (json, error) -> () in
            if let unWrapperJson = json {
                DataManager.sharedInstance.parseJSON(unWrapperJson)
                if let info = DataManager.sharedInstance.information?.nameAndLocation{
                    println(DataManager.sharedInstance.information?.nameAndLocation)
                }
            } else {
                println("nil")
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

