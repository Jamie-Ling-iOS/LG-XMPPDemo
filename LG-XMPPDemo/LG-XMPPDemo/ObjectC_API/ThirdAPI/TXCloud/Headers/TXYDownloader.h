//
//  TXYDownloader.h
//  QZDLSDK
//
//  Created by Tencent on 15/2/5.
//  Copyright (c) 2015年 Qzone. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @enum TXYDownloaderParam enum
 @abstract 下载请求中可以指定一些控制参数.
 */
typedef NS_ENUM(NSInteger, TXYDownloaderParam) {
    /*! 默认值,后进先出  */
    TXYDownloaderParamLIFO,
    /*! 任务队列正常情况是按照后进先出的优先级下载的，指定这个参数可以让任务采用先进先出的下载方式 */
    TXYDownloaderParamFIFO,
};

/*!
 @enum TXYDownloadType enum
 @abstract 下载的类型.
 */
typedef NS_ENUM(NSInteger, TXYDownloadType) {
    /*! 下载图片  */
    TXYDownloadTypePhoto,
    /*! 下载视频 */
    TXYDownloadTypeVideo,
    /*! 下载文件 */
    TXYDownloadTypeFile,
};
/*!
 * 腾讯云下载接口
 */

@interface TXYDownloader : NSObject


/*!
 * @brief 下载SDK的版本号
 */
+ (NSString *)version;
/*!
 * @brief 对应用程序的id,初始化一次即可
 * @param appId 应用程序id,必填
 * @param userId 用户id,选填
 * @return 成功返回YES，失败返回NO
 */
+ (BOOL)authorize:(NSString *)appId userId:(NSString *)userId;

/*!
 * @brief 获取设备唯一标示,可以通过设备标识来定位具体设备的问题
 * @return 返回设备唯一标示符
 */
+ (NSString *)getDeviceUniqueIdentifier;

/**
 *  @brief 把下载本地log给QCloud，遇到用户反馈的时候，可以帮助排查问题
 *
 *  @param beginDate 开始的日期，SDK只保持最多7天的日志，所以开始时间必须在当前日期7天之内。
 *  @param days     相对于开始日期，上传多少天的日志。最多不超过7天。
 *
 *  @note beginDate这个参数为nil，将会自动上传最近一天的日志，days被忽略
 */
+ (BOOL)uploadLogFromDate:(NSDate *)beginDate numOfdays:(NSUInteger)days;

/*!
 * @brief TXYDownloader构造函数
 * @param persistenceId 值不同表示缓存目录不同，为nil内部会自动创建一个缓存目录统一管理
 * @return TXYDownloader实例
 */
+ (instancetype)sharedInstanceWithPersistenceId:(NSString *)persistenceId type:(TXYDownloadType)type;

/*!
 * @brief TXYDownloader构造函数
 * @param persistenceId 值不同表示缓存目录不同，为nil内部会自动创建一个缓存目录统一管理
 * @return TXYDownloader实例
 */
- (instancetype)initWithPersistenceId:(NSString *)persistenceId type:(TXYDownloadType)type;

/*!
 * @brief 指定下载是否支持断点续传
 * @param enable YES表示支持，为NO表示不支持,默认为YES
 * @return 成功返回YES，失败返回NO
 */
- (void)enableHTTPRange:(BOOL)enable;

/*!
 * @brief 指定是否支持HTTP长连接
 * @param flag YES表示支持，为NO表示不支持,默认为YES
 * @return 成功返回YES，失败返回NO
 */
- (void)enableKeepAlive:(BOOL)enable;

/*!
 * @brief 指定下载队列的最大并发数
 * @param count 下载队列最大并发数,调用下载接口再修改则无效
 * @return 成功返回YES，失败返回NO
 */
- (void)setMaxConcurrent:(int)count;

/*!
 * @brief 指定下载数据超时时间
 * @param secs 超时时间，单位为秒
 * @return 成功返回YES，失败返回NO
 */
- (void)setTimeoutSeconds:(int)secs;

/*!
 * @brief 判断指定url数据对应的本地缓存路径是否存在
 * @param url 资源地址
 * @return 成功返回YES，失败返回NO
 */
- (BOOL)hasCache:(NSString *)url;

/*!
 * @brief 获取指定url的对应的二进制对象
 * @param url 资源地址
 * @return 找到了返回资源对应的NSData对象，否则返回nil
 */
- (NSData *)getCacheData:(NSString *)url;

/*!
 * @brief 获取指定url的对应的本地缓存路径
 * @param url 资源地址
 * @return 找到了返回资源对应的本地缓存路径，否则返回nil
 */
- (NSString *)getCachePath:(NSString *)url;

/*!
 * @brief 清除指定url对应的缓存
 * @param url 资源地址
 * @return 成功返回YES，失败返回NO
 */
- (BOOL)clearCache:(NSString *)url;

/*!
 * @brief 清除所有缓存
 * @return 成功返回YES，失败返回NO
 */
- (BOOL)clearCache;

/*!
 * @brief 下载指定url的数据，并自动缓存到磁盘中
 * @param url 资源地址
 */
- (void)download:(NSString *)url;

/*!
 * @brief 下载指定url的数据，并自动缓存到磁盘中，然后回调通知Target
 * @param url 图片资源地址
 * @param target 通知的对象
 * @param succBlock 成功通知
 * @param failBlock 失败通知
 * @param progressBlock 进度通知,当前下载百分比
 * @param param 可以指定TXYDownloaderParam族一系列参数,也可以用于透传使用者的参数
 * @see <TXYDownloaderParam> 其中param中的key可以按照TXYDownloaderParam枚举指定
 */
- (void)download:(NSString *)url target:(id)target succBlock:(void (^)(NSString *url, NSData *data, NSDictionary *info))succBlock failBlock:(void (^)(NSString *url, NSError *error))failBlock progressBlock:(void (^)(NSString *url, NSNumber *value))progressBlock param:(NSDictionary *)param;

/*!
 * @brief 提升指定url的下载优先级
 * @param url 资源地址
 */
- (void)raisePriority:(NSString *)url;

/*!
 * @brief 取消target对应的下载请求
 * @param url 资源地址
 * @param target 通知的对象
 */
- (void)cancel:(NSString *)url target:(id)target;

/*!
 * @brief 取消所有的下载请求
 */
- (void)cancelAll;

/*!
 * @brief 清除target下指定url的通知，不取消下载任务,继续下载
 * @param urlPath 资源地址
 * @param target 通知的对象
 */
- (void)clearTarget:(id)target url:(NSString *)url;

/*!
 * @brief 清除指定Target所有的通知，不取消下载任务,继续下载
 * @param target 通知的对象
 */
- (void)clearTarget:(id)target;

@end
