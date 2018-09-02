//
//  ViewController.m
//  多线程Demo
//
//  Created by MichaelMao on 2018/9/2.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)gcdLockExample{
    NSLog(@"currentThread = %@", [NSThread currentThread]);
    
    NSLog(@"1"); // 任务1
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2"); // 任务2
        NSLog(@"currentThread = %@", [NSThread currentThread]);
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"3"); // 任务3
            NSLog(@"currentThread = %@", [NSThread currentThread]);
        });
        NSLog(@"4"); // 任务4
        NSLog(@"currentThread = %@", [NSThread currentThread]);
    });
    NSLog(@"5"); // 任务5
}

@end
