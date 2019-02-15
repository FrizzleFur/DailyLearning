> `Runtime`一直被一些开发者津津乐道，它强大的API可以帮助你更好的理解OC的运行时机制，也是项目中不可缺少的“黑魔法”。本篇将结合一些优秀的`Runtime`文章，简单介绍`Runtime`原理以及其应用。

## `Runtime`运行时的机制

* 对于C语言，函数的调用在编译的时候会决定调用哪个函数。 在编译阶段，C语言调用未实现的函数就会报错。
* 对于`Objective-C`的函数，属于动态调用过程，在编译的时候并不能决定真正调用哪个函数，只有在真正运行的时候才会根据函数的名称找到对应的函数来调用。在编译阶段，`Objective-C`可以调用任何函数，即使这个函数并未实现，只要声明过就不会报错。

* `Objective-C`语言是一门动态语言，它将很多静态语言在编译和链接时期做的事放到了运行时来处理。这种动态语言的优势在于：我们写代码时更具灵活性，如我们可以把消息转发给我们想要的对象，或者随意交换一个方法的实现等。
* 这种特性意味着`Objective-C`不仅需要一个编译器，还需要一个运行时系统来执行编译的代码。对于`Objective-C`来说，这个运行时系统就像一个操作系统一样：它让所有的工作可以正常的运行。这个运行时系统即`Objc Runtime`。`Objc Runtime`其实是一个`Runtime`库，它基本上是用C和汇编写的，这个库使得C语言有了面向对象的能力。

<!-- more -->

## `Runtime`运行时的作用

* 能获得某个类的所有成员变量
* 能获得某个类的所有属性
* 能获得某个类的所有方法
* 交换方法实现
* 能动态添加一个成员变量
* 能动态添加一个属性
* 字典转模型
* `Runtime`归档/反归档

## `Runtime`运行时的优点

1. 实现多继承`Multiple Inheritance`
2. `Method Swizzling`
3. 面向切面编程`Aspect Oriented Programming`（在运行时，动态地将代码切入到类的指定方法、指定位置上的编程思想就是面向切面的编程。）
4. `Isa Swizzling` 
5. 使用`Associated Object`关联对象
6. 动态的添加方法
7. `NSCoding`的自动归档和自动解档
8. 字典和模型互相转换


## `Runtime`的术语

> 先明白`Runtime`的一些常用术语

1. `objc_object` ：`Objective-C`对象的定义，根据其`isa`指针就可以顺藤摸瓜找到对象所属的类
2. `objc_class` ： `Objective-C`类的定义，类也是一种对象，**类方法可以理解成类对象的实例方法。每个类仅有一个类对象，而每个类对象仅有一个与之相关的元类**
3. `isa指针`：`Objective-C`中，类和类的实例在本质上没有区别，都是对象，任何对象都有`isa`指针，它指向类或元类（元类后面会讲解）。
4. `SEL`：`SEL`方法选择器，是**方法名`selector`的指针**。方法的`selector`表示**运行时方法的名字**。`Objective-C`在编译时，会依据每一个方法的名字、参数，生成一个唯一的**整型标识**(Int类型的地址)，这个标识就是`SEL`。
5. `IMP`：`IMP`是一个**函数指针**，指向方法最终实现的首地址。`SEL`就是为了查找方法的最终实现`IMP`。
6. `Method`：用于表示类定义中的方法，它的结构体中包含一个`SEL`和`IMP`，相当于在`SEL`和`IMP`之间作了一个映射。
7. 消息机制：任何方法的调用本质就是发送一个消息。编译器会将消息表达式`[receiver message]`转化为一个消息函数`objc_msgSend(receiver, selector)`。

### `objc_object`

常见的`id` 它是一个指向类实例（`objc_object`类型）的指针 ` typedef struct objc_object *id;`

而`objc_object`类型的结构如下

```objc
struct objc_object {
private:
    isa_t isa;

public:

    // ISA() assumes this is NOT a tagged pointer object
    Class ISA();

    // getIsa() allows this to be a tagged pointer object
    Class getIsa();
    ... 此处省略其他方法声明
}
```

根据 `isa` 就可以顺藤摸瓜找到对象所属的类；
由此可见，所有的`Objective-C`类和对象，在`Runtime`层都是用`struct`结构表示。

### `objc_class`


类的定义
```objc
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;
```
`objc_class`的定义

```objc
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;
    const char *name                                         OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
#endif


} OBJC2_UNAVAILABLE;
/* Use `Class` instead of `struct objc_class *` */

#endif
```

在版本`objc4-680`的`Runtime`源码中的数据结构定义中

```objc
struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
    class_rw_t *data() { 
        return bits.data();
    }
    ... 省略其他方法
}
```
可以看到`objc_class`是继承`objc_object`的，说明`ObjC` 类本身同时也是一个对象。为了处理类和对象的关系，`Runtime` 库创建了一种叫做元类 (`Meta Class`) 的概念，类对象所属类型就叫做元类，它用来表述类对象本身所具备的元数据（类方法等）

**类方法可以理解成类对象的实例方法。每个类仅有一个类对象，而每个类对象仅有一个与之相关的元类**

当你发出一个类似` [NSObject alloc]` 的消息时，你事实上是把这个消息发给了一个类对象 (`Class Object`) ，这个类对象必须是一个元类的实例，而这个元类同时也是一个根元类 (`root meta class`) 的实例。所有的元类最终都指向根元类为其超类。

所有的元类的方法列表都有能够响应消息的类方法。所以当 `[NSObject alloc]` 这条消息发给类对象的时候，`objc_msgSend()` 会去它的元类里面去查找能够响应消息的方法，如果找到了，然后对这个类对象执行方法调用。

### `isa`
根据 `isa` 就可以顺藤摸瓜找到对象所属的类
PS: `isa` 指针不总是指向实例对象所属的类，不能依靠它来确定类型，而是应该用 `class` 方法来确定实例对象的类。因为`KVO`的实现机理就是将被观察对象的 isa 指针指向一个中间类而不是真实的类

### `SEL`

`SEL` 区分方法的 `ID`，而这个 `ID` 的数据结构是`SEL`,**其实它就是个映射到方法的C字符串**，你可以用 `Objc` 编译器命令 `@selector()` 或者 `Runtime` 系统的 `sel_registerName` 函数来获得一个 `SEL` 类型的方法选择器。
它是一个模仿C的构造指针类型的对象，可以定义很多方法指针。 常作为形参。 用于运行时或者多类之间隔文件 传递方法。
* `@selector`是查找当前类的实例方法，而`[object @selector(方法名:方法参数..) ]` ;是取object所属类的实例方法.
* 查找类方法时，除了方法名,方法参数也查询条件之一.
* 可以运行中用`SEL`变量反向查出方法名字字符串

1. 方法的存储位置
- 每个类的方法列表都存储在类对象中 （`struct objc_method_list **methodLists`）
- 每个方法都有一个与之对应的`SEL`类型的对象（方法名的指针）根据`SEL`对象就可以找到对应方法的地址，进而调用该方法。

2. `SEL`对象的创建

```objc
SEL sel = @selector(testMethodName);
SEL sel2 = NSSelectorFromString(@"testMethodName");
```

3. `SEL`对象转`NSString`

```objc
NSString *testSelStr = NSStringFromSelector(sel2);
NSString *testClassStr = NSStringFromClass([self class]);
SEL sel = NSSelectorFromString(@"testMethodName");
[self performSelector:sel]
```

### `IMP`

`IMP`实际上是一个函数指针，指向方法实现的首地址。其定义如下：

```objc
if !OBJC_OLD_DISPATCH_PROTOTYPES
typedef void (*IMP)(void /* id, SEL, ... */ );
else
typedef id (*IMP)(id, SEL, ...);
endif
```

这个函数使用当前 CPU 架构实现的标准的 C 调用约定。第一个参数是指向 `self` 的指针(如果是实例方法，则是类实例的内存地址；如果是类方法，则是指向元类的指针)，第二个参数是方法选择器(`selector`)，接下来是方法的实际参数列表。
前面介绍过的 `SEL` 就是为了查找方法的最终实现 `IMP` 的。**由于每个方法对应唯一的 `SEL`**，因此我们可以通过 `SEL` 方便快速准确地获得它所对应的 `IMP`，查找过程将在下面讨论。取得 `IMP` 后，我们就获得了执行这个方法代码的入口点，此时，我们就可以像调用普通的 C 语言函数一样来使用这个函数指针了。
通过取得 `IMP`，我们可以跳过 `Runtime` 的消息传递机制，直接执行 `IMP` 指向的函数实现，这样省去了 `Runtime` 消息传递过程中所做的一系列查找操作，会比直接向对象发送消息高效一些。


### `Method`

介绍完 `SEL` 和 `IMP`，我们就可以来讲讲 `Method` 了。`Method` 用于表示类定义中的方法，则定义如下：

```objc
typedef struct objc_method *Method;
struct objc_method {
    SEL method_name                 OBJC2_UNAVAILABLE;  // 方法名
    char *method_types                  OBJC2_UNAVAILABLE;
    IMP method_imp                      OBJC2_UNAVAILABLE;  // 方法实现
}
```

我们可以看到该结构体中包含一个 `SEL` 和 `IMP`，实际上相当于在 `SEL` 和 `IMP` 之间作了一个映射。有了 `SEL`，我们便可以找到对应的 `IMP`，从而调用方法的实现代码。

`objc_method_description`定义了一个`Objective-C`方法，其定义如下：

```objc
struct objc_method_description {
	SEL name;               /**< The name of the method */
	char *types;            /**< The types of the method arguments */
};
```


## 消息机制

> 消息发送（`Messaging`）是 **`Runtime` 通过 `selector` 快速查找 `IMP` 的过程**，有了函数指针就可以执行对应的方法实现；**消息转发（`Message Forwarding`）是在查找 `IMP` 失败后执行一系列转发流程的慢速通道，如果不作转发处理，则会打日志和抛出异常。**

![Objective-C消息发送和转发流程图](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15143584958990.jpg)

当执行了`[receiver message]`的时候，相当于向`receiver`发送一条消息`message`。`Runtime`会根据`reveiver`能否处理这条`message`，从而做出不同的反应。

#### 方法的调用流程

消息直到运行时才绑定到方法的实现上。编译器会将消息表达式`[receiver message]`转化为一个消息函数，即`objc_msgSend(receiver, selector)`。	
![](https://i.imgur.com/2EO8fz2.jpg)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-08-15-15027671461420.png)

#### objc_msgSend

Objective-C 方法的调用，会转换成消息发送的代码，如 `id objc_msgSend(id self, SEL op, ...)`;`...`表示可变参数，方法的参数可能会有多个。

```objc
MyClass *myObject = [[MyClass alloc] initWithString:@"someString"];
```

上述代码会被编译器转换成：

```objc
class myClass = objc_getClass("MyClass");
SEL allocSelector = @selector(alloc);
MyClass *myObject1 = objc_msgSend(myClass, allocSelector);

SEL initSelector = @selector(initWithString:);
MyClass *myObject2 = objc_msgSend(myObject1, initSelector, @"someString");
```

`objc_msgSend`做了如下事情：

1. （把方法名注册成方法编号）检测这个 `selector` 是不是要忽略的，或者是不是 nil 对象，是则忽略。
2. 如果满足查找条件，通过对象的`isa`指针获取类的结构体。开始查找这个类的 `IMP`，先从 `cache` 里面找，完了找得到就跳到对应的函数去执行。
3. 如果 `cache` 找不到就在类的方法分发表`objc_method_list`中查找
3. 如果没有找到`selector`，则通过`objc_msgSend`结构体中指向父类的指针找到父类，并在父类的方法表里查找方法的`selector`。
4. 依次会一直找到`NSObject`。
5. 一旦找到`selector`，就会获取到方法实现`IMP`。
6. 传入相应的参数来执行方法的具体实现。
7. 如果最终没有定位到`selector`，就会走消息转发流程。

![objc_msgSend流程](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15143579087191.jpg)

#### 重定向

在消息转发机制执行前，`Runtime` 系统会再给我们一次偷梁换柱的机会，即通过重载`- (id)forwardingTargetForSelector:(SEL)aSelector`方法替换消息的接受者为其他对象

### 消息转发机制

以 `[receiver message]`的方式调用方法，如果`receiver`无法响应`message`，编译器会报错。但如果是以`performSelector`来调用，则需要等到运行时才能确定`object`是否能接收`message`消息。如果不能，则程序崩溃。
当我们不能确定一个对象是否能接收某个消息时，会先调用`respondsToSelector:`来判断一下
	
##### `respondsToSelector`

* 如果不使用`respondsToSelector:`来判断，那么这就可以用到“消息转发”机制。
* 当对象无法接收消息，就会启动消息转发机制，通过这一机制，告诉对象如何处理未知的消息。

这样就可以采取一些措施，让程序执行特定的逻辑，从而避免崩溃。措施分为三个步骤。

##### 1. 动态方法解析

对象接收到未知的消息时，首先会调用所属类的类方法`+resolveInstanceMethod:(实例方法)`或 者`+resolveClassMethod:(类方法)`。
在这个方法中，我们有机会为该未知消息新增一个”处理方法”。使用该“处理方法”的前提是已经实现，只需要在运行时通过class_addMethod函数，动态的添加到类里面就可以了。代码如下。
	
```objc
class_addMethod
```

##### 2. 备用接收者

如果在上一步无法处理消息，则Runtime会继续调`forwardingTargetForSelector`方法。

如果这个方法返回一个对象，则这个对象会作为消息的新接收者。注意这个对象不能是self自身，否则就是出现无限循环。如果没有指定对象来处理aSelector，则应该 `return [super forwardingTargetForSelector:aSelector]`。
但是我们只将消息转发到另一个能处理该消息的对象上，无法对消息进行处理，例如操作消息的参数和返回值。

##### 3. 完整消息转发

如果在上一步还是不能处理未知消息，则唯一能做的就是启用完整的消息转发机制。此时会调用以下方法：
	
`forwardInvocation`
这是最后一次机会将消息转发给其它对象。创建一个表示消息的NSInvocation对象，把与消息的有关全部细节封装在anInvocation中，包括selector，目标(target)和参数。在forwardInvocation 方法中将消息转发给其它对象。
`forwardInvocation:`方法的实现有两个任务：
	
```
a. 定位可以响应封装在anInvocation中的消息的对象。
b. 使用anInvocation作为参数，将消息发送到选中的对象。anInvocation将会保留调用结果，runtime会提取这一结果并发送到消息的原始发送者。
```

在这个方法中我们可以实现一些更复杂的功能，我们可以对消息的内容进行修改。另外，若发现消息不应由本类处理，则应调用父类的同名方法，以便继承体系中的每个类都有机会处理。
另外，必须重写下面的方法：
	
```
methodSignatureForSelector
```
消息转发机制从这个方法中获取信息来创建NSInvocation对象。完整的示例如下：
	
`NSObject`的`forwardInvocation`方法只是调用了`doesNotRecognizeSelector`方法，它不会转发任何消息。如果不在以上所述的三个步骤中处理未知消息，则会引发异常。
`forwardInvocation`就像一个未知消息的分发中心，将这些未知的消息转发给其它对象。或者也可以像一个运输站一样将所有未知消息都发送给同一个接收对象，取决于具体的实现。

消息的转发机制可以用下图来帮助理解。
	
![消息的转发机制](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15134116331645.jpg)

#### 消息的转发机制

=======================================================================
可能很多童鞋初学` Objective-C` 时会把` [receiver message] `当成简单的方法调用，而无视了“发送消息”这句话的深刻含义。其实 `[receiver message]` 会被编译器转化为：

```
objc_msgSend(receiver, selector)
```
如果消息含有参数，则为：

```
objc_msgSend(receiver, selector, arg1, arg2, ...)
```
如果消息的接收者能够找到对应的 `selector`，那么就相当于直接执行了接收者这个对象的特定方法；否则，消息要么被转发，或是临时向接收者动态添加这个 `selector` 对应的实现内容，要么就干脆玩完崩溃掉。

现在可以看出 `[receiver message] `真的不是一个简简单单的方法调用。因为这只是在编译阶段确定了要向接收者发送 message 这条消息，而 receive 将要如何响应这条消息，那就要看运行时发生的情况来决定了。
从上述代码中可以看到，`objc_msgSend`（就arm平台而言）的消息分发分为以下几个步骤：

* 判断`receiver`是否为nil，也就是objc_msgSend的第一个参数self，也就是要调用的那个方法所属对象
* 从缓存里寻找，找到了则分发，否则
* 利用objc-class.mm中`_class_lookupMethodAndLoadCache3`（为什么有个这么奇怪的方法。本文末尾会解释）方法去寻找`selector`
    - 如果支持GC，忽略掉非GC环境的方法（retain等）
    - 从本`class`的`method list`寻找`selector`，如果找到，填充到缓存中，并返回`selector`，否则
    - 寻找父类的`method list`，并依次往上寻找，直到找到selector，填充到缓存中，并返回selector，否则
    - 调用`_class_resolveMethod`，如果可以动态resolve为一个`selector`，不缓存，方法返回，否则
    - 转发这个selector，否则
* 报错，抛出异常

当一个方法在比较“上层”的类中，用比较“下层”（继承关系上的上下层）对象去调用的时候，如果没有缓存，那么整个查找链是相当长的。就算方法是在这个类里面，当方法比较多的时候，每次都查找也是费事费力的一件事情。
考虑下面的一个调用过程：

```objc
for ( int i = 0; i < 100000; ++i) {
    MyClass *myObject = myObjects[i];
    [myObject methodA];
}
```

当我们需要去调用一个方法数十万次甚至更多地时候，查找方法的消耗会变的非常显著。
就算我们平常的非大规模调用，除非一个方法只会调用一次，否则缓存都是有用的。在运行时，那么多对象，那么多方法调用，节省下来的时间也是非常可观的。
追本溯源，何为方法缓存
本着源码面前，了无秘密的原则，我们看下源码中的方法缓存到底是什么，在`objc-cache.mm`中，`objc_cache`的定义如下：

```objc
struct objc_cache {
    uintptr_t mask;            /* total = mask + 1 */
    uintptr_t occupied;       
    cache_entry *buckets[1];
};
```
嗯，`objc_cache`的定义看起来很简单，它包含了下面三个变量：
1)、`mask`：可以认为是当前能达到的最大index（从0开始的），所以缓存的size（total）是mask+1
2)、`occupied`：被占用的槽位，因为缓存是以散列表的形式存在的，所以会有空槽，而occupied表示当前被占用的数目
3)、`buckets`：用数组表示的hash表，`cache_entry`类型，每一个`cache_entry`代表一个方法缓存
(`buckets`定义在`objc_cache`的最后，说明这是一个可变长度的数组)
而`cache_entry`的定义如下：

```objc
typedef struct {
    SEL name;     // same layout as struct old_method
    void *unused;
    IMP imp;  // same layout as struct old_method
} cache_entry;
```
`cache_entry`定义也包含了三个字段，分别是：
1)、name，被缓存的方法名字
2)、unused，保留字段，还没被使用。
3)、imp，方法实现

## Runtime实战

> 我们知道App在项目开发过程中。由于不断迭代的业务逻辑和增加的模块，由于网络性能或者代码质量的或者项目Bug等问题，会出现App报出异常，出现崩溃的问题，如果次数多了会非常影响用户体验，在关键的模块，比如支付，登录等等，需要写很多校验就是防止出现异常。那么如何使用一种有效的手段来减少异常呢？

其实`Runtime`就可以做到这点，在OC中，方法的调用在运行时会被编译成一个消息，在这个消息中不断去顺着isa指针在类或父类的元类的方法列表methodLists中寻找接受者，如果没有找到方法，就会开启消息转发机制。直接调用`[reciever methodName]`


### `method_invoke`

> Calls the implementation of a specified method.

```objc
Method method= class_getInstanceMethod([Son class], @selector(getNameWithfamily:));
NSString *invokeName= method_invoke(son,method,@"Zhao");
NSLog(@"%@",invokeName);// (Son Zhao)

Method method= class_getInstanceMethod([father class], @selector(getNameWithfamily:));
NSString *invokeName= method_invoke(father,method,@"Zhao");
NSLog(@"%@",invokeName);
```


### `Runtime`应用举例

> 设置按钮的快速点击的时间间隔

建一个`UIControl`的分类，使用属性关联添加属性，并且交换`sendAction:to:forEvent:`的方法实现，

```objc
//
//  UIControl+Event.m

#import "UIControl+Event.h"
#import "objc/runtime.h"

@implementation UIControl (Event)

static char acceptEventIntervalKey;
static char acceptEventTimeKey;

+ (void)load {
    Method a = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod(self, @selector(__yh_sendAction:to:forEvent:));
    method_exchangeImplementations(a, b);
}

- (NSTimeInterval)acceptEventInterval {
    return [objc_getAssociatedObject(self, &acceptEventIntervalKey) doubleValue];
}

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval {
    objc_setAssociatedObject(self, &acceptEventIntervalKey, @(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)acceptEventTime {
    return [objc_getAssociatedObject(self, &acceptEventTimeKey) doubleValue];
}

- (void)setAcceptEventTime:(NSTimeInterval)acceptEventTime {
    objc_setAssociatedObject(self, &acceptEventTimeKey, @(acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)__yh_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([[NSDate date] timeIntervalSince1970] - self.acceptEventTime < self.acceptEventInterval) {
        return;
    }
    if (self.acceptEventInterval > 0) {
        self.acceptEventTime = [[NSDate date] timeIntervalSince1970];
    }
    [self __yh_sendAction:action to:target forEvent:event];
}

@end
```

### objc_getClass & object_getClass

isa指针的实现是相当于调用方法：`object_getClass(id)`
`[object class]`的实现相当于调用方法：`objc_getClass(const char * _Nonnull name)
`
objc_getClass参数是类名的字符串，返回的就是这个类的类对象；object_getClass参数是id类型，它返回的是这个id的isa指针所指向的Class，如果传参是Class，则返回该Class的metaClass。

这两个方法的区别可以通过下面两个例子来展示：

```objc
Son *sonObject = [Son new];
Class currentClass = [sonObject class];
const char *className = object_getClassName(currentClass);
/*
sonObject->(class)Son->(isa)MetaClassOfSon->(isa)MetaClassOfNSObject->(isa)MetaClassOfNSObject
*/
for (int i=0; i<4; i++) {
    NSLog(@"class:%p-----className:%s-------superClass: %@\n",currentClass,className,[currentClass superclass]);
    currentClass = object_getClass(currentClass);
    className = object_getClassName(currentClass);
}
```

打印结果：
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15360562621048.jpg)

从中可以看到最后两次打印的currentClass地址相同，说明最后MetaClassOfNSObject的isa指针最终指向了本身。

```objc
Son *sonObject = [Son new];
Class currentClass = [sonObject class];
const char *className = object_getClassName(currentClass);

for (int i=0; i<4; i++) {
    NSLog(@"class:%p-----className:%s-------superClass:%@\n",currentClass,className,[currentClass superclass]);
    currentClass = objc_getClass([NSStringFromClass(currentClass) UTF8String]);
    className = object_getClassName(currentClass);
}
```

打印结果：
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15360563486710.jpg)

由此可知objc_getClass方法只是单纯地返回了Class，而非isa指针指向的Class

## Runtime的使用

`Runtime`的使用：获取属性列表，获取成员变量列表，获得方法列表，获取协议列表，方法交换（黑魔法），动态的添加方法，调用私有方法，为分类添加属性。

## 类在`Runtime`中的表示

```objc
//类在runtime中的表示
struct objc_class {
    Class isa;//指针，顾名思义，表示是一个什么，
    //实例的isa指向类对象，类对象的isa指向元类
#if !__OBJC2__
    Class super_class;  //指向父类
    const char *name;  //类名
    long version;
    long info;
    long instance_size
    struct objc_ivar_list *ivars //成员变量列表
    struct objc_method_list **methodLists; //方法列表
    struct objc_cache *cache;//缓存
    //一种优化，调用过的方法存入缓存列表，下次调用先找缓存
    struct objc_protocol_list *protocols //协议列表
    #endif
} OBJC2_UNAVAILABLE;
/* Use `Class` instead of `struct objc_class *` */
```

### 获取方法/属性等列表

有时候会有这样的需求，我们需要知道当前类中每个属性的名字（比如字典转模型，字典的Key和模型对象的属性名字不匹配）。
我们可以通过`Runtime`的一系列方法获取类的一些信息（包括属性列表，方法列表，成员变量列表，和遵循的协议列表）。

```objc
  unsigned int count;
    //获取属性列表
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property---->%@", [NSString stringWithUTF8String:propertyName]);
    }
    
    //获取方法列表
    Method *methodList = class_copyMethodList([self class], &count);
    for (unsigned int i; i<count; i++) {
        Method method = methodList[i];
        NSLog(@"method---->%@", NSStringFromSelector(method_getName(method)));
    }
    
    //获取成员变量列表
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i; i<count; i++) {
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSLog(@"Ivar---->%@", [NSString stringWithUTF8String:ivarName]);
    }
    
    //获取协议列表
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for (unsigned int i; i<count; i++) {
        Protocol *myProtocal = protocolList[i];
        const char *protocolName = protocol_getName(myProtocal);
        NSLog(@"protocol---->%@", [NSString stringWithUTF8String:protocolName]);
    }
```

注意：`class_copyPropertyList`返回的仅仅是对象类的属性(@property声明的属性)，而`class_copyIvarList`返回类的所有属性和变量(包括在`@interface`大括号中声明的变量)

可以另建一个`NSObject`的分类把这些方法写在分类里面,以后需要的话直接把文件拖进项目里就可以直接使用了


```objc
#import <objc/runtime.h>

@implementation NSObject (XXOOProperty)

/* 获取对象的所有属性和属性内容 */
- (NSDictionary *)getAllPropertiesAndVaules
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties =class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}
/* 获取对象的所有属性 */
- (NSArray *)getAllProperties
{
    u_int count;

    objc_property_t *properties  =class_copyPropertyList([self class], &count);

    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];

    for (int i = 0; i < count ; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }

    free(properties);

    return propertiesArray;
}
/* 获取对象的所有方法 */
-(void)getAllMethods
{
    unsigned int mothCout_f =0;
    Method* mothList_f = class_copyMethodList([selfclass],&mothCout_f);
    for(int i=0;i<mothCout_f;i++)
    {
        Method temp_f = mothList_f[i];
        IMP imp_f = method_getImplementation(temp_f);
        SEL name_f = method_getName(temp_f);
        const char* name_s =sel_getName(method_getName(temp_f));
        int arguments = method_getNumberOfArguments(temp_f);
        const char* encoding =method_getTypeEncoding(temp_f);
        NSLog(@"方法名：%@,参数个数：%d,编码方式：%@",[NSString stringWithUTF8String:name_s],
              arguments,
              [NSString stringWithUTF8String:encoding]);
    }
    free(mothList_f);
}
@end
```

## 方法交换

使用场景：

需求:
比如说有一个项目,已经开发了2年，忽然项目负责人添加一个功能,每次UIImage加载图片,告诉我是否加载成功
// 1.自定义UIImage，重写方法，给原来方法添加新功能。
// 2. UIImage添加分类，分类方法会重写原来的方法,最好加上前缀来封装。

弊端:
    1. 每次使用，都需要导入
    2. 项目大了, 没办法实现，获取不到

```objc

@implementation UIViewController (SPNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(sp_viewDidLoad);
        swizzleMethod([self class], originalSelector, swizzledSelector);
        
        originalSelector = @selector(viewWillAppear:);
        swizzledSelector = @selector(sp_viewWillAppear:);
        swizzleMethod([self class], originalSelector, swizzledSelector);
        
        originalSelector = @selector(viewWillDisappear:);
        swizzledSelector = @selector(sp_viewWillDisappear:);
        swizzleMethod([self class], originalSelector, swizzledSelector);
    });
}

void swizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector);

//静态就交换静态，实例方法就交换实例方法
void swizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = nil;
    if (!originalMethod) {//处理为类的方法
        originalMethod = class_getClassMethod(cls, originalSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
        if (!originalMethod || !swizzledMethod) return;
    } else {//处理为事例的方法
        swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
        if (!swizzledMethod) return;
    }
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
```

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15360623948928.jpg)

## 属性关联

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190214171822.png)

> 我们知道，在 Objective-C 中可以通过 Category 给一个现有的类添加属性，但是却不能添加实例变量，这似乎成为了 Objective-C 的一个明显短板。然而值得庆幸的是，我们可以通过 Associated Objects 来弥补这一不足。本文将结合 runtime 源码深入探究Objective-C 中 Associated Objects 的实现原理。

Associated Objects 主要有以下三个使用场景：

* 为现有的类添加私有变量以帮助实现细节；
* 为现有的类添加公有属性；
* 为 KVO 创建一个关联的观察者。

声明 static char kAssociatedObjectKey; ，使用 &kAssociatedObjectKey 作为key 值;
声明 static void *kAssociatedObjectKey = &kAssociatedObjectKey; ，使用 kAssociatedObjectKey 作为 key 值；
用 selector ，使用 getter 方法的名称作为 key 值。


```objc
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
id objc_getAssociatedObject(id object, const void *key);
void objc_removeAssociatedObjects(id object);
```

* 以键值对形式添加关联对象
* 根据 key 获取关联对象
* 移除所有关联对象

举例

```objc
@interface ViewController (AssociatedObjects)

@property (assign, nonatomic) NSString *associatedObject_assign;
@property (strong, nonatomic) NSString *associatedObject_retain;
@property (copy,   nonatomic) NSString *associatedObject_copy;

@end

@implementation ViewController (AssociatedObjects)

- (NSString *)associatedObject_assign {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssociatedObject_assign:(NSString *)associatedObject_assign {
    objc_setAssociatedObject(self, @selector(associatedObject_assign), associatedObject_assign, OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)associatedObject_retain {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssociatedObject_retain:(NSString *)associatedObject_retain {
    objc_setAssociatedObject(self, @selector(associatedObject_retain), associatedObject_retain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)associatedObject_copy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssociatedObject_copy:(NSString *)associatedObject_copy {
    objc_setAssociatedObject(self, @selector(associatedObject_copy), associatedObject_copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

```

关联对象的释放时机与被移除的时机并不总是一致的，比如上面的 self.associatedObject_assign 所指向的对象在 ViewController 出现后就被释放了，但是 self.associatedObject_assign 仍然有值，还是保存的原对象的地址。如果之后再使用 self.associatedObject_assign 就会造成 Crash ，所以我们在使用弱引用的关联对象时要非常小心；
一个对象的所有关联对象是在这个对象被释放时调用的 _object_remove_assocations 函数中被移除的。
接下来，我们就一起看看 runtime 中的源码，来验证下我们的实验结论。


## 参考

1. [Runtime运行时 isa指针 SEL方法选择器 IMP函数指针 Method方法 `Runtime`消息机制 `Runtime`的使用](http://www.jianshu.com/p/d6a68575ce10)
2. [iOS~Runtime理解 - 简书](http://www.jianshu.com/p/927c8384855a)
3. [Objective-C Runtime | yulingtianxia's blog](http://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/)
4. [iOS - Runtime 方法与消息 - 简书](https://www.jianshu.com/p/2bf7fedb86b6)
5. [深入理解Objective-C：方法缓存](https://tech.meituan.com/DiveIntoMethodCache.html)
6. [Objective-C 消息发送与转发机制原理](http://yulingtianxia.com/blog/2016/06/15/Objective-C-Message-Sending-and-Forwarding/)
7. [RuntimePDF](https://github.com/DeveloperErenLiu/RuntimePDF)
8. [object_getClass与objc_getClass的不同 - 掘金](https://juejin.im/post/5afaaf5df265da0ba567b2b2)
9. [Objective-C Associated Objects 的实现原理 - 雷纯锋的技术博客](http://blog.leichunfeng.com/blog/2015/06/26/objective-c-associated-objects-implementation-principle/)
10. [关联对象 AssociatedObject 完全解析](https://draveness.me/ao)

