//
//  EnviromentGlobal.swift
//  LG-Demo
//
//  Created by jamie on 15/5/21.QQ:2726786161
//  Copyright (c) 2015年 LG. All rights reserved.
//  环境总配置（不包括网络环境的相关配置，网络配置文件 -> Urls.plist）

import Foundation

/// 环境总开关 0:生产   1:测试    2:自己的环境等
let ENVIRENTMENT = 1                   //注意：！！！发布时必须为 0

/// 客户端版本管理开关   false:关闭版本管理 true:开启版本管理
let CLIENT_VERSION_MANAGER = true

/// 本地缓存管理开关    false:关闭本地缓存 true:开启本地缓存
let CACHE_MANAGER = true

/// 消息推送管理开关    false:关闭消息推送 true:开启消息推送
let MESSAGE_PUSH_MANAGER = true

/// 埋点管理开关       false:关闭埋点 true:开启埋点
let MA_POINT_MANAGER = true

/**
日志打印
*/
func DPrintln(str:String) {
    if ENVIRENTMENT != 0 {
        print(str)
    }
    else {
    }
}


