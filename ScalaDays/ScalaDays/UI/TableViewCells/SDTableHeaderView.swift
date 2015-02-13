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

class SDTableHeaderView: UIView {

    let kHeaderTextPadding : CGPoint = CGPointMake(15, 13)
    let kHeaderTextInitialWidth : CGFloat = 300.0
    let kHeaderTextInitialHeight : CGFloat = 15.0
    
    let lblDate: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.appScheduleTimeBlueBackgroundColor()
        lblDate = UILabel(frame: CGRectMake(kHeaderTextPadding.x, kHeaderTextPadding.y, kHeaderTextInitialWidth, kHeaderTextInitialHeight))
        lblDate.backgroundColor = UIColor.clearColor()
        lblDate.setCustomFont(UIFont.fontHelveticaNeue(13), colorFont: UIColor.whiteColor())
        self.addSubview(lblDate)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
