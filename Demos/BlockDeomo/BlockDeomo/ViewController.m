//
//  ViewController.m
//  BlockDeomo
//
//  Created by MichaelMao on 17/4/17.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

typedef void (^completion_t)(id result);

@interface ViewController ()

@property (nonatomic, copy) void (^myBlock)(void);
@property (nonatomic, strong) void (^delayBlock)(void);

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    void (^myBlock)(void) = ^{};
    myBlock();

    [self myMethodWithABlock:^NSString *(NSString *string) {
      return @"";
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self retainCycle];
}


#pragma mark -
#pragma mark - Block用法

- (void)addBlock{
    
    NSString *(^sumBlock)(int, int) = ^NSString*(int a, int b){
        return [NSString stringWithFormat:@"%d + %d = %d", a, b, (a + b)];
    };
    
    NSString *blockStr = sumBlock(1, 3);
    NSLog(@"blockStr = %@", blockStr);
}

/** block作为函数参数 */
- (void)myMethodWithABlock:(NSString* (^)(NSString * string))myblock{
    
}

- (void)callCompletionHandler{
    [self writeImages:nil completion:^(id result) {
        NSLog(@"Result: %@", result);
    }];
}
     

/** 使用传入参数的的block，可以省去参数名，以表示需要传入参数 */
- (void)writeImages:(NSMutableArray*)images
                 completion:(void (^)(id ))completionHandler {
    if (completionHandler) {
        completionHandler(@"所有图片都成功保存");
    }
}


#pragma mark -
#pragma mark - Block的循环引用


- (void)retainCycle {
    
    __weak typeof(self) weakSelf = self;//weakSelf是retainCycle的局部变量

    _delayBlock = ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf; //strongSelf是_delayBlock代码块的局部变量
        //延时操作，使得weakSelf可能被释放了
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog (@"weakSelf = %@" ,weakSelf);
            NSLog (@"strongSelf = %@" ,strongSelf);
        });
    };
    _delayBlock();
    //具体调用看图
    /*
     _delayBlock是VC的一个属性，被VC强引用。
     _delayBlock对象的weakSelf指向VC。
     _delayBlock对象的strongSelf指向VC，dispatch_after块中捕获的strongSelf又指向了VC,VC被2个强指针所引用
     在_delayBlock执行完毕后，_delayBlock的局部变量strongSelf被释放，
     但是在系统延时操作的dispatch_after的block中会有strongSelf强指针指向当前VC的_delayBlock，
     所以不会被释放，直到dispatch_after延迟结束，dispatch_after的strongSelf不再指向VC，VC释放，_delayBlock最后释放。
     */
    
    //![](http://oc98nass3.bkt.clouddn.com/15359369719422.jpg)
}

@end
