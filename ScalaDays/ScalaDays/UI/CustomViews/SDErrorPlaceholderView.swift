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

@objc protocol SDErrorPlaceholderViewDelegate {
    
    optional func didTapRefreshButtonInErrorPlaceholder()
    
}

class SDErrorPlaceholderView: UIView {
    
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnRefresh: UIButton!
    weak var delegate : SDErrorPlaceholderViewDelegate?
    
    let customConstraints : NSMutableArray = NSMutableArray()
    var containerView: UIView!
    
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
        if let container = loadNibSubviewsFromNib("SDErrorPlaceholderView") {
            containerView = container
        }
        self.hidden = true
    }
    
    override func updateConstraints() {
        self.updateCustomConstraints(customConstraints, containerView: containerView)
        super.updateConstraints()
    }
    
    @IBAction func didTapRefreshButton() {
        delegate?.didTapRefreshButtonInErrorPlaceholder?()
    }
    
    func show(message: String) {
        show(message, isGeneralMessage: false)
    }
    
    func show(message: String, isGeneralMessage: Bool) {
        show(message, isGeneralMessage: isGeneralMessage, buttonTitle: NSLocalizedString("error_placeholder_button_refresh", comment: ""))
    }
    
    func show(message: String, isGeneralMessage: Bool, buttonTitle: String) {
        if self.hidden {
            self.alpha = 0
            self.hidden = false
            self.btnRefresh.setTitle(buttonTitle, forState: .Normal)
            self.lblErrorMessage.text = message
            self.imgIcon.image = isGeneralMessage ? UIImage(named: "placeholder_general") : UIImage(named: "placeholder_error")
            UIView.animateWithDuration(kAnimationShowHideTimeInterval, animations: { () -> Void in
                self.alpha = 1
            })
        }
    }
    
    func hide() {
        if !self.hidden {
            UIView.animateWithDuration(kAnimationShowHideTimeInterval, animations: { () -> Void in
                self.alpha = 0
                }) { (completed) -> Void in
                    self.hidden = true
                    self.alpha = 1
            }
        }
    }
}
