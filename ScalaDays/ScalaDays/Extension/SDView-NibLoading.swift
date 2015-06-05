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

extension UIView {
   
    func loadNibSubviewsFromNib(nibName: String) -> UIView? {
        let objects = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil)
        
        objects.filter({$0 is UIView})
        if objects.count > 0 {
            let containerView = objects[0] as! UIView
            containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
            addSubview(containerView)
            needsUpdateConstraints()
            
            return containerView
        }
        return nil
    }
    
    func updateCustomConstraints(customConstraints : NSMutableArray, containerView: UIView!) {
        removeConstraints(customConstraints as [AnyObject])
        customConstraints.removeAllObjects()
        
        if containerView != nil {
            let viewDictionary : [NSObject : AnyObject] = ["view" : containerView]
            customConstraints.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDictionary as [NSObject:AnyObject]))
            customConstraints.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDictionary as [NSObject:AnyObject]))
            
            addConstraints(customConstraints as [AnyObject])
        }
    }
    
}
