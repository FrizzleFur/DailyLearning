//
//  MyProtocol.h
//  Protocol-01
//
//  Created by MZN on 15/12/27.
//  Copyright © 2015年 MZN. All rights reserved.
//

#ifndef MyProtocol_h
#define MyProtocol_h


#import <Foundation/Foundation.h>

//定义了一个名叫protocol的协议
@protocol MyProtocol <NSObject>


@required

- (void)protocolTest1;

- (void)protocolTest2;


@optional

- (void)protocolTest3;


@end


#endif /* MyProtocol_h */





