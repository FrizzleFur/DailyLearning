//
//  NextVC.m
//  Memory-RetainCycleDemo
//
//  Created by MichaelMao on 2019/3/27.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

#import "NextVC.h"

@interface NextVC ()
@property(nonatomic, copy) NSString *name;
@property (nonatomic, copy) void (^block)(UIViewController *vc);


@end

@implementation NextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor greenColor];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self testMethod];
}


- (void)testMethod{
    
    /* log：
      weakSelf.name = testName
      -[NextVC dealloc]
     */
    
    __weak __typeof(self)weakSelf = self;
    
    self.name = @"testName";
    self.block = ^(UIViewController *vc) {
       // 延时操作，然后pop，vcu出栈，被释放
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // pop回去后nextVC已经被释放，所以打印是空值
            //            NSLog(@"weakSelf.name = %@", weakSelf.name);
            
            // vc被block存储，拷贝到堆上，所以可以获取打印的值
            NextVC *nextVC = (NextVC *)vc;
            NSLog(@"weakSelf.name = %@", nextVC.name);
            
        });
        
        // 强引用，导致循环链
        //        NSLog(@"self.name = %@", self.name);
        
        // 使用弱引用，避免循环链
        //        NSLog(@"weakSelf.name = %@", weakSelf.name);
    };
    
    self.block(self);
}


- (void)dealloc{
    
    NSLog(@"%s", __func__);
}


@end
