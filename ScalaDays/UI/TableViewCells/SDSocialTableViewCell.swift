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
import NSDate_TimeAgo

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
    
    internal func drawTweetData(_ tweet: SDTweet) {
        lblFullName.text = tweet.username
        lblUsername.text = "@\(tweet.fullName)"
        lblContent.attributedText = tweet.tweetText.tweetAttributedText
        lblDate.text = (tweet.date as NSDate).timeAgoSimple()
        let imageUrl = URL(string: tweet.profileImage)
        if let profileImageUrl = imageUrl {
            imgView.sd_setImage(with: profileImageUrl)
        }
        layoutSubviews()
    }
}

// MARK: - Tweets style <helpers>

private extension String {
    var tweetAttributedText: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: self)
        guard let regexHastags = Regex.hastagsOrMentions.regularExpression,
              let regexURLs = NSTextCheckingResult.CheckingType.link.regularExpression else {
            return attributedText
        }
        
        regexHastags.matches(in: attributedText.string).forEach { range in
            attributedText.addAttribute(.foregroundColor, value: Color.highlight, range: range)
        }
        
        regexURLs.matches(in: attributedText.string).forEach { range in
            attributedText.addAttribute(.foregroundColor, value: Color.highlight, range: range)
        }

        return attributedText
    }
    
    enum Regex {
        static let hastagsOrMentions = "\\B([\\#|\\@][a-zA-Z0-9_]+\\b)(?!;)"
    }
    
    enum Color {
        static let highlight = UIColor.init(red: 27/255.0, green: 149/255.0, blue: 224/255.0, alpha: 1)
    }
}

private extension String {
    var regularExpression: NSRegularExpression? {
        try? NSRegularExpression(pattern: self, options: [])
    }
}

private extension NSTextCheckingResult.CheckingType {
    var regularExpression: NSRegularExpression? {
        try? NSDataDetector(types: rawValue)
    }
}

private extension NSRegularExpression {
    func matches(in input: String) -> [NSRange] {
        matches(in: input, options: [], range: NSMakeRange(0, input.utf16.count)).map(\.range)
    }
}
