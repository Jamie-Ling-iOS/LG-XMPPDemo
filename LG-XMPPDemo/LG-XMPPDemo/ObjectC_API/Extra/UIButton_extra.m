//
//  UIButton_extra.m
//  LG-Demo
//
//  Created by jamie on 15/7/20.
//  Copyright (c) 2015年 LG. All rights reserved.
//

#import "UIButton_extra.h"

@implementation UIButton (extra)

/**
 *  设置按钮不同状态下的背景颜色（通过重绘背景图片的方法完成）
 *
 *  @param backgroundColor 颜色
 *  @param state           状态
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[UIButton imageWithColor:backgroundColor] forState:state];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
