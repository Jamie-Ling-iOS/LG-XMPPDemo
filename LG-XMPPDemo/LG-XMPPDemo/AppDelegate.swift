//
//  AppDelegate.swift
//  LG-Demo
//
//  Created by jamie on 16/6/16. QQ:2726786161
//  App主代理

//  Demo提示：如果发送图片或音频时提示密钥过期，请参考 GlobalTool.swift 代码中“第三方相关”内容更新密钥

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var _mainNavigationController: UINavigationController?      //主页面流程控制器
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Override point for customization after application launch.
        
        self.window!.backgroundColor = kBackgroundColor         //设置通用背景颜色
        self.window!.makeKeyAndVisible()                        //提前//实现各种视图切换
        
        //添加主框架
        self.addMainFrameWork()
        
        return true
    }
    
    /**
     将进入非活动状态
     */
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state here you can undo many of the changes made on entering the background.
        
    }
    
    /**
     将进入活动状态
     */
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    /**
     将结束应用
     */
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    // MARK:  --------------------------------  初始化配置  -------------------------------
    
    // MARK:  --------------------------------  主框架  -------------------------------
    /**
     添加主框架
     */
    func addMainFrameWork()
    {
        self.setUpViewControllers()
        
        self.setNavStyle()
    }
    
    /**
     建立所有视图控制器
     */
    func setUpViewControllers()
    {
        
        LGXMPPManager.shared
        
        _mainNavigationController = UINavigationController(rootViewController: LoginViewController.loadFromStoryBoard()!)
        _mainNavigationController?.setNavigationBarHidden(true, animated: false)
        self.window!.rootViewController = _mainNavigationController
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.joinChatRoom(_:)), name: "joinChatRoom", object: nil)
    }
    
    
    /**
     设置导航条样式
     */
    func setNavStyle()
    {
        //透明样式---ios7不支持
        if kIOSVersion >= 8.0
        {
            UINavigationBar.appearance().translucent = false
        }
        //设置背景颜色
        UINavigationBar.appearance().barTintColor = kNavigationBarBackgroundColor
        //字体颜色
        UINavigationBar.appearance().tintColor = kNavigationBarTitleColor
        
        //设置标题样式
        var titleBarAttributes = [String: AnyObject]()
        titleBarAttributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Light", size: kNavigationBarTitleFontSize)
        titleBarAttributes[NSForegroundColorAttributeName] = kNavigationBarTitleColor
        UINavigationBar.appearance().titleTextAttributes = titleBarAttributes
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    // MARK:  --------------------------------  介绍页 & 介绍页回调  -------------------------------
    // MARK:  --------------------------------  TabVC 回调  ----------------------------------
    // MARK:  --------------------------------  登录  &  退出  -------------------------------
    // MARK:  --------------------------------  帐号体系相关  -------------------------------
    // MARK:  --------------------------------  埋点  -------------------------------
    // MARK:  --------------------------------  第三方应用相关  -------------------------------
    // MARK:  第三方应用相关--注册所有的第三方相关组件
    // MARK:  --------------------------------  推送相关 处理  -------------------------------
    // MARK:  --------------------------------  信息上报  -------------------------------
    // MARK:  --------------------------------  版本校验  -------------------------------
    // MARK:  --------------------------------  消息中心  -------------------------------
    
    
    // MARK:  --------------------------------  群聊 -------------------------------
    /**
     加入聊天室
     - parameter notification: 通知对象
     */
    func joinChatRoom(notification: NSNotification)  {
        let roomJIDString = notification.object as! String
        let groupChatRoomVC = ChatMessageTableViewController(clientIDs: nil, roomName: roomJIDString, roomID: roomJIDString)
        let groupChatNavController = UINavigationController(rootViewController: groupChatRoomVC)
        weak var chatRoomVC = groupChatRoomVC
        self.window?.rootViewController!.presentViewController(groupChatNavController, animated: true, completion: {
            
            chatRoomVC?.setRoomIDList(LGXMPPManager.shared.getRoomAllOccupantsList())
            /*
             //延迟进行群内人员信息请求
             //获取群主持人
             LGXMPPManager.shared.fetchModeratorsList({ (membersList, faildMsg) in
             if membersList != nil{
             var idArray = [String]()
             for xmlItem in membersList as! [DDXMLElement]{
             let jidString = xmlItem.attributeForName("jid").stringValue()
             idArray.append(LGXMPPManager.shared.getChatUserId(jidString))
             }
             chatRoomVC?.setRoomIDList(idArray)
             }
             })
             */
        })
    }
    
    /**
     创建聊天室，并进入聊天室界面
     */
    func createChatRoom(groupChatRoomVC: UIViewController)  {
        
        let groupChatNavController = UINavigationController(rootViewController: groupChatRoomVC)
        self.window?.rootViewController!.presentViewController(groupChatNavController, animated: true, completion: {
            
        })
    }
    
}



