//
//  ChatMessageTableViewController.swift
//  LG-Demo
//
//  Created by jamie on 16/7/7.QQ:2726786161
//  Copyright © 2016年 LG. All rights reserved.
//  聊天界面，单聊/群聊

let vOneTimeAddOldMessageCount = 10   //一次最多加载历史消息数

import UIKit

enum ConversationType {
    case OneToOne
    case Room
}

class ChatMessageTableViewController: XHMessageTableViewController, XHAudioPlayerHelperDelegate {

    var _clientIDs: NSArray!                             //群聊时用户名数组（不是完整的jidstring）
    //    var _oneToOneFriendID: String?                 //一对一聊天时对方的id
    //    var _roomID: String?                           //群聊时ID
    var _receiveID: String!                              //聊天对方id，当为聊天室时是房间的id
    
    var _conversationType = ConversationType.OneToOne
    var _emotionManagers: NSArray!  // 表情组
    var _currentSelectedCell: XHMessageTableViewCell?    //选择的cell
    
    var _getOldMessageSuccess = false
    
    var _popMenuItemArray: [XHPopMenuItem]?
    
    /**
     单人聊天
     */
    init(oneToOneFriendID: String){
        super.init(nibName: nil, bundle: nil)
        
        _conversationType = ConversationType.OneToOne
        
        _receiveID = oneToOneFriendID
        self.title = oneToOneFriendID
        
        self.customUI()
    }
    
    /**
     聊天室聊天，好友列表可能还未获取到
     */
    init(clientIDs: NSArray?, roomName: String?, roomID: String){
        super.init(nibName: nil, bundle: nil)
        
        if clientIDs != nil{
            self._clientIDs = clientIDs
        }
        _receiveID = roomID
        _conversationType = ConversationType.Room
        if !NSString.isNilOrEmpty(roomName){
            self.title = roomName!
        } else if _clientIDs != nil{
            self.title = self.getGroupName(clientIDs!)
        }else{
            self.title = "群聊"
        }
        self.customUI()
    }
    
    func customUI() {
        // 配置输入框UI的样式
        self.allowsSendVoice = true
        self.allowsSendFace = true
        self.allowsSendMultiMedia = true
        
        self.keyboardViewHeight = (kISIpad() ? 264 : 216)
        self.allowsPanToDismissKeyboard = true
        self.inputViewStyle = XHMessageInputViewStyle.Flat
        
        self.delegate = self
        self.dataSource = self
        
        self.loadMoreActivityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
        
        // 设置自身jidstring
        self.messageSender = LGXMPPManager.shared._xmppStream.myJID.full()
        
        if _conversationType == .Room{
            let backString = LGXMPPManager.shared._xmppRoomOwnerMe ? "销毁聊天室" : "退出聊天室"
             self.navigationItem.leftBarButtonItem = Tools.createRightBarButtonItem(backString, target: self, selector: #selector(ChatMessageTableViewController.dismiss), imageName: nil)
            self.navigationItem.rightBarButtonItem = Tools.createRightBarButtonItem("群成员", target: self, selector: #selector(ChatMessageTableViewController.showMenu(_:)), imageName: nil)
        }
       
        // 添加第三方接入数据------------
        let plugIcons = ["sharemore_pic", "sharemore_video", "sharemore_location", "sharemore_videovoip", "sharemore_friendcard", "sharemore_myfav", "sharemore_wxtalk", "sharemore_voiceinput", "sharemore_openapi", "sharemore_openapi"]
        let plugTitle = ["照片", "拍摄", "位置", "视频", "名片", "我的收藏", "实时对讲机", "语音输入", "大众点评", "应用"]
        
        let shareMenuItems = NSMutableArray(capacity: 32)
        for plugIcon in plugIcons{
            let shareMenuItem = XHShareMenuItem(normalIconImage: UIImage(named: plugIcon), title: plugTitle[plugIcons.indexOf(plugIcon)!])
            shareMenuItems.addObject(shareMenuItem)
        }
        self.shareMenuItems = shareMenuItems as [AnyObject]
        self.shareMenuView.reloadData()
        
        // 添加表情 ------------
        let emotionManagers = NSMutableArray(capacity: 32)
        //4组表情
        for i in 0...3 {
            let emotionManager = XHEmotionManager()
            emotionManager.emotionName = "表情\(i)"
            
            let emotions = NSMutableArray(capacity: 32)
            //一组16张
            for j in 0..<16 {
                
                let emotion = XHEmotion()
                emotion.emotionConverPhoto = UIImage(named: "section\(i)_emotion\(j)")
                emotion.emotionPath = NSBundle.mainBundle().pathForResource("emotion\(j)", ofType: "gif")
                emotions.addObject(emotion)
            }
            emotionManager.emotions = emotions
            emotionManagers.addObject(emotionManager)
        }
        
        self._emotionManagers = emotionManagers
        self.emotionManagerView.reloadData()
        
        //先获取聊天记录
        self.loadMoreMessagesScrollTotop()
        
        //给tableview加点击事件
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatMessageTableViewController.hideKeyBoard))
        self.messageTableView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.cancelsTouchesInView = false      //不影响原本事件
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //增加新消息监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageTableViewController.receiveANewMessage), name: kXMPPNewMessage, object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        XHAudioPlayerHelper.shareInstance().stopAudio()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kXMPPNewMessage, object: nil)
    }

    deinit{
        _emotionManagers = nil
        _clientIDs = nil
        _receiveID = nil
        _popMenuItemArray = nil
        _currentSelectedCell = nil
        
        XHAudioPlayerHelper.shareInstance().setDelegate(nil)
    }
    
    
     // MARK: ------------------- user action-----------------------
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            LGXMPPManager.shared.levaRoom()
        })
    }
    
    func getGroupName(idArray: NSArray) -> String {
        var groupName = ""
        for oneId in idArray{
            groupName += "、\(oneId)"
        }
        return groupName
    }
    
    func hideKeyBoard() {
        self.messageInputView.inputTextView.resignFirstResponder()
    }
    
    func setRoomIDList(roomIDList: NSArray?)  {
        if roomIDList == nil || roomIDList?.count == 0{
            return
        }
        //如果是被邀请者应该把自己除重，来避免自己和自己聊天的情况
        _clientIDs = roomIDList
        self.navigationItem.rightBarButtonItem = Tools.createRightBarButtonItem("群成员", target: self, selector: #selector(ChatMessageTableViewController.showMenu(_:)), imageName: nil)
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
            let titleArray = _clientIDs
            for i in 0..<_clientIDs.count {
                let popMenuItem = XHPopMenuItem(title: titleArray[i] as! String, image: UIImage(named: "contacts_add_friend")!, target: self, action: #selector(ChatMessageTableViewController.startOneToOneChat(_:)))
                _popMenuItemArray!.append(popMenuItem)
            }
        }
    }
    
    func startOneToOneChat(popMenuItem: XHPopMenuItem) {
        let chatMessageVC = ChatMessageTableViewController(oneToOneFriendID: popMenuItem.title)
        self.navigationController?.pushViewController(chatMessageVC, animated: true)
    }

    
    // MARK: --------------- 聊天记录  ---------------
    /**
     获取所有的聊天记录
     
     - parameter loadFinish: 读取完成的回调
     */
    func loadDataSourceMessage(loadFinish:([XHMessage]?)->Void) {
        weak var weakSelf = self
        LGXMPPManager.shared.getMessageList(_receiveID, getMessageListBlock: { (messageList, faildMsg) in
            if messageList != nil{
                //                dispatch_async(dispatch_get_main_queue(), {
                //                    weakSelf?.insertOldMessages(messageList!)
                //                })
                weakSelf?._getOldMessageSuccess = true
                return loadFinish(messageList)
                
            } else if faildMsg != nil{
                Tools.shared.showAlertViewAndDismissDefault("获取聊天记录失败", message: faildMsg!)
            }else{
                DPrintln("聊天记录为空")
                weakSelf?._getOldMessageSuccess = true
            }
            
            return loadFinish(nil)
        })
    }
    
    // MARK: --------------- 新消息  ---------------
    /**
     收到一个消息回复
     */
    func receiveANewMessage(notific: NSNotification) {
        if let newMessage = notific.object as? XHMessage{
            if LGXMPPManager.shared.getChatUserId(newMessage.sender).lowercaseString == LGXMPPManager.shared.getChatUserId(_receiveID).lowercaseString{
                newMessage.avatar = UIImage(named: "_App_Icons")
                newMessage.avatarUrl = "http://lorempixel.com/400/200/"
                if _conversationType == .Room{
                    newMessage.sender = newMessage.sender.lastPathComponent
                    newMessage.shouldShowUserName = true
                    
                }
                
                if newMessage.messageMediaType != XHBubbleMessageMediaType.Voice{
                    self.addMessage(newMessage)
                    return
                }else{
                    //语音内容先下载，再显示
                    self.receiveANewVoiceMessage(newMessage)
                }
            }
        }
    }
    
    
    func receiveANewVoiceMessage(newMessage: XHMessage){
        let resultPath = LGTXCloudManager.shared.getFilePathFromURLString(newMessage.voiceUrl, typeString: "file")
        if NSFileManager.defaultManager().fileExistsAtPath(resultPath){
            newMessage.voicePath = resultPath
            self.addMessage(newMessage)
            return
        }else {
            LGTXCloudManager.shared.downloadFile(newMessage.voiceUrl, sign: kTXCloud_File_Secret_ManyTime, sucessResult: { (theResultString) in
                newMessage.voicePath = theResultString as! String
                self.addMessage(newMessage)
                }, faildMsg: { (errMsg) in
                    DPrintln("有消息接收失败，\(errMsg)")
            })
        }
    }
    
    // MARK: --------------- XHMessageTableViewCell Delegate  ---------------
    override func multiMediaMessageDidSelectedOnMessage(message: XHMessageModel!, atIndexPath indexPath: NSIndexPath!, onMessageTableViewCell messageTableViewCell: XHMessageTableViewCell!) {
        DPrintln("点击了多媒体消息")
        var displayVC: UIViewController!
        switch message.messageMediaType() {
        case .Video:
            DPrintln("视频")
            displayVC = XHDisplayMediaViewController()
            (displayVC as! XHDisplayMediaViewController).message = message
        case .Photo:
            DPrintln("图片")
            displayVC = XHDisplayMediaViewController()
            (displayVC as! XHDisplayMediaViewController).message = message
        case .Voice:
            DPrintln("语音")
            //先消除未读标志
            message.setIsRead!(true)
            messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = true
            (XHAudioPlayerHelper.shareInstance() as! XHAudioPlayerHelper).delegate = self
            //暂停其它播放
            if _currentSelectedCell != nil{
                _currentSelectedCell?.messageBubbleView.animationVoiceImageView.stopAnimating()
            }
            //如果是重复点击自己，暂停播放，否则开始播放
            if _currentSelectedCell == messageTableViewCell{
                messageTableViewCell.messageBubbleView.animationVoiceImageView.stopAnimating()
                XHAudioPlayerHelper.shareInstance().stopAudio()
                _currentSelectedCell = nil
            } else {
                _currentSelectedCell = messageTableViewCell
                messageTableViewCell.messageBubbleView.animationVoiceImageView.startAnimating()
                //                let theVoicePath = message.voicePath() ?? message.voiceUrl()  //最好先下载到本地再播放，所以不使用url方式
                XHAudioPlayerHelper.shareInstance().managerAudioWithFileName(message.voicePath(), toPlay: true)
            }
        case .Emotion:
            DPrintln("表情 \(message.emotionPath())")
        case .LocalPosition:
            DPrintln("定位信息 \(message.location())")
            displayVC = XHDisplayLocationViewController()
            (displayVC as! XHDisplayLocationViewController).message = message
        default:
            break
        }
        
        if displayVC != nil{
            self.navigationController?.pushViewController(displayVC!, animated: true)
        }
    }
    
    override func didDoubleSelectedOnTextMessage(message: XHMessageModel!, atIndexPath indexPath: NSIndexPath!) {
        DPrintln("双击文字信息 text: \(message.text())")
        let displayVC = XHDisplayTextViewController()
        displayVC.message = message
        self.navigationController?.pushViewController(displayVC, animated: true)
    }
    
    override func didSelectedAvatarOnMessage(message: XHMessageModel!, atIndexPath indexPath: NSIndexPath!) {
        DPrintln("点击了会话者的头像 \(message.sender!())")
        DPrintln("可以跳转至会话者资料信息页")
        //        XHContact *contact = [[XHContact alloc] init];
        //        contact.contactName = [message sender];
        //        contact.contactIntroduction = @"自定义描述，这个需要和业务逻辑挂钩";
        //        XHContactDetailTableViewController *contactDetailTableViewController = [[XHContactDetailTableViewController alloc] initWithContact:contact];
        //        [self.navigationController pushViewController:contactDetailTableViewController animated:YES]
    }
    
    override func menuDidSelectedAtBubbleMessageMenuSelecteType(bubbleMessageMenuSelecteType: XHBubbleMessageMenuSelecteType) {
        DPrintln("点击了附件")
    }
    
    
    
    // MARK: --------------- XHAudioPlayerHelper Delegate  ---------------
    func didAudioPlayerStopPlay(audioPlayer: AVAudioPlayer!) {
        if _currentSelectedCell == nil{
            return
        }
        _currentSelectedCell?.messageBubbleView.animationVoiceImageView.stopAnimating()
        _currentSelectedCell = nil
    }
    
    // MARK: --------------- XHEmotionManagerView Delegate  ---------------
    override func numberOfEmotionManagers() -> Int {
        return _emotionManagers.count
    }
    
    override func emotionManagerForColumn(column: Int) -> XHEmotionManager! {
        return _emotionManagers.objectAtIndex(column) as! XHEmotionManager
    }
    
    // MARK: --------------- XHMessageTableViewController Delegate  ---------------
    override func shouldLoadMoreMessagesScrollToTop() -> Bool {
        DPrintln("是否还能加载更多信息")
        if (_getOldMessageSuccess == false) && self.loadingMoreMessage == false
        {
            //还未查询成功且还没开始查询
            return true
        }
        return false
    }
    
    override func loadMoreMessagesScrollTotop() {
        weak var weakSelf = self
        if self.loadingMoreMessage == false{
            self.loadingMoreMessage = true
            
            self.loadDataSourceMessage({ (oldMessageList) in
                if oldMessageList == nil || oldMessageList?.count == 0{
                    self.loadingMoreMessage = false
                    return
                }
                
                let oldMessageArray = NSMutableArray(array: oldMessageList!)
                weakSelf?.dealWithOldMessage(oldMessageArray)
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf?.insertOldMessages(oldMessageArray as [AnyObject])
                })
                self.loadingMoreMessage = false
            })
            
            
        }
    }
    
    func dealWithOldMessage(oldMessageList: NSMutableArray){
        if self.messages.count == 0{
            return
        }
        let firstMessageNow = self.messages.firstObject as! XHMessage
        var i = oldMessageList.count
        while i - 1 >= 0 {
            let oldMessage = oldMessageList.objectAtIndex(i - 1) as! XHMessage
            if oldMessage.timestamp.timeIntervalSince1970 >= firstMessageNow.timestamp.timeIntervalSince1970{
                oldMessageList.removeObjectAtIndex(i - 1)
            }else{
                break
            }
            i -= 1
        }
    }
    
    //    func addOldMessage(){
    //        if _oldMessageArray == nil || _oldMessageArray?.count == 0{
    //            return
    //        }
    //        if _oldMessageArray?.count > vOneTimeAddOldMessageCount
    //        {
    //            var tempArray = [XHMessage]()
    //            for _ in 0..<vOneTimeAddOldMessageCount{
    //                tempArray.append(_oldMessageArray![0])
    //                _oldMessageArray?.removeAtIndex(0)
    //            }
    //            self.insertOldMessages(tempArray)
    //        }else{
    //            self.insertOldMessages(_oldMessageArray)
    //        }
    //    }
    
    /**
     *  发送文本消息的回调方法
     *
     *  @param text   目标文本字符串
     *  @param sender 发送者的名字
     *  @param date   发送时间
     */
    override func didSendText(text: String!, fromSender sender: String!, onDate date: NSDate!) {
        let textMessage = XHMessage(text: text, sender: sender, timestamp: date)
        textMessage.avatar = UIImage(named: "_App_Icons")
        textMessage.avatarUrl = "http://lorempixel.com/400/200/"
        self.addMessage(textMessage)
        
        LGXMPPManager.shared.sendMessage(XHBubbleMessageMediaType.Text, messageURL: nil, messageText: text, otherMessage: nil, receiveId: _receiveID, isRoomChat: _conversationType == .Room, sendMessageBlock: { (isSucess, faildMsg) in
            if isSucess == true{
                DPrintln("发送成功")
                self.finishSendMessageWithBubbleMessageType(XHBubbleMessageMediaType.Text)
            }else{
                Tools.shared.showAlertViewAndDismissDefault("发送失败", message: faildMsg)
                self.removeMessageAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0))
            }
        })
        
        
    }
    
    
    /**
     *  发送图片消息的回调方法
     *
     *  @param photo  目标图片对象，后续有可能会换
     *  @param sender 发送者的名字
     *  @param date   发送时间
     */
    override func didSendPhoto(photo: UIImage!, fromSender sender: String!, onDate date: NSDate!) {
        let photoMessage = XHMessage(photo: photo, thumbnailUrl: nil, originPhotoUrl: nil, sender: sender, timestamp: date)
        photoMessage.avatar = UIImage(named: "_App_Icons")
        photoMessage.avatarUrl = "http://lorempixel.com/400/200/"
        self.addMessage(photoMessage)
        
        weak var weakSelf = self
        LGTXCloudManager.shared.uploadImageWithData(UIImageJPEGRepresentation(photo, 0.8)!, fileName: "photo_\(date.timeIntervalSince1970)", sign: kTXCloud_Pic_Secret_ManyTime, bucket: kTXCloud_Pic_Bucket, expiredDate: nil, msgContext: sender, fileId: "photo_\(date.timeIntervalSince1970)", sucessResult: { (photoURLString) in
            if weakSelf != nil{
                LGXMPPManager.shared.sendMessage(XHBubbleMessageMediaType.Photo, messageURL: photoURLString as? String, messageText: nil, otherMessage: nil, receiveId: weakSelf!._receiveID,isRoomChat: weakSelf!._conversationType == .Room, sendMessageBlock: { (isSucess, faildMsg) in
                    if isSucess == true{
                        DPrintln("发送成功")
                        self.finishSendMessageWithBubbleMessageType(XHBubbleMessageMediaType.Text)
                    }else{
                        Tools.shared.showAlertViewAndDismissDefault("发送失败", message: faildMsg)
                        self.removeMessageAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0))
                    }
                })
            }
        }) { (faildMsg) in
            Tools.shared.showAlertViewAndDismissDefault("发送失败", message: faildMsg)
            self.removeMessageAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0))
            
        }
        
        //        self.finishSendMessageWithBubbleMessageType(XHBubbleMessageMediaType.Photo)
    }
    
    
    /**
     *  发送视频消息的回调方法
     *
     *  @param videoPath 目标视频本地路径
     *  @param sender    发送者的名字
     *  @param date      发送时间
     */
    override func didSendVideoConverPhoto(videoConverPhoto: UIImage!, videoPath: String!, fromSender sender: String!, onDate date: NSDate!) {
        let videoMessage = XHMessage(videoConverPhoto: videoConverPhoto, videoPath: videoPath, videoUrl: nil, sender: sender, timestamp: date)
        videoMessage.avatar = UIImage(named: "_App_Icons")
        videoMessage.avatarUrl = "http://lorempixel.com/400/200/"
        self.addMessage(videoMessage)
        self.finishSendMessageWithBubbleMessageType(XHBubbleMessageMediaType.Video)
    }
    
    
    /**
     *  发送语音消息的回调方法
     *
     *  @param voicePath        目标语音本地路径
     *  @param voiceDuration    目标语音时长
     *  @param sender           发送者的名字
     *  @param date             发送时间
     */
    override func didSendVoice(voicePath: String!, voiceDuration: String!, fromSender sender: String!, onDate date: NSDate!) {
        let voiceMessage = XHMessage(voicePath: voicePath, voiceUrl: nil, voiceDuration: voiceDuration, sender: sender, timestamp: date)
        voiceMessage.avatar = UIImage(named: "_App_Icons")
        voiceMessage.avatarUrl = "http://lorempixel.com/400/200/"
        self.addMessage(voiceMessage)
        weak var weakSelf = self
        
        LGTXCloudManager.shared.uploadFile(voicePath, sign: kTXCloud_File_Secret_ManyTime, bucket: kTXCloud_File_Bucket, fileName: "\(voicePath.lastPathComponent)", attrs: "voice", directory: "/Voice", insertOnly: true ,sucessResult: { (voiceURLString) in
            if weakSelf != nil{
                LGXMPPManager.shared.sendMessage(XHBubbleMessageMediaType.Voice, messageURL: voiceURLString as? String, messageText: nil, otherMessage: "\(voiceDuration)", receiveId: weakSelf!._receiveID, isRoomChat: weakSelf!._conversationType == .Room, sendMessageBlock: { (isSucess, faildMsg) in
                    if isSucess == true{
                        DPrintln("发送成功")
                        self.finishSendMessageWithBubbleMessageType(XHBubbleMessageMediaType.Text)
                    }else{
                        Tools.shared.showAlertViewAndDismissDefault("发送失败", message: faildMsg)
                        self.removeMessageAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0))
                    }
                })
            }
        }) { (faildMsg) in
            Tools.shared.showAlertViewAndDismissDefault("发送失败", message: faildMsg)
            self.removeMessageAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0))
            
        }
    }
    
    
    /**
     *  发送第三方表情消息的回调方法
     *
     *  @param facePath 目标第三方表情的本地路径
     *  @param sender   发送者的名字
     *  @param date     发送时间
     */
    override func didSendEmotion(emotionPath: String!, fromSender sender: String!, onDate date: NSDate!) {
        let emotionMessage = XHMessage(emotionPath: emotionPath, sender: sender, timestamp: date)
        emotionMessage.avatar = UIImage(named: "_App_Icons")
        emotionMessage.avatarUrl = "http://lorempixel.com/400/200/"
        self.addMessage(emotionMessage)
        LGXMPPManager.shared.sendMessage(XHBubbleMessageMediaType.Emotion, messageURL: emotionPath.lastPathComponent, messageText: nil, otherMessage: nil, receiveId: _receiveID, isRoomChat: _conversationType == .Room, sendMessageBlock: { (isSucess, faildMsg) in
            if isSucess == true{
                DPrintln("发送成功")
                self.finishSendMessageWithBubbleMessageType(XHBubbleMessageMediaType.Text)
            }else{
                Tools.shared.showAlertViewAndDismissDefault("发送失败", message: faildMsg)
                self.removeMessageAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0))
            }
        })
        
    }
    
    /**
     发送位置
     */
    override func didSendGeoLocationsPhoto(geoLocationsPhoto: UIImage!, geolocations: String!, location: CLLocation!, fromSender sender: String!, onDate date: NSDate!) {
        let locationMessage = XHMessage(localPositionPhoto: geoLocationsPhoto, geolocations: geolocations, location: location, sender: sender, timestamp: date)
        locationMessage.avatar = UIImage(named: "_App_Icons")
        locationMessage.avatarUrl = "http://lorempixel.com/400/200/"
        self.addMessage(locationMessage)
        self.finishSendMessageWithBubbleMessageType(XHBubbleMessageMediaType.LocalPosition)
    }
    
    /**
     *  是否显示时间轴Label的回调方法
     *
     *  @param indexPath 目标消息的位置IndexPath
     *
     *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
     */
    override func shouldDisplayTimestampForRowAtIndexPath(indexPath: NSIndexPath!) -> Bool {
        if indexPath.row == 0 || indexPath.row >= self.messages.count{
            //如果为第一条消息，或此次对话的新消息，就标记时间
            return true
        } else if let message = self.messages.objectAtIndex(indexPath.row) as? XHMessage, let previousMessage = self.messages.objectAtIndex(indexPath.row - 1) as? XHMessage{
            //前后消息间隔超过3分钟时显示，否则不显示
            let interval = message.timestamp.timeIntervalSinceDate(previousMessage.timestamp)
            if interval > 60 * 3{
                return true
            }
        }
        return false
        
    }
    
    /**
     *  配置Cell的样式或者字体
     *
     *  @param cell      目标Cell
     *  @param indexPath 目标Cell所在位置IndexPath
     */
    override func configureCell(cell: XHMessageTableViewCell!, atIndexPath indexPath: NSIndexPath!) {
        
    }
    
    /**
     *  协议回掉是否支持用户手动滚动
     *
     *  @return 返回YES or NO
     */
    override func shouldPreventScrollToBottomWhileUserScrolling() -> Bool {
        return true
    }
    
}


