//
//  NSObject+Model.m
//  RuntimeDemo
//
//  Created by MichaelMao on 2018/9/5.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "NSObject+Model.h"
#import <objc/message.h>

@implementation NSObject (Model)

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    
    id objc = [[self alloc] init];
    
    unsigned int count = 2;
    
    // 获取当前类的成员变量
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    // 变量所有成员变量
    for (int i = 0; i < count; i ++) {
        
        // 获取成员变量
        Ivar ivar = ivarList[i];
        
        // 获取成员变量的名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 获取Key
        NSString *key = [ivarName substringFromIndex:1];
        
        // 字典中查找对应的value
        id value = dict[key];
        
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        // @\"User\" -> User
        ivarType = [ivarType stringByReplacingOccurrencesOfString :@"\"" withString: @""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString: @"@" withString: @""];
        
        // 二级转换，判断value是否是字典，如果是自定义对象，尝试转换成model
        if ([value isKindOfClass:[NSDictionary class]] && ![ivarType hasPrefix:@"NS"]) {
            // 获取类
            Class modelClass = NSClassFromString(ivarType);
            value = [modelClass modelWithDict:value];
        }
        
        if (value) {
            [objc setValue:value forKey:key];
        }
        NSLog(@"key = %@", key);
    }
    
    return objc;
}

@end
