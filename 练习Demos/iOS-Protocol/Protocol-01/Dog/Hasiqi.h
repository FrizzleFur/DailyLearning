//
//  Hasiqi.h
//  Protocol-01
//
//  Created by MZN on 15/12/27.
//  Copyright © 2015年 MZN. All rights reserved.
//

#import "Dog.h"


//协议只和这个类有关的时候，直接写在类的头文件里即可
@protocol MyDogProtocol <NSObject>

-(void)MyDogMethod;

@end

@interface Hasiqi : Dog

@end

//可以把分类写在类的头文件里//但是大部分都是在单独文件里，尽量把分类写在单独的文件中
@interface Hasiqi (AddCategory)

-(void)addTest;

@end
