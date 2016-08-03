//  GlobalTool.swift
//  LG-Demo
//
//  Created by jamie on 15/5/21.QQ:2726786161
//  Copyright (c) 2015年 LG. All rights reserved.
//  通用宏

import Foundation
import UIKit

// MARK: - 设备判断-------------------------------------------
/*
 判断是否是ipad
 */
func kISIpad() -> Bool
{
    return UIDevice.currentDevice().respondsToSelector(Selector("userInterfaceIdiom")) && (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
}

// MARK: - 屏幕适配----------------------------------------------
let kScreenSize = UIScreen.mainScreen().bounds.size                                 //(e.g. 320,480)
let kScreenWidth: CGFloat = UIScreen.mainScreen().bounds.size.width                 //(e.g. 320)
let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.size.height               //包含状态bar的高度(e.g. 480、568)

let kApplicationSize = UIScreen.mainScreen().applicationFrame.size                  //(e.g. 320,460)
let kApplicationWidth = UIScreen.mainScreen().applicationFrame.size.width           //(e.g. 320)
let kApplicationHeight = UIScreen.mainScreen().applicationFrame.size.height         //不包含状态bar的高度(e.g. 460)

let kStatusBarHeight: CGFloat = 20
let kNavigationBarHeight: CGFloat = 44

let kContentHeight: CGFloat = (kApplicationHeight - kNavigationBarHeight)
let kIOS7OffHeight: CGFloat = (kIOS7_OR_LATER ? 64 : 0)         //设置

let kTabBarHeight: CGFloat = 49                                 //tabbar高度

// MARK: - 尺寸适配-------------------------------------------

// MARK: - 应用相关,版本/名称等-------------------------------------------

//系统当前版本
let kIOSVersion = NSString(UTF8String: (UIDevice.currentDevice().systemVersion))?.floatValue

let kIOS7_OR_LATER = kIOSVersion >= 7.0  //判断是否是7.0以后


// MARK: - 字体/颜色/大小/图片设置等-------------------------------------------
/*
自定义颜色
*/
func kRGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor
{
    return UIColor(red:red/255.0, green:green/255.0, blue:blue/255.0, alpha:1.0)
}

func kRGBAlpha(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor
{
    return UIColor(red:red/255.0, green:green/255.0, blue:blue/255.0, alpha:alpha)
}

func kHexRGB(rgbValue: UInt32) -> UIColor
{
    return UIColor(red:(CGFloat((rgbValue & 0xFF0000) >> 16))/255.0, green:(CGFloat((rgbValue & 0xFF00) >> 8))/255.0, blue:(CGFloat(rgbValue & 0xFF))/255.0, alpha: 1.0)
}

func kHexRGBAlpha(rgbValue: UInt32, alpha: CGFloat) -> UIColor
{
    return UIColor(red:(CGFloat((rgbValue & 0xFF0000) >> 16))/255.0, green:(CGFloat((rgbValue & 0xFF00) >> 8))/255.0, blue:(CGFloat(rgbValue & 0xFF))/255.0, alpha: alpha)
}

let kBackgroundColor = kHexRGB(0xFFFFFF)    //页面通用背景颜色

//自定义导航条背景颜色
let kNavigationBarBackgroundColor = kHexRGB(0x26b8f2)

//导航栏字体颜色值：#FFFFFF
let kNavigationBarTitleColor = kHexRGB(0xFFFFFF)

/*
字体大小
*/
let kNavigationBarTitleFontSize: CGFloat = 20           //导航条标题字体大小
let kTextFontSize = UIFont.systemFontOfSize(16)         //正文字体大小

let kNavigationBarTitleFont = UIFont(name: "HelveticaNeue-Light", size: kNavigationBarTitleFontSize)    //导航标题字体

/*
其它-图片等
*/
let kBackBarButtonItemName = "backArrow"                        //导航条返回默认图片名


// MARK: - 信息存储 关键key ----------------------------------------------
let kUserIdKey = "pin"          //用户id的key
let kUserTokenKey = "tgt"       //用户token的key

let kLastLoginUserInfo = "kLastLoginUserInfo"               //上次登录的完整用户信息 用于持续登录

let kLoginSuccess_Last_userName = "LoginSuccess_userName"   //前一次登录用户名

let kXMPPNewMessage = "kXMPPNewMessage"                 //有新消息

let kLastLoginAccount = "kLastLoginAccount"             //上次登录帐户
let kLastLoginPin = "kLastLoginPin"                     //上次登录Pin

let kDeviceIdentifierKey = "uuid"                       //设备标志符（代替uuid）的存储key
let kDeviceIdentifierService = "uuidService"            //设备标志符（代替uuid）的存储服务名

let kCacheIsCloseKey = "CacheIsCloseKey"                //缓存是否关闭

// MARK: - 通知----------------------------------------------
let kNotifyLoginSuccess = "kNotifyLoginSuccess"         //登录成功
let kNotifyLoginFailure = "kNotifyLoginFailure"         //登录失败

let kNotifyMessageNumberUpdate = "kNotifyMessageNumberUpdate"   //消息数目有更新


// MARK: - Cookie相关----------------------------------------------

// MARK: - Web相关地址----------------------------------------------

// MARK: - 黑名单/相关处理----------------------------------------------

// MARK: - 枚举/类型/请求----------------------------------------------
/*
接收、发送、更新数据
*/
enum kAPI_PROTO{
    case kAPI_GET           //get data from civichero sever
    case kAPI_POST          //post data to  civichero sever
    case kAPI_PUT           //update the data to civichero sever
    case kAPI_DELETE        //delete
}

/*
API接口
*/
let kGetUserInfo = "GetUserInfo"            //查询用户信息
let kCheckShopInfo = "CheckShopInfo"        //登录后查询是否有店铺相关信息

let kCreateShop = "CreateShop"              //创建店铺
let kReportAppInfo = "ReportAppInfo"        //信息上报
let kUpgrade = "Upgrade"                    //jxj升级
let kFeedBackInfo = "FeedBackInfo"          //意见反馈上报
let kLoginApp = "LoginApp"                  //登录接口（将店铺查询kCheckShopInfo接口合并）
let kNewMessageNumber = "NewMessageNumber"  //查询未读消息数目


//pb
let kGetShopInfo = "GetShopInfo"            //查询店铺信息

// MARK: - 业务相关数据----------------------------------------------
let kAppHelpPhone = "400-606-5500"      //客服电话

let kShareDefaultImage = UIImage(named: "_App_Icons")!              //分享默认图片

let kDefaultPlaceholderImage = "_App_Icons"
let kDefaultUserHeadImageName = "defaultHead"                       //默认头像

let kUserNamePlaceHoldText = "请输入帐号/邮箱/手机号"                       //用户名holdplace文字
let kPasswordPlaceHoldText = "请输入密码"                                   //密码holdplace文字
let kLoginShortSMSPlaceHoldText = "请输入验证码"                            //登录时简短验证码
let kSMSPlaceHoldText = "请输入手机获取的验证码"                              //验证码...
let kPhonePlaceHoldText = "请输入手机号"                                    //手机号码...
let kNickNamePlaceHoldText = "请输入您的昵称，最多16位"                       //昵称...
let kNewPasswordPlaceHoldText  = "请输入6-20位字符"                         //新密码...
let kNewPassword2PlaceHoldText  = "请再次输入您的密码"                       //新密码确认密码
let kNewPasswordRuleShowText  = "密码由6-20位字符组成，包含至少两种以上字母、数字、或者半角字符，区分大小写。"                  //密码下面的规格介绍
let kPasswordErrorMessage  =  "密码格式不正确"                         //密码错误时提示

/**
发送验证码后的倒记时提示
*/
func kGetSMSNoteTextFormate(timeInterval: NSTimeInterval) -> String
{
    return String("重新获取(\(Int(timeInterval))秒)")
}


// MARK: - 第三方相关----------------------------------------------
/**
*  分享配置中心
*/
public struct kShareManagerMetaData {

}

//对象存储：jamiebucket
//图片存储 jamiepic
//secretID	AKIDTxM6uDEjYk0odjujmGcTHT7pCDvwrWnN
//secretKey	7lOhwMCZseaQS4yRJksotS0CO8ZVZNJA

//腾讯云，如果发送图片时提示校验过期，请将PHP内容直接贴到http://www.shucunwang.com/RunCode/php/ 中，生成新的pic密钥，然后更新对应的kTXCloud_Pic_Secret_ManyTime、kTXCloud_Pic_Secret_OneTime
//如果是音频过期，先将PHP的$bucket更新为"jamiebucket"，再和上面一样，生成对应的kTXCloud_File_Secret_ManyTime和kTXCloud_File_Secret_OneTime
let kTXCloud_ID = 10051805
let kTXCloud_Pic_Bucket = "jamiepic"
let kTXCloud_Pic_Secret_ManyTime = "y9sxnvX+UBa8dwVlwwB/oy5RnVFhPTEwMDUxODA1JmI9amFtaWVwaWMmaz1BS0lEVHhNNnVERWpZazBvZGp1am1HY1RIVDdwQ0R2d3JXbk4mZT0xNDcyNzk4MDc5JnQ9MTQ3MDIwNjA3OSZyPTI5NDQxODAxMCZmPQ=="
let kTXCloud_Pic_Secret_OneTime = "+TqmZZSTFl10lRYdJSUslQmVquRhPTEwMDUxODA1JmI9amFtaWVwaWMmaz1BS0lEVHhNNnVERWpZazBvZGp1am1HY1RIVDdwQ0R2d3JXbk4mZT0wJnQ9MTQ3MDIwNjA3OSZyPTI5NDQxODAxMCZmPS8xMDA1MTgwNS9qYW1pZWJ1Y2tldC90ZW5jZW50X3Rlc3QuanBn"

let kTXCloud_File_Bucket = "jamiebucket"
let kTXCloud_File_Secret_ManyTime = "KiISBGLJs4o+zgSVbYlWIzgACtFhPTEwMDUxODA1JmI9amFtaWVidWNrZXQmaz1BS0lEVHhNNnVERWpZazBvZGp1am1HY1RIVDdwQ0R2d3JXbk4mZT0xNDcyNzk4MTQ4JnQ9MTQ3MDIwNjE0OCZyPTE4NzAwNzc4MTYmZj0="
let kTXCloud_File_Secret_OneTime = "83Ct7FL58QJwBJ4/Gewb+L1aJyphPTEwMDUxODA1JmI9amFtaWVidWNrZXQmaz1BS0lEVHhNNnVERWpZazBvZGp1am1HY1RIVDdwQ0R2d3JXbk4mZT0wJnQ9MTQ3MDIwNjE0OCZyPTE4NzAwNzc4MTYmZj0vMTAwNTE4MDUvamFtaWVidWNrZXQvdGVuY2VudF90ZXN0LmpwZw=="

//http://www.shucunwang.com/RunCode/php/ 在线生成器生成,粘贴内容如下,下面的time最多可设置成30天：
/*
<?php
$appid = "10051805";
$bucket = "jamiepic";
$secret_id = "AKIDTxM6uDEjYk0odjujmGcTHT7pCDvwrWnN";
$secret_key = "7lOhwMCZseaQS4yRJksotS0CO8ZVZNJA";
$expired = time() + 60 * 60 * 24 * 30;
$onceExpired = 0;
$current = time();
$rdm = rand();
$userid = "0";
$fileid = "/10051805/jamiebucket/tencent_test.jpg";

$srcStr = 'a='.$appid.'&b='.$bucket.'&k='.$secret_id.'&e='.$expired.'&t='.$current.'&r='.$rdm.'&f=';

$srcStrOnce= 'a='.$appid.'&b='.$bucket.'&k='.$secret_id.'&e='.$onceExpired .'&t='.$current.'&r='.$rdm
.'&f='.$fileid;

echo $srcStr."\n";

echo $srcStrOnce."\n";

$signStr = base64_encode(hash_hmac('SHA1', $srcStr, $secret_key, true).$srcStr);

$signStrOnce = base64_encode(hash_hmac('SHA1',$srcStrOnce,$secret_key, true).$srcStrOnce);

echo $signStr."\n";

echo $signStrOnce."\n";
?>
*/

/**
*  推送配置中心
*/
public struct kPushManager {

}


// MARK: - H5离线缓存----------------------------------------------
/**
获取缓存路径
*/
func kGetCachesPath() -> String
{
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    return paths[0]
}

/**
*  H5缓存目录
*/
public struct kH5FilePath {

}
