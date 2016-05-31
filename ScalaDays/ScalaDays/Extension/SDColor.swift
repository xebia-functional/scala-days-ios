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

extension UIColor {
   
    class func grayScaleColor(grayScale: CGFloat) -> UIColor {
        return UIColor(red: grayScale / 255.0, green: grayScale / 255.0, blue: grayScale / 255.0, alpha: 1.0)
    }

    class func appColor() -> UIColor {
         return UIColor(red: 54/255, green: 69/255, blue: 80/255, alpha: 255/255)
    }
    
    class func selectedCellMenu() -> UIColor {
        return UIColor(red: 43/255, green: 56/255, blue: 65/255, alpha: 255/255)
    }
    
    class func appRedColor() -> UIColor {
        return UIColor(red: 224/255, green: 95/255, blue: 94/255, alpha: 255/255)
    }

    class func appScheduleBlueBackgroundColor() -> UIColor {
        return UIColor(red: 108/255, green: 207/255, blue: 233/255, alpha: 255/255)
    }

    class func appScheduleTimeBlueBackgroundColor() -> UIColor {
        return UIColor(red: 108/255, green: 207/255, blue: 233/255, alpha: 255/255)
    }
    
    class func appSeparatorLineColor() -> UIColor {
        return UIColor(red: 54/255, green: 69/255, blue: 80/255, alpha: 0.3)
    }
    
    class func disabledButtonColor() -> UIColor {
        return grayScaleColor(190.0)
    }
    
    class func enabledSendVoteButtonColor() -> UIColor {
        return grayScaleColor(12.0)
    }
    
    class func grayButtonBorder() -> UIColor {
        return grayScaleColor(218.0)
    }
    
    class func grayCommentsPlaceholder() -> UIColor {
        return grayScaleColor(185.0)
    }
    
    class func blackForCommentsNormalText() -> UIColor {
        return UIColor(red: 41.0/255.0, green: 53.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    }

}

 