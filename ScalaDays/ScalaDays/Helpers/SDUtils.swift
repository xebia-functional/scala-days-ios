//
//  SDUtils.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 02/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDUtils: NSObject {
    class func isIosVersionAtLeastVersion(version: String) -> Bool {
        switch UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            return true
        case .OrderedAscending:
            return false
        }
    }
}
