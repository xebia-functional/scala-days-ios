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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension UIView {
   
    func loadNibSubviewsFromNib(_ nibName: String) -> UIView? {
        let objects = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        
        objects?.filter({$0 is UIView})
        if objects?.count > 0 {
            let containerView = objects![0] as! UIView
            containerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(containerView)
            needsUpdateConstraints()
            
            return containerView
        }
        return nil
    }
    
    func updateCustomConstraints(_ customConstraints : NSMutableArray, containerView: UIView!) {
       
        for object in customConstraints {
            if let const = object as? NSLayoutConstraint {
                removeConstraint(const)
            }
        }
        customConstraints.removeAllObjects()

        if containerView != nil {
            let viewDictionary : NSDictionary = ["view" : containerView]
            customConstraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary as! [String : AnyObject]))
            customConstraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary as! [String:AnyObject]))

            for object in customConstraints {
                if let const = object as? NSLayoutConstraint {
                    addConstraint(const)
                }
            }
        }
    }
    
}
