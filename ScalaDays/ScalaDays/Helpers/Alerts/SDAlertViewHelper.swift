//
//  SDAlertViewHelper.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 05/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

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
