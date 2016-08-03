//
//  UIImage_extra.h
//  LG-Demo
//
//  Created by jamie on 15/7/17.
//  Copyright (c) 2015年 LG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (extra)
/**
 图片重绘，将一张小图放入一个大图中 间
 
 :param: superImage 大图（父图）
 :param: subImage   小图（子图）
 :param: subRect    小图（子图）大小
 */
+ (UIImage *)addSubImage:(UIImage *)img sub:(UIImage *) subImage subRect: (CGSize) subRect;

// 等比例缩放
- (UIImage*)scaleToSize:(CGSize)size;
+ (UIImage *)resizeImage:(NSString *)imageName;
+ (UIImage *)setImageFromFile:(NSString *)fileString;

//压缩图片
+ (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;

@end
