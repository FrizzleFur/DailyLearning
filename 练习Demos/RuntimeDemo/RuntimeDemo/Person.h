//
//  Person.h
//  RuntimeDemo
//
//  Created by MichaelMao on 2018/9/4.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Person : NSObject

@property (nonatomic, copy) NSString *school;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) User *user;

- (void)printName:(NSString *)name;

/** 未实现的方法 */
- (void)unImpMethod;

@end
