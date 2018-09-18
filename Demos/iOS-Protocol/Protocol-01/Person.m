//
//  Person.m
//  Protocol-01
//
//  Created by MZN on 15/12/27.
//  Copyright © 2015年 MZN. All rights reserved.
//

#import "Person.h"


//需要用到的时候导入头文件
#import "MyProtocol2.h"
#import "MyProtocol3.h"



@implementation Person

//没空去买票
-(void)buyTicket{
    
    NSLog(@"buyTicket");

    //叫代理去帮自己买票（询问一下票价，询问一下余票张数）
    double price = [_agentDelegate ticketsPrice];
    int  num     = [_agentDelegate letfTicketsNum];
    
    NSLog(@"通过代理的帮忙，票价 = %lf, 余票张数%d", price, num);
}


-(void)protocolTest1{

    NSLog(@"protocolTest1");
}

-(void)protocolTest2{
    
    NSLog(@"protocolTest2");
}

-(void)haha2{
    NSLog(@"haha2");

}


-(void)hehe{

    NSLog(@"hehe");

}

@end
