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

@objc protocol SDQRScannerOverlayViewDelegate {
    
    optional func didTapCancelButtonInQRScanner()
    
}

class SDQRScannerOverlayView: UIView {
    
    lazy var customConstraints : NSMutableArray = NSMutableArray()

    @IBOutlet weak var btnCancel: UIBarButtonItem!
    var containerView: UIView!
    weak var delegate : SDQRScannerOverlayViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        // This init function loads our custom view from the nib:
        let objects = NSBundle.mainBundle().loadNibNamed("SDQRScannerOverlayView", owner: self, options: nil)
        
        objects.filter({$0 is UIView})
        if objects.count > 0 {
            containerView = objects[0] as UIView
            containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
            addSubview(containerView)
            needsUpdateConstraints()
        }
        btnCancel.title = NSLocalizedString("common_cancel", comment: "Cancel")
        btnCancel.target = self
        btnCancel.action = "didTapCancelButton"
    }
    
    override func updateConstraints() {
        removeConstraints(customConstraints)
        customConstraints.removeAllObjects()
        
        if containerView != nil {
            let viewDictionary : [NSObject : AnyObject] = ["view" : containerView]
            customConstraints.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDictionary as [NSObject:AnyObject]))
            customConstraints.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDictionary as [NSObject:AnyObject]))
            
            self.addConstraints(customConstraints)
        }
        super.updateConstraints()
    }
    
    // MARK: - Cancel scanning handling
    
    func didTapCancelButton() {
        delegate?.didTapCancelButtonInQRScanner?()
    }
}
