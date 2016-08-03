# XHPopMenu
a menu like pop view
弹出菜单

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
![CocoaPods Version](https://img.shields.io/badge/pod-v0.36.4-brightgreen.svg)

### Using CocoaPods
    pod 'XHPopMenu'

目前支持的自定义选项...

```objective-c

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

```

###gif
![预览图](https://github.com/chengxianghe/watch-gif/blob/master/PopMenu.gif?raw=true)

