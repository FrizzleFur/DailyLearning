//
//  ViewController.m
//  Notification
//
//  Created by MichaelMao on 17/3/28.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn0 = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    btn0.layer.borderColor = [[UIColor blueColor] CGColor];
    btn0.layer.borderWidth = 2.0f;
    [btn0 setTitle:@"request local notification" forState:UIControlStateNormal];
    [btn0 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn0 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btn0 addTarget:self action:@selector(requestLocalNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn0];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 50)];
    btn1.layer.borderColor = [[UIColor blueColor] CGColor];
    btn1.layer.borderWidth = 2.0f;
    [btn1 setTitle:@"10's local notification" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btn1 addTarget:self action:@selector(demoLocalNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 50)];
    btn2.layer.borderColor = [[UIColor blueColor] CGColor];
    btn2.layer.borderWidth = 2.0f;
    [btn2 setTitle:@"clock local notification" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btn2 addTarget:self action:@selector(demoLocalNotificationClock) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 50)];
    btn3.layer.borderColor = [[UIColor blueColor] CGColor];
    btn3.layer.borderWidth = 2.0f;
    [btn3 setTitle:@"remove local notification" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btn3 addTarget:self action:@selector(removeLocalNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestLocalNotification {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
}

- (void)removeLocalNotification {
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (!notifications) {
        return;
    }
    for (UILocalNotification *notification in notifications) {
        if ([[notification.userInfo objectForKey:@"id"] isEqualToString:@"notification_1"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
}

- (void)demoLocalNotification {
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    if (notification) {
//        NSLog(@">> 10s' local notification");
//        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
//        notification.timeZone = [NSTimeZone defaultTimeZone];
//        notification.alertTitle = @"AlertTitle 1";
//        notification.alertBody = @"AlertBody 1";
//        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"notification_1", @"id", nil];
//        notification.userInfo = infoDict;
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
//    
        UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        NSLog(@">> 10s' local notification");
        notification.alertBody = @"Hello, this is a notice";
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
        //使用本地时区
        notification.timeZone=[NSTimeZone defaultTimeZone];
        
    //    通知行为（alertAction,hasAction）
        notification.alertAction=NSLocalizedString(@"锁屏啦，通知时间到啦", nil);
    //    触发通知时的启动画面（alertLaunchImage）
    //    通知的正文内容（alertTitle、alertBody）
        notification.alertTitle = @"AlertTitle 1";
        notification.alertBody=@"通知内容";
    //    通知的声音（soundName）
        notification.soundName = UILocalNotificationDefaultSoundName;
    //    通知消息数的展示（applicationIconBadgeNumber）App图标左上角的红数字
        notification.applicationIconBadgeNumber = 10;//不显示为0
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }   
}

- (void)demoLocalNotificationClock {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        NSLog(@">> clock local notification");
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        dateComponents.hour = 21;
        dateComponents.minute = 00;
        NSDate *time = [calendar dateFromComponents:dateComponents];
        
        notification.fireDate = [time dateByAddingTimeInterval:7*24*60*60];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.alertTitle = @"AlertTitle 2";
        notification.alertBody = @"AlertBody 2";
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.userInfo = @{@"id": @"notification_2"};
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


@end
