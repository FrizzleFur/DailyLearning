//
//  ChildViewController.h
//  MMPageViewController
//
//  Created by MichaelMao on 17/3/4.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChildViewController : UIViewController
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, readonly, strong) UITableView *tableView;

@end
