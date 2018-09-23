# KVC 与 KVO 使用姿势和原理解析
## KVC
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

3. 用 KVC 可以访问对象的私有成员变量。

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
键值编码是一种间接访问对象的属性使用字符串来标识属性，而不是通过调用存取方法直接或通过实例变量访问的机制，非对象类型的变量将被自动封装或者解封成对象，很多情况下会简化程序代码。

**优点：**

1. 不需要通过 setter、getter 方法去访问对象的属性，可以访问对象的私有属性

2. 可以轻松处理集合类(NSArray)。

**缺点：**

1. 一旦使用KVC你的编译器无法检查出错误，即不会对设置的键、键值路径进行错误检查。

2. 执行效率要低于 setter 和 getter 方法。因为使用 KVC 键值编码，它必须先解析字符串，然后在设置或者访问对象的实例变量。

3. 使用 KVC 会破坏类的封装性。

## KVO

1. KVO 是 Key-Value-Observing 的简称。

2. KVO 是一个观察者模式。观察一个对象的属性，注册一个指定的路径，若这个对象的的属性被修改，则 KVO 会自动通知观察者。

3. 更通俗的话来说就是任何对象都允许观察其他对象的属性，并且可以接收其他对象状态变化的通知。

### KVO 基本使用

```objc
1.// 注册观察者，实施监听；
[self.person addObserver:self
              forKeyPath:@"age"
                 options:NSKeyValueObservingOptionNew
                 context:nil];

2.// 回调方法，在这里处理属性发生的变化；
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context


3.// 移除观察者；
[self removeObserver:self forKeyPath:@“age"];
```

KVO 在 Apple 中的 API 文档如下： 
>Automatic key-value observing is implemented using a technique called isa-swizzling… When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class …

Apple 使用了 isa 搅拌技术（isa-swizzling）来实现的 KVO 。当一个观察者注册对象的一个属性 isa 观察对象的指针被修改，指着一个中间类而不是在真正的类。

isa 指针的作用：每个对象都有 isa 指针，指向该对象的类，它告诉 runtime 系统这个对象的类是什么。

注：如果对 runtime 不很清楚的话可以看下这篇文章[Objective-C 中的 Runtime](http://www.jianshu.com/p/3e050ec3b759)

举个栗子：

```objc
_person = [[Person alloc] init];
    
/**
 *  添加观察者
 *
 *  @param observer 观察者
 *  @param keyPath  被观察的属性名称
 *  @param options  观察属性的新值、旧值等的一些配置（枚举值，可以根据需要设置，例如这里可以使用两项）
 *  @param context  上下文，可以为nil。
 */
[_person addObserver:self
          forKeyPath:@"age"
             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
             context:nil];
```

```objc
/**
 *  KVO回调方法
 *
 *  @param keyPath 被修改的属性
 *  @param object  被修改的属性所属对象
 *  @param change  属性改变情况（新旧值）
 *  @param context context传过来的值
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    NSLog(@"%@对象的%@属性改变了：%@",object,keyPath,change);
 }
```

```objc
/**
 *  移除观察者
 */
- (void)dealloc
{
    [self.person removeObserver:self forKeyPath:@"age"];
}
```


### KVO 实现原理

当某个类的对象第一次被观察时，系统就会在运行期动态地创建该类的一个派生类，在这个派生类中重写基类中任何被观察属性的 setter 方法。
派生类在被重写的 setter 方法实现真正的通知机制，就如前面手动实现键值观察那样。这么做是基于设置属性会调用 setter 方法，而通过重写就获得了 KVO 需要的通知机制。当然前提是要通过遵循 KVO 的属性设置方式来变更属性值，如果仅是直接修改属性对应的成员变量，是无法实现 KVO 的。
同时派生类还重写了 class 方法以“欺骗”外部调用者它就是起初的那个类。然后系统将这个对象的 isa 指针指向这个新诞生的派生类，因此这个对象就成为该派生类的对象了，因而在该对象上对 setter 的调用就会调用重写的 setter，从而激活键值通知机制。此外，派生类还重写了 dealloc 方法来释放资源。

**派生类 NSKVONotifying_Person 剖析：**

在这个过程，被观察对象的 isa 指针从指向原来的 Person 类，被 KVO 机制修改为指向系统新创建的子类 NSKVONotifying_Person 类，来实现当前类属性值改变的监听。

所以当我们从应用层面上看来，完全没有意识到有新的类出现，这是系统“隐瞒”了对 KVO 的底层实现过程，让我们误以为还是原来的类。但是此时如果我们创建一个新的名为 NSKVONotifying_Person 的类()，就会发现系统运行到注册 KVO 的那段代码时程序就崩溃，因为系统在注册监听的时候动态创建了名为 NSKVONotifying_Person 的中间类，并指向这个中间类了。

因而在该对象上对 setter 的调用就会调用已重写的 setter，从而激活键值通知机制。这也是 KVO 回调机制，为什么都俗称 KVO 技术为黑魔法的原因之一吧：内部神秘、外观简洁。

**子类 setter 方法剖析：**

KVO 在调用存取方法之前总是调用 willChangeValueForKey:，通知系统该 keyPath 的属性值即将变更。
当改变发生后，didChangeValueForKey: 被调用，通知系统该 keyPath 的属性值已经变更。
之后，observeValueForKey:ofObject:change:context: 也会被调用。

重写观察属性的 setter 方法这种方式是在运行时而不是编译时实现的。
KVO 为子类的观察者属性重写调用存取方法的工作原理在代码中相当于：

```objc
- (void)setName:(NSString *)newName
{
    [self willChangeValueForKey:@"name"];    // KVO在调用存取方法之前总调用
    [super setValue:newName forKey:@"name"]; // 调用父类的存取方法
    [self didChangeValueForKey:@"name"];     // KVO在调用存取方法之后总调用
}
```
![KVO 实现原理图](http://upload-images.jianshu.io/upload_images/1321491-aca98737b7158db9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>总结：
>KVO 的本质就是监听对象的属性进行赋值的时候有没有调用 setter 方法 

>1. 系统会动态创建一个继承于 Person 的 NSKVONotifying_Person
2. person 的 isa 指针指向的类 Person 变成 NSKVONotifying_Person，所以接下来的 person.age = newAge 的时候，他调用的不是 Person 的 setter 方法，而是 NSKVONotifying_Person（子类）的 setter 方法
3. 重写`NSKVONotifying_Person的setter方法：[super setName:newName]`
4. 通知观察者告诉属性改变。

### KVO 应用

监听 ScrollView 的 contentOffSet 属性，采取相应的措施：

```objc
[scrollview addObserver:self
             forKeyPath:@“contentOffset                   
                options:NSKeyValueObservingOptionNew
                context:nil];
```      

下面是用 KVO 写的一个通过监听 scrollview 的 contentOffSet 实现的一个小刷新功能，感兴趣的可以看下。

![gif](http://upload-images.jianshu.io/upload_images/1321491-e55e4dbf2efda347.gif?imageMogr2/auto-orient/strip)  

### KVO 总结

KVO 是一个对象能观察另一个对象属性的值，KVO 适合任何对象监听另一个对象的改变，这是一个对象与另外一个对象保持同步的一种方法。KVO 只能对属性做出反应，不会用来对方法或者动作做出反应。

优点：

1. 提供一个简单的方法来实现两个对象的同步。
2. 能够提供观察的属性的新值和旧值。
3. 每一次属性值改变都是自动发送通知，不需要开发者手动实现。
4. 用 keypath 来观察属性，因此也可以观察嵌套对象。

缺点：

1. 观察的属性必须使用字符串来定义，因此编译器不会出现警告和检查
2. 只能重写回调方法来后去通知，不能自定义 selector。当观察多个对象的属性时就要写"if"语句，来判断当前的回调属于哪个对象的属性的回调。

## 参考资料

[KVC/KVO原理详解及编程指南](http://blog.csdn.net/wzzvictory/article/details/9674431?utm_source=tuicool)
[iOS KVC](http://blog.csdn.net/u010123208/article/details/40425147)
[《招聘一个靠谱的 iOS》—参考答案（三）](http://www.jianshu.com/p/20655f394736)

## 最后
由于笔者水平有限，文中如果有错误的地方，还望大神指出。或者有更好的方法和建议，我们可以一起交流。

附上本文的所有 demo 下载链接[【GitHub】](https://github.com/leejayID/KVC-KVO)，配合 demo 一起看文章，效果会更佳。

如果你看完后觉得对你有所帮助，还望在 GitHub 上点个 star。赠人玫瑰，手有余香。



## 参考

1. [leejayID/KVC-KVO: KVC 与 KVO 使用姿势和原理解析](https://github.com/leejayID/KVC-KVO)
