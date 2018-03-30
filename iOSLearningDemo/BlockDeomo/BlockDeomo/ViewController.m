//
//  ViewController.m
//  BlockDeomo
//
//  Created by MichaelMao on 17/4/17.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, copy) void (^myBlock)(void);

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  NSString *(^sumBlock)(int, int) = ^NSString*(int a, int b){
    return [NSString stringWithFormat:@"%d + %d = %d", a, b, (a + b)];
  };
  
  NSString *blockStr = sumBlock(1, 3);
  NSLog(@"blockStr = %@", blockStr);
}

- (void)myMethodWithABlock:(NSString* (^)(NSString * string))myblock{

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
