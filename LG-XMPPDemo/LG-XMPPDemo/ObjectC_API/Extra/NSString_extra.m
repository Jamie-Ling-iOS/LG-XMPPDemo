//
//  NSString_extra.m
//  LG-Demo
//
//  Created by Jamie on 14-12-17.
//  Copyright 2014 LG-Demo. All rights reserved.
//

#import "NSString_extra.h"
#import <UIKit/UIKit.h>
//#import "LG_App-Swift.h"   //只能放在.m文件中

@implementation NSString(extra)

/**
 *  判断字符串是否为Nil或者空
 *
 *  @param str 需要校验的字符串
 *
 *  @return  YES:为nil或者空，NO:有内容
 */
+ (BOOL )isNilOrEmpty: (NSString *) str;
{
    if (str && ![str isEqualToString:@""] && ![str isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    
    return YES;
}

/**
 *  电话号码去掉多余的字符
 *
 *  @param phoneNumber 要处理的电话号码字符串
 *
 *  @return 处理过的电话号码
 */
+ (NSString *)normaPhoneNumber:(NSString *)phoneNumber
{
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:phoneNumber.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:phoneNumber];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
        }
        // --------- Add the following to get out of endless loop
        else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
        // --------- End of addition
    }
    return strippedString;
}



//字符串转换为16进制
+(NSString *)hexStringFromString:(NSString *)string{
    NSMutableString *str = [[NSMutableString alloc]init];
    //反转
    for (NSUInteger i=string.length; i>0 ; i--) {
        [str appendString:[string substringWithRange:NSMakeRange(i-1, 1)]];
    }
    
    NSData *myD = [str dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //转16进制。
    [str setString:@""];
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            str = [NSMutableString stringWithFormat:@"%@0%@",str,newHexStr];
        else
            str = [NSMutableString stringWithFormat:@"%@%@",str,newHexStr];
    }
    //加头
    [str insertString:@"00" atIndex:0];
    //加 -
    [str insertString:@"-" atIndex:8];
    [str insertString:@"-" atIndex:13];
    [str insertString:@"-" atIndex:18];
    [str insertString:@"-" atIndex:23];
    
    return (NSString *)[str uppercaseString];
}

////十六进制转字符串
//+ (NSString *)stringFromHexString:(NSString *)hexString { //
//    //去 -
//    hexString = [hexString stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    //去头
//    hexString = [hexString substringFromIndex:2];
//    //转字符串
//    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
//    bzero(myBuffer, [hexString length] / 2 + 1);
//    for (int i = 0; i < [hexString length] - 1; i += 2) {
//        unsigned int anInt;
//        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
//        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr] ;
//        [scanner scanHexInt:&anInt];
//        myBuffer[i / 2] = (char)anInt;
//    }
//    NSString *string = [NSString stringWithCString:myBuffer encoding:NSUTF8StringEncoding];
//    //反转
//    NSMutableString *s = [[NSMutableString alloc]init];
//    for (NSUInteger i=string.length; i>0 ; i--) {
//        [s appendString:[string substringWithRange:NSMakeRange(i-1, 1)]];
//    }
//    return (NSString *)s;
//}


//字符串格式化
+ (NSString*)stringByURLEncodingString:(NSString*)unescapedString {
    NSString* result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                             kCFAllocatorDefault,
                                                                                             (CFStringRef)unescapedString,
                                                                                             NULL, // characters to leave unescaped
                                                                                             (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                                                                             kCFStringEncodingUTF8));
    return result;
}

+(void) logInfo:(NSString *)format,...
{
    va_list argumentList;
    
    va_start(argumentList, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    NSLog(@"%@",str);
}

//body参数拼接
+ (NSString *)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params {
    
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    if (!params) {
        params = [[NSMutableDictionary alloc] init] ;
        NSLocale *locale=[NSLocale currentLocale];
        NSString *language = [NSString stringWithFormat:@"%@", locale.localeIdentifier];
        [params setValue:language forKey:@"lang"];
    }else{
        
        params = [NSMutableDictionary dictionaryWithDictionary:params];
        
        if (![params objectForKey:@"lang"]) {
            NSLocale *locale=[NSLocale currentLocale];
            NSString *language = [NSString stringWithFormat:@"%@", locale.localeIdentifier];
            [params setValue:language forKey:@"lang"];
        }
    }
    
    NSMutableArray* pairs = [NSMutableArray array];
    if (params) {
        for (NSString* key in [params keyEnumerator]){
            NSString *paramValue = [NSString stringWithFormat:@"%@",[params valueForKey:key]];
            NSString* escaped_value = [self stringByURLEncodingString:paramValue];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
    }
    
    NSString* query = [pairs componentsJoinedByString:@"&"];
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}


//字符串输出
+ (void)logInfo: (NSString *)path withParameters: (id)parameters withAPIPort: (NSString *) apiPort
{
    if ([apiPort isEqualToString:@"Get"])
    {
        AMLogInfo(@"\nBegin Request[Get]: %@ ", [self serializeURL:path params:parameters]);
    }
    else if ([apiPort isEqualToString:@"Post"])
    {
         AMLogInfo(@"\nBegin Request[Post]: %@ \n Post Body: %@ ", path,parameters);
    }
    else if ([apiPort isEqualToString:@"Delete"])
    {
        AMLogInfo(@"\nBegin Request[Delete]: %@ ", [self serializeURL:path params:parameters]);
    }
    else if ([apiPort isEqualToString:@"Put"])
    {
         AMLogInfo(@"\nBegin Request[Put]: %@ \n Post Body: %@ ", path,parameters);
    }
}

/**
 *  data转换成字符串（通过kCFStringEncodingGB_18030_2000）
 *
 *  @param data 数据
 *
 *  @return 转换成的string
 */
+ (NSString *) convertEncodingToNSStringWithkCFStringEncodingGB: (NSData *) data
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [[NSString alloc]initWithData:data encoding:enc];
}

/**
 *  判断2个字符串是否相等
 *
 *
 *  @return 返回是否相等，yes：相等，no:不相等
 */
+ (BOOL) isSame:(NSString *) string1 with:(NSString *) string2;
{
    if ([string1 compare: string2] != NSOrderedSame)
    {
        return NO;
    }
    return YES;
}


/**
 *  得到中英文混合字符串长度 方法1
 *
 */
+ (int)convertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
}


/**
 *  得到中英文混合字符串长度 方法2
 */
+ (int)getToInt:(NSString*)strtemp

{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return (int)[da length];
}


@end
