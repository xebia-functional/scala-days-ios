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

class SDSocialTableViewCell: UITableViewCell {
    @IBOutlet weak var imgView : UIImageView!
    @IBOutlet weak var lblFullName : UILabel!
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var lblContent : UILabel!
    @IBOutlet weak var lblDate : UILabel!
    @IBOutlet weak var lblContentBottomConstraint : NSLayoutConstraint!
    
    let kPaddingLeftForLblContent : CGFloat = 15.0
    let kPaddingRightForLblContent : CGFloat = 15.0
    let kPaddingLeftForImgView : CGFloat = 15.0
    let kWidthForImgView : CGFloat = 40.0
    
    override func awakeFromNib() {
        imgView.circularImage()
        lblContent.numberOfLines = 0
        lblContent.setCustomFont(UIFont.fontHelveticaNeueLight(15), colorFont: UIColor.appColor())
        lblFullName.setCustomFont(UIFont.fontHelveticaNeueMedium(15), colorFont: UIColor.appColor())
        lblDate.setCustomFont(UIFont.fontHelveticaNeue(12), colorFont: UIColor.appColor())
        lblDate.alpha = 0.7
        lblUsername.setCustomFont(UIFont.fontHelveticaNeue(15), colorFont: UIColor.appRedColor())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lblContent?.preferredMaxLayoutWidth = self.frame.size.width - kWidthForImgView - kPaddingLeftForImgView - kPaddingLeftForLblContent - kPaddingRightForLblContent
    }
}
