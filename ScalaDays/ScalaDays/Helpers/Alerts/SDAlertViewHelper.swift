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

class SDAlertViewHelper: NSObject {
    class func showSimpleAlertViewOnViewController(viewController: UIViewController!, title: String?, message: String?, cancelButtonTitle: String!, otherButtonTitle: String?, tag: Int?, delegate: UIAlertViewDelegate?, handler: ((UIAlertAction!) -> Void)?) {
        if isIOS8OrLater() {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let actionCancel = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: handler)
            if let otherButton = otherButtonTitle {
                let actionOther = UIAlertAction(title: otherButton, style: .Default, handler: handler)
                alertController.addAction(actionOther)
            }
            
            alertController.addAction(actionCancel)
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let alertView = UIAlertView()
            if let unwrappedTitle = title {
                alertView.title = unwrappedTitle
            }
            alertView.message = message
            alertView.delegate = delegate
            alertView.addButtonWithTitle(cancelButtonTitle)
            alertView.cancelButtonIndex = 0
            if let unwrappedOtherButton = otherButtonTitle {
                alertView.addButtonWithTitle(unwrappedOtherButton)
            }
            if let unwrappedTag = tag {
                alertView.tag = unwrappedTag
            }
            alertView.show()
        }
    }
}
