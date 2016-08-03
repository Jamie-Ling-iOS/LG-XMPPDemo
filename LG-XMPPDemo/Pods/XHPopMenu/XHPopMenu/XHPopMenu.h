//
//  XHPopMenu.h
//  XHPopMenu
//
//  Created by chengxianghe on 16/4/7.
//  Copyright © 2016年 cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XHPopMenuView, XHPopMenuItem, XHPopMenuConfiguration;

typedef void (^XHPopMenuItemAction)(XHPopMenuItem *item);

typedef NS_ENUM(NSUInteger, XHPopMenuAnimationStyle) {
    XHPopMenuAnimationStyleNone,
    XHPopMenuAnimationStyleFade,
    XHPopMenuAnimationStyleScale,
    XHPopMenuAnimationStyleWeiXin,
};

static const CGFloat kDefaultAnimateDuration = 0.15;

@interface XHPopMenu : NSObject

+ (void)showMenuInView:(UIView * __nullable)inView
              withView:(UIView * __nonnull)view
             menuItems:(NSArray<__kindof XHPopMenuItem *> * __nonnull)menuItems
           withOptions:(XHPopMenuConfiguration * __nullable)options;

+ (void)showMenuWithView:(UIView * __nonnull)view
               menuItems:(NSArray<__kindof XHPopMenuItem *> * __nonnull)menuItems
             withOptions:(XHPopMenuConfiguration * __nullable)options;

+ (void)dismissMenu;

@end

@interface XHPopMenuConfiguration : NSObject

@property (nonatomic, assign) XHPopMenuAnimationStyle style; // 动画风格
@property (nonatomic, assign) CGFloat arrowSize; // 箭头大小
@property (nonatomic, assign) CGFloat arrowMargin; // 手动设置箭头和目标view的距离
@property (nonatomic, assign) CGFloat marginXSpacing; // MenuItem左右边距
@property (nonatomic, assign) CGFloat marginYSpacing; // MenuItem上下边距
@property (nonatomic, assign) CGFloat intervalSpacing; // MenuItemImage与MenuItemTitle的间距
@property (nonatomic, assign) CGFloat menuCornerRadius; // 菜单圆角半径
@property (nonatomic, assign) CGFloat menuScreenMinMargin; // 菜单和屏幕最小间距
@property (nonatomic, assign) CGFloat menuMaxHeight; // 菜单最大高度
@property (nonatomic, assign) CGFloat separatorInsetLeft; // 分割线左侧Insets
@property (nonatomic, assign) CGFloat separatorInsetRight; // 分割线右侧Insets
@property (nonatomic, assign) CGFloat separatorHeight; // 分割线高度
@property (nonatomic, assign) CGFloat fontSize; // 字体大小
@property (nonatomic, assign) CGFloat itemHeight; // 单行高度
@property (nonatomic, assign) CGFloat itemMaxWidth; // 单行最大宽度
@property (nonatomic, assign) NSTextAlignment alignment; // 文字对齐方式
@property (nonatomic, assign) Boolean shadowOfMenu; // 是否添加菜单阴影
@property (nonatomic, assign) Boolean hasSeparatorLine; // 是否设置分割线

@property (nonatomic, strong) UIColor *titleColor; // menuItem字体颜色
@property (nonatomic, strong) UIColor *separatorColor; // 分割线颜色
@property (nonatomic, strong) UIColor *shadowColor; // 阴影颜色
@property (nonatomic, strong) UIColor *menuBackgroundColor; // 菜单的底色
@property (nonatomic, strong) UIColor *selectedColor; // menuItem选中颜色
@property (nonatomic, strong) UIColor *maskBackgroundColor; // 遮罩颜色

+ (instancetype)defaultConfiguration;

@end

@interface XHPopMenuItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, readonly) SEL action;
@property (nonatomic,   weak, readonly) id target;
@property (nonatomic,   copy, readonly) XHPopMenuItemAction block;

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                       target:(id)target
                       action:(SEL)action;

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                        block:(XHPopMenuItemAction)block;

@end

NS_ASSUME_NONNULL_END
