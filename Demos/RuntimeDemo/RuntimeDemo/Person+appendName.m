//
//  Person+appendName.m
//  RuntimeDemo
//
//  Created by MichaelMao on 2018/9/4.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "Person+appendName.h"
#import <objc/runtime.h>

@implementation Person (appendName)

#pragma mark - 交换方法

+ (void)load {
    
    Method originalSelector = class_getInstanceMethod(self, @selector(printName:));
    Method swizzleSelector = class_getInstanceMethod(self, @selector(zn_printName:));
    method_exchangeImplementations(originalSelector, swizzleSelector);
}

- (void)zn_printName:(NSString *)name{
    
    //插入逻辑
    NSString *appendName = name;
    if (name != nil) {
        appendName = [[NSString alloc] initWithFormat:@"%@---appendName", name];
    }
    [self zn_printName:appendName];
}

#pragma mark - 属性绑定

- (void)setFirstName:(NSString *)firstName{
    objc_setAssociatedObject(self, @selector(firstName), firstName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)firstName{
    return objc_getAssociatedObject(self, @selector(firstName));
}

- (void)setLastName:(NSString *)lastName{
    objc_setAssociatedObject(self, @selector(lastName), lastName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)lastName{
    return objc_getAssociatedObject(self, @selector(lastName));
}

@end
