//
//  Tools.swift
//  LG-Demo
//
//  Created by jamie on 15/5/21.QQ:2726786161
//  Copyright (c) 2015年 LG. All rights reserved.
//  常用方法,工具集,控件封装

let vDissmissAlertViewDefaultTime = 1.5                 //默认显示时间


import Foundation
import MessageUI


// MARK: -  工具集*********************************************
class Tools: NSObject {
    
    /// 单例
    class var shared: Tools {
        dispatch_once(&Inner.token) {
            Inner.instance = Tools()
        }
        return Inner.instance!
    }
    
    struct Inner {
        static var instance: Tools?
        static var token: dispatch_once_t = 0
    }
    
    var _automaticDissmissAlertView: UIAlertView?       //会自动消失的alertview
    var _action: Selector?                              //alertview消失后的动作
    var _phoneCallWebView: UIWebView?                   //打电话的webview
    var _messageVC: MFMessageComposeViewController?     //发短信VC
    var _pasteboard: UIPasteboard?                      //剪切板
    
    // MARK: - 主代理等关键对象获取----------------------------------------------
    /**
    获取主代理
    */
    class func getAppDelegate() -> AppDelegate!
    {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    /**
    获取主Window
    */
    class func getWindow() -> UIWindow!
    {
        return self.getAppDelegate().window!
    }
    
    // MARK: - plist方式持久化及读取----------------------------------------------
    
    // MARK: -  钥匙串*********************************************
    
    // MARK: -  控件封装  导航条按钮 ****************************************
    /**
    *  创建导航条右按钮
    *
    *  @param title     按钮标题
    *  @param obj       按钮作用对象（响应方法的对象）
    *  @param selector  按钮响应的方法
    *  @param imageName 按钮图片名称
    *
    *  @return 右按钮对象
    */
    class func createRightBarButtonItem(title: String?, target: AnyObject!, selector: Selector!, imageName: String?) -> UIBarButtonItem?
    {
        var image: UIImage?
        if !(NSString.isNilOrEmpty(imageName))
        {
            image = UIImage(named: imageName!)
        }
        
        let theButton = UIButton(type: UIButtonType.Custom)
        if image != nil
        {
            theButton.setImage(image!, forState: UIControlState.Normal)
        }
        theButton.setTitle(title, forState: UIControlState.Normal)
        theButton.titleLabel!.font = UIFont.systemFontOfSize(18.0)
        theButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        theButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        theButton .addTarget(target, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        theButton.sizeToFit()
        
        return  UIBarButtonItem(customView: theButton)
    }
    
    /**
    *  创建导航条左按钮
    *
    *  @param title     按钮标题,当为@""空时，选择默认图片vBackBarButtonItemName
    *  @param obj       按钮作用对象（响应方法的对象）
    *  @param selector  按钮响应的方法
    *  @param imageName 按钮图片名称
    *
    *  @return 左按钮对象
    */
    class func createLeftBarButtonItem(title: String?, target: AnyObject!, selector: Selector!, imageName: String?) -> UIBarButtonItem?
    {
        var image: UIImage?
        if !(NSString.isNilOrEmpty(imageName))
        {
            image = UIImage(named: imageName!)
        }
        else
        {
            image = UIImage(named: kBackBarButtonItemName)
        }
        
        let theButton = UIButton(type: UIButtonType.Custom)
        if image != nil
        {
            theButton.setImage(image!, forState: UIControlState.Normal)
        }
        var showTitle = title
        if showTitle == "返回" || showTitle == nil
        {
            showTitle = "    "
        }
        else
        {
            theButton.setTitle(showTitle, forState: UIControlState.Normal)
        }
        
        //计算尺寸
        let fnt = UIFont.systemFontOfSize(18)
        var titleSize = NSString(string: showTitle!).sizeWithAttributes([NSFontAttributeName: fnt])
        if titleSize.width < 44.0
        {
            titleSize.width = 44.0
        }
        theButton.width = titleSize.width
        
        theButton.titleLabel!.font = UIFont.systemFontOfSize(18.0)
        theButton.titleLabel!.textAlignment = NSTextAlignment.Left
        theButton.titleLabel!.adjustsFontSizeToFitWidth = true
        theButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        theButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        theButton .addTarget(target, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        theButton.sizeToFit()
        
        return  UIBarButtonItem(customView: theButton)
    }
    
    // MARK: - 加载圈----------------------------------------------
    /**
    添加加载圈至主window
    */
    class func addLoadingInWindow()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD .showHUDAddedTo(self.getWindow(), animated: true)
        })
    }
    
    /**
    去掉主window的加载圈
    */
    class func dissmissLoadingInWindow()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.hideAllHUDsForView(self.getWindow(), animated: true)
        })
    }
    
    /**
    添加加载圈至指定View
    
    - parameter view: 指定加载圈的父View
    */
    class func addLoadingInView(view: UIView!)
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD .showHUDAddedTo(view, animated: true)
        })
    }
    
    /**
    去掉指定View的加载圈
    */
    class func dissmissLoadingInView(view: UIView!)
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        })
    }
    
    /**
    *  弹出一个会自动消失和弹窗(默认时间内消失）
    *
    *  @param title        标题
    *  @param message      提示信息
    */
    func showAlertViewAndDismissDefault(title: String?, message: String!)
    {
        self._automaticDissmissAlertView?.dismissWithClickedButtonIndex(0, animated: true)
        self._action = nil
        self._automaticDissmissAlertView = nil
        self.showAlertViewAndDissmissAutomatic(title, message: message, dissmissTime: vDissmissAlertViewDefaultTime, delegate: nil, action: nil)
    }
    
    /**
    *  弹出一个会自动消失和弹窗
    *
    *  @param title        标题
    *  @param message      提示信息
    *  @param dissmisstime 消失等待时间
    *  @param delegate     消失后响应的代理
    *  @param action       消失后的动作
    */
    func showAlertViewAndDissmissAutomatic(title: String?, message: String!, dissmissTime: NSTimeInterval, delegate: UIViewController?, action: Selector?)
    {
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            weakSelf!._automaticDissmissAlertView = UIAlertView()
            if !NSString.isNilOrEmpty(title)
            {
                weakSelf!._automaticDissmissAlertView!.title = title!
            }
            if !NSString.isNilOrEmpty(message)
            {
                weakSelf!._automaticDissmissAlertView!.message = message!
            }
            if delegate != nil
            {
                weakSelf!._automaticDissmissAlertView!.delegate = delegate
            }
            weakSelf!._action = action
            
            weakSelf!._automaticDissmissAlertView!.show()
            
            NSTimer.scheduledTimerWithTimeInterval(dissmissTime, target: self, selector: #selector(Tools.performDismiss(_:)), userInfo: nil, repeats: false)
            
        })
    }
    
    
    /**
    *  自动消失
    */
    func performDismiss(timer: NSTimer)
    {
        self._automaticDissmissAlertView?.dismissWithClickedButtonIndex(0, animated: true)
        
        if self._action != nil && self._automaticDissmissAlertView?.delegate != nil
        {
            if self._automaticDissmissAlertView!.delegate!.respondsToSelector(self._action!)
            {
                UIControl().sendAction(self._action!, to: self._automaticDissmissAlertView!.delegate!, forEvent: nil)
            }
        }
        self._action = nil
        self._automaticDissmissAlertView = nil
    }
    
    // MARK: -  格式校验 *********************************************
    /**
    *  密码校验
    *
    *  @param numString 待校验的密码
    *
    *  @return 校验结果，YES：合格， NO：密码格式不正确
    */
    class func checkPassword(passwdString: String) -> Bool
    {
           return true
    }
    
    /**
    *  邮箱校验
    *
    *  @param str2validate 待校验的邮箱
    *
    *  @return 校验结果，YES：合格， NO：邮箱格式不正确
    */
    class func checkEmail(emailString: String) -> Bool
    {

        
        return true
    }
    
    /**
    *  手机号码简单校验
    *
    *  @param phoneNumberString 等校验的手机号码
    *
    *  @return 校验结果，YES：合格， NO：手机号码格式不正确
    */
    class func checkPhoneNumber(phoneNumberString: String) -> Bool
    {
        
        return true
    }
    
    /**
    *  手机号码或者邮箱号码校验
    *
    *  @param numberOrEmailString 待校验的用户名（可能为手机号码或者邮箱号码）
    *
    *  @return 校验结果，YES：合格， NO：手机号码格式及邮箱格式均不正确
    */
    class func checkPhoneNumberOrEmail(numberOrEmailString: String) -> Bool
    {

        
        return true
    }
    
    
    // MARK: -  短信/电话/剪切板等 *********************************************
    
    // MARK: -  图片处理-设置相关 *********************************************
    
    /**
     *  放置URL图片至view或button上，在此之前取磁盘图片
     *
     *  @param imageUrlString           图片url地址
     *  @param placeholderImageName placeholderImage,如果为nil 或空，就设置为默认holder图片
     *  @param imageView                要设置此图片的view
     *  @param button                   要设置此图片的button
     *  @param needGetFromDiskCache     是否优先从默认的磁盘读取图片
     */
    class func setURLImage(imageUrlString: String?, placeholderImageName: String?, imageView: UIImageView?, button: UIButton?, needGetFromDiskCache: Bool)
    {
    }

    // MARK: -  二维码相关 *********************************************
    // MARK: -  截屏 *********************************************
    // MARK: -  缓存相关 *********************************************
    // MARK: -  版本等应用相关信息 *********************************************
    // MARK: -  Other *********************************************
    
    
}
