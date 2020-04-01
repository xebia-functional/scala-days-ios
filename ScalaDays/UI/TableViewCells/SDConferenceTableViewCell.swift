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

class SDConferenceTableViewCell: UITableViewCell {

    @IBOutlet weak var lblConferenceName: UILabel!
    @IBOutlet weak var conferenceImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.conferenceImageView.circularImage()
        self.lblConferenceName.numberOfLines = 0
        self.lblConferenceName.setCustomFont(UIFont.fontHelveticaNeue(15), colorFont: UIColor(white: 1, alpha: 0.9))
        self.backgroundColor = UIColor.appColor()
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.selectedCellMenu()
        self.selectedBackgroundView = bgColorView
    }

    func drawConferenceData(_ conference: Conference) {
        self.lblConferenceName.text = conference.info.longName
        if let pictureUrl = URL(string: conference.info.pictures[0].url) {
            conferenceImageView.sd_setImage(with: pictureUrl, placeholderImage: UIImage(named: "menu_icon_places"))
        }
        layoutSubviews()
    }
    
}
