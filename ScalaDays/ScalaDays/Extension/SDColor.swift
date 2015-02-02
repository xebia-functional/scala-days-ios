//
//  SDColor.swift
//  ScalaDays
//
//  Created by Ana on 29/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//


import UIKit

extension UIColor {

    convenience init(r: Int, g: Int, b: Int, a: Int) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    class func appLightGrayColor() -> UIColor {
        return UIColor(red: 190.0 / 255.0, green: 190.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
    }

    class func grayScaleColor(grayScale: CGFloat) -> UIColor {
        return UIColor(red: grayScale / 255.0, green: grayScale / 255.0, blue: grayScale / 255.0, alpha: 1.0)
    }

    class func appColor() -> UIColor {
        return UIColor(r: 54, g: 69, b: 80, a: 1)
    }

}

 