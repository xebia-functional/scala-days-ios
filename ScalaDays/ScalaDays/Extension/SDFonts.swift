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

extension UIFont {

    class func fontHelveticaNeue(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: fontSize)!
    }

    class func fontHelveticaNeueMedium(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: fontSize)!
    }

    class func fontHelveticaNeueLight(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: fontSize)!
    }

}

extension UILabel {

    func setCustomFont(typeFont: UIFont, colorFont: UIColor) -> UILabel {
        self.font = typeFont
        self.textColor = colorFont
        self.sizeToFit()
        return self;
    }

}