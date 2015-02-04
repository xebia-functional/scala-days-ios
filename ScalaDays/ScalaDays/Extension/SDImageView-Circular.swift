//
//  SDImageView-Circular.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 02/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

extension UIImageView {

    func circularImage() -> Void {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

}
