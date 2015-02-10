//
//  SDQRScannerOverlayView.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 06/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

@objc protocol SDQRScannerOverlayViewDelegate {
    
    optional func didTapCancelButtonInQRScanner()
    
}

class SDQRScannerOverlayView: UIView {
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    
    let customConstraints : NSMutableArray = NSMutableArray()
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
        if let container = self.loadNibSubviewsFromNib("SDQRScannerOverlayView") {
            containerView = container
        }
        btnCancel.title = NSLocalizedString("common_cancel", comment: "Cancel")
        btnCancel.target = self
        btnCancel.action = "didTapCancelButton"
    }
    
    override func updateConstraints() {
        self.updateCustomConstraints(customConstraints, containerView: containerView)
        super.updateConstraints()
    }
    
    // MARK: - Cancel scanning handling
    
    func didTapCancelButton() {
        delegate?.didTapCancelButtonInQRScanner?()
    }
}
