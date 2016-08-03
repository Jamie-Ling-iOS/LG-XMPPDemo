//
//  FriendListViewController.swift
//  LG-Demo
//
//  Created by jamie on 16/6/28.QQ:2726786161
//  Copyright © 2016年 LG. All rights reserved.
//  好友列表

import UIKit

class FriendListViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIAlertViewDelegate{
    
    var _friendResultsConrtoller: NSFetchedResultsController?           //好友结果搜索控制器
    var _popMenuItemArray: [XHPopMenuItem]?                             //pop元素
    
    // MARK: -  单例  **********
    ///单例
    class var shared: FriendListViewController {
        dispatch_once(&Inner.token) {
            Inner.instance = FriendListViewController()
        }
        return Inner.instance!
    }
    
    struct Inner {
        static var instance: FriendListViewController?
        static var token: Int = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.view.backgroundColor = UIColor.orangeColor()

        self.title = "好友列表"
        weak var weakSelf = self
        self.tableView.mj_header = MJRefreshHeader(refreshingBlock: {
            weakSelf?.updateFriendList()
        })
        
        self.navigationItem.leftBarButtonItem = Tools.createRightBarButtonItem("退出登录", target: self, selector: #selector(FriendListViewController.goBack), imageName: nil)
        self.navigationItem.rightBarButtonItem = Tools.createRightBarButtonItem("更多", target: self, selector: #selector(FriendListViewController.showMenu(_:)), imageName: nil)
        
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func goBack() {
        LGXMPPManager.shared.outLine()
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ------------------- 更新 -----------------------
    func updateFriendList() {
        weak var weakSelf = self
        LGXMPPManager.shared.getFriendList({ (theFetchedResultsController) in
            weakSelf?._friendResultsConrtoller?.delegate = nil
            weakSelf?._friendResultsConrtoller = nil
            weakSelf?._friendResultsConrtoller = theFetchedResultsController
            weakSelf?._friendResultsConrtoller?.delegate = self
            weakSelf?.tableView.reloadData()
            weakSelf?.tableView.mj_header.endRefreshing()
            }) { (errorMsg) in
                if errorMsg != nil{
                    Tools.shared.showAlertViewAndDismissDefault("获取好友列表失败", message: errorMsg!)
                }
                weakSelf?.tableView.mj_header.endRefreshing()
        }
  
    }
    
    

    
    // MARK: ------------------- 添加好友-----------------------
    func addFriend() {
        
        let alertView = UIAlertView(title: "添加好友", message: "请输入想要添加的好友名称", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "添加")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alertView.textFieldAtIndex(0)!.placeholder = "用户名"
        alertView.tag = vAddFriendAlertTag
        alertView.show()
    }
    
    // MARK: ------------------- UITableViewDelegate-----------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = _friendResultsConrtoller?.sections{
            return sections.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfo = _friendResultsConrtoller?.sections?[section]{
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UserInfoCell!
        cell = tableView.dequeueReusableCellWithIdentifier("UserInfoCell") as? UserInfoCell
        
        if cell == nil
        {
            cell = UserInfoCell.loadViewFromNib()
        }
        
        //获取数据
        if let dataObject = _friendResultsConrtoller?.objectAtIndexPath(indexPath) as? XMPPUserCoreDataStorageObject{
            
            let theUserInfoModel = UserInfoModel(dataObject: dataObject)
            cell?.updatCell(theUserInfoModel)
 
            }
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //获取数据
        if let dataObject = _friendResultsConrtoller?.objectAtIndexPath(indexPath) as? XMPPUserCoreDataStorageObject{
            
            let theUserInfoModel = UserInfoModel(dataObject: dataObject)
            let chatMessageVC = ChatMessageTableViewController(oneToOneFriendID: theUserInfoModel.userID)
            self.navigationController?.pushViewController(chatMessageVC, animated: true)
        }
    }
    
    // MARK: --------------- 删除功能  ---------------
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let dataObject = _friendResultsConrtoller?.objectAtIndexPath(indexPath) as? XMPPUserCoreDataStorageObject{
            //只有我的好友或者彼此之间为好友才能删除
            if dataObject.subscription == "both" || dataObject.subscription == "to"{
                return true
            }
        }
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            if let dataObject = _friendResultsConrtoller?.objectAtIndexPath(indexPath) as? XMPPUserCoreDataStorageObject{
                LGXMPPManager.shared.deleteFriend(dataObject.jid, deleteFriendBlock: { (isSuccess, faildMsg) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if isSuccess{
                            
                            Tools.shared.showAlertViewAndDismissDefault("删除好友成功", message: nil)
                        }else if faildMsg != nil{
                            Tools.shared.showAlertViewAndDismissDefault("删除好友失败", message: faildMsg!)
                            
                        }
                    })
                })
            }
        }
    }
    
    
    // MARK:  ---------------- UIAlertView delegate -----------------
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        DPrintln("check index = \(buttonIndex)")
        
        if alertView.tag == vAddFriendAlertTag{
            if buttonIndex == 1{
                DPrintln("添加好友")
                let textField = alertView.textFieldAtIndex(0)!
                if NSString.isNilOrEmpty(textField.text){
                    Tools.shared.showAlertViewAndDismissDefault("请输入想要添加的用户名", message: nil)
                    alertView.show()
                }else{
                    LGXMPPManager.shared.addFriend(textField.text!, addFriendBlock: { (isSuccess, faildMsg) in
                        if isSuccess{
                            Tools.shared.showAlertViewAndDismissDefault("发送好友请求成功，等待对方接受", message: nil)
                        }else if !NSString.isNilOrEmpty(faildMsg){
                            Tools.shared.showAlertViewAndDismissDefault("添加\(textField.text!)失败", message: faildMsg!)
                        }
                    })
                }
            }
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        DPrintln("好友 列表有更新")
        self.tableView.reloadData()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if anObject .isKindOfClass(XMPPMessageArchiving_Message_CoreDataObject){
            DPrintln("聊天信息数据库有变化 ")
            
        }else{
            DPrintln("数据库有变化 ")
        }
    }
    
    // MARK: ------------------- 群聊相关-----------------------
    func choiceFriendToRoomChat() {
        weak var weakSelf = self
        LGXMPPManager.shared.getFriendResultController_noSession({ (resultArray: [AnyObject]?) in
            var itemArray = [MultiSelectItem]()
            for userData in resultArray as! [XMPPUserCoreDataStorageObject]{
                let selectItem = MultiSelectItem()
                selectItem.imageURL = NSURL(string:"http://lorempixel.com/400/200/")
                selectItem.name = userData.displayName
                //                selectItem.selected = true
                selectItem.userId = userData.jid.user
                selectItem.selected = false
                itemArray.append(selectItem)
            }
            let multiSelectVC = MultiSelectViewController()
            multiSelectVC.items = itemArray
            
            multiSelectVC.completeBlock = {(array) in
                weakSelf!.startRoomChat(array as! [MultiSelectItem])
            }
            let multiSelectNavController = UINavigationController(rootViewController: multiSelectVC)
            self.navigationController?.presentViewController(multiSelectNavController, animated: true, completion: nil)
        }) { (errorMsg: String?) in
            if errorMsg != nil{
                Tools.shared.showAlertViewAndDismissDefault("建立群聊失败", message: errorMsg!)
            }
        }
    }
    
    func startRoomChat(friendItem: [MultiSelectItem]) {
//        weak var weakSelf = self
        LGXMPPManager.shared.createChatRoom(LGXMPPManager.shared._userId!+"_room", ownerMe: true) { (isSuccess, faildMsg) in
            if isSuccess{
                //自己默认已经加入，再邀请其它人加入
                dispatch_async(dispatch_get_main_queue(), {
                    
                    var idArray = [String]()
                    
                    for item in friendItem{
                        LGXMPPManager.shared.inviteUserToChatRoom(item.userId)
                        idArray.append(item.userId)
                    }
                    let roomJidString = "\(LGXMPPManager.shared._userId!+"_room")@\(vHostRoom)"
                    //推出群界面
                    let chatVC = ChatMessageTableViewController(clientIDs: idArray, roomName: LGXMPPManager.shared._userId!+"_room", roomID: roomJidString)
                    Tools.getAppDelegate().createChatRoom(chatVC)
                })
            }
        }
    }
    
    // MARK: ------------------- Menu-----------------------
    func showMenu(sender: UIButton) {
        self.initPopMenuArray()
        
        let options = XHPopMenuConfiguration.defaultConfiguration()
        options.style = XHPopMenuAnimationStyle.WeiXin
        
        options.menuMaxHeight       = 240; // 菜单最大高度
        options.itemHeight          = 40;
        options.itemMaxWidth        = 140;
        options.arrowSize           = 15; //指示箭头大小
        options.arrowMargin         = 0; // 手动设置箭头和目标view的距离
        options.marginXSpacing      = 10; //MenuItem左右边距
        options.marginYSpacing      = 9; //MenuItem上下边距
        options.intervalSpacing     = 15; //MenuItemImage与MenuItemTitle的间距
        options.menuCornerRadius    = 3; //菜单圆角半径
        options.shadowOfMenu        = true; //是否添加菜单阴影
        options.hasSeparatorLine    = true; //是否设置分割线
        options.separatorInsetLeft  = 10; //分割线左侧Insets
        options.separatorInsetRight = 0; //分割线右侧Insets
        //        options.separatorHeight     = 1.0 / [UIScreen mainScreen].scale;//分割线高度
        options.titleColor          = UIColor.whiteColor();//menuItem字体颜色
        options.separatorColor      = UIColor.grayColor();//分割线颜色
        options.menuBackgroundColor = kHexRGBAlpha(0x26b8f2, alpha: 0.7)//菜单的底色
        options.selectedColor       = UIColor.grayColor()// menuItem选中颜色
        
        XHPopMenu.showMenuWithView(sender, menuItems: _popMenuItemArray!, withOptions: options)
    }
    
    func initPopMenuArray() {
        if _popMenuItemArray == nil {
            _popMenuItemArray = [XHPopMenuItem]()
            let titleArray = ["发起群聊", "添加朋友"]
            let imageNameArray = ["contacts_add_newmessage", "contacts_add_friend"]
            //            let actionArray = [#selector(FriendListViewController.startRoomChat), #selector(FriendListViewController.addFriend)]
            let actionArray = [#selector(FriendListViewController.choiceFriendToRoomChat), #selector(FriendListViewController.addFriend)]
            for i in 0...1 {
                let popMenuItem = XHPopMenuItem(title: titleArray[i], image: UIImage(named: imageNameArray[i])!, target: self, action: actionArray[i])
                _popMenuItemArray!.append(popMenuItem)
            }
        }
    }
}
