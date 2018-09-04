//
//  ViewController.m
//  RuntimeDemo
//
//  Created by MichaelMao on 2018/9/4.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
#import "Person.h"
#import "Person+appendName.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
      [self testAssoicateObject];
}

#pragma mark - 消息转发

- (void)msgSend{
    
    Person *person = [[Person alloc] init];
    //    Person *p = objc_msgSend(object_getClass(person), sel_registerName("alloc"));
    Person *p = objc_msgSend(objc_getClass("Person"), sel_registerName("alloc"));
    p = objc_msgSend(p, sel_registerName("init"));
    NSLog(@"%@-----%@", person, p);
    //调用实例方法
    objc_msgSend(p, @selector(printName:), @"MyName");
}

#pragma mark - 动态添加方法

- (void)dynamicAddMethod{

    Person *person = [[Person alloc] init];
//    [person unImpMethod];
    [person performSelector:@selector(unImpMethod) withObject:@"parameter"];
}

#pragma mark - 添加属性

//添加属性本质:让某个属性与某个对象产生-一个关联
- (void)testAssoicateObject{
    
    Person *person = [[Person alloc] init];
    person.lastName = @"Smith";
    NSLog(@"person.lastName = %@", person.lastName);
}

#pragma mark - PSTCollection/UICollection interoperability
// 环信的SDK中的方法
//消息转发实现动态添加方法

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *sig = [super methodSignatureForSelector:selector];
    if(!sig) {
        NSString *selString = NSStringFromSelector(selector);
        if ([selString hasPrefix:@"_"]) {
            SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
            sig = [super methodSignatureForSelector:cleanedSelector];
        }
    }
    return sig;
}


- (void)forwardInvocation:(NSInvocation *)inv {
    NSString *selString = NSStringFromSelector([inv selector]);
    if ([selString hasPrefix:@"_"]) {
        SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
        if ([self respondsToSelector:cleanedSelector]) {
            // dynamically add method for faster resolving
            Method newMethod = class_getInstanceMethod(self.class, [inv selector]);
            IMP underscoreIMP = imp_implementationWithBlock(^(id _self) {
                return objc_msgSend(_self, cleanedSelector);
            });
            class_addMethod(self.class, [inv selector], underscoreIMP, method_getTypeEncoding(newMethod));
            // invoke now
            inv.selector = cleanedSelector;
            [inv invokeWithTarget:self];
        }
    }else {
        [super forwardInvocation:inv];
    }
}

@end
