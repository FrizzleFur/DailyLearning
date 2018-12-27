//
//  TicketDelegate.h
//  Protocol-01
//
//  Created by MZN on 15/12/27.
//  Copyright © 2015年 MZN. All rights reserved.
//

#ifndef TicketDelegate_h
#define TicketDelegate_h


@protocol TicketDelegate <NSObject>


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



#endif /* TicketDelegate_h */
