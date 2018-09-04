//
//  Person.h
//  RuntimeDemo
//
//  Created by MichaelMao on 2018/9/4.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

- (void)printName:(NSString *)name;

/** 未实现的方法 */
- (void)unImpMethod;

@end
