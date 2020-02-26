//
//  FirebaseAnalytics.swift
//  ScalaDays
//
//  Created by Miguel Angel on 26/02/2020.
//  Copyright © 2020 47 Degrees. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseScalaDays: Analytics {
    
    init() {
        FirebaseApp.configure()
    }
    
    func screenName(_ screen: String) {
        fatalError()
    }
}
