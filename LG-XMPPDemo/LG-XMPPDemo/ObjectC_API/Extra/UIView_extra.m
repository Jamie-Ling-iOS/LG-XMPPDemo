//
//  UIView_extra.m
//  LG-Demo
//
//  Created by jamie on 14-11-25.
//  Copyright (c) 2014年 LG-Demo. All rights reserved.
//

//动画
#define vSemiModalAnimationDuration 0.3f            //时长

#import "UIView_extra.h"

@implementation UIView (extra)

@dynamic x;
@dynamic y;
@dynamic width;
@dynamic height;
@dynamic origin;
@dynamic size;

#pragma mark ---------------- Setters-----------------
-(void)setX:(CGFloat)x{
    CGRect r        = self.frame;
    r.origin.x      = x;
    self.frame      = r;
}

-(void)setY:(CGFloat)y{
    CGRect r        = self.frame;
    r.origin.y      = y;
    self.frame      = r;
}

-(void)setWidth:(CGFloat)width{
    CGRect r        = self.frame;
    r.size.width    = width;
    self.frame      = r;
}

-(void)setHeight:(CGFloat)height{
    CGRect r        = self.frame;
    r.size.height   = height;
    self.frame      = r;
}

-(void)setOrigin:(CGPoint)origin{
    self.x          = origin.x;
    self.y          = origin.y;
}

-(void)setSize:(CGSize)size{
    self.width      = size.width;
    self.height     = size.height;
}

-(void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

-(void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

-(void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

-(void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

#pragma mark ---------------- Getters-----------------
-(CGFloat)x{
    return self.frame.origin.x;
}

-(CGFloat)y{
    return self.frame.origin.y;
}

-(CGFloat)width{
    return self.frame.size.width;
}

-(CGFloat)height{
    return self.frame.size.height;
}

-(CGPoint)origin{
    return CGPointMake(self.x, self.y);
}

-(CGSize)size{
    return CGSizeMake(self.width, self.height);
}

-(CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

-(CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

-(CGFloat)centerX {
    return self.center.x;
}

-(CGFloat)centerY {
    return self.center.y;
}

-(UIView *)lastSubviewOnX{
    if(self.subviews.count > 0){
        UIView *outView = self.subviews[0];
        
        for(UIView *v in self.subviews)
            if(v.x > outView.x)
                outView = v;
        
        return outView;
    }
    
    return nil;
}

-(UIView *)lastSubviewOnY{
    if(self.subviews.count > 0){
        UIView *outView = self.subviews[0];
        
        for(UIView *v in self.subviews)
            if(v.y > outView.y)
                outView = v;
        
        return outView;
    }
    
    return nil;
}

#pragma mark ---------------- other-----------------
/**
 * @brief 移除此view上的所有子视图
 */
- (void)removeAllSubviews {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    return;
}

/**
 *  设置为居中
 */
- (void)centerSelfToWindow
{
    self.centerX =  [[UIScreen mainScreen] bounds].size.width / 2.0;
}

/**
 @brief 弹窗
 @param title 弹窗标题
 message 弹窗信息
 */
+ (void) showAlertView: (NSString*) title andMessage: (NSString *) message
{
    dispatch_async(dispatch_get_main_queue() , ^{
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = title;
        alert.message = message;
        [alert addButtonWithTitle:@"确定"];
        [alert show];
        alert = nil;
    });
}

/**
 *  弹窗
 *
 *  @param title    弹窗标题
 *  @param message  弹窗信息
 *  @param delegate 弹窗代理
 */
+ (void) showAlertView: (NSString*) title
            andMessage: (NSString *) message
          withDelegate: (UIViewController<UIAlertViewDelegate> *) delegate
{
    dispatch_async(dispatch_get_main_queue() , ^{
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = title;
        alert.message = message;
        alert.delegate = delegate;
        alert.tag = vAlertTag;
        [alert addButtonWithTitle:@"确定"];
        [alert show];
        alert = nil;
    });
}

- (void)presentModelView
{
   
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    
    if (keywindow.tag == 13842)
    {
        return;
    }
    keywindow.tag = 13842;
    //    NSLog(@"%@", keywindow);
    if (![keywindow.subviews containsObject:self]) {
        // Calulate all frames
        CGRect sf = self.frame;
        CGRect vf = keywindow.frame;
        CGRect f  = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
        CGRect of = CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);
        
        // Add semi overlay
        UIView * overlay = [[UIView alloc] initWithFrame:keywindow.bounds];
        overlay.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.6];
        
        UIView* ss = [[UIView alloc] initWithFrame:keywindow.bounds];
        [overlay addSubview:ss];
        [keywindow addSubview:overlay];
        
        //点击其它地方消失
        UIControl * dismissButton = [[UIControl alloc] initWithFrame:CGRectZero];
        [dismissButton addTarget:self action:@selector(dismissModalView) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.backgroundColor = [UIColor clearColor];
        dismissButton.frame = of;
        [overlay addSubview:dismissButton];
        
        // 遮盖动画
        [UIView animateWithDuration:vSemiModalAnimationDuration animations:^{
            ss.alpha = 0.5;
        }];
        
        // 自我动画
        self.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
        [keywindow addSubview:self];
        //去除阴影特效
        //        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        //        self.layer.shadowOffset = CGSizeMake(0, -2);
        //        self.layer.shadowRadius = 5.0;
        //        self.layer.shadowOpacity = 0.8;
        [UIView animateWithDuration:vSemiModalAnimationDuration animations:^{
            self.frame = f;
        }];
    }
}

- (void)dismissModalView
{
    UIWindow * keywindow = [[UIApplication sharedApplication] keyWindow];
    keywindow.tag = 10000;
    
    if (keywindow.subviews.count < 2)
    {
        return;
    }
    UIView * modal = [keywindow.subviews objectAtIndex:keywindow.subviews.count-1];
    UIView * overlay = [keywindow.subviews objectAtIndex:keywindow.subviews.count-2];
    [UIView animateWithDuration:vSemiModalAnimationDuration animations:^{
        modal.frame = CGRectMake(0, keywindow.frame.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        
        [modal removeFromSuperview];
    }];
    
    // Begin overlay animation
    if (overlay.subviews.count < 1)
    {
        modal = nil;
        overlay = nil;
        return;
    }
    UIImageView * ss = (UIImageView*)[overlay.subviews objectAtIndex:0];
    [UIView animateWithDuration:vSemiModalAnimationDuration animations:^{
        ss.alpha = 1;
    }];
    
    
    modal = nil;
    overlay = nil;
}



- (void) changeBackgroundColorForEditingDidBegin
{
    self.backgroundColor = [UIColor whiteColor];
}


- (void) changeBackgroundColorForEditingEditingDidEnd
{
    self.backgroundColor = kHexRGB(0xffccc5);
}

/**
 *  点击时颜色变化
 */
- (void) changeBorderColorForEditingDidBegin
{
    
    self.layer.borderColor = kHexRGB(0xe4393c).CGColor;
}


/**
 *  非点击时颜色变化
 */
- (void) changeBorderColorForEditingEditingDidEnd
{
    self.layer.borderColor = kHexRGB(0xe8e8e8).CGColor;
}


/**
 *  点击时颜色变化--红底时
 */
- (void) changeBorderColorForEditingDidBeginRedBackColor
{
     self.layer.borderColor = kHexRGB(0xffffff).CGColor;
}


/**
 *  非点击时颜色变化--红底时
 */
- (void) changeBorderColorForEditingEditingDidEndRedBackColor
{
      self.layer.borderColor = kHexRGBAlpha(0xffffff, 0.6).CGColor;
}


@end
