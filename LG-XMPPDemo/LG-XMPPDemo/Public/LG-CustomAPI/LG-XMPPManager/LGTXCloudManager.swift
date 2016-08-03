//
//  LGTXCloudManager.swift
//  LG-Demo
//
//  Created by jamie on 16/7/13.QQ:2726786161
//  Copyright © 2016年 LG. All rights reserved.
//  腾讯云存储 管理类封装，腾讯云存储服务：https://www.qcloud.com/product/cos.html

import UIKit

class LGTXCloudManager: NSObject {
    
    var _uploadFileManager: TXYUploadManager!
    var _uploadImageManager: TXYUploadManager!
    var _uploadVideoManager: TXYUploadManager!
    
    var _fileTask: TXYFileUploadTask?
    var _imageTask: TXYPhotoUploadTask?
    var _videoTask: TXYVideoUploadTask?
    
    
    var _downloadFileManager: TXYDownloader!
    var _downloadImageManager: TXYDownloader!
    var _downloadVideoManager: TXYDownloader!
    
    
    // MARK: -  单例  **********
    ///单例
    class var shared: LGTXCloudManager {
        dispatch_once(&Inner.token) {
            Inner.instance = LGTXCloudManager()
            Inner.instance!.managerInit()
        }
        return Inner.instance!
    }
    
    struct Inner {
        static var instance: LGTXCloudManager?
        static var token: Int = 0
    }
    
    func managerInit() {
        _uploadFileManager = TXYUploadManager(cloudType: TXYCloudType.ForFile, persistenceId: "LGTXCloudFileUploadManager", appId: "\(kTXCloud_ID)")
        _uploadImageManager = TXYUploadManager(cloudType: TXYCloudType.ForImage, persistenceId: "LGTXCloudImageUploadManager", appId: "\(kTXCloud_ID)")
        _uploadVideoManager = TXYUploadManager(cloudType: TXYCloudType.ForVideo, persistenceId: "LGTXCloudVideoUploadManager", appId: "\(kTXCloud_ID)")
        
        _downloadFileManager = TXYDownloader(persistenceId: "LGTXCloudFileDownloadManager", type: TXYDownloadType.File)
        _downloadImageManager = TXYDownloader(persistenceId: "LGTXCloudImageDownloadManager", type: TXYDownloadType.Photo)
        _downloadVideoManager = TXYDownloader(persistenceId: "LGTXCloudVideoDownloadManager", type: TXYDownloadType.Video)
        
    }
    
    // MARK: --------------- 上传  ---------------
    /**
     上传文件
     
     - parameter filePath:   文件路径
     - parameter sign:       签名
     - parameter bucket:     目标bucket名称
     - parameter fileName:   上传成功后cos上显示的名称（控制台上显示的名称）
     - parameter attrs:      文件自定义属性
     - parameter directory:  文件上传目录，相对路径，如“/path”
     - parameter insertOnly: yes时，不覆盖之前上传的同名文件
     */
    func uploadFile(filePath: String, sign: String, bucket: String, fileName: String, attrs: String?, directory: String, insertOnly: Bool, sucessResult: (AnyObject -> Void)?, faildMsg: (String? -> Void)?) {
        
        _fileTask = TXYFileUploadTask(path: filePath, sign: sign, bucket: bucket, fileName: fileName, customAttribute: attrs, uploadDirectory: directory, insertOnly: insertOnly)
        _uploadFileManager.upload(_fileTask!, complete: { (resp, dictionaryContext) in
            self._fileTask = nil    //单例所以不用担心循环引用
            
            let fileResp = resp as! TXYFileUploadTaskRsp
            if fileResp.retCode >= 0{
                let url = fileResp.sourceURL
                DPrintln("上传成功\(url)")
                if sucessResult != nil{
                    sucessResult!(url)
                }
    
            }else{
                DPrintln("上传失败\(fileResp.descMsg)")
                if faildMsg != nil{
                    faildMsg!(fileResp.descMsg)
                }
            }
            }, progress: { (totalSize, sendSize, dictionaryContext) in
                DPrintln("上传进度 = \(sendSize / totalSize)")
            }) { (state, dictionaryContext) in
                DPrintln("上传状态变化 \(state)")
        }
    
    }
    
    /**
     上传图片--URL方式
     * @param filePath 图片路径，必填
     * @param expiredDate 过期时间，选填
     * @param msgContext  通知用户业务后台的信息，选填
     * @param bucket 上传空间的名字
     * @param fileId 通过这个字段可以自定义url
     * @return TXYPhotoUploadTask实例
     */
    func uploadImageWithUrl(imagePath: String, sign: String, bucket: String, expiredDate: UInt32, msgContext: String?, fileId: String?, sucessResult: (AnyObject -> Void)?, faildMsg: (String? -> Void)?) {
        _imageTask = TXYPhotoUploadTask(path: imagePath, sign: sign, bucket: bucket, expiredDate: expiredDate, msgContext: msgContext, fileId: fileId)
        _uploadImageManager.upload(_imageTask!, complete: { (resp, dictionaryContext) in
            self._imageTask = nil    //单例所以不用担心循环引用
            
            let imageResp = resp as! TXYPhotoUploadTaskRsp
            if imageResp.retCode >= 0{
                let url = imageResp.photoURL
                DPrintln("上传成功\(url)")
                if sucessResult != nil{
                    sucessResult!(url)
                }
            }else{
                DPrintln("上传失败\(imageResp.descMsg)")
                if faildMsg != nil{
                    faildMsg!(imageResp.descMsg)
                }
            }
            }, progress: { (totalSize, sendSize, dictionaryContext) in
                DPrintln("上传进度 = \(sendSize / totalSize)")
        }) { (state, dictionaryContext) in
            DPrintln("上传状态变化 \(state)")
        }
        
    }
    
    
    /**
     上传图片--数据流方式
     
     * @param imageData 图片对象的数据，必填
     * @param fileName 文件名，必填
     * @param expiredDate 过期时间，选填
     * @param msgContext  通知用户业务后台的信息，选填
     * @param bucket 上传空间的名字
     * @param fileId 通过这个字段可以自定义url
     * @return TXYPhotoUploadTask实例
     */
    func uploadImageWithData(imageData: NSData, fileName: String, sign: String, bucket: String, expiredDate: UInt32?, msgContext: String?, fileId: String?, sucessResult: (AnyObject -> Void)?, faildMsg: (String? -> Void)?) {
        _imageTask = TXYPhotoUploadTask(imageData: imageData, fileName: fileName, sign: sign, bucket: bucket, expiredDate: expiredDate ?? 0, msgContext: msgContext, fileId: fileId)
        _uploadImageManager.upload(_imageTask!, complete: { (resp, dictionaryContext) in
            self._imageTask = nil    //单例所以不用担心循环引用
            
            let imageResp = resp as! TXYPhotoUploadTaskRsp
            if imageResp.retCode >= 0{
                let url = imageResp.photoURL
                DPrintln("上传成功\(url)")
                if sucessResult != nil{
                    sucessResult!(url)
                }
            }else{
                DPrintln("上传失败\(imageResp.descMsg)")
                if faildMsg != nil{
                    faildMsg!(imageResp.descMsg)
                }
            }
            }, progress: { (totalSize, sendSize, dictionaryContext) in
                DPrintln("上传进度 = \(sendSize / totalSize)")
        }) { (state, dictionaryContext) in
            DPrintln("上传状态变化 \(state)")
        }
        
    }
    
    /**
     上传视频
     
     * @param filePath 文件路径，必填
     * @param attrs 文件属性，选填
     * @param uploadDirectory 上传文件到哪个目录
     * @param videoInfo 视频信息
     * @param msgContext  通知用户业务后台的信息，选填
     * @return TXYFileUploadTask实例
     */
    func uploadVideo(path: String, sign: String, bucket: String, fileName: String, customAttribute: String?, uploadDirectory: String?, videoFileInfo: TXYVideoFileInfo?, msgContext: String?, insertOnly: Bool, sucessResult: (AnyObject -> Void)?, faildMsg: (String? -> Void)?) {
        _videoTask = TXYVideoUploadTask(path: path, sign: sign, bucket: bucket, fileName: fileName, customAttribute: customAttribute, uploadDirectory: uploadDirectory, videoFileInfo: videoFileInfo, msgContext: msgContext, insertOnly: insertOnly)
        _uploadVideoManager.upload(_videoTask!, complete: { (resp, dictionaryContext) in
            self._videoTask = nil    //单例所以不用担心循环引用
            
            let videoResp = resp as! TXYVideoUploadTaskRsp
            if videoResp.retCode >= 0{
                let url = videoResp.sourceURL
                DPrintln("上传成功\(url)")
                if sucessResult != nil{
                    sucessResult!(url)
                }
            }else{
                DPrintln("上传失败\(videoResp.descMsg)")
                if faildMsg != nil{
                    faildMsg!(videoResp.descMsg)
                }
            }
            }, progress: { (totalSize, sendSize, dictionaryContext) in
                DPrintln("上传进度 = \(sendSize / totalSize)")
        }) { (state, dictionaryContext) in
            DPrintln("上传状态变化 \(state)")
        }
        
    }
    
    // MARK: --------------- 下载  ---------------
    func downloadFile(url: String, sign: String, sucessResult: (AnyObject -> Void)?, faildMsg: (String? -> Void)?) {
        //公开读私有写，不然存储时麻烦，
        //        let fullUrl = url+"?sign="+sign
        _downloadFileManager.download(url, target: self, succBlock: { (theUrl, data, info) in
            
            let fileCachePath = info["filePath"] as! String
            let resultPath = self.getFilePathFromURLString(url, typeString: "file")
            DPrintln("下载成功,地址为 \(fileCachePath)")
            do {
                try NSFileManager.defaultManager().copyItemAtPath(fileCachePath, toPath:resultPath )
            }catch let error as NSError{
                DPrintln("拷贝已下载缓存失败 \(error)")
                if faildMsg != nil{
                    return faildMsg!(error.domain)
                }
            }
            if sucessResult != nil{
                return sucessResult!(resultPath)
            }
            
            }, failBlock: { (theUrl, error) in
                DPrintln("下载失败，\(error.code) + \(error.domain)）")
                if faildMsg != nil{
                    return faildMsg!(error.domain)
                }
            }, progressBlock: { (url, value) in
                DPrintln("下载进度， \(value)")
            }, param: ["TXYDownloaderParam" : TXYDownloaderParam.FIFO.rawValue]) // 先进先出
    }
    
    /**
     通过URL得到文件存储路径
     */
    func getFilePathFromURLString(url: String, typeString: String) -> String {
        let fileName = url.lastPathComponent
        let cacheDir = NSHomeDirectory().stringByAppendingPathComponent("Library/Caches/download\(typeString)/")
        if NSFileManager.defaultManager().fileExistsAtPath(cacheDir) == false {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(cacheDir, withIntermediateDirectories: true, attributes: nil)
            }catch let error {
                 DPrintln("创建文件夹失败 \(error)")
            }
        }
        return cacheDir.stringByAppendingPathComponent(fileName)
    }

}
