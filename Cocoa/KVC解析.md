
# KVC解析


> KVC全称是Key Value Coding，定义在NSKeyValueCoding.h文件中，是一个非正式协议。KVC提供了一种间接访问其属性方法或成员变量的机制，可以通过字符串来访问对应的属性方法或成员变量。

![](http://oc98nass3.bkt.clouddn.com/15359757363122.jpg)

### 基础操作

`KVC`主要对三种类型进行操作，基础数据类型及常量、对象类型、集合类型。

```objc
@interface BankAccount : NSObject
@property (nonatomic, strong) NSNumber *currentBalance;
@property (nonatomic, strong) Person *owner;
@property (nonatomic, strong) NSArray<Transaction *> *transactions;
@end
```

在使用`KVC`时，直接将属性名当做`key`，并设置`value`，即可对属性进行赋值。

```objc
[myAccount setValue:@(100.0) forKey:@"currentBalance"];
```



## 参考

1. [KVC原理剖析 - 简书](https://www.jianshu.com/p/1d39bc610a5b)
