//
//  LGXMPPManager.swift
//  LG-Demo
//
//  Created by jamie on 16/6/12.QQ:2726786161
//  Copyright © 2016年 LG. All rights reserved.
//  XMPP-个人管理类

//因为是在个人MAC搭建Openfire服务器调试，所以此hostname为个人MAC共享访问地址
//在mac的系统偏好设置-共享里查看完整地址
//let vHostName = "JamieiMac.local"


//链接通过Mac共享出的wifi时，要用此host
let vHostName = "JamieiMac.local"

let vHostChat = "JamieiMac.local"
let vHostRoom = "conference.JamieiMac.local"

//如果一切正常但发送消息失败，尝试切换到下面的host，反之切换到上面的host
//正常情况下均用此host
//let vHostChat = "localhost"
//let vHostRoom = "conference.localhost"


let vAddFriendAlertTag = 999
let vJoinGroupAlertTag = 1000

import UIKit
/// 发送消息回调block
typealias LGXMPP_SendMessageBlock = (isSucess: Bool, faildMsg: String?) -> Void
/// 获取历史消息结果回调
typealias LGXMPP_GetMessageListBlock =  (messageList: [XHMessage]?, faildMsg: String?) -> Void
/// 添加或删除好友，信息发送状态回调
typealias LGXMPP_AddOrDeleteFriendRequestBlock = (isSuccess: Bool, faildMsg: String?) -> Void
/// 创建房间
typealias LGXMPP_CreateChatRoomBlock = (isSuccess: Bool, faildMsg: String?) -> Void
/// 获取房间所有主持人
typealias LGXMPP_GetChatRoomModeratorsBlock =  (membersList: [AnyObject]?, faildMsg: String?) -> Void

class LGXMPPManager: NSObject, XMPPStreamDelegate, XMPPRosterDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, XMPPRoomDelegate, XMPPMUCDelegate {
    
    var _userId: String?                    //用户名，不包括域名
    var _pwd: String?                       //用户密码，因为在用户连接成功的回调中才能发送密码验证身份
    var _xmppStream: XMPPStream!            //xmpp基础服务
    var _xmppReconnect: XMPPReconnect!      //重连服务,意外断开连接并自动重连
    
    //花名册相关----
    var _xmppRoster: XMPPRoster!
    var _xmppRosterStorage = XMPPRosterCoreDataStorage.sharedInstance()     //花名单存储
    
    //消息相关----
    var _xmppMessageArchinving: XMPPMessageArchiving!
    var _xmppMessageStorage: XMPPMessageArchivingCoreDataStorage!
    var _sendMessageBlock: LGXMPP_SendMessageBlock?    //发送消息的回调
    
    //聊天室----
    var _xmppRoom: XMPPRoom?                                    //自己当前创建的聊天室
    var _xmppRoomJid: XMPPJID?                                  //房间jid
    var _xmppRoomOwnerMe = false                                //此房间是否是我创建的
    var _xmppRoomStorage = XMPPRoomMemoryStorage()              //聊天室信息存储，只是放到内存中，也可根据业务情况用coredata方式的对象存储,如XMPPRoomCoreDataStorage
    var _createChatRoomBlock: LGXMPP_CreateChatRoomBlock?       //创建房间回调
    var _getChatRoomModeratorsBlock: LGXMPP_GetChatRoomModeratorsBlock? //获取房间主持人列表
    var _xmppRoomCreateSuccess = false                          //房间创建成功
    var _inChatRoom = false                                     //是否已经在聊天室内，因为本demo要确保同一时间只能在一个聊天室聊天
    
    var _xmppMuc: XMPPMUC!                                      //房间邀请等数据对象

    //状态相关----
    var _addFriendBlock: LGXMPP_AddOrDeleteFriendRequestBlock?
    var _deleteFriendBlock: LGXMPP_AddOrDeleteFriendRequestBlock?
    var _addMeJid: XMPPJID?
    
    var _isActiveXMPPModules = false                            //模块是否已经激活
    
    // MARK: -  单例  **********
    ///单例
    class var shared: LGXMPPManager {
        dispatch_once(&Inner.token) {
            Inner.instance = LGXMPPManager()
            Inner.instance!.xmppInit()
        }
        return Inner.instance!
    }
    
    struct Inner {
        static var instance: LGXMPPManager?
        static var token: Int = 0
    }
    
     // MARK:  --------------------------------  初始化  -------------------------------
    /**
     初始化
     */
    func xmppInit()
    {
        _xmppStream = XMPPStream()
        _xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    /**
     激活其它模块
     */
    func activeXMPPModules() {
        
        if _isActiveXMPPModules{
            //确保只激活一次
            return
        }
        //花名册
        _xmppRoster = XMPPRoster(rosterStorage: _xmppRosterStorage)
        //自动获取用户列表
        _xmppRoster.autoFetchRoster = true
        _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = true
        //激活&添加代理
        _xmppRoster.activate(_xmppStream)
        _xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        //重连
        _xmppReconnect = XMPPReconnect()
        _xmppReconnect.activate(_xmppStream)
        
        //消息相关
        _xmppMessageStorage = XMPPMessageArchivingCoreDataStorage()
        _xmppMessageArchinving = XMPPMessageArchiving(messageArchivingStorage: _xmppMessageStorage)
        _xmppMessageArchinving.clientSideMessageArchivingOnly = true
        //激活&添加代理
        _xmppMessageArchinving.activate(_xmppStream)
        _xmppMessageArchinving.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        //聊天室相关
        _xmppMuc = XMPPMUC()
        _xmppStream.registerModule(_xmppMuc)
        _xmppMuc.activate(_xmppStream)
        _xmppMuc.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        _isActiveXMPPModules = true
    }
    
    // MARK:  --------------------------------  辅助  -------------------------------
    /**
     将传入的字符串拼接成jid格式
     */
    func getChatJidString(theString: String) -> String {
        if theString.hasSuffix(vHostChat) || theString.containsString("@"){
            return theString
        }
        return "\(theString)@\(vHostChat)"
    }
    
    /**
     将传入的可能为jid格式的字符串去掉域名，得到userid
     */
    func getChatUserId(theString: String) -> String {
        if theString.hasSuffix(vHostChat) || theString.containsString("@"){
            return theString.componentsSeparatedByString("@").first!
        }
        return theString
    }
    
    func getMessageTypeString(messageType: XHBubbleMessageMediaType) -> String {
        switch messageType {
        case .Emotion:
            return "emotion"
        case .LocalPosition:
            return "location"
        case .Photo:
            return "photo"
        case .Text:
            return "text"
        case .Video:
            return "video"
        case .Voice:
            return "voice"
        }
    }
    
    func getMessageTypeFromString(messageTypeString: String?) -> XHBubbleMessageMediaType {
        if messageTypeString == nil
        {
            return .Text
        }
        switch messageTypeString! {
        case "emotion":
            return .Emotion
        case "location":
            return .LocalPosition
        case "photo":
            return .Photo
        case "text":
            return .Text
        case "video":
            return .Video
        case "voice":
            return .Voice
        default:
            return .Text
        }
    }
    
    // MARK:  --------------------------------  登录  -------------------------------
    func login(userId: String, password: String){
        
        Tools.addLoadingInWindow()
        
        if _xmppStream.isConnected(){
            //连接状态，如果不是同一用户，就先确保断开
            if _userId != userId{
                _xmppStream.disconnect()
            }
        }
        
        _userId = userId
        self.xmppConnect(userId, password: password)

    }
    
    /**
     连接服务器（并进行验证）
     
     - parameter userId:   用户名
     - parameter password: 密码
     */
    func xmppConnect(userId: String, password: String) {
        
        var userJidString = userId
        if userId.hasSuffix(vHostName) == false{
            userJidString = "\(userId)@\(vHostName)"
        }
        let jid = XMPPJID.jidWithString(userJidString)
        
        _xmppStream.myJID = jid
        _xmppStream.hostName = vHostName
        _pwd = password
        
        dispatch_async(dispatch_get_main_queue(), {
            do {
                try self._xmppStream.connectWithTimeout(10)
            } catch let error {
                Tools.dissmissLoadingInWindow()
                DPrintln("发送连接请求失败 \(error),请检查网络或服务器配置")
            }
        })
    }
    
    /**
     进行身份校验
     */
    func authenticateUser() {
        
        if _xmppStream.isAuthenticated(){
            return
        }
        do {
            try _xmppStream.authenticateWithPassword(_pwd)
        } catch let error {
            Tools.dissmissLoadingInWindow()
            DPrintln("发送验证请求失败 \(error)")
            _xmppStream.disconnect()
        }
    }
    
    
    // MARK:  --------------------------------  状态更新  -------------------------------
    /*
     
     presence 的状态：
     
     available 上线
     
     away 离开
     
     do not disturb 忙碌
     
     unavailable 下线
     */
    func onLine(){
        DPrintln("发送上线状态")
        //type默认为available
        let presence = XMPPPresence()
        
        _xmppStream.sendElement(presence)
    }
    
    func outLine(){
        DPrintln("发送下线状态")
        
        let presence = XMPPPresence(type: "unavailable")
        _xmppStream.sendElement(presence)
//        _xmppStream.disconnect()  //有可能下线状态还未发送成功就断开了连接，所以使用下面的方法
        _xmppStream.disconnectAfterSending()
    }
    
    
    // MARK:  --------------------------------  添加删除好友  -------------------------------
    /**
     添加好友
     
     - parameter userId:         好友id
     - parameter addFriendBlock: 添加好友请求的结果回调（并非好友回复的结果，只是请求是否发送成功的回调）
     */
    func addFriend(friendId: String, addFriendBlock: LGXMPP_AddOrDeleteFriendRequestBlock?) {
        
        let friendJidString = self.getChatJidString(friendId)
        //先判断是不是添加了自己
        if friendJidString == "\(_userId!)@\(vHostChat)"{
            if addFriendBlock != nil{
                addFriendBlock!(isSuccess: false, faildMsg: "你不能添加你自己哦")
                return
            }
        }
        
        // 先判断是否已经是我的好友，如果是，就不再添加
        let userJID = XMPPJID.jidWithString(friendJidString)
        if let theFirendData = _xmppRosterStorage.userForJID(userJID, xmppStream: _xmppStream, managedObjectContext: _xmppRosterStorage.mainThreadManagedObjectContext){
            if theFirendData.subscription == "to" || theFirendData.subscription == "both"{
                if addFriendBlock != nil{
                    addFriendBlock!(isSuccess: false, faildMsg: "\(friendJidString)已经是你的好友了或者已发送过请求了哦")
                    return
                }
            }
           
        }
        _addFriendBlock = addFriendBlock
        // 发送添加好友请求
        /*
         presence.type有以下几种状态：
         
         available: 表示处于在线状态(通知好友在线)
         unavailable: 表示处于离线状态（通知好友下线）
         subscribe: 表示发出添加好友的申请（添加好友请求）
         unsubscribe: 表示发出删除好友的申请（删除好友请求）
         unsubscribed: 表示拒绝添加对方为好友（拒绝添加对方为好友）
         error: 表示presence信息报中包含了一个错误消息。（出错）
         */
        _xmppRoster.subscribePresenceToUser(userJID)
    }
    
    func deleteFriend(friendJid: XMPPJID, deleteFriendBlock: LGXMPP_AddOrDeleteFriendRequestBlock?) {
        _deleteFriendBlock = deleteFriendBlock
        _xmppRoster.removeUser(friendJid)
    }
    
    // MARK:  --------------------------------  发送消息  -------------------------------
    /*
     <message type="chat" to="xiaoming@example.com">
     　　<body>Hello World!<body />
     <message />
 **/
    
    /**
     发送消息(文字，图片，视频，语音等所有格式),包括单独聊天和群聊
     
     - parameter messageType:      消息类型，来自MessageDisplayKit,也可以自己实现枚举
     - parameter messageURL:       多媒体消息时，传递的是URL
     - parameter messageText:      文字消息时的文字内容
     - parameter otherMessage:     其它附带属性
     - parameter receiveId:        发送对象的id，可能是某个人也可以是某个房间id
     - parameter isRoomChat:       是否是聊天室（房间）聊天
     - parameter sendMessageBlock: 发送成功后的回调（来确保消息已成功到达服务器）
     */
    func sendMessage(messageType: XHBubbleMessageMediaType, messageURL: String?, messageText: String?, otherMessage: String?, receiveId: String, isRoomChat: Bool,sendMessageBlock: LGXMPP_SendMessageBlock) {
        if isRoomChat && _xmppRoom == nil {
            //默认只允许在一个房间聊天
            sendMessageBlock(isSucess: false, faildMsg: "你已经退出了放间或房间已经不存在")
            return
        }
        
        _sendMessageBlock = nil
        _sendMessageBlock = sendMessageBlock
        
        let bodyElement = DDXMLElement(name: "body")
        if messageType == .Text{
            bodyElement.setStringValue(messageText)
        }else {
            bodyElement.setStringValue(messageURL)
        }
        
        let messageElement = DDXMLElement(name: "message")
        messageElement.addAttributeWithName("type", stringValue: isRoomChat ? "groupchat" : "chat")
        messageElement.addAttributeWithName("releayType", stringValue: self.getMessageTypeString(messageType))
        if otherMessage != nil{
            messageElement.addAttributeWithName("otherMessage", stringValue: otherMessage!)
        }
        
        let recevieJidString = self.getChatJidString(receiveId)
        messageElement.addAttributeWithName("to", stringValue: recevieJidString)
        messageElement.addChild(bodyElement)
        _xmppStream.sendElement(messageElement)
    }

    
    // MARK:  --------------------------------  信息查询   -------------------------------
    /**
     获取聊天记录
     
     - parameter userID:              如果为空，就是本地所有好友全部的聊天记录，这里friendid也可以为房间id,因为我们的房间信息发送走的也是正常聊天的_xmppMessageStorage存储
     - parameter getMessageListBlock: 回调
     */
    func getMessageList(friendId: String?, getMessageListBlock: LGXMPP_GetMessageListBlock) {
        
        //如果是房间聊天，也可以从_xmppRoomStorage中获取数据库（xmppRoomStorage可以初始化为内存中的群消息对象，或者单独为群创建的coredata）
        let context = _xmppMessageStorage.mainThreadManagedObjectContext
        let entity = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entity
        
        //全部查询出来
        //request.fetchLimit = 50         //一次最多查询50
        
        if friendId != nil{
            // 过滤内容，只找我与正要聊天的好友的聊天记录,注意：数据库内为小写
            let friendJidString = self.getChatJidString(friendId!).lowercaseString
            let predicate = NSPredicate(format: "bareJidStr = %@", friendJidString)

            request.predicate = predicate
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            var results: [XMPPMessageArchiving_Message_CoreDataObject]?
            do {
                try results = context.executeFetchRequest(request) as? [XMPPMessageArchiving_Message_CoreDataObject]
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue(), {
                    return getMessageListBlock(messageList: nil, faildMsg: error.description)
                })
            }
            if (results != nil) && (results?.count != 0){
                var array = [XHMessage]()
                for object in results! {
                    
                    let oldMessage = self.getXHMessageFromXMPPMessage(object.message, messageSender: object.bareJidStr, isUserSendMessage: object.outgoing.intValue == 1 ? true : false, isHistory: true)

                    if oldMessage.messageMediaType == XHBubbleMessageMediaType.Voice && oldMessage.voicePath == nil{
                        //语音没有从本地读到
                        //尝试在子线程去下载，下次拉记录时可以刷新出来，这次不再显示----也可以自己控制异步加载显示
                        LGTXCloudManager.shared.downloadFile(oldMessage.voiceUrl, sign: kTXCloud_File_Secret_ManyTime, sucessResult: nil, faildMsg: nil)
                        continue
                    }
                    
                    oldMessage.avatar = UIImage(named: "_App_Icons")
                    oldMessage.avatarUrl = "http://lorempixel.com/400/200/"
                    array.append(oldMessage)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    return getMessageListBlock(messageList: array, faildMsg: nil)
                })
            }
            dispatch_async(dispatch_get_main_queue(), {
                return getMessageListBlock(messageList: nil, faildMsg: nil)
            })
        }
    }
    
    //好友列表-//好友搜索结果控制器
    func getFriendList(sucessResult: (NSFetchedResultsController -> Void)?, faildMsg: (String? -> Void)?){
        
        if !_xmppStream.isAuthenticated()
        {
            if faildMsg != nil{
                return faildMsg!("请先登录哦")
            }
        }
        
        let context = _xmppRosterStorage.mainThreadManagedObjectContext
        //从CoreData中获取数据
        //通过实体获取FetchRequest实体
        let request = NSFetchRequest(entityName: NSStringFromClass(XMPPUserCoreDataStorageObject))
        
//        //添加排序规则
//        let sortFriend = NSSortDescriptor(key: "jidStr", ascending: true)
//        request.sortDescriptors = [sortFriend]
        
        // 在线状态排序
        let sortOnLine = NSSortDescriptor(key: "sectionNum", ascending: true)
        // 显示的名称排序
        let sortByName = NSSortDescriptor(key: "displayName", ascending: true)
        
        // 添加排序
        request.sortDescriptors = [sortOnLine, sortByName]
        
        // 添加谓词过滤器 状态为None的排除（加好友对方还没确认，或者好友关系，被对方删除）
        request.predicate = NSPredicate(format: "!(subscription CONTAINS 'none')")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            //获取FRC
            let friendResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try friendResultsController.performFetch()
            } catch let error as NSError {
                
                dispatch_async(dispatch_get_main_queue(), {
                    if faildMsg != nil{
                        return faildMsg!(error.description)
                    }
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                if sucessResult != nil{
                    return sucessResult!(friendResultsController)
                }
            })
        }
    }
    

    
    //好友列表-//好友搜索结果控制器
    func getFriendResultController_noSession(sucessResult: ([AnyObject]? -> Void)?, faildMsg: (String? -> Void)?){
        
        if !_xmppStream.isAuthenticated()
        {
            if faildMsg != nil{
                return faildMsg!("请先登录哦")
            }
        }
        
        //从CoreData中获取数据
        let context = _xmppRosterStorage.mainThreadManagedObjectContext
        
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("XMPPUserCoreDataStorageObject", inManagedObjectContext: context)
        request.entity = entity
        

        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            var results: [AnyObject]?

            do {
                try results = context.executeFetchRequest(request)
            } catch let error as NSError{
                dispatch_async(dispatch_get_main_queue(), {
                    if faildMsg != nil{
                        return faildMsg!(error.description)
                    }
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                if sucessResult != nil{
                    return sucessResult!(results)
                }
            })
        }
        
}


/*
    func queryRoster() {
//        _xmppRoster.fetchRoster()
        
        /*
        //服务器查询
        //创建iq节点
        let iqElement = DDXMLElement(name: "iq")
        
        let myJID = _xmppStream.myJID
        iqElement.addAttributeWithName("from", stringValue: myJID?.description)
        iqElement.addAttributeWithName("to", stringValue: myJID?.domain)
        iqElement.addAttributeWithName("id", stringValue: self.generateRequestID())
        iqElement.addAttributeWithName("type", stringValue: "get")
        
        //添加查询类型
        let queryElement = DDXMLElement(name: "query", xmlns: "jabber:iq:roster")
        iqElement.addChild(queryElement)
        
        //发送查询
        _xmppStream.sendElement(iqElement)
 */
        

//本地coredata中获取
        
        let context = XMPPRosterCoreDataStorage.sharedInstance().mainThreadManagedObjectContext
        let request = NSFetchRequest(entityName: "XMPPUserCoreDataStorageObject")
        
//        //筛选出本用户的好友
//        let userInfo = "\(_userId!)@127.0.0.1"
//        let predicate = NSPredicate(format: "streamBareJidStr = \(userInfo)")
//        request.predicate = predicate

        
        //排序
        let sort = NSSortDescriptor(key: "displayName", ascending: true)
        request.sortDescriptors = [sort]
        
        let fetFriends = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetFriends.delegate = self
        
        do {
            try fetFriends.performFetch()
        } catch let error {
            
            DPrintln("performFetch请求失败 \(error)")
        }
        
        
        //返回的数组是XMPPUserCoreDataStorageObject  *obj类型的
        //名称为 obj.displayName
        DPrintln("\(fetFriends.fetchedObjects)")
   
//        return  self.fetFriend.fetchedObjects;
 
        
    }
*/
    func generateRequestID() -> String {
        return "123"
    }
 
     // MARK:  --------------------------------  链接回调  -------------------------------
    func xmppStream(sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        DPrintln("建立socket链接")
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        DPrintln("链接成功")
        
        //进行身份校验
        self.authenticateUser()
        
        //注册所有模块
        self.activeXMPPModules()
    }
    
    func xmppStreamConnectDidTimeout(sender: XMPPStream!){
        DPrintln("链接超时")
        Tools.dissmissLoadingInWindow()
        Tools.shared.showAlertViewAndDismissDefault(nil, message: "链接超时，请重试")
    }
    
    //退出登录或者掉线或链接异常
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
        DPrintln("链接断开")
        if error != nil
        {
            Tools.dissmissLoadingInWindow()
            Tools.shared.showAlertViewAndDismissDefault(nil, message: "链接异常, \(error.domain)")
        }
    }
    

    // MARK:  --------------------------------  身份验证回调  -------------------------------
    func xmppStreamDidAuthenticate(sender: XMPPStream!){
        DPrintln("身份验证成功")
//        Tools.shared.showAlertViewAndDismissDefault(nil, message: "登录成功!")
        self.onLine()
        Tools.dissmissLoadingInWindow()
        NSNotificationCenter.defaultCenter().postNotificationName("loginSuccess", object: nil, userInfo: nil)
    }
    
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        DPrintln("身份验证失败")
        Tools.dissmissLoadingInWindow()
      
        NSNotificationCenter.defaultCenter().postNotificationName("loginError", object: nil, userInfo: nil)
        _xmppStream.disconnect()
    }
    

    
    ///获取好友状态
    func xmppStream(sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        let presenceType = presence.type()
        let presenceFromJID = presence.from()
        if presenceFromJID != sender.myJID{
            if presenceType == "available"{
                DPrintln("\(presenceFromJID) 已上线")
            }else if presenceType == "unavailable"{
                DPrintln("\(presenceFromJID) 已下线")
            }
        }
    }
    

//<message xmlns="jabber:client" to="jamie@127.0.0.1/h99zy6fj5" from="mina@jamieimac.local" type="error"><error code="404" type="cancel"><remote-server-not-found xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></message>
    
//    <message xmlns="jabber:client" from="127.0.0.1"><body>想起</body></message>
    // MARK:  --------------------------------  接收消息-来自XMPP回调  -------------------------------
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        DPrintln("收到消息 \(message)")
        //stringValue默认解析body内字符
//        let messageString = message.stringValue()
//        if !NSString.isNilOrEmpty(messageString)
        if message.isChatMessageWithBody(){
            
            let newMessage = self.getXHMessageFromXMPPMessage(message, messageSender: message.from().full(), isUserSendMessage: false, isHistory: false)
             //用通知的方式来触发聊天界面刷新相关UI
            NSNotificationCenter.defaultCenter().postNotificationName(kXMPPNewMessage, object: newMessage, userInfo: nil)
        }
        else{
            DPrintln("收到其它类型消息/非正常消息")
            //在这里可以判断是否是消息回执，对消息回执作处理，可参考：http://blog.csdn.net/huwenfeng_2011/article/details/43459039
            //消息回执说明文档 http://xmpp.org/extensions/xep-0184.html
        }
        
        
        /*
 
         {
         //回执判断
         NSXMLElement *request = [message elementForName:@request];
         if (request)
         {
         if ([request.xmlns isEqualToString:@urn:xmpp:receipts])//消息回执
         {
         //组装消息回执
         XMPPMessage *msg = [XMPPMessage messageWithType:[message attributeStringValueForName:@type] to:message.from elementID:[message attributeStringValueForName:@id]];
         NSXMLElement *recieved = [NSXMLElement elementWithName:@received xmlns:@urn:xmpp:receipts];
         [msg addChild:recieved];
         
         //发送回执
         [self.xmppStream sendElement:msg];
         }
         }else
         {
         NSXMLElement *received = [message elementForName:@received];
         if (received)
         {
         if ([received.xmlns isEqualToString:@urn:xmpp:receipts])//消息回执
         {
         //发送成功
         NSLog(@message send success!);
         }
         }
         }
         
         //消息处理
         //...
 */
    }
    
    /**
     将XMPPMessage转成和UI可对应的XHMessage,(XHMessage来自MessageDisplayKit,也可以实现自己的UI模型)
     
     - parameter message:           收到的消息
     - parameter messageSender:     消息发送者
     - parameter isUserSendMessage: 是否是我自己发送的消息
     - parameter isHistory:         是否是历史记录
     
     - returns: 返回XHMessage
     */
    func getXHMessageFromXMPPMessage(message: XMPPMessage, messageSender: String?, isUserSendMessage: Bool, isHistory: Bool) -> XHMessage {

        var sender = messageSender
        if sender == nil{
            //发送者为空，判定为自己发出去的信息
           sender = "\(_userId!)@\(vHostChat)"
        }
        let nowTime = NSDate()
        let mediaText = message.body()
        
        var newMessage: XHMessage
        var messageType = XHBubbleMessageMediaType.Text
        if let releayType = message.attributeForName("releayType"){
            messageType = self.getMessageTypeFromString(releayType.stringValue())
        }
        
        switch messageType {
        case .Emotion:
            newMessage = XHMessage(emotionPath: NSBundle.mainBundle().pathForResource(mediaText, ofType: nil), sender: sender, timestamp: nowTime)
        case .LocalPosition:
            newMessage = XHMessage(text: "发送了位置信息", sender: sender, timestamp: nowTime)
        case .Photo:
            newMessage = XHMessage(photo: nil, thumbnailUrl: mediaText, originPhotoUrl: nil, sender: sender, timestamp: nowTime)
        case .Text:
            newMessage = XHMessage(text: mediaText, sender: sender, timestamp: nowTime)
        case .Video:
            newMessage = XHMessage(videoConverPhoto: nil, videoPath: nil, videoUrl: mediaText, sender: sender, timestamp: nowTime)
        case .Voice:
            var durantion = "60"
            if let durantionMessage = message.attributeForName("otherMessage"){
                durantion = durantionMessage.stringValue()
            }
            
            newMessage = XHMessage(voicePath: nil, voiceUrl: mediaText, voiceDuration: durantion, sender: sender, timestamp: nowTime)
            //当前收到的消息，通过腾讯云来下载语音
            //历史记录复用此方法时，通过查询Url来得到可能已存在本地的voicepath
            let resultPath = LGTXCloudManager.shared.getFilePathFromURLString(mediaText, typeString: "file")
            if NSFileManager.defaultManager().fileExistsAtPath(resultPath){
                newMessage.voicePath = resultPath
            }
         
        }
        DPrintln("sender = \(sender)")
        if isUserSendMessage {
            newMessage.bubbleMessageType = .Sending         //发送消息
        }else{
            newMessage.bubbleMessageType = .Receiving       //接收消息
        }
        //未读已读推送等需定制化实现，这里简单将历史信息全部标记成已读
        newMessage.isRead = isHistory
        return newMessage
    }
    
    // MARK:  --------------------------------  发送消息-回调  -------------------------------
    //message是一种基本推送消息方法，它不要求响应。主要用于IM、groupChat、alert和notification之类的应用中。
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        DPrintln("发送成功")
        if _sendMessageBlock != nil{
            _sendMessageBlock!(isSucess: true, faildMsg: nil)
        }
    }
    
    func xmppStream(sender: XMPPStream!, didFailToSendMessage message: XMPPMessage!, error: NSError!) {
        Tools.shared.showAlertViewAndDismissDefault(nil, message: "消息发送失败")
        if _sendMessageBlock != nil{
            _sendMessageBlock!(isSucess: false, faildMsg: error.description)
        }
    }
    
    /*
     available 上线
     away 离开
     do not disturb 忙碌
     unavailable 下线
     */
    //presence用来表明用户的状态，如：online、away、dnd(请勿打扰)等。当改变自己的状态时，就会在stream的上下文中插入一个Presence元素，来表明自身的状态。要想接受presence消息，必须经过一个叫做presence subscription的授权过程。
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
    }
    
    func xmppStream(sender: XMPPStream!, didSendPresence presence: XMPPPresence!) {
        
    }
    func xmppStream(sender: XMPPStream!, didFailToSendPresence presence: XMPPPresence!, error: NSError!) {
        
    }
    
    // MARK:  --------------------------------  好友列表 -------------------------------
    //获取到一个好友节点- 已经互为好友以后，会回调此方法
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        DPrintln("11 item = \(item)")
    }

    func xmppRosterDidEndPopulating(sender: XMPPRoster!) {
        DPrintln("好友列表加载完毕")
    }
    
    /**
      加好友回调函数
     presence.type有以下几种状态：
        available 上线
        away 离开
        do not disturb 忙碌
        unavailable 下线
     available: 表示处于在线状态(通知好友在线)
     unavailable: 表示处于离线状态（通知好友下线）
     subscribe: 表示发出添加好友的申请（添加好友请求）
     unsubscribe: 表示发出删除好友的申请（删除好友请求）
     unsubscribed: 表示拒绝添加对方为好友（拒绝添加对方为好友）
     error: 表示presence信息报中包含了一个错误消息。（出错）
     */
 
    func xmppRoster(sender: XMPPRoster!, didReceivePresenceSubscriptionRequest presence: XMPPPresence!) {
        DPrintln("\(presence)")
        
        // 好友在线状态
        let type = presence.type()
        let fromUser = presence.from().user
        let user = _xmppStream.myJID.user
        DPrintln("接收到状态为：\(type),来自发送者\(fromUser),接收者\(user)")
        
        // 防止自己添加自己为好友
        if fromUser != user{
            switch type {
            case "available":
                DPrintln("好友上线")
            case "away":
                DPrintln("好友离开")
            case "do not disturb":
                DPrintln("好友忙碌")
            case "unavailable":
                DPrintln("好友下线")
            case "subscribe":
                DPrintln("请求添加好友")
                _addMeJid = presence.from()
                let alert = UIAlertView(title: "好友申请", message: "\(fromUser)请求添加你为好友，是否同意?", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                alert.tag = vAddFriendAlertTag
                alert.show()
            case "unsubscribe":
                DPrintln("请求并删除了我这个好友")
                case "unsubscribed":
                DPrintln("对方拒绝了我的好友请求")
                case "error":
                DPrintln("错误信息")
            default:
                DPrintln("其它信息 type = \(type)")
            }
        }
    }
    
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterPush iq: XMPPIQ!) {

        let query = iq.elementForName("query").childAtIndex(0) as! DDXMLElement
        
        let jidString = query.attributeForName("jid").stringValue()
        let subscription = query.attributeForName("subscription").stringValue()
        if let ask = query.attributeForName("ask")
        {
            DPrintln("请求类型 \(ask.stringValue())")
            if _addFriendBlock != nil{
                _addFriendBlock!(isSuccess: true, faildMsg: nil)
                _addFriendBlock = nil
            }
            return
        }

        switch subscription {
        case "from":
            DPrintln("我已同意对方添加我为好友，关系确认成功")
            //此处不用提示，因为同意对方后，就会双方都变成彼此的好友，会进入both，同时 from会回调两次,ask也会被调用两次（从from变成both）
//            Tools.shared.showAlertViewAndDismissDefault("你已经成为\(jidString)的好友", message: nil)

        case "to":
            DPrintln("添加对方为好友成功,或者被对方删除")
            //此处不用提示，因为添加好友：默认对方同意后，就会双方都变成彼此的好友，会进入both，同时 to会回调两次
            //还有可能是被对方删除我这个好友的回调
//            Tools.shared.showAlertViewAndDismissDefault("\(jidString)已经成为你的好友", message: nil)
        case "both":
            DPrintln("添加好友成功，彼此成为好友")
            //此处不用提示，因为默认对方同意后，就会双方都变成彼此的好友，会进入both，同时 to会回调两次
            Tools.shared.showAlertViewAndDismissDefault("\(jidString)和你已经互为好友", message: nil)

        case "remove":
            DPrintln("删除好友成功")
            if _deleteFriendBlock != nil{
                //删除会调用两次,subscription会从 from(带ask) 变成 none(带ask)，最后是remove
                _deleteFriendBlock!(isSuccess: true, faildMsg: nil)
                _deleteFriendBlock = nil
            }

        default:
            DPrintln("subscription = \(subscription)）")
        }
        
    }
    
    
    // MARK:  --------------------------------  服务器IQ请求 -------------------------------
    //IQ:一种请求／响应机制，从一个实体从发送请求，另外一个实体接受请求，并进行响应。例如，client在stream的上下文中插入一个元素，向Server请求得到自己的好友列表，Server返回一个，里面是请求的结果。
 
    func xmppStream(sender: XMPPStream!, didSendIQ iq: XMPPIQ!) {
        
    }
    
    func xmppStream(sender: XMPPStream!, didFailToSendIQ iq: XMPPIQ!, error: NSError!) {
        
    }

    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
    
        //查询等结果
        DPrintln("receiveiq = \(iq)）")
        
        return true
    }
    
    // MARK:  --------------------------------  聊天室  -------------------------------
    /**
     创建聊天室，并且直接加入此聊天室
     
     - parameter roomID:              聊天室ID，可以自己创建，也可根据需求向服务器申请
     - parameter ownerMe:             是否是自己创建的房间，他人邀请我加入房间时，我也要生成对应的房间对象
     - parameter createChatRoomBlock: 创建完房间的回调
     */
    func createChatRoom(roomID: String, ownerMe: Bool, createChatRoomBlock: LGXMPP_CreateChatRoomBlock) {
        
        let roomJid = XMPPJID.jidWithString("\(roomID)@\(vHostRoom)")
        
        _xmppRoomOwnerMe = ownerMe
        if _xmppRoom != nil && _xmppRoom?.roomJID.user == roomJid.user && _xmppRoomCreateSuccess == true {
            //已经创建过了的房间
            createChatRoomBlock(isSuccess: true, faildMsg: nil)
            return
        }
        
        _xmppRoomCreateSuccess = false
        _createChatRoomBlock = nil
        _createChatRoomBlock = createChatRoomBlock
        
        _xmppRoom = XMPPRoom(roomStorage: _xmppRoomStorage, jid: roomJid, dispatchQueue: dispatch_get_main_queue())
        
        _xmppRoom?.activate(_xmppStream)
        _xmppRoom?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        //默认自己肯定加入房间，同时要加入房间才能收到房间建立成功的回调
        self.joinNowChatRoom(_userId!)
    }
    
    /**
     加入聊天室
     - parameter nickName: 聊天室内的个人昵称
     */
    func joinNowChatRoom(nickName: String) {
        _xmppRoom!.joinRoomUsingNickname(nickName, history: nil)
    }
    
    /**
     邀请新人进入聊天室
     - parameter friendId: 好友ID（通常只能邀请自己的好友）
     */
    func inviteUserToChatRoom(friendId: String) {
        let friendJidString = self.getChatJidString(friendId)
        let friendJID = XMPPJID.jidWithString(friendJidString)
        _xmppRoom!.inviteUser(friendJID, withMessage: "\(_userId!)邀请您加入群")
        
        /*
         聊天室也就是群聊，不过有一些业务权限上的区别，XMPP里面的聊天室是比较传统的聊天室业务，权限有：
         拥有者 owner, 管理员：admin, 成员：member, 黑名单：outcast,游客：none（默认被邀请者为游客）
         创建房间的人，默认就会成为owner，当owner邀请新用户加入房间时，如果不指定角色，默认为游客
         房间拥有者可以改变房间配置、授予用户所有权和管理权限以及毁掉此房间。房间管理员可以禁止或授予用户权限和新的管理员权限。房间成员仅能允许用户加入房间（如果该房间配置为仅对成员开放）。同时房间被排除者是已禁止进入该房间的用户。XMPP中所说的主持人角色包括owner和admin，详见http://xmpp.org/extensions/xep-0045.html#associations
         以上角色通过邀请时指定Affiliation来实现，如设置被邀请者的Affiliation为member表示给此被邀请用户成员角色
         注意：只有owner和admin才有查询房间所有角色名单的权限，所以根据需求这里我们给被邀请者admin权限, 所有人都是主持人，但只有拥有者才可以销毁房间
         */
        //        _xmppRoom!.editRoomPrivileges([XMPPRoom.itemWithRole("moderator", jid: friendJID)])
        _xmppRoom!.editRoomPrivileges([XMPPRoom.itemWithAffiliation("admin", jid: friendJID)])
    }
    
    //通过请求获取当前群的所有主持人，带回调
    func fetchModeratorsList(getChatRoomModeratorsBlock: LGXMPP_GetChatRoomModeratorsBlock) {
        _getChatRoomModeratorsBlock = getChatRoomModeratorsBlock
        _xmppRoom!.fetchModeratorsList()
    }
    
    //参赛过请求获取当前群的所有主持人,不带回调
    func fetchModeratorsListNoBlock() {
        _xmppRoom!.fetchModeratorsList()
    }
    
    /**
     获取群内所有人的userid清单（即jid的user）
     */
    func getRoomAllOccupantsList() -> [String]? {
        if _xmppRoomStorage.occupants() == nil{
            return nil
        }
        var idArray = [String]()
        for occupantStorageObject in _xmppRoomStorage.occupants(){
            let jidString = occupantStorageObject.realJID().user
            idArray.append(jidString)
        }
        return idArray
    }
    /**
     离开当前房间
     */
    func levaRoom() {
        
        if _xmppRoom != nil{
            //如果是自己创建的房间，直接销毁此房间
            if _xmppRoomOwnerMe{
                _xmppRoom?.destroyRoom()
                
            }
            else{
                _xmppRoom!.leaveRoom()
            }
            _inChatRoom = false
        }
    }
    
    // MARK:  --------------------------------  聊天室回调 -- 状态 -------------------------------
    func xmppRoomDidCreate(sender: XMPPRoom!) {
        
        DPrintln("房间创建成功 \(sender)")
        
        //设置房间默认配置属性
        _xmppRoom!.configureRoomUsingOptions(nil)
        
        
        _xmppRoomCreateSuccess = true
        if _createChatRoomBlock != nil{
            _createChatRoomBlock!(isSuccess: true, faildMsg: nil)
            _createChatRoomBlock = nil
        }
    }
    
    
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        DPrintln("加入房间成功\(sender)")
        
        _inChatRoom = true
        
        //当加入已创建聊天室时，不会回调xmppRoomDidCreate，所以在此进行回调处理
        _xmppRoomCreateSuccess = true
        if _createChatRoomBlock != nil{
            _createChatRoomBlock!(isSuccess: true, faildMsg: nil)
            _createChatRoomBlock = nil
        }
    }

    
    func xmppRoomDidLeave(sender: XMPPRoom!) {
        DPrintln("退出房间成功\(sender)")
        _xmppRoom = nil
    }
    
    func xmppRoomDidDestroy(sender: XMPPRoom!) {
        DPrintln("房间已经销毁\(sender)")
        _xmppRoom = nil
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        DPrintln("有新人加入房间\(occupantJID)")
 
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidLeave occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        DPrintln("有新人离开房间\(occupantJID)")
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidUpdate occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        DPrintln("房间有人更新了个人状态\(occupantJID)")
    }
    
    
     // MARK:  --------------------------------  聊天室回调 -- 信息查询  -------------------------------
    func xmppRoom(sender: XMPPRoom!, didFetchBanList items: [AnyObject]!) {
        DPrintln("收到本群/房间 禁止人员 名单 \(items)")
    }
    
    func xmppRoom(sender: XMPPRoom!, didFetchMembersList items: [AnyObject]!) {
        DPrintln("收到本群/房间 所有成员角色名单 \(items)")
 
    }
    
    func xmppRoom(sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
        DPrintln("获取到了聊天室配置属性\(configForm)")
    }
    
    /*
     [<item role="moderator" jid="haha@jamieimac.local/9w9fsn0pcb" nick="haha" affiliation="admin"/>, <item role="moderator" jid="mina@jamieimac.local/4i64wzvltf" nick="Mina" affiliation="owner"/>]
     */
    func xmppRoom(sender: XMPPRoom!, didFetchModeratorsList items: [AnyObject]!) {
        DPrintln("收到本群/房间 主持人员/管理人员  名单 \(items)")
//        //查询为空时，很可能是需要延时才能获取到信息,可以间隔几秒后再去获取
//        if items.count == 0 && _getChatRoomModeratorsBlock != nil{
//            self.performSelector(#selector(LGXMPPManager.fetchModeratorsListNoBlock), withObject: nil, afterDelay: 0.5)
//            return
//        }
        if _getChatRoomModeratorsBlock != nil{
            _getChatRoomModeratorsBlock!(membersList: items, faildMsg: nil)
            _getChatRoomModeratorsBlock = nil
        }
    }
    
    func xmppRoom(sender: XMPPRoom!, didNotFetchBanList iqError: XMPPIQ!) {
        DPrintln("查询失败，无法收到本群/房间 禁止人员 名单")
    }
    
    func xmppRoom(sender: XMPPRoom!, didNotFetchMembersList iqError: XMPPIQ!) {
        DPrintln("查询失败，无法收到本群/房间 所有人员 名单")
    }
    
    func xmppRoom(sender: XMPPRoom!, didNotFetchModeratorsList iqError: XMPPIQ!) {
        DPrintln("查询失败，无法收到本群/房间 主持人员/管理人员  名单")
    }
    
    // MARK:  --------------------------------  聊天室回调 -- 收到信息  -------------------------------
    func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
        DPrintln("收到信息, 来自房间 \(sender), 内容：\(message) ）")
        
        let messageString = message.stringValue()
        
        //群聊时要将自己的信息排除，因为发出去的信息还会回传给自己
        let fromID = occupantJID.full().lastPathComponent
        if !messageString.isEmpty && fromID.lowercaseString != _userId?.lowercaseString{
            
            let newMessage = self.getXHMessageFromXMPPMessage(message, messageSender: message.from().full(), isUserSendMessage: false, isHistory: false)
            //同1对1接收消息一样，走同样的通知
            NSNotificationCenter.defaultCenter().postNotificationName(kXMPPNewMessage, object: newMessage, userInfo: nil)
        }
        else{
            DPrintln("收到其它类型消息/非正常消息/回执等")
        }
    }
     // MARK:  --------------------------------  聊天室回调 -- XMPPMUCDelegate  ------------------------------
    /*
 <message xmlns="jabber:client" from="mina_room@conference.127.0.0.1" to="haha@127.0.0.1"><x xmlns="http://jabber.org/protocol/muc#user"><invite from="mina@127.0.0.1"><reason>Optional("Mina")邀请您加入群Optional("Mina")</reason></invite></x><x xmlns="jabber:x:conference" jid="mina_room@conference.127.0.0.1"/></message>
 */
    func xmppMUC(sender: XMPPMUC!, roomJID: XMPPJID!, didReceiveInvitation message: XMPPMessage!) {
        DPrintln("收到聊天室邀请")

        let roomName = message.attributeForName("from").stringValue()
        let x = message.elementForName("x") as DDXMLElement
        let invite = x.elementForName("invite")
        let fromUser = invite.attributeForName("from").stringValue()
        let reason = invite.elementForName("reason").stringValue()
        
        _xmppRoomJid = roomJID  //记录要进入的房间id
        let alert = UIAlertView(title: "来自\(fromUser)的聊天室邀请", message: "\(reason)，是否加入\(roomName)?", delegate: self, cancelButtonTitle: "拒绝", otherButtonTitles: "加入")
        alert.tag = vJoinGroupAlertTag
        alert.show()
    }
    
    
    // MARK:  ---------------- UIAlertView delegate -----------------
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        DPrintln("check index = \(buttonIndex)")
        if alertView.tag == vAddFriendAlertTag{
            if buttonIndex == 1{
                DPrintln("同意添加好友")
                _xmppRoster.acceptPresenceSubscriptionRequestFrom(_addMeJid!, andAddToRoster: true)
                _addMeJid = nil
            }else{
                DPrintln("拒接好友申请")
                _xmppRoster.rejectPresenceSubscriptionRequestFrom(_addMeJid!)
                _addMeJid = nil
            }
        }else if alertView.tag == vJoinGroupAlertTag{
            if buttonIndex == 1{
                DPrintln("同意加入群")
                if _inChatRoom == true && _xmppRoom != nil{
                    //或者此处让用户选择直接退出当前房间的逻辑也可
                    Tools.shared.showAlertViewAndDismissDefault("请先退出当前房间", message: "同一时刻你只能加入一个房间")
                    return
                }
                
                weak var weakSelf = self
                //创建此群对象及相关代理
                self.createChatRoom(_xmppRoomJid!.user, ownerMe: false, createChatRoomBlock: { (isSuccess, faildMsg) in
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if isSuccess{
                            //以通知的方式将房间完整jid传给对应的界面去跳转或刷新UI
                            //需要群人员清单时通过上面的getRoomAllOccupantsList()方法获取
                            NSNotificationCenter.defaultCenter().postNotificationName("joinChatRoom", object: weakSelf!._xmppRoomJid!.bareJID().full(), userInfo: nil)
                        }
                    })
                })
            }else{
                DPrintln("")
            }
        }
    }
}

