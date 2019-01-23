//
//  main.m
//  Protocol-01
//
//  Created by MZN on 15/12/25.
//  Copyright © 2015年 MZN. All rights reserved.
//

/**
 
 1. 协议的定义
 
 @Protocol 协议名称 <NSObject>
    // 方法声明列表...
 @end
 
 2. 如何遵守协议
 
 1> 一个类遵守协议
 
 @interface 类名 : 父类名 <协议名称>
 
 @end
 
 
 
 2> 协议遵守协议
 
 @Protocol 协议名称 <其他协议名称1, 其他协议名称2, ...>
 
 @end
 
 
 3. 协议中方法声明的关键字
 
 1> @@required (默认)
    要求实现，如果没有实现，会发出警告
 
 2> @optional
    不要求实现
 
 4. 定义一个变量的时候，限制这个变量保存的对象遵守某个协议
 
 类名<协议名称> *变量名;
 id<协议名称> 变量名;
 NSObject<MyProtocol> *obj;
 id<MyProtocol> obj2;
 
 如果没有遵守对应的协议，编译器会警告

 5. @property中声明的数学也可用作一个遵守协议的限制
 
 @property (nonatomic, strong) 类名<协议名称> *属性名;
 @property (nonatomic, strong) id<协议名称> 属性名;
 
 @property (nonatomic, strong) Dog<MyProtocol> *dog;
 @property (nonatomic, strong) id<MyProtocol> dog2;

 6. 协议可用在单独的.h文件中，也可以用在定义某个类中
 
 1> 如果这个协议只用在某个类中，应该把协议定义在该类中
 
 2> 如果这个协议用在很多类中，就应该把协议定义单独文件中
 
 7. 分类可以定义在单的的.h和.m文件中，也可以定义在原来的类中
 
 1> 一般情况下，都是i单独文件中

 2> 定义在原来类中的分类，只要求能看懂语法
 
 */


#import <Foundation/Foundation.h>

#import "MyProtocol.h"
#import "MyProtocol3.h"

#import "Person.h"
#import "Agent.h"
#import "Agent2.h"


#import "Dog.h"
#import "Hasiqi.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        //人
        Person *p   = [[Person alloc] init];
        //代理1
        Agent  *a1  = [[Agent alloc] init];
        //代理2
        Agent2  *a2 = [[Agent2 alloc] init];

        NSLog(@"a1 = %@", a1);
        NSLog(@"a2 = %@", a2);
        
        //设置人的代理
        p.agentDelegate = a2;
        
        // 人打算看电影
        [p buyTicket];
        
    }
    return 0;
}



void test1 (){

    //要求obj保存的对象必须遵守MyProtocol协议
    NSObject<MyProtocol> *obj = [[Person alloc] init];
    obj = nil;
    
    
    id<MyProtocol> obj2 = [[Person alloc] init];
    obj2 = nil;
    
    
    //要求obj3，保存的对象必须遵守MyProtol3,并且继承了Person
    
    Person <MyProtocol3> * obj3 = [[Person alloc] init];
    obj3 = nil;

}

void test2 (){

//    Person * p = [[Person alloc] init];
//    p.obj = [[Dog alloc] init];
//    //父类继承了协议，子类拥有父类所有的协议方法声明
//    p.obj = [[Hasiqi alloc] init];

}



