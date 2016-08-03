//
//  UserInfoModel.swift
//  LG-Demo
//
//  Created by jamie on 16/6/28.QQ:2726786161
//  Copyright © 2016年 LG. All rights reserved.
//

import UIKit

class UserInfoModel: NSObject {
    
    //jid包括域名
    //userid不包括
    var userID: String!
    var jidString: String!
    
    var nickName = ""
    var signatureString: String?     //签名
    
    var section = "在线"                 //在线状态 默认在线
    var subscription = ""
    //头像URL
    var avatarImageURL: NSURL!{
        get{
            return NSURL(string:"http://lorempixel.com/400/200/")
        }
    }
 
    var avatarImage: UIImage!
    
    init(userID: String!) {
        super.init()
        self.userID = userID
    }
    
    init(dataObject: XMPPUserCoreDataStorageObject) {
        super.init()
        self.userID = dataObject.jid.user
        self.jidString = dataObject.jidStr

        self.avatarImage = dataObject.photo
        if dataObject.nickname != nil{
            self.nickName = dataObject.nickname
        }
        self.subscription = self.subscriptionText(dataObject.subscription)
        self.signatureString = dataObject.subscription
        self.section = (dataObject.section == 0 ? "在线" : dataObject.section == 1 ? "离开" : "离线")
    }
    
    //subscription:
    //    . none  表示对方还没有确认
    //    . to    我关注对方
    //    . from  对方关注我
    //    . both  互粉
    func  subscriptionText(subscription: String) -> String {
        var subscriptionText = "等待对方确认"
        switch subscription {
        case "to":
            subscriptionText = "我的好友"
        case "from":
            subscriptionText = "陌生人"
        case "both":
            subscriptionText = "互为好友"
        default: break
        }
        return subscriptionText
    }
}
