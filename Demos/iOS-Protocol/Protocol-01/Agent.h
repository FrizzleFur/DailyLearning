//
//  Agent.h
//  Protocol-01
//
//  Created by MZN on 15/12/27.
//  Copyright © 2015年 MZN. All rights reserved.
//

#import <Foundation/Foundation.h>


//代理
@interface Agent : NSObject

/**
 *  返回票价
 *
 *  @return 返回票价double类型
 */
-(double) ticketsPrice;


/**
 *  返回余票张数
 *
 *  @return 返回余票张数
 */
-(int) letfTicketsNum;




@end
