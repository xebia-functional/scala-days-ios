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

class SDSpeakerDetailView: UIView {

    let customConstraints : NSMutableArray = NSMutableArray()

    var containerView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    let kSeparatorHeight : CGFloat = 1.0
    let kBottomPadding : CGFloat = 30.0
    let kHorizontalPadding : CGFloat = 18.0
    
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
        if let container = loadNibSubviewsFromNib("SDSpeakerDetailView") {
            containerView = container
            imgView.circularImage()
            lblDescription.preferredMaxLayoutWidth = self.frame.size.width - imgView.frame.size.width - (kHorizontalPadding * 2)
            lblCompany.preferredMaxLayoutWidth = lblDescription.preferredMaxLayoutWidth
        }
    }
    
    override func updateConstraints() {
        self.updateCustomConstraints(customConstraints, containerView: containerView)
        super.updateConstraints()
    }
    
    func drawSpeakerData(speaker: Speaker) {
        lblName.text = speaker.name
        if let twitterUsername = speaker.twitter {
            if contains(twitterUsername, "@") {
                lblUsername.text = twitterUsername
            } else {
                lblUsername.text = "@\(twitterUsername)"
            }
        } else {
            lblUsername.text = ""
        }
        lblCompany.text = speaker.company
        
        lblDescription.text = speaker.bio.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if let pictureUrlString = speaker.picture {
            if let pictureUrl = NSURL(string: pictureUrlString) {
                imgView.sd_setImageWithURL(pictureUrl, placeholderImage: UIImage(named: "avatar")!)
            }
        }
        layoutSubviews()
    }

    func contentHeight() -> CGFloat {
        return lblDescription.frame.origin.y + lblDescription.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + kBottomPadding
    }
    
    func drawSeparator() {
        let separatorLayer = CALayer()
        let contentHeight = self.contentHeight()
        separatorLayer.frame = CGRectMake(0, contentHeight - kSeparatorHeight, self.frame.size.width, kSeparatorHeight)
        separatorLayer.backgroundColor = UIColor.appSeparatorLineColor().CGColor
        self.layer.addSublayer(separatorLayer)
    }
}
