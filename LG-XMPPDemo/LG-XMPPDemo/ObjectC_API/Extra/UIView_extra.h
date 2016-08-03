//
//  UIView_extra.h
//  LG-Demo
//
//  Created by jamie on 14-11-25.
//  Copyright (c) 2014年 LG-Demo. All rights reserved.
//


#pragma mark ---------------- 屏幕适配 ------------
#define kIOSVersions [[[UIDevice currentDevice] systemVersion] floatValue] //获得iOS版本
#define kUIWindow    [[[UIApplication sharedApplication] delegate] window] //获得window
#define kUnderStatusBarStartY (kIOSVersions>=7.0 ? 20 : 0)                 //7.0以上stautsbar不占位置，内容视图的起始位置要往下20

#define kIPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIPhone5s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define kScreenSize           [[UIScreen mainScreen] bounds].size                 //(e.g. 320,480)
#define kScreenWidth          [[UIScreen mainScreen] bounds].size.width           //(e.g. 320)
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height
#define kIOS7OffHeight (kIOSVersions>=7.0 ? 64 : 0)     //设置

#define kApplicationSize      [[UIScreen mainScreen] applicationFrame].size       //(e.g. 320,460)
#define kApplicationWidth     [[UIScreen mainScreen] applicationFrame].size.width //(e.g. 320)
#define kApplicationHeight    [[UIScreen mainScreen] applicationFrame].size.height//不包含状态bar的高度(e.g. 460)

#define kStatusBarHeight         20
#define kNavigationBarHeight     44
#define kNavigationheightForIOS7 64
#define kContentHeight           (kApplicationHeight - kNavigationBarHeight)
#define kTabBarHeight            49
#define kTableRowTitleSize       14
#define maxPopLength             215

#define kButtonDefaultWidth (kIPhone4s ? 278 : 288)   //默认输入框宽
#define kSendSMSButtonWidth  90  //验证码按钮长度
#define kButtonDefaultHeight 42  //默认输入框&按钮高
#define kCellDefaultHeight = 44       //默认Cell高度

#pragma mark ---------------- 第三方函数 ------------
//比较字符串是否相等（忽略大小写），相等的话返回YES，否则返回NO。
#define kCompareStringCaseInsenstive(thing1, thing2) [thing1 compare:thing2 options:NSCaseInsensitiveSearch|NSNumericSearch] == NSOrderedSame
#define kCenterTheView(view) view.center = CGPointMake(kScreenWidth / 2.0, view.center.y)  //设置x方向屏幕居中


#pragma mark ---------------- 字体/颜色 ------------
#define kRGB(r, g, b)             [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define kRGBAlpha(r, g, b, a)     [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

#define kHexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kHexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

//页面通用背景颜色
#define kBackgroundColor kHexRGB(0xFFFFFF)
//导航栏背景颜色值
#define kNavigationBarColor kHexRGB(0xe4393c)
//导航栏字体颜色值：#FFFFFF;
#define kNavigationBarTitleColor kHexRGB(0xFFFFFF)
//页面字体颜色
#define kPageTitleColor [UIColor blackColor]
//holdPlacer字体颜色
#define kHoldPlacerColor kRGB(166.0, 166.0, 166.0)


#define kGetAutoSizeScaleX()    (kScreenHeight <= 480 ? 1.0 : (kScreenWidth / 320.0))

#define kGetAutoSizeScaleY()    (kScreenHeight <= 480 ? 1.0 : (kScreenHeight / 568.0))

#define kButtonFontSize  [UIFont systemFontOfSize:(12 + (kGetAutoSizeScaleX() > 1.0 ? 2 : 0) )]

#define vAlertTag    10086

#import <UIKit/UIKit.h>

@interface UIView (extra)
@property (nonatomic, assign) CGFloat   x;
@property (nonatomic, assign) CGFloat   y;
@property (nonatomic, assign) CGFloat   width;
@property (nonatomic, assign) CGFloat   height;
@property (nonatomic, assign) CGPoint   origin;
@property (nonatomic, assign) CGSize    size;
@property (nonatomic, assign) CGFloat   bottom;
@property (nonatomic, assign) CGFloat   right;
@property (nonatomic, assign) CGFloat   centerX;
@property (nonatomic, assign) CGFloat   centerY;
@property (nonatomic, strong, readonly) UIView *lastSubviewOnX;
@property (nonatomic, strong, readonly) UIView *lastSubviewOnY;


#pragma mark - 布局-----------------
/**
 * @brief 移除此view上的所有子视图
 */
- (void)removeAllSubviews;


/**
 *  设置为居中
 */
- (void)centerSelfToWindow;


#pragma mark - 弹窗-----------------
/**
 @brief 弹窗
 @param title 弹窗标题
        message 弹窗信息
 */
+ (void) showAlertView: (NSString*) title andMessage: (NSString *) message;

/**
 *  弹窗
 *
 *  @param title    弹窗标题
 *  @param message  弹窗信息
 *  @param delegate 弹窗代理
 */
+ (void) showAlertView: (NSString*) title
            andMessage: (NSString *) message
          withDelegate: (UIViewController<UIAlertViewDelegate> *) delegate;

/**
 *  弹出一个显示自身的模态窗口:注意，来自底部
 */
- (void)presentModelView;

/**
 *  让基于自身展现的模态窗口消失
 */
- (void)dismissModalView;



#pragma mark - 其它------------------------------------
//针对输入框底部线条颜色会变化实现2个方法--也可用于其它view
/**
 *  点击时颜色变化
 */
- (void) changeBackgroundColorForEditingDidBegin;


/**
 *  非点击时颜色变化
 */
- (void) changeBackgroundColorForEditingEditingDidEnd;


//针对输入框外框线条颜色会变化实现2个方法--也可用于其它view
/**
 *  点击时颜色变化
 */
- (void) changeBorderColorForEditingDidBegin;


/**
 *  非点击时颜色变化
 */
- (void) changeBorderColorForEditingEditingDidEnd;


/**
 *  点击时颜色变化--红底时
 */
- (void) changeBorderColorForEditingDidBeginRedBackColor;


/**
 *  非点击时颜色变化--红底时
 */
- (void) changeBorderColorForEditingEditingDidEndRedBackColor;



@end
