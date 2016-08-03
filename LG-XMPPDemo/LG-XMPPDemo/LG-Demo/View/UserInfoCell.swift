//
//  UserInfoCell.swift
//  LG-Demo
//
//  Created by jamie on 16/7/4.QQ:2726786161
//  Copyright © 2016年 LG. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {

    @IBOutlet weak var _signatureLabel: UILabel!
    @IBOutlet weak var _nameLabel: UILabel!
    @IBOutlet weak var _headImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    class func loadViewFromNib() -> UserInfoCell {
        let cell = NSBundle.mainBundle().loadNibNamed("UserInfoCell", owner: self, options: nil).last as! UserInfoCell
        
        return cell
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*
     section:
     .0 在线
     .1 离开
     .2 离线
     */
    func updatCell(theUserInfoModel: UserInfoModel) {
        _headImageView.sd_setImageWithURL(theUserInfoModel.avatarImageURL, placeholderImage: kShareDefaultImage, options: SDWebImageOptions.RefreshCached)
        _nameLabel.text =  "[\(theUserInfoModel.section)]" + (theUserInfoModel.nickName != "" ? theUserInfoModel.nickName : theUserInfoModel.jidString)
        _signatureLabel.text = theUserInfoModel.subscription
    }
}
