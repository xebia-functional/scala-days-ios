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
    
    let kWidthForImgView : CGFloat = 40.0
    
    override func awakeFromNib() {
        self.imgView.circularImage()
        self.lblContent.numberOfLines = 0
        self.lblContent.setCustomFont(UIFont.fontHelveticaNeueLight(15), colorFont: UIColor.appColor())
        self.lblFullName.setCustomFont(UIFont.fontHelveticaNeueMedium(15), colorFont: UIColor.appColor())
        self.lblDate.setCustomFont(UIFont.fontHelveticaNeue(12), colorFont: UIColor.appColor())
        self.lblDate.alpha = 0.7
        self.lblUsername.setCustomFont(UIFont.fontHelveticaNeue(15), colorFont: UIColor.appRedColor())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lblContent?.preferredMaxLayoutWidth = self.frame.size.width - kWidthForImgView - (kGlobalPadding * 3)
    }
    
    internal func drawTweetData(tweet: SDTweet) {
        lblFullName.text = tweet.fullName
        lblUsername.text = "@\(tweet.username)"
        lblContent.text = tweet.tweetText
        if let date = SDDateHandler.sharedInstance.parseTwitterDate(tweet.dateString) {
            lblDate.text = date.timeAgoSimple()
        }
        let imageUrl = NSURL(string: tweet.profileImage)
        if let profileImageUrl = imageUrl {
            imgView.sd_setImageWithURL(profileImageUrl)
        }
        layoutSubviews()
    }
}
