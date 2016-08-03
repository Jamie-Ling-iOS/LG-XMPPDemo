//
//  MultiSelectViewController.h
//  MultiSelectTableViewController
//
//  Created by molon on 6/7/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^multiSelectComplete)(NSArray *);

@interface MultiSelectViewController : UIViewController

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) multiSelectComplete completeBlock;


@end
