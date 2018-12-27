//
//  MyProtocol3.h
//  Protocol-01
//
//  Created by MZN on 15/12/27.
//  Copyright © 2015年 MZN. All rights reserved.
//

#ifndef MyProtocol3_h
#define MyProtocol3_h


//一个协议遵守了另外一个协议，就可以拥有这份协议中的所有方法声明
#import "MyProtocol.h"

@protocol MyProtocol3 <MyProtocol>

-(void)hehe;

@end


#endif /* MyProtocol3_h */
