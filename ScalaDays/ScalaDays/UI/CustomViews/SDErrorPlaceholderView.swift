//
//  SDErrorPlaceholderView.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 18/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

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
        btnRefresh.setTitle(NSLocalizedString("error_placeholder_button_refresh", comment: ""), forState: UIControlState.Normal)
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
        if self.hidden {
            self.alpha = 0
            self.hidden = false
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
