//
//  NSString_extra.h
//  LG-Demo
//
//  Created by Jamie on 14-12-17.
//  Copyright 2014 LG-Demo. All rights reserved.
//



#import <Foundation/Foundation.h>


@interface NSString (extra)

/**
*  判断字符串是否为Nil或者空
*
*  @param str 需要校验的字符串
*
*  @return  YES:为nil或者空，NO:有内容
*/
+ (BOOL )isNilOrEmpty: (NSString *) str;

/**
 *  电话号码去掉多余的字符
 *
 *  @param phoneNumber 要处理的电话号码字符串
 *
 *  @return 处理过的电话号码
 */
+ (NSString *)normaPhoneNumber:(NSString *)phoneNumber;

/**
 *  字符串转换为16进制
 *
 *  @param string <#string description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)hexStringFromString:(NSString *)string;

///**
// *  十六进制转字符串
// *
// *  @param hexString <#hexString description#>
// *
// *  @return <#return value description#>
// */
//+ (NSString *)stringFromHexString:(NSString *)hexString;

/**
 *  判断2个字符串是否相等
 *
 *
 *  @return 返回是否相等，yes：相等，no:不相等
 */
+ (BOOL) isSame:(NSString *) string1 with:(NSString *) string2;


#pragma mark - 网络请求相关的字符串输出

#define AMLogInfo(frmt, ...) [self logInfo:frmt, ##__VA_ARGS__]

//字符串格式化
+ (NSString*)stringByURLEncodingString:(NSString*)unescapedString;

//字符串输出
+ (void)logInfo: (NSString *)path withParameters: (id )parameters withAPIPort: (NSString *) apiPort;

/**
 *  data转换成字符串（通过kCFStringEncodingGB_18030_2000）
 *
 *  @param data 数据
 *
 *  @return 转换成的string
 */
+ (NSString *) convertEncodingToNSStringWithkCFStringEncodingGB: (NSData *) data;

/**
 *  得到中英文混合字符串长度 方法1
 *
 */
+ (int)convertToInt:(NSString*)strtemp;

/**
 *  得到中英文混合字符串长度 方法2  可能会有4个字符的误差
 */
+ (int)getToInt:(NSString*)strtemp;
@end
