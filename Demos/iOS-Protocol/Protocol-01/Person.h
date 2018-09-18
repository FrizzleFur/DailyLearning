//
//  Person.h
//  Protocol-01
//
//  Created by MZN on 15/12/27.
//  Copyright © 2015年 MZN. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Agent.h"
#import "Hasiqi.h"
//@class Hasiqi;

//协议的提前声明， 具体方法名无法知道
@protocol MyProtocol2;
@protocol MyProtocol3;

//#import "MyProtocol2.h"
//#import "MyProtocol3.h"


//遵守协议

//protocol主要用于代理和观察模式



//@protocol TicketDelegate <NSObject>
//
//
///**
// *  返回票价
// *
// *  @return 返回票价double类型
// */
//-(double) ticketsPrice;
//
//
///**
// *  返回余票张数
// *
// *  @return 返回余票张数
// */
//-(int) letfTicketsNum;
//
//
//@end

#import "TicketDelegate.h"

@interface Person : NSObject <MyProtocol2, MyProtocol3>

@property (nonatomic, strong) id<MyProtocol2> obj;

//拥有一个代理属性//过于依赖Agent//可拓展性很差
@property (nonatomic, assign) Agent *delegate;



/** 
    1. 兼容任何类型//任何对象都可以成文Person的代理
    2. 需要知道代理有哪些方法，把代理的方法放到协议里
    3. 代理的类名不限制，但需遵守TicketDelegate的协议
*/
@property (nonatomic, assign) id<TicketDelegate> agentDelegate;


/**
 *  买电影票
 */
-(void)buyTicket;


@end
