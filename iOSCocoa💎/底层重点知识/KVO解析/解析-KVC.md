# KVC解析

> KVC全称是Key Value Coding，定义在NSKeyValueCoding.h文件中，是一个非正式协议。KVC提供了一种间接访问其属性方法或成员变量的机制，可以通过字符串来访问对应的属性方法或成员变量。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190214144540.png)

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

### 什么是 KVC

1. KVC 是 Key-Value-Coding 的简称。

2. KVC 是一种可以直接通过字符串的名字 key 来访问类属性的机制，而不是通过调用 setter、getter 方法去访问。

3. 我们可以通过在运行时动态的访问和修改对象的属性。而不是在编译时确定，KVC 是 iOS 开发中的黑魔法之一。

### KVC 主要方法

KVC 定义了一种按名称访问对象属性的机制，支持这种访问的主要方法是：

* 设置值

```objc
// value的值为OC对象，如果是基本数据类型要包装成NSNumber
- (void)setValue:(id)value forKey:(NSString *)key;

// keyPath键路径，类型为xx.xx
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;

// 它的默认实现是抛出异常，可以重写这个函数做错误处理。
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
```

* 获取值

```objc
- (id)valueForKey:(NSString *)key;

- (id)valueForKeyPath:(NSString *)keyPath;

// 如果Key不存在，且没有KVC无法搜索到任何和Key有关的字段或者属性，则会调用这个方法，默认是抛出异常
- (id)valueForUndefinedKey:(NSString *)key;
```

NSKeyValueCoding 类别中还有其他的一些方法:

```objc
// 允许直接访问实例变量，默认返回YES。如果某个类重写了这个方法，且返回NO，则KVC不可以访问该类。
+ (BOOL)accessInstanceVariablesDirectly;

// 这是集合操作的API，里面还有一系列这样的API，如果属性是一个NSMutableArray，那么可以用这个方法来返回
- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;

// 如果你在setValue方法时面给Value传nil，则会调用这个方法
- (void)setNilValueForKey:(NSString *)key;

// 输入一组key，返回该组key对应的Value，再转成字典返回，用于将Model转到字典。
- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;

// KVC提供属性值确认的API，它可以用来检查set的值是否正确、为不正确的值做一个替换值或者拒绝设置新值并返回错误原因。
- (BOOL)validateValue:(id)ioValue forKey:(NSString *)inKey error:(NSError)outError;
```

举个栗子：

```objc
@interface Teacher : NSObject
{
    @private
    int _age;
}

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, assign, getter = isMale) BOOL male;

- (void)log;

@end
```

这个类有私有 private 变量和只读 readonly 变量，如果用一般的 setter 和 getter，在类外部是不能访问到私有变量的，不能设值给只读变量，那是不是就拿它没办法了呢?

然而 KVC 可以做到，就是这么神奇。

```objc
Teacher *teacher = [Teacher new];
        
[teacher log];
    
// 设置 readonly value
[teacher setValue:@"Jack" forKey:@"name"];
// teacher.name = @"Jack";
   
// 设置 private value
[teacher setValue:@24 forKey:@"age"];
// teacher.age = 24;

[teacher setValue:@1 forKey:@"male"];
   
[teacher log];

// 获取 readonly value
NSLog(@"name: %@", [teacher valueForKey:@"_name"]);
   
// 获取 private value
NSLog(@"age: %d", [[teacher valueForKey:@"_age"] intValue]);
   
NSLog(@"male: %d", [[teacher valueForKey:@"isMale"] boolValue]);
```

文章后面有 demo 链接，这边就不贴打印了。

### KVC 实现细节

```objc
- (void)setValue:(id)value forKey:(NSString *)key;
```

1. 首先搜索 setter 方法，有就直接赋值。

2. 如果上面的 setter 方法没有找到，再检查类方法```+ (BOOL)accessInstanceVariablesDirectly```
    1. 返回 NO，则执行```setValue：forUNdefinedKey：```
    2. 返回 YES，则按```_<key>，_<isKey>，<key>，<isKey>```的顺序搜索成员名。
    
3. 还没有找到的话，就调用```setValue:forUndefinedKey:```

```objc
- (id)valueForKey:(NSString *)key;
```

1. 首先查找 getter 方法，找到直接调用。如果是 bool、int、float 等基本数据类型，会做 NSNumber 的转换。

2. 如果没查到，再检查类方法```+ (BOOL)accessInstanceVariablesDirectly```
    1. 返回 NO，则执行```valueForUNdefinedKey:```
    2. 返回 YES，则按```_<key>,_is<Key>,<key>,is<Key>```的顺序搜索成员名。

3. 还没有找到的话，调用```valueForUndefinedKey:```

### KVC 与点语法比较

用 KVC 访问属性和用点语法访问属性的区别：

1. 用点语法编译器会做预编译检查，访问不存在的属性编译器会报错，但是用 KVC 方式编译器无法做检查，如果有错误只能运行的时候才能发现（crash）。

2. 相比点语法用 KVC 方式 KVC 的效率会稍低一点，但是灵活，可以在程序运行时决定访问哪些属性。

3. 用 `KVC` **可以访问对象的私有成员变量**。

### KVC 应用

**字典转模型**

```objc
- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
```

**集合类操作符**

获取集合类的 count，max，min，avg，svm。确保操作的属性为数字类型，否则会报错。

```objc
NSMutableArray *bookList = [NSMutableArray array];
for (int i = 0; i <= 20; i++)  {
  Book *book = [[Book alloc] initWithName:[NSString stringWithFormat:@"book%d",i] price:i*10];
  [bookList addObject:book];
}
   
Student *student = [[Student alloc] initWithBookList:bookList];
   
Teacher *teacher = [[Teacher alloc] initWithStudent:student];

// KVC获取数组
for (Book *book in [student valueForKey:@"bookList"]) {
  NSLog(@"bookName : %@ \t price : %f",book.name,book.price);
}
   
NSLog(@"All book name  : %@",[teacher valueForKeyPath:@"student.bookList.name"]);
NSLog(@"All book name  : %@",[student valueForKeyPath:@"bookList.name"]);
NSLog(@"All book price : %@",[student valueForKeyPath:@"bookList.price"]);
   
// 计算（确保操作的属性为数字类型，否则会报错。)  五种集合运算符
NSLog(@"count of book price : %@",[student valueForKeyPath:@"bookList.@count.price"]);
NSLog(@"min of book price : %@",[student valueForKeyPath:@"bookList.@min.price"]);
NSLog(@"avg of book price : %@",[student valueForKeyPath:@"bookList.@max.price"]);
NSLog(@"sum of book price : %@",[student valueForKeyPath:@"bookList.@sum.price"]);
NSLog(@"avg of book price : %@",[student valueForKeyPath:@"bookList.@avg.price"]);
```

打印结果如下：

```objc
All book price : (
    0,
    10,
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100
)
2017-01-18 20:45:26.640887 KVC-Demo[58294:5509308] count of book price : 11
2017-01-18 20:45:26.640956 KVC-Demo[58294:5509308] min of book price : 0
2017-01-18 20:45:26.641039 KVC-Demo[58294:5509308] avg of book price : 100
2017-01-18 20:45:26.641220 KVC-Demo[58294:5509308] sum of book price : 550
2017-01-18 20:45:26.641300 KVC-Demo[58294:5509308] avg of book price : 50
```

**修改私有属性**

1.修改 TextField 的 placeholder：

```objc
[_textField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];   

[_textField setValue:[UIFont systemFontOfSize:14] forKeyPath:@“_placeholderLabel.font"];
```
2.修改 UIPageControl 的图片：

```objc
[_pageControl setValue:[UIImage imageNamed:@"selected"] forKeyPath:@"_currentPageImage"];

[_pageControl setValue:[UIImage imageNamed:@"unselected"] forKeyPath:@"_pageImage"];
```     

### KVC 总结 


**键值编码是一种间接访问对象的属性使用字符串来标识属性，而不是通过调用存取方法直接或通过实例变量访问的机制，非对象类型的变量将被自动封装或者解封成对象，很多情况下会简化程序代码。**

**优点：**

1. 不需要通过 setter、getter 方法去访问对象的属性，可以访问对象的私有属性

2. 可以轻松处理集合类(NSArray)。

**缺点：**

1. 一旦使用KVC你的编译器无法检查出错误，即不会对设置的键、键值路径进行错误检查。

2. 执行效率要低于 setter 和 getter 方法。因为使用 KVC 键值编码，它必须先解析字符串，然后在设置或者访问对象的实例变量。

3. 使用 KVC 会破坏类的封装性。



## 参考

1. [KVC原理剖析 - 简书](https://www.jianshu.com/p/1d39bc610a5b)
2. [iOS KVC](http://blog.csdn.net/u010123208/article/details/40425147)

