//
//  Person.m
//  RuntimeDemo
//
//  Created by MichaelMao on 2018/9/4.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "Person.h"
#import "User.h"
#import <objc/message.h>

@implementation Person

- (instancetype)init{
    if (self = [super init]) {
        //在对象的初始化，添加逻辑
    }
    return self;
}

- (void)printName:(NSString *)name {
    NSLog(@"func = %s", __func__);
    NSLog(@"_cmd = %@", NSStringFromSelector(_cmd));
    NSLog(@"name = %@", name);
}


#pragma mark - 动态添加方法

void dynamicImpMethodIMP(id self, SEL _cmd, NSString *para) {
    
    NSLog(@"func = %s", __func__);
    NSLog(@"unImpMethod is resolved with------%@", para);
}

// 只要一个对象掉用了一个未实现的方法，就会调用resolve
// 动态添加实例方法
//任何方法默认都有两个隐式參数,self,_ .cmd
//_cmd: 当前方法方法编号
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(unImpMethod)) {
        //添加
        class_addMethod([self class], sel, (IMP)dynamicImpMethodIMP, "v@:@");
        return true;
    }
    return [super resolveInstanceMethod:sel];
}

@end
