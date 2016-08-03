//
//  UIImage_extra.m
//  LG-Demo
//
//  Created by jamie on 15/7/17.
//  Copyright (c) 2015年 LG. All rights reserved.
//

#import "UIImage_extra.h"

@implementation UIImage (extra)

/**
 图片重绘，将一张小图放入一个大图中 间
 
 :param: superImage 大图（父图）
 :param: subImage   小图（子图）
 :param: subRect    小图（子图）大小
 */
+ (UIImage *)addSubImage:(UIImage *)img sub:(UIImage *) subImage subRect: (CGSize) subRect
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
//    int subWidth = subImage.size.width;
//    int subHeight = subImage.size.height;
    
    int subWidth = subRect.width;
    int subHeight = subRect.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake( (w-subWidth)/2, (h - subHeight)/2, subWidth, subHeight), [subImage CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *overImage = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    
    return overImage;
    //  CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
}


- (UIImage *)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)resizeImage:(NSString *)imageName
{
    UIImage *image = [UIImage setImageFromFile:imageName];
    CGFloat imageW = image.size.width * 0.5;
    CGFloat imageH = image.size.height * 0.5;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageH, imageW, imageH, imageW) resizingMode:UIImageResizingModeTile];
}

+ (UIImage *)setImageFromFile:(NSString *)fileString
{
    return  [UIImage imageWithFile:[[NSBundle mainBundle]pathForResource:fileString ofType:nil]];
}

+ (UIImage *)imageWithFile:(NSString *)path{
    UIImage *img = nil;
    
    if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
        img = [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else {
        img = [UIImage imageWithContentsOfFile:path];
    }
    return img;
}


//压缩图片
+ (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    
    if (nil == image) {
        
        newimage = nil;
        
    }
    
    else{
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(asize);
        // 绘制改变大小的图片
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        // 从当前context中创建一个改变大小后的图片
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        
    }
    // 返回新的改变大小后的图片
    return newimage;
    
}

@end
