//
//  Person+rename.h
//  RuntimeDemo
//
//  Created by MichaelMao on 2018/9/4.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "Person.h"

@interface Person (appendName)

// @property分类:只会生成get, set方法声明,不会生成实现,也不会生成下划线成员属性
@property (nonatomic, copy) NSString *firstName;
@property NSString *lastName;

@end
