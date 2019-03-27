//
//  ViewController.m
//  Memory-RetainCycleDemo
//
//  Created by MichaelMao on 2019/3/27.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

#import "ViewController.h"
#import "NextVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NextVC *vc = [NextVC new];
    [self.navigationController pushViewController:vc animated:true];
}


@end
