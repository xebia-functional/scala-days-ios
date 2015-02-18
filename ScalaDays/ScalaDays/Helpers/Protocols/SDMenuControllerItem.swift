//
//  SDMenuControllerItem.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 18/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

@objc protocol SDMenuControllerItem {
    
    var isDataLoaded : Bool { get set }
    
    func loadData()
    
}