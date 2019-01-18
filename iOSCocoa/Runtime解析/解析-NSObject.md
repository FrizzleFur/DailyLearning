# iOS文档补完计划--NSObject

[![96](https://upload.jianshu.io/users/upload_avatars/1552225/c358b707-f650-4cf2-9c20-4d7097a7970c.jpg?imageMogr2/auto-orient/strip|imageView2/1/w/96/h/96)](https://www.jianshu.com/u/f8c6149f1b15) 

[kirito_song](https://www.jianshu.com/u/f8c6149f1b15) 关注

2018.08.26 19:32* 字数 4085 阅读 616评论 10喜欢 12

![](https://upload-images.jianshu.io/upload_images/1552225-438aa43917b0cee2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/715/format/webp)

## [目录](https://www.jianshu.com/p/29dface773ad)

*   NSObject类/NSObject协议
*   类的初始化
    *   load
    *   initialize
*   创建、复制和销毁
    *   alloc
    *   allocWithZone
    *   init
    *   new
    *   copy
    *   mutableCopy
    *   copyWithZone:
    *   mutableCopyWithZone:
    *   dealloc
*   类/对象的识别与判等
    *   class
    *   superclass
    *   hash
    *   isEqual
    *   isProxy
    *   isKindOfClass
    *   isMemberOfClass
    *   isSubclassOfClass:
*   类/对象的测试
    *   instancesRespondToSelector:
    *   conformsToProtocol:
*   获取方法信息
    *   methodForSelector:
    *   instanceMethodForSelector:
*   类/对象的描述
    *   debugDescription
    *   description
*   发送消息
    *   performSelector:withObject:afterDelay:
    *   performSelector:withObject:afterDelay:inModes:
    *   performSelectorOnMainThread:withObject:waitUntilDone:
    *   performSelectorOnMainThread:withObject:waitUntilDone:modes:
    *   performSelector:onThread:withObject:waitUntilDone:
    *   performSelector:onThread:withObject:waitUntilDone:modes:
    *   performSelectorInBackground:withObject:
    *   cancelPreviousPerformRequestsWithTarget:
    *   cancelPreviousPerformRequestsWithTarget:selector:object:
*   动态解析（消息转发）
    *   解决阶段
        *   resolveClassMethod
        *   resolveInstanceMethod
    *   重定向(Fast Forwarding)
        *   forwardingTargetForSelector
    *   消息转发(Normal Forwarding)
        *   methodSignatureForSelector
        *   instanceMethodSignatureForSelector
        *   forwardInvocation
    *   错误处理
        *   doesNotRecognizeSelector:
*   Weak相关
    *   allowsWeakReference
    *   retainWeakReference

* * *

### NSObject类/NSObject协议

> 几乎所有OC对象都可以使用NSObject的方法、因为绝大部分OC对象都继承者他。

> NSObject协议

方法很多与NSObject的方法相同、只是从类方法(`为了简便`)变成了对象方法/属性这种形式。
并且、他也被`NSProxy`遵循、这点正体现了OC的多继承。比如`NSObject`与`NSProxy`对象都可以使用isKindOfClass方法。
而类对象、也可以使用对象方法(大概是因为类对象也是一种对象吧)。

所以、下文中:

1.  对于"-"的标记、本身就是可以作用于类对象的。
2.  而"+"、但并不代表只能用于类对象。(NSObject协议中可能声明了"-"的版本)。
    比如`[NSObject hash]、[[NSObject class] hash]、[[NSObject new] hash]`。

* * *

### 类的初始化

*   ##### + (void)load

> 程序运行时加载(`添加到Runtime中`)一个`Class`、或者`Category`时调用。
> 并且只会调用一次。

**1. `+(void)load`整个类最先被调用的方法**
所以、对于`method swizzle`这种从一开始就希望起作用的操作、需要放在这里。

**2\. 父类先于子类、主类优先于分类**
需要注意的是如果子类没有使用`+(void)load`方法、父类并不会被优先调用（也就是依旧按照`Compile Sources`的顺序）。
由于这个规则存在、我们也不需要主动实现`[super load]`方法。

**3\. 与`Compile Sources`的关系**
只要加入`Compile Sources`中、即使项目中没有人对其`#import`也一样会调用(`毕竟是动态语言`)。
**默认的调用的顺序**、也与`Compile Sources`中的顺序相同。

![](https://upload-images.jianshu.io/upload_images/1552225-e9a3e8b88047999e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

**4\. 不主动实现、就不会被调用**
`+ load`会按照模块被存储在`loadable_classes`/`loadable_categories`结构体中。而后取出、并且通过C函数指针调用。
所以、也不会经过消息转发的过程(`子类没实现、并不会调用父类`)。
详情可以参考[《iOS基础(九) - load和initialize的实现原理》](https://www.jianshu.com/p/66b366ed850e)

**5\. 在`load`方法被自动调用之前、一个类仍然可以被使用**
`In a custom implementation of load you can therefore safely message other unrelated classes from the same image, but any load methods implemented by those classes may not have run yet.`

也就是你可以这样写、但我不知道有什么意义~

```
@implementation Test
+ (void)load {
    [[Test3 new]hahaha];
}

```

*   ##### + (void)initialize [ɪ'nɪʃəlaɪz]

> 向一个类发送第一条消息前被调用、对于父类实现(`注意不是父类`)的调用可能不止一次。

**1\. 父类调用在子类之前**
在本类initialize(`callInitialize(cls)`)调用之前、如果父类没被调用过、会主动调用一次。并且父类中也如此实现、也就是会递归调用。

```
void _class_initialize(Class cls)
{
    assert(!cls->isMetaClass());

    Class supercls;
    bool reallyInitialize = NO;

    // Make sure super is done initializing BEFORE beginning to initialize cls.
    // See note about deadlock above.
    supercls = cls->superclass;
    if (supercls  &&  !supercls->isInitialized()) {
        _class_initialize(supercls);
    }
    ...    
    if (reallyInitialize) {
            callInitialize(cls);
    }
    ...
}

```

**2\. 如果子类未实现`+ (void)initialize`、则会调用一次父类**
所以、在官方文档以及xcode自动补全中采用以下写法

```
+ (void)initialize {
  if (self == [ClassName self]) {
    // ... do the initialization ...
  }
}

```

**3\. 每个类只会被调用一次**
分类如果实现、则不会调用主类、这与`+ (void)load`不同。
所以如果需要分别定制主类以及category、应该写在`+ (void)load`中。

**3\. 调用在`+(void)load`~~之前~~**
~~毕竟`+(void)load`也是个消息。~~
[原因是直接被`call_load_methods`方法对IMP地址进行调用、并没有经过消息机制。](http://www.cocoachina.com/ios/20170711/19799.html)

**4\. 如果一个类没有被使用(即使被`#import`)、便不会被调用**
但如果他自己实现了`+(void)load`方法、系统在调用`+(void)load`之前、会调用`+ (void)initialize`进行初始化。

> `load`和`initialize`内部都实现了加锁、是线程安全的。

* * *

### 创建、复制和销毁

*   ##### alloc

> 为该对象分配地址空间

**对象创建后、isa以外的实例变量都默认初始化为0**。

~~对于`NSObject`而言、`alloc`其实已经初始化完毕了~~。但对于其他(`比如UIView`)类、还需要init来进行进一步配置。

*   ##### allocWithZone

作用于`alloc`相同。文档上上说是由于历史原因。

*   ##### init

> 对已经分配了内存空间的对象进行进一步配置。

在某些情况下、`init`可能会返回一个新的对象(详见[《iOS架构补完计划--设计模式》](https://www.jianshu.com/p/b2005236dd67)中对于工厂模式的介绍)。

*   ##### new

> 集alloc和init于一身

相当于调用`[[Class alloc] init];`、也是一种历史遗留的产物、不过还挺方便。

*   ##### copy

通过自己实现`<NSCopying>`协议的`copyWithZone:`方法返回一个`不可变的副本`。

如果没有实现协议方法、则会崩溃。

*   ##### mutableCopy

通过自己实现`< NSMutableCopying >`协议的`mutableCopyWithZone:`方法返回一个`可变的副本`。

*   ##### + (id)copyWithZone:

*   ##### + (id)mutableCopyWithZone:

需要注意这两个方法并不是`<NSCopying/NSMutableCopying>`那个对象方法、而是系统为`类对象`实现的。

二者均被标记成`OBJC_ARC_UNAVAILABLE`、也就是ARC下不需要(~~主动实现?~~)。

但是官方文档中指出`This method exists so class objects can be used in situations where you need an object that conforms to the NSCopying protocol.`

也就是说、类对象也可以被`copy`、并且系统帮我们进行了内部实现。
需要注意的是、类对象的`copy`只是单纯的返回自身而已。
但是这个机制让我们可以将类对象作为key使用。

```
id obj0 = [Test class];
id obj1 = [Test copy];
id obj2 = [Test mutableCopy];
id obj3 = [obj0 copyWithZone:nil];
id obj4 = [obj0 mutableCopyWithZone:nil];
NSDictionary * dic = @{obj0:@"0",obj1:@"1",obj2:@"2",obj3:@"3",obj4:@"4"};

NSLog(@"%p_obj0",obj0);
NSLog(@"%p_obj1",obj1);
NSLog(@"%p_obj2",obj2);
NSLog(@"%p_obj3",obj3);
NSLog(@"%p_obj4",obj4);
NSLog(@"%@_dic",dic);

//打印
NSObject[46855:3785930] category_test_initialize
NSObject[46855:3785930] 0x10235a1d0_obj0
NSObject[46855:3785930] 0x10235a1d0_obj1
NSObject[46855:3785930] 0x10235a1d0_obj2
NSObject[46855:3785930] 0x10235a1d0_obj3
NSObject[46855:3785930] 0x10235a1d0_obj4
NSObject[46855:3785930] {
    Test = 0;
}_dic

```

###### 关于深拷贝和浅拷贝

**深拷贝**
产生新对象的情况
**浅拷贝**
是指未产生新对象的情况(`刚才对类对象的拷贝就是典型的浅拷贝`)
**简而言之**
只有不可变对象的copy方式，是浅复制，其他都是深复制。
更多可以查阅[《iOS基础深入补完计划--带你重识Property》](https://www.jianshu.com/p/be10e24d345f)

*   ##### dealloc

> 当一个对象的引用计数为0时、系统就会将这个对象释放。

我们不需要、也不应该主动调用该方法。只需要处置一些不会随着实例生命周期而变化的事情即可(比如通知、C对象的free)。

* * *

### 类/对象的识别与判等

*   ##### + class

> 返回类对象

对象的 `[someObj class]`方法、是`NSObject`的协议方法

*   ##### + superclass

> 返回父类对象

*   #### + hash

> 通常来讲、返回对象的地址(NSObject、UIView)。
> 对于字符串/字典/数组、根据内容不同可能对内容有不同的hash方式、可以看看[《解读Objective-C中的[NSString hash]方法》](https://www.jianshu.com/p/92d83bd10821)

```
id obj0 = [NSObject new];
id obj1 = [NSObject class];
id obj2 = [NSObject new];
id obj3 = [NSObject class];
id obj4 = [UIView new];
id obj5 = [UIView class];
id obj6 = [NSString new];
id obj7 = [NSString class];
id obj8 = [NSDictionary new];
id obj9 = [NSDictionary class];
id obj10 = [NSArray new];
id obj11 = [NSArray class];

NSLog(@"obj0::%zd_%ld",[obj0 hash],(NSUInteger)obj0);
NSLog(@"obj1::%zd_%ld",[obj1 hash],(NSUInteger)obj1);
NSLog(@"obj2::%zd_%ld",[obj2 hash],(NSUInteger)obj2);
NSLog(@"obj3::%zd_%ld",[obj3 hash],(NSUInteger)obj3);
NSLog(@"obj4::%zd_%ld",[obj4 hash],(NSUInteger)obj4);
NSLog(@"obj5::%zd_%ld",[obj5 hash],(NSUInteger)obj5);
NSLog(@"obj6::%zd_%ld",[obj6 hash],(NSUInteger)obj6);
NSLog(@"obj7::%zd_%ld",[obj7 hash],(NSUInteger)obj7);
NSLog(@"obj8::%zd_%ld",[obj8 hash],(NSUInteger)obj8);
NSLog(@"obj9::%zd_%ld",[obj9 hash],(NSUInteger)obj9);
NSLog(@"obj10::%zd_%ld",[obj10 hash],(NSUInteger)obj10);
NSLog(@"obj11::%zd_%ld",[obj11 hash],(NSUInteger)obj11);

//打印结果
obj0::105827994210384_105827994210384
obj1::4533444264_4533444264
obj2::105827994210416_105827994210416
obj3::4533444264_4533444264
obj4::140577323666816_140577323666816
obj5::4563397296_4563397296
obj6::0_4523287328
obj7::4523970768_4523970768
obj8::0_105553116300640
obj9::4539240872_4539240872
obj10::0_105553116300656
obj11::4539240232_4539240232

```

> hash方法只在对象被添加至NSSet和设置为NSDictionary的key时会调用

此时他会作为`key的查找以及判等`依据避免重复添加

为了优化判等的效率, 基于hash的NSSet和NSDictionary在判断成员是否相等时, 会这样做

Step 1: 集成成员的hash值是否和目标hash值相等, 如果相同进入Step 2, 如果不等, 直接判断不相等

Step 2: hash值相同(即Step 1)的情况下, 再进行对象判等, 作为判等的结果

> 也就是说。我们如果在插入对象之后手动修改了hash值、在进行查找的时候是查找不到滴。

##### 自定义hash插入NSSet/NSDictionay

由于hash只返回对象地址、我们可以通过对象内容进行自定义hash。（`特指你希望相同名字和生日不想重复插入这种情况`）

```
- (NSUInteger)hash {
    return [self.name hash] ^ [self.birthday hash];
}

```

*   ##### - isEqual

> 判断两个对象内容是否相等、并不只是单纯判断是否为同一个对象(`内存地址`)。

自定义对象需要自己实现判等逻辑。

*   ##### - isProxy

> 判断对象是否继承NSProxy

需要注意我们绝大部分的类都继承与`NSObject`而非`NSProxy`。
所以绝大部分都会返回No。你可以自己做一个继承于`NSProxy`的类来测试。

*   ##### - isKindOfClass

> 判断对象是否是指定类或其子类

具体比较的、应该是[本对象的isa指针与一个class对象](https://blog.csdn.net/ChSaDiN/article/details/51672087)、所以如果想比较一个类、请于一个类的元类进行比较(NSObject除外)。可以看下面的例子:

```
BOOL a = [NSString isKindOfClass:[NSString class]];
BOOL b = [NSString isKindOfClass:object_getClass([NSString class])];
BOOL c = [UIView isKindOfClass:[UIView class]];
BOOL d = [UIView isKindOfClass:object_getClass([UIView class])];
NSLog(@"a::%d",a);
NSLog(@"b::%d",b);
NSLog(@"c::%d",c);
NSLog(@"d::%d",d);

//打印结果
test[4039:505795] a::0
test[4039:505795] b::1
test[4039:505795] c::0
test[4039:505795] d::1

```

*   ##### - isMemberOfClass

> 判断对象是否是给定类的实例(注意不包含子类)

所比较的、依旧是isa指针。可以自己照上面试试。

**需要注意的是:**
对于`NSString/NSDictionay/NSArray`这类类族对象来说。直接用抽象产品(`NSString/NSDictionay/NSArray`)进行判等、是会失败的。

对象的 `[someObj superclass]`方法、是`NSObject`的协议方法

*   ##### + isSubclassOfClass:

> 查看一个类对象是否是另一个类对象的子类或者本身

```
BOOL a = [Test isSubclassOfClass:[Test2 class]];
BOOL b = [Test2 isSubclassOfClass:[Test class]];
BOOL c = [Test isSubclassOfClass:[Test class]];
NSLog(@"a==%d,b==%d,c==%d",a,b,c);

//打印
a==1,b==0,c==1

```

**对对象而言、并没有能直接比较从属关系的方法。**

* * *

### 类/对象的测试

*   ##### - respondsToSelector:

> 判断`对象`是否能够调用给定的(`对象`)方法。(如果用类对象来测试、自然测试的就是类方法咯)

需要注意如果只做了声明但没有实现、也是会返回No的。

*   ##### + instancesRespondToSelector:

> 用`[类对象]`测试(类)方法是否被实现

需要注意如果只做了声明但没有实现、也是会返回No的。

所以说`respondsToSelector`既可以测类方法也可以测实例方法。
`instancesRespondToSelector`则可以用类对象来测试类方法。

*   ##### + conformsToProtocol:

> 测试一个类是否`遵循`了某个协议

主要注意：1、遵循不代表实现。2、遵循不代表必须在.h中声明。

* * *

### 获取方法信息

*   ##### - methodForSelector:

*   ##### + instanceMethodForSelector:

> 分别返回类/对象的某个对象方法以及类方法的`实现(IMP)`

* * *

### 类/对象的描述

*   ##### + debugDescription

> 控制台中打印的信息、就是通过这个方法输出。

类方法只打印出了类名、实例方法(`NSObject协议`)可能会打印出更多内容。

*   ##### + description

> NSLog、就是通过这个方法输出。

类方法只打印出了类名、实例方法(`NSObject协议`)可能会打印出更多内容。

* * *

### 发送消息

*   ##### - performSelector:withObject:afterDelay:

> 在延迟之后在`当前线程`上调用某对象的方法。

*   ##### - performSelector:withObject:afterDelay:inModes:

> 在延迟之后使用指定的`Runloop模式`在`当前线程`上调用某对象的方法。

*   ##### - performSelectorOnMainThread:withObject:waitUntilDone:

> 使用在`主线程`上调用某对象的方法

*   ##### - performSelectorOnMainThread:withObject:waitUntilDone:modes:

> 使用指定的`Runloop模式`在`主线程上`调用某对象的方法。

*   ##### - performSelector:onThread:withObject:waitUntilDone:

> 在`指定线程上`调用某对象的方法

*   ##### - performSelector:onThread:withObject:waitUntilDone:modes:

> 使用指定的`Runloop模式`在指定的线程上调用某对象的方法

*   ##### - performSelectorInBackground:withObject:

> 在新的`后台线程上`调用某对象的方法

*   ##### + cancelPreviousPerformRequestsWithTarget:

> 取消执行某对象先前注册的`所有`请求。

*   ##### + cancelPreviousPerformRequestsWithTarget:selector:object:

> 取消执行某对象先前注册的`指定selector`请求。

`object`参数必须与注册时相同(并不需要是同一个、但内部会经过`isEqual`判断)。

> ##### 需要注意的是
> 
> **1\. 关于RunloopMode**
> 如果没有声明指定的`Runloop模式`、那么就会使用默认`NSDefaultRunLoopMode`。
> 如果(正式发送消息时)当前Runloop模式不匹配、则会等待直到Runloop切换到对应模式。
> **2\. 关于wait参数:**
> 一个布尔值，指定当前线程是否阻塞，直到在主线程上的接收器上执行指定的选择器之后。指定YES阻止此线程; 否则，指定NO立即返回此方法。
> 如果当前线程也是主线程，并且您YES为此参数指定，则会立即传递和处理消息。
> **3\. 关于取消**
> 只有在使用`afterDelay`参数的方法上才可以工作

* * *

### 动态解析（消息转发）

> 如果runtime调用了一个未实现的方法、在崩溃(`unrecognized selector`)之前会经过一下四步。

*   ##### 解决阶段

**+ resolveClassMethod:**
**+ resolveInstanceMethod:**

> 允许尝试解决这个问题、无论返回YES/NO。(~~这个我查了很久也没能找到返回值到底有什么用...~~)

比如用runtime、为当前类添加这个方法实现。举一个官方文档的例子：

```

void dynamicMethodIMP(id self, SEL _cmd)
{
    // implementation ....
}

+ (BOOL) resolveInstanceMethod:(SEL)aSEL
{
    if (aSEL == @selector(resolveThisMethodDynamically))
    {
          class_addMethod([self class], aSEL, (IMP) dynamicMethodIMP, "v@:");
          return YES;
    }
    return [super resolveInstanceMethod:aSel];
}

```

官方文档中还有这样一句话:
`This method is called before the Objective-C forwarding mechanism is invoked. If respondsToSelector: or instancesRespondToSelector: is invoked, the dynamic method resolver is given the opportunity to provide an IMP for the given selector first.`
也就是说、这个方法会在启用消息转发前小调用。并且动态添加的方法可以被`respondsToSelector`/`instancesRespondToSelector`识别。

*   ##### 重定向(Fast Forwarding)

**- forwardingTargetForSelector**

> 允许我们为消息指定一个新的对象进行响应。

如果在前一步你没能对问题进行解决、runtime允许你将这个消息转发给一个特定的类。

从文档规范上来讲、你需要这样实现：

1.  返回一个非nil以及非self的对象。
2.  不知道返回啥应该返回super调用(或者干脆别实现了)
3.  如果你指向做单纯的消息转发、用这个。反之如果想要做更高级的事(比如修改参数等等)、这个方法做不到。应该用下面的。

*   ##### 消息转发(Normal Forwarding)

**- methodSignatureForSelector**
**+ instanceMethodSignatureForSelector**

> 正常情况下：通过SEL获取某个类/对象的对应方法签名

> 在消息转发(决议)的阶段：`如果返回一个函数签名，系统就会创建一个NSInvocation对象并调用(下一步)-forwardInvocation:方法`

```
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
    }
    return methodSignature;
}

```

**- forwardInvocation:**

> 允许对方法签名进行转发(并由该对象尝试执行)

```
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    Test2 *test2 = [Test2 new];
    if ([test2 respondsToSelector:anInvocation.selector]) {

//        NSString * str;
//        [anInvocation getArgument:&str atIndex:2];
        NSString * str = @"5";
        [anInvocation setArgument:&str atIndex:2];

        [anInvocation invokeWithTarget:test2];
        //需要注意的是这里的invaction是不需要、也不能调用invoke执行的。否则会执行两次
//        [anInvocation invoke];

    }else {
        [super forwardInvocation:anInvocation];
    }
}

```

1.  这里新的`Target`对象会尝试响应该方法。
2.  如果新的`Target`对象依旧未实现该方法、会由该对象继续进行决议(也允许继续转发)。
3.  参数在`methodSignatureForSelector`返回签名之后已经自动设置好了。我们只需要指定新的`Target`便可。
4.  签名的返回值将会发回给原调用方。

*   ##### 错误处理

**- doesNotRecognizeSelector:**

> 处理接收方无法识别的消息

这个方法必须要调用父类实现、不推荐(允许)颠覆。否则将不会抛出错误信息。

```
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    //弹窗啊、打点啊、等等等等
    [super doesNotRecognizeSelector:aSelector];
}

```

官方提供了一写应用举例。当你不允许别人使用某个方法:

```
- (id)copy/init
{
    [self doesNotRecognizeSelector:_cmd];
}

```

> ##### 需要注意的是
> 
> 除非你从`resolveInstanceMethod`/`resolveClassMethod`阶段就用runtime添加了方法。不然每一次调用该方法都需要重新走一次消息转发的过程。详情可以去看看send_msg中的方法缓存逻辑。

* * *

### Weak相关

*   ##### - allowsWeakReference:

> 允许弱引用标量、对于所有`allowsWeakReference`方法返回NO的类都绝对不能使用__weak修饰符。否则会崩溃。

*   ##### - retainWeakReference

> 保留弱引用变量、在使用__weak修饰符的变量时、当被赋值对象的`retainWeakReference`方法返回NO的情况下、该变量将使用“nil” 。

* * *

### 最后

本文主要是自己的学习与总结。如果文内存在纰漏、万望留言斧正。如果愿意补充以及不吝赐教小弟会更加感激。

* * *

### 参考资料

[官方文档 - NSObject_Class](https://developer.apple.com/documentation/objectivec/nsobject?language=objc)
[NSObject Class 浅析](https://blog.csdn.net/adamska0104/article/details/54949880)
[iOS类方法load和initialize详解](https://www.jianshu.com/p/c52d0b6ee5e9)
[ios开发 之 NSObject详解](https://blog.csdn.net/zeng_zhiming/article/details/70225456)
[iOS基础(九) - load和initialize的实现原理](https://www.jianshu.com/p/66b366ed850e)
[NSObject之一](http://www.cocoachina.com/ios/20150205/11113.html)
[深入理解Objective-C的Runtime机制](https://www.csdn.net/article/2015-07-06/2825133-objective-c-runtime/5)