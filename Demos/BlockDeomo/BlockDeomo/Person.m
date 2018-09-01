//
//  Person.m
//  BlockDeomo
//
//  Created by MichaelMao on 17/4/17.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

#import "Person.h"
typedef void(^blk_t)(void);

@interface Person (){
    blk_t blk_;
//    id obj_;
}
@property (nonatomic, weak) id objc_;

@end

@implementation Person

- (instancetype)init{
    
    self = [super init];
    blk_ = ^{
        
        NSLog(@"obj_ = %@", _objc_);
    };
    return self;
}

- (void)test {

    blk_ = ^{
        NSLog(@"obj_ = %@", _objc_);
    };
}

/***
 还是会有循环引用的警告提示，因为循环引用的是self和block之间的事情，
 这个被Block持有的成员变量是strong还是weak都没有关系,而且即使是基本类型
 （assign）也是一样。
 ***/
//参考[《Objective-C 高级编程》干货三部曲（二）：Blocks篇](http://www.jianshu.com/p/f3ee592e57f5)
@end
