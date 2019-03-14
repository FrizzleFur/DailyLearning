## OC的类和元类

###  进一步熟悉内存机制

```objc
NSString *str = [[NSString alloc] initWithString:@"This is a string"];
```

常说的实例对象其实是指向对象内存地址的指针， 本质是`objc_object` 结构体
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190306155521.png)


![实例对象.png](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112506999252.png)

### 命名规范

OC的方法名可能很长，但是是为了避免歧义，在命名方面，先要保证表达清楚，没有歧义，然后再考虑长度优化。

### 进一步理解消息转发机制

OC是一门极其动态语言，在编译器定义好的方法在运行期系统会查找、调用某方法的实现代码，才能真正确定所调用的方法，如果类无法立即响应某个Selector，就会启动消息转发流程。

1. objc_msgSend传递消息

![objc_msgSend](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112512635482.png)

```objc
id returnValue = [someObject messageName: parameter];
```


消息传递调用的核心函数叫做objc_msgSend，编译器会把刚才的方法转换成：

```objc
id returnValue = objc_msgSend(someObject, @selecor(messageName:), parameter);
```


在`objc_msgSend()`方法中，主要通过以下步骤来查找和调用函数：
根据对象obj找到对象类中存储的函数列表methodLists。
再根据SEL@selector(doSth)在`methodLists`中查找对应的函数指针`method_imp`。
根据函数指针`method_imp`调用响应的函数。

`old_method_list`结构体:

```objc
struct old_method_list {
    void *obsolete;        //废弃的属性
    int method_count;    //方法的个数
    /* variable length structure */
    struct old_method method_list[1];    //方法的首地址
};
```
`old_method`结构体:

```objc
struct old_method {
    SEL method_name;    //函数的SEL
    char *method_types;        //函数的类型
    IMP method_imp;        //函数指针
};
```


* obj->isa(Class类型) obj对象通过isa属性拿到对应的Class
* Class->methodLists(old_method_list类型) Class通过methodLists属性拿到存放所有方法的列表
* old_method_list->old_method 在old_method_list中通过SEL查找到对应的old_method
* old_method->method_imp(IMP类型) old_method通过method_imp属性拿到函数指针


method_imp->调用函数 通过函数指针调用函数
`objc_msgSend`函数会根据接受者和Selector的类型来调用适当的方法，如果找到与Selector名称相符的方法名，就跳转到该方法的实现代码，如果没有就沿着继承体系继续向上查找，如果还是找不到，就执行消息转发。

2. 消息转发
- 2.1 “动态方法解析”(`dynamic method resolution`) 查看所属的类是否能动态添加方法，已处理当前的未知选择子（unknown selector）.

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190306162028.png)

查看是类还是元类：

- 类： 实例方法列表
- 元类： 类方法列表

* 我们知道发送消息是通过，objc_msgSend(id, SEL, ...)来实现的。首先会在对象的类对象的cache,method list以及父类对象的cache,method list依次查找SEL对应的IMP。
* 如果没有找到，并且实现了动态方法决议机制就会决议。如果没有实现动态决议机制或者决议失败且实现了消息转发机制。就会进入消息转发流程。否则程序Crash.
* 也就是说如果同时实现了动态决议和消息转发。那么动态决议先于消息转发。只有当动态决议无法决议selector的实现，才会尝试进行消息转发。


- 2.2 “完整的消息转发机制”（`full forwatding mechanism`）请接受者看看有没有其他对象能处理这个消息，如果可以就把消息转发给那个对象，如果没有”备援接受者”（`replacement receiver`）则启动完整的消息转发机制，运行期系统会把消息有关的全部细节封装到`NSInvocation`对象中，给receiver最后一次机会，设法解决这条未处理的消息.


![消息转发](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112511322781.png)

`Selector`是方法选择器，里面存放的是方法的名字。对应方法的映射列表。
`objc_msgSend`函数会一句及守着与Selector的类型来调用适当的方法，他会在方法接受者所属类中搜寻方法列表，如果找到了与Selector名称相符的方法。

3. Method Swizzing


使用`method_exchangeImplemetations`(`originalMethod, swappedMethod`);实现运行时的`Selector`交换
![methodSwizzing](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112511121054.png)

## 类和元类

### class对象

我们通过class方法或runtime方法得到一个class对象。class对象也就是类对象

```objc
Class objectClass1 = [object1 class];
Class objectClass2 = [object2 class];
Class objectClass3 = [NSObject class];

// runtime
Class objectClass4 = object_getClass(object1);
Class objectClass5 = object_getClass(object2);
NSLog(@"%p %p %p %p %p", objectClass1, objectClass2, objectClass3, objectClass4, objectClass5);
```

**每一个类在内存中有且只有一个class对象。可以通过打印内存地址证明**

class对象在内存中存储的信息主要包括：

1. isa指针
2. superclass指针
3. 类的属性信息（@property），类的成员变量信息（ivar）
4. 类的对象方法信息（instance method），类的协议信息（protocol）

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190218210900.png)


### 1. 理解类的概念

比起类，可能对象的概念更熟悉一点，这是对象的定义：
![对象的结构体](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112508168734.png)

你会发现有一个定义成`Class`类型的`isa`，这是实例对象用以表明其所属类型的，指向`Class`对象的指针。通过`Class`搭建了类的继承体系(`class hirerarchy`)。

其实类也是对象，打开定义的头文件，发现是用一个结构体来存储类的信息。

![类的结构体](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112508358881.png)

```objc
typedef struct objc_class *Class;
struct objc_class {
    Class isa; // 指向metaclass 
    Class superclass;  // 指向父类Class
    const char *name;  // 类名
    uint32_t version;  // 类的版本信息
    uint32_t info;        // 一些标识信息，标明是普通的Class还是metaclass
    uint32_t instance_size;        // 该类的实例变量大小(包括从父类继承下来的实例变量);
    struct old_ivar_list *ivars;    //类中成员变量的信息
    struct old_method_list **methodLists;    类中对象方法列表
    Cache cache;    查找方法的缓存，用于提升效率
    struct old_protocol_list *protocols;  // 存储该类遵守的协议 
}
```

类的结构体存放着该类的信息：类的对象方法列表，实例变量，协议，父类等信息。
每个类的`isa`指针指向该类的所属类型元类(`metaClass`),用来表述类对象的数据。每个类仅有一个类对象，而每个类对象仅有一个与之相关的”元类”。
比如一个继承`NSObjct`名叫SomeClass的类，其继承体系如下:
![类的继承体系](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112508819933.png)


在`Objective-C`中任何的类定义都是对象。即在程序启动的时候任何类定义都对应于一块内存。在编译的时候，编译器会给每一个类生成一个且只生成一个”描述其定义的对象”,也就是水果公司说的类对象(`class object`),它是一个单例(`singleton`).
因此,程序里的所有实例对象(`instance object`)都是在运行时由`Objective-C`的运行时库生成的，而这个类对象(`class object`)就是运行时库用来创建实例对象(`instance object`)的依据。

[Programming with Objective-C](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/DefiningClasses/DefiningClasses.html)的说法就是：`Classes Are Blueprints for Objects`,  类是对象的抽象设计图。

### 2. 查询类型信息

有时候会需要查询一个"objct"对象的所属的类，有人会这样写：

```objc
id objct = /* ... */
if ([objct class] == [SomeClass class]) {
	//objct is an instance of SomeClass.
}
```

其实`Objective-C`中提供了专门用于查询类型信息的方法，由于`runtime`在运行时的动态性，对于对象所属类的查询，建议使用`isKindOfClass`和`isMemberOfClass`,因为某些对象可能实现了消息转发功能，从而判断可能不准确.

### 3. 理解元类（`meta class`）

为了调用类里的类方法，类的isa指针必须指向包含这些类方法的类结构体。
这就引出了元类的定义：**元类是类对象的类**。
简单说就是：
* 当你给对象发送消息时，消息是在寻找这个对象的类的方法列表。
* 当你给类发消息时，消息是在寻找这个类的元类的方法列表。
* 元类是必不可少的，因为它存储了类的类方法。每个类都必须有独一无二的元类，因为每个类都有独一无二的类方法。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190218210518.png)


### 4. "元类的类”

元类，就像之前的类一样，它也是一个对象。你也可以调用它的方法。自然的，这就意味着他必须也有一个类。

* 所有的元类都使用根元类（继承体系中处于顶端的类的元类）作为他们的类。**这就意味着所有`NSObject`的子类（大多数类）的元类都会以`NSObject`的元类作为他们的类**
* 所有的元类使用根元类作为他们的类，根元类的元类则就是它自己。也就是说基类的元类的`isa`指针指向他自己。

关于这两点，原文是这样描述的：

**A metaclass is an instance of the root class's metaclass; the root   metaclass is itself an instance of the root metaclass.**

所谓的元类就是根类的元类的一个实例。

第二点： **And the root metaclass's superclass is the root class**，就说名 `根元类` (Root Class meta)的父类是 `根类` (Root Class class).可以看到图中的 `根元类` (Root Class meta)的superclass是指向 `根类` (Root Class class)的。

![类的图解.png](http://upload-images.jianshu.io/upload_images/225323-e6115d1e3d6d0e86.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 5. 类的继承

类用`super_class`指针指向了超类，同样的，元类用`super_class`指向类的`super_class`的元类。
说的更拗口一点就是，根元类把它自己的基类设置成了`super_class`。
在这样的继承体系下，所有实例、类以及元类（`meta class`）都继承自一个基类。
这意味着对于继承于`NSObject`的所有实例、类和元类，他们可以使用`NSObject`的所有实例方法，类和元类可以使用`NSObject`的所有类方法
这些文字看起来莫名其妙难以理解，可以用一份图谱来展示这些关系：

![类和元类](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15112504019864.jpg)

如上图，对象是由按照类所定义的各个属性和方法“制造”的，类作为对象的模板，也可看成是对象。正如工厂里面的模子也是要专门制作模子的机器生产，`元类` (`meta class`)就是设计、管理 `类` (class)的角色。所以图上直观的表现出类和元类平行的父类链，表明实例方法和类方法都是并行继承的，每个对象都响应了根类的方法。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190218211941.png)

### 注意点

需要弄清的有两点：

 1. 所谓的元类就是根类的元类的一个实例，而根元类的实例就是它自己。
 2. 根元类的父类是根类。

### 类方法和实例方法

#### 类方法

以`+`开头的方法是类方法。Objc中的类方法类似Java中的static静态方法，它是属于**类本身的方法，不属于类的某一个实例对象**，所以不需要实例化类，用类名即可使用，是将消息发送给类：

类方法可以独立于对象而执行，所以在其他的语言里面类方法有的时候被称为静态方法。

1. 类方法可以调用类方法。
2. 类方法不可以调用实例方法，但是类方法可以通过创建对象来访问实例方法。
3. 类方法不可以使用任何实例变量。但是类方法可以使用`self`，因为`self`不是实例变量。
4. 类方法作为消息，可以被发送到类或者对象里面去（实际上，就是可以通过类或者对象调用类方法的意思）。

* 类方法是属于类对象的
* 类方法只能通过类对象调用
* 类方法中的self是类对象
* 类方法可以调用其他的类方法
* 类方法中不能访问成员变量
* 类方法中不能直接调用对象方法

#### 实例方法

以`-`开头的方法是实例方法。它属于类的某一个或某几个实例对象，即类对象必须实例化后才可以使用的方法，将消息发送给实例对象：

_成员变量的值时存储在实例对象中的_，因为只有当创建实例对象的时候才为成员变赋值。但是成员变量叫什么名字，是什么类型，只需要有一份就可以了。所以存储在class对象中。

* 实例方法是属于实例对象的
* 实例方法只能通过实例对象调用
* 实例方法中的self是实例对象
* 实例方法中可以访问成员变量
* 实例方法中直接调用实例方法
* 实例方法中也可以调用类方法(通过类名)


## self关键字

`self`的规则大家需要记住下面的规则：

1. 实例方法里面的`self`，是对象的首地址。
2. 类方法里面的`self`，是`Class`.

* 尽管在同一个类里面的使用`self`，但是`self`却有着不同的解读。在类方法里面的`self`，可以翻译成`class self`；在实例方法里面的`self`，应该被翻译成为`object self`。在类方法里面的`self`和实例方法里面的`self`有着本质上的不同，尽管他们的名字都叫`self`。

* 平常在构造方法里做一些初始化工作时都会写上这样的代码， self = [super init] 这里先调用父类的构造方法也符合上述的构造顺序问题，但疑惑的是，为什么 [super init] 要赋值给 self ？为什么需要使用 if 作校验？

看如下一段代码

```objc
- (id)initWithString:(NSString *)aString
{
    self = [super init];
    if (self)
    {
        instanceString = [aString retain];
    }
    return self;
}
```

你所声明的每个方法都有两个隐藏参数：self和_cmd。

```objc
- (id)initWithString:(NSString *)aString;
```
将由编译器转换为以下函数调用：

```objc
id initWithString(id self, SEL _cmd, NSString *aString);
```
* 实际情况是，这self只是每个方法的隐藏参数。与任何其他参数一样，它从函数调用接收其值。
* 方法需要知道要处理的数据。该self参数告诉类要处理的数据
* 实际情况是编译器使用该self参数来解析对方法内的实例变量的任何引用。

```objc
[[MyClass alloc] initWithString:@"someString"]
//转换成一个objc_msgSend调用
MyClass *myObject2 = objc_msgSend(myObject1, initSelector, @"someString");
```
所以当我们到达方法的内部时，self已经有了一个值; 它的值是myObject1（即从[MyClass alloc]调用返回的已分配对象。这是必不可少的，因为没有它，super调用将不可能 - self编译器使用该值来发送调用：

## super关键字

回到 [super init] 这句代码，要注意，它不是被编译器转换成 objc_msgSend(super, @selector(init)) ，而是会被转换成 objc_msgSendSuper(self, @selector(init)) 。

这里的 super 是一个编译器指令，和 self 指向同一个消息接受者，即当前调用方法的实例。他们两个的不同点在于：**super 会告诉编译器，执行 [super xxx] 时转换成 objc_msgSendSuper ，即要去父类的方法列表找，而不是本类**。

🌰 下面的代码输出什么？


```objc
   @implementation Son : Father
   - (id)init
   {
       self = [super init];
       if (self) {
           NSLog(@"%@", NSStringFromClass([self class]));
           NSLog(@"%@", NSStringFromClass([super class]));
       }
       return self;
   }
   @end
```

答案：

都输出 Son

```objc
NSStringFromClass([self class]) = Son
NSStringFromClass([super class]) = Son

```
这个题目主要是考察关于 Objective-C 中对 self 和 super 的理解。

我们都知道：self 是类的隐藏参数，指向当前调用方法的这个类的实例。那 super 呢？

很多人会想当然的认为“ super 和 self 类似，应该是指向父类的指针吧！”。这是很普遍的一个误区。其实 super 是一个 Magic Keyword， 它本质是一个编译器标示符，和 self 是指向的同一个消息接受者！他们两个的不同点在于：super 会告诉编译器，调用 class 这个方法时，要去父类的方法，而不是本类里的。

所以，当调用 ［self class] 时，实际先调用的是 objc_msgSend函数，第一个参数是 Son当前的这个实例，然后在 Son 这个类里面去找 - (Class)class这个方法，没有，去父类 Father里找，也没有，最后在 NSObject类中发现这个方法。而 - (Class)class的实现就是返回self的类别，故上述输出结果为 Son。


而在调用 [super class]时，会转化成 objc_msgSendSuper函数。看下函数定义:


```
   id objc_msgSendSuper(struct objc_super *super, SEL op, ...)
```

而当调用 [super class]时，会转换成objc_msgSendSuper函数。第一步先构造 objc_super 结构体，结构体第一个成员就是 self 。 第二个成员是 (id)class_getSuperclass(objc_getClass(“Son”)) , 实际该函数输出结果为 Father。
第二步是去 Father这个类里去找 - (Class)class，没有，然后去NSObject类去找，找到了。最后内部是使用 objc_msgSend(objc_super->receiver, @selector(class))去调用，

此时已经和[self class]调用相同了，故上述输出结果仍然返回 Son。


[iOSInterviewQuestions/《招聘一个靠谱的iOS》面试题参考答案（上）.md at master · ChenYilong/iOSInterviewQuestions](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8A%EF%BC%89.md#20-%E4%B8%80%E4%B8%AAobjc%E5%AF%B9%E8%B1%A1%E7%9A%84isa%E7%9A%84%E6%8C%87%E9%92%88%E6%8C%87%E5%90%91%E4%BB%80%E4%B9%88%E6%9C%89%E4%BB%80%E4%B9%88%E4%BD%9C%E7%94%A8)

这也就是为什么说“不推荐在 init 方法中使用点语法”，如果想访问实例变量 iVar 应该使用下划线（ _iVar ），而非点语法（ self.iVar ）。


#### 类方法和实例方法认知的误区

1. 类方法常驻内存，所以比实例方法效率高，类方法效率高但占内存
答：事实上，方法都是一样的，在加载时机和占用内存上，静态方法和实例方法是一样的，在类型第一次被使用时加载。调用的速度基本上没有差别。

2. 类方法分配在堆上，实例方法分配在栈上。
答：事实上，所有的方法都不可能分配在堆栈区，方法作为二进制代码是存储在内存的程序代码区，这个内存区域是不可写的。

#### 其他注意

* 实例方法需要先创建实例才可以调用，比较麻烦，静态方法不用，比较简单。
* **静态方法是静态绑定到子类，不是被继承。**
* 一般使用频繁的方法用静态方法，用的少的方法用动态的。静态的速度快，占内存。动态的速度相对慢些，但调用完后，立即释放，可以节省内存，可以根据自己的需要选择是用动态方法还是静态方法。
* 静态方法修改的是类的状态，而对象修改的是各个对象的状态。
* **类的实例调用是在类的生命周期中存在，当类没有了以后，对应的实例也就没有了，对应的方法也就没有了**。静态类不然，只要你引用了那个静态类的命名空间，它就会一直存在，直到我们退出系统。

## isa 指针

Objective-C 对象都是 C 语言结构体，所有的对象都包含一个类型为  isa 的指针，
所有继承自 NSObject 的类实例化后的对象都会包含一个类型为 isa_t 的结构体。

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15340400765116.jpg)

从上图中可以看出，不只是实例会包含一个 isa 结构体，所有的类也有这么一个 isa。在 ObjC 中 Class 的定义也是一个名为 objc_class 的结构体，如下：

```objc
struct objc_class : objc_object {
    isa_t isa;
    Class superclass;
    cache_t cache;
    class_data_bits_t bits;
};
```

### 对象的isa指针指向哪里

当对象调用实例方法的时候，我们上面讲到，实例方法信息是存储在class类对象中的，那么要想找到实例方法，就必须找到class类对象，那么此时isa的作用就来了。

```objc
[stu studentMethod];
```

* instance的isa指向class，当调用对象方法时，通过instance的isa找到class，最后找到对象方法的实现进行调用。

当类对象调用类方法的时候，同上，类方法是存储在meta-class元类对象中的。那么要找到类方法，就需要找到meta-class元类对象，而class类对象的isa指针就指向元类对象

```objc
[Student studentClassMethod];
```

* class的isa指向meta-class
当调用类方法时，通过class的isa找到meta-class，最后找到类方法的实现进行调用
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15340403445496.jpg)

* 当对象调用其父类对象方法的时候，又是怎么找到父类对象方法的呢？，此时就需要使用到class类对象superclass指针。

* 当Student的instance对象要调用Person的对象方法时，会先通过isa找到Student的class，然后通过superclass找到Person的class，最后找到对象方法的实现进行调用，同样如果Person发现自己没有响应的对象方法，又会通过Person的superclass指针找到NSObject的class对象，去寻找响应的方法

* 当类对象调用父类的类方法时，就需要先通过isa指针找到meta-class，然后通过superclass去寻找响应的方法

### 实例对象和类对象

* 实例对象的isa指针指向类对象，类对象的isa指针指向元类对象，当instance调用instanceMethod方法时，类对象的isa指针找到类对象的isa指针，然后在类对象中查找对象方法，如果没有找到，就通过类对象的superclass指针找到父类对象，接着去寻找instanceMethod方法。

* 因为在 Objective-C 中，对象的方法并没有存储于对象的结构体中（如果每一个对象都保存了自己能执行的方法，那么对内存的占用有极大的影响）。

* 当实例方法被调用时，它要通过自己持有的 isa 来查找对应的类，然后在这里的 class_data_bits_t 结构体中查找对应方法的实现。同时，每一个 objc_class 也有一个指向自己的父类的指针 super_class 用来查找继承的方法。

* 实例方法调用时，通过对象的 `isa` 在类中获取方法的实现
* 类方法调用时，通过类的 `isa` 在**元类**中获取方法的实现

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15328565624560.jpg)

[从 NSObject 的初始化了解 isa](https://draveness.me/isa)

`Objective-C`中对象最重要的特性是你可以向它们发送消息：

```objc
[@"stringValue" writeToFile:@"/file.txt" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
```

这是有效的，因为当您向Objective-C对象（如此处的NSCFString）发送消息时，运行时遵循对象的isa指针来获取对象的Class（在本例中为NSCFString类）。然后，类包含一个适用于该类的所有对象的方法列表和一个指向超类的指针，以查找继承的方法。运行时查看类和超类上的方法列表，找到与消息选择器匹配的方法（在上面的例子中，NSString的writeToFile:atomically:encoding:error ）。然后运行时调用该方法的函数（IMP）。

重要的是，Class定义了什么样的消息可以发送给对象。

## 元类

现在，正如您可能已经知道的那样，Objective-C中的一个类也是一个对象。这意味着您可以向类发送消息。

```objc
typedef struct objc_class *Class;
struct objc_class {
    Class isa;
    Class super_class;
    /* followed by runtime specific details... */
};
```

但是，为了让我们在Class上调用一个方法，Class的isa指针本身必须指向一个Class结构，并且该Class结构必须包含我们可以在Class上调用的Methods列表。
这引出了元类的定义：元类是Class对象的类。

* 向对象发送消息时，将在对象类的方法列表中查找该消息。
* 当您向类发送消息时，将在元类的方法列表中查找该消息。

* 元类是必不可少的，因为它存储了类的类方法。每个Class必须有一个唯一的元类，因为每个Class都有一个可能唯一的类方法列表。

* 所有元类都使用基类的元类（其继承层次结构中顶级类的元类）作为它们的类。这意味着对于所有来自NSObject（大多数类）的类，元类都将NSObject元类作为其类。

* 遵循所有元类使用基类的元类作为其类的规则，任何基础元类都将是它自己的类（它们的isa指针指向它们自己）。这意味着NSObject元类上的isa指针指向它自己（它是它自己的一个实例）。

* 基类(NSObject)的元类将其super_class设置为基类(NSObject)本身。

* 此继承层次结构的结果是层次结构中的所有实例，类和元类都继承自这个层次结构的基类。
* 这意味着对于NSObject层次结构中的所有实例，类和元类，所有_NSObject实例方法_都是有效的。对于类和元类，所有_NSObject类方法_也是有效的。

* 元类将始终确保Class对象包含该层次结构中基类的所有实例方法和类方法，以及中间所有的类方法。对于来自NSObject的类，这意味着所有NSObject实例和协议方法都是为所有Class（和meta-class）对象定义的。

* 所有元类本身都使用基类的元类（NSObject元类用于NSObject层次结构类）作为它们的类，包括基类级元类，它是运行时中唯一的自己定义自己的类

```objc
//runtime中传入类对象此时得到的就是元类对象
Class objectMetaClass = object_getClass([NSObject class]);
// 而调用类对象的class方法时得到还是类对象，无论调用多少次都是类对象
Class cls = [[NSObject class] class];
Class objectClass3 = [NSObject class];
class_isMetaClass(objectMetaClass) // 判断该对象是否为元类对象
NSLog(@"%p %p %p", objectMetaClass, objectClass3, cls); // 后面两个地址相同，说明多次调用class得到的还是类对象
```

**每个类在内存中有且只有一个meta-class对象。**
meta-class对象和class对象的内存结构是一样的，但是用途不一样，在内存中存储的信息主要包括

1.  isa指针
2.  superclass指针
3.  类的类方法的信息（class method）
meta-class对象和class对象的内存结构是一样的，所以meta-class中也有类的属性信息，类的对象方法信息等成员变量，但是其中的值可能是空的。

## NSProxy

NSProxy是一个虚基类，它为一些表现的像是其它对象替身或者并不存在的对象定义一套API。一般的，发送给代理的消息被转发给一个真实的对象或者代理本身load(或者将本身转换成)一个 真实的对象。NSProxy的基类可以被用来透明的转发消息或者耗费巨大的对象的lazy初始化。

NSProxy是一个虚类。它有什么用处呢？
OC中类是不支持多继承的，要想实现多继承一般是有protocol的方式，还有一种就是利用NSProxy。有同学可能会问为什么不用NSObject来做？同样都是基类，都支持NSObject协议，NSProxy 有的NSObject 都有。但是点进NSProxy .h可以看见NSProxy没有init方法，而且NSProxy自身的方法很少，是一个很干净的类。这点很重要，因为NSObject自身的分类特别多，**而消息转发的机制是当接收者无法处理时才会通过forwardInvocation:来寻求能够处理的对象.**在日常使用时，我们很难避免不使用NSObject的分类方法比如valueForKey这个方法NSObject就不会转发。

### 1.多继承

多重继承：多重继承是编程语言中的概念，多重继承指的是一个类可以同时继承多个类，比如A类继承自B类和C类，这就是多重继承。

* [谈谈NSProxy - 简书](https://www.jianshu.com/p/20c441f19126)
* [NSProxy 使用总结 - 简书](https://www.jianshu.com/p/b0f5fd3e4b7c)
* [协议和 NSProxy 实现多继承 - 简书](https://www.jianshu.com/p/6bf49eb47371)




## 分类(category)

### 概念

分类（Category）是OC中的特有语法，它是表示一个指向分类的结构体的指针。原则上它只能增加方法，不能增加成员（实例）变量。具体原因看源码组成:

### Category源码：

Category 是表示一个指向分类的结构体的指针，其定义如下：

```objc
typedef struct objc_category *Category;
struct objc_category {
  char *category_name                          OBJC2_UNAVAILABLE; // 分类名
  char *class_name                             OBJC2_UNAVAILABLE; // 分类所属的类名
  struct objc_method_list *instance_methods    OBJC2_UNAVAILABLE; // 实例方法列表
  struct objc_method_list *class_methods       OBJC2_UNAVAILABLE; // 类方法列表
  struct objc_protocol_list *protocols         OBJC2_UNAVAILABLE; // 分类所实现的协议列表
}

struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods; // 对象方法
    struct method_list_t *classMethods; // 类方法
    struct protocol_list_t *protocols; // 协议
    struct property_list_t *instanceProperties; // 属性
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
};

```

通过上面我们可以发现，这个结构体主要包含了分类定义的实例方法与类方法，其中instance_methods 列表是 objc_class 中方法列表的一个子集，而class_methods列表是元类方法列表的一个子集。但这个结构体里面，**没有属性列表**。

1. 分类是用于给原有类添加方法的,因为分类的结构体指针中，没有属性列表，只有方法列表。所以< 原则上讲它只能添加方法, 不能添加属性(成员变量),实际上可以通过其它方式添加属性> ;
2. 分类中的可以写@property, 但不会生成setter/getter方法, 也不会生成实现以及私有的成员变量（编译时会报警告）;我们知道在一个类中用@property声明属性，编译器会自动帮我们生成_成员变量和setter/getter，但分类的指针结构体中，根本没有属性列表。 x以在分类中用@property声明属性，既无法生成_成员变量也无法生成setter/getter。
因此结论是：我们可以用@property声明属性，编译和运行都会通过，只要不使用程序也不会崩溃。但如果调用了_成员变量和setter/getter方法，报错就在所难免了。
3. 可以在分类中访问原有类中.h中的属性;
4. **如果分类中有和原有类同名的方法, 会优先调用分类中的方法**, 就是说会忽略原有类的方法。所以同名方法调用的优先级为 分类 > 本类 > 父类。因此在开发中尽量不要覆盖原有类;
5. **如果多个分类中都有和原有类中同名的方法,那么调用该方法的时候执行谁由编译器决定；编译器会执行最后一个参与编译的分类中的方法**。

### 分类格式：

```objc
@interface 待扩展的类（分类的名称）
@end

@implementation 待扩展的名称（分类的名称）
@end
```

### 分类的方法
  
分类中的对象方法依然是存储在类对象中的，同对象方法在同一个地方，那么调用步骤也同调用对象方法一样。如果是类方法的话，也同样是存储在元类对象中。
那么分类方法是如何存储在类对象中的，我们来通过源码看一下分类的底层结构。

### 手动添加变量setter/getter方法

```objc
#import <objc/runtime.h>

//定义一个key值
static NSString *nameWithSetterGetterKey = @"nameWithSetterGetterKey"; 

@implementation Programmer (Category)

//运行时实现setter方法
- (void)setNameWithSetterGetter:(NSString *)nameWithSetterGetter {
        objc_setAssociatedObject(self, &nameWithSetterGetterKey, nameWithSetterGetter, OBJC_ASSOCIATION_COPY);
}

//运行时实现getter方法
- (NSString *)nameWithSetterGetter {
    return objc_getAssociatedObject(self, &nameWithSetterGetterKey);
}

@end
```

`objc_setAssociatedObject`方法的策略，一般对象使用`OBJC_ASSOCIATION_RETAIN_NONATOMIC`，Block、NSString类型使用`OBJC_ASSOCIATION_COPY_NONATOMIC`

```objc
typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies a weak reference to the associated object. */
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_RETAIN = 01401,       /**< Specifies a strong reference to the associated object.
                                            *   The association is made atomically. */
    OBJC_ASSOCIATION_COPY = 01403          /**< Specifies that the associated object is copied.
                                            *   The association is made atomically. */
};
```

## 类扩展(extension)

### 类扩展格式

```objc
@interface ClassName ()
//私有属性
//私有方法（如果不实现，编译时会报警,Method definition for 'XXX' not found）
@end
```

### 类扩展作用

* 为一个类添加额外的原来没有变量，方法和属性
* 一般的类扩展写到.m文件中
* 一般的私有属性写到.m文件中的类扩展中

### 类扩展和分类的区别

* ① 类别（分类）中原则上只能增加方法（能添加属性的的原因只是通过runtime解决无setter/getter的问题而已）；
* ② 类扩展不仅可以增加方法，还可以增加实例变量（或者属性），**只是该实例变量默认是@private类型的（用范围只能在自身类，而不是子类或其他地方）**"{}"内部变量是@protected；
* ③ 类扩展中声明的方法没被实现，编译器会报警，但是类别（分类）中的方法没被实现编译器是不会有任何警告的。**这是因为类扩展是在编译阶段被添加到类中，而类别是在运行时添加到类中。** 
* ④ 类扩展不能像类别（分类）那样拥有独立的实现部分（@implementation部分），也就是说，类扩展所声明的方法必须依托对应类的实现部分来实现。
* ⑤ **定义在 .m 文件中的类扩展方法为私有的，定义在 .h 文件（头文件）中的类扩展方法为公有的**。类扩展是在 .m 文件中声明私有方法的非常好的方式。


### .(点）和->（箭头）

.(点）和->（箭头）的区别了：

* .(点语法）是访问类的属性，本质是调用set、get方法。
* ->是访问成员变量，但成员变量默认受保护，所以常常报错，手动设为public即可解决

## Load 和initialize & init

### Load方法

1. Load， initialize， init

```objc	
+ (void)load{
    NSLog(@"%s",__func__);
}
 + (void)initialize{
    [super initialize];
    NSLog(@"%s %@",__func__,[self class]);
}
 - (instancetype)init{
    if (self = [super init]) {
        NSLog(@"%s",__func__);
    }
    return self;
}
```


Invoked whenever a class or category is added to the Objective-C runtime; implement this method to perform class-specific behavior upon loading.

当类（Class）或者类别（Category）加入Runtime中时（就是被引用的时候）。
实现该方法，可以在加载时做一些类特有的操作。

* **load方法会在程序启动就会调用，当装载类信息的时候就会调**用。
* load方法在这个文件被程序装载时调用。只要是在Compile Sources中出现的文件总是会被装载，这与这个类是否被用到无关，因此load方法总是在main函数之前调用。
* 如果一个类实现了load方法，在调用这个方法前会首先调用父类的load方法。而且这个过程是自动完成的，并不需要我们手动实现：
* **由于调用load方法时的环境很不安全，我们应该尽量减少load方法的逻辑**。另一个原因是load方法是线程安全的，它内部使用了锁，所以我们应该避免线程阻塞在load方法中。
* 优先调用类的load方法，之后调用分类的load方法。

一个常见的使用场景是在load方法中实现`Method Swizzle`：

```objc
// In Other.m
+ (void)load {
    Method originalFunc = class_getInstanceMethod([self class], @selector(originalFunc));
    Method swizzledFunc = class_getInstanceMethod([self class], @selector(swizzledFunc));
    
    method_exchangeImplementations(originalFunc, swizzledFunc);
}
```


+ load 作为 Objective-C 中的一个方法，与其它方法有很大的不同。只是一个在整个文件被加载到运行时，在 main 函数调用之前被 ObjC 运行时调用的钩子方法。其中关键字有这么几个：

* 文件刚加载
* main 函数之前
* 钩子方法
 
#### 针对提问进行整理学习

Q1：load 方法是如何被调用的？

A1：当 Objective-C 运行时初始化的时候，会通过 dyld_register_image_state_change_handler 在每次有新的镜像加入运行时的时候，进行回调。执行 load_images 将所有包含 load 方法的文件加入列表 loadable_classes ，然后从这个列表中找到对应的 load 方法的实现，调用 load 方法。

Q2：load 方法会有为我们所知的这种调用顺序？

* 规则一: 父类先于子类调用 
* 规则二: 类先于分类调用


[iOS认识load方法 - 多两口 - 博客园](https://www.cnblogs.com/xs514521/p/7010458.html)

### initialize

**这个方法在第一次给某个类发送消息时调用**（比如实例化一个对象），并且只会调用一次。initialize方法实际上是一种惰性调用，也就是说如果一个类一直没被用到，那它的initialize方法也不会被调用，这一点有利于节约资源。

initialize方法主要用来对一些不方便在编译期初始化的对象进行赋值。比如NSMutableArray这种类型的实例化依赖于runtime的消息发送，所以显然无法在编译器初始化。


虽然initialize方法对一个类而言只会调用一次，但这里由于出现了两个类，所以调用两次符合规则，但不符合我们的需求。正确使用initialize方法的姿势如下：

```objc
// In Parent.m
+ (void)initialize {
    if (self == [Parent class]) {
        NSLog(@"Initialize Parent, caller Class %@", [self class]);
    }
}
```

加上判断后，就不会因为子类而调用到自己的initialize方法了。

1. load和initialize方法都会在实例化对象之前调用，以main函数为分水岭，前者在main函数之前调用，后者在之后调用。这两个方法会被自动调用，不能手动调用它们。
2. **load和initialize方法都不用显示的调用父类的方法而是自动调用**，即使子类没有initialize方法也会调用父类的方法，而load方法则不会调用父类。
3. load方法通常用来进行Method Swizzle，initialize方法一般用于初始化全局变量或静态变量。
4. load和initialize方法内部使用了锁，因此它们是线程安全的。实现时要尽可能保持简单，避免阻塞线程，不要再使用锁。
5. 父类的initialize方法会比子类先执行
6. 当子类未实现initialize方法时,会调用父类initialize方法,子类实现initialize方法时,会覆盖父类initialize方法.
7. 当有多个Category都实现了initialize方法,会覆盖类中的方法,只执行一个(会执行Compile Sources 列表中最后一个Category 的initialize方法)

*load先在main函数之前加载，初始化类，然后initialize是类的一个懒加载*，如果没有使用这个类就不回去调用这个方法，默认只加载一次，而且发生在init方法之前。还有,创建子类的时候，子类会去调用父类的 + initialize 方法。

#### initialize方法和init区别详解

```objc
#import "Father.h"
 
@implementation Father
 
+(void)initialize
{
    NSLog(@"Father中的 initialize 方法执行");
}
 
-(Father *)init
{
    NSLog(@"Father中的 init 方法执行");
    return [super init];
}
 
@end

#import "Father.h"  
  
@interface Son : Father  
  
@end  
```

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15335755081498.jpg)

从以上图中可以看出

- Father类实例化3次，initialize执行一次，init执行3次
- Son继承自Father,当Son实例化一次的时候，其它父类中的initialize执行一次,init方法执行一次

#### initialize不是init

initialize在这个类第一次被调用的时候比如[[class alloc] init]会调用一次initialize方法,不管创建多少次这个类,都只会调用一次这个方法,我们用它来初始化静态变量,而init方法是只要这个类被调用,就会调用这个init方法,这个类被调用几次,这个init方法就会被调用几次,当有一个类继承这个类,是这个类的子类的时候,当子类被调用的时候比如子类被[[class alloc] init]的时候,父类的initialize和init方法都会被调用一次,

在程序运行过程中，它会在你程序中每个类调用一次initialize。这个调用的时间发生在你的类接收到消息之前，但是在它的父类接收到initialize之后。

### 设计一个类的interface

类与接口的设计原则 - 电视和遥控器
我喜欢将Class和interface的关系比喻成电视+遥控器，那么objc中的消息机制就可以理解成：

用户（caller）通过遥控器（interface）上的按钮（methods）发送红外线（message）来操纵电视（object）

所以，有没有遥控器，电视都在那儿，也就是说，有没有interface，class都是存在的，只是这种存在并没有意义，就好像这个电视没人会打开，没人会用，没人能看，一堆废铁摆在那儿。

所以，在设计一个类的interface的时候，如同在设计遥控器应该有怎样功能的按钮，要从调用者的角度出发，区分边界，应该时刻有以下几点考虑：

这个方法或属性真的属于这个类的职责么？（电视遥控器能遥控空调？）
这个方法或属性真的必须放在.h中（而不是放在.m的类扩展中）么？
调用者必须看文档才能知道这个类该如何使用么？（同一个业务需要调用者按顺序调用多次（而不是将这些细节隐藏，同时提供一个简洁的接口）才行）
调用者是否可以很容易发现类内部的变量和实现方式？（脑补下电视里面一块电路板漏在外面半截- -）

## 总结

1. 任何直接或间接继承了`NSObject`的类，它的实例对象 (`instacne object`)中都有一个`isa`指针，指向它的类对象(`class object`)。这个类对象(`class object`)中存储了关于这个实例对象(`instace object`)所属的类的定义的一切：包括变量，方法，遵守的协议等等。
2. `NSObject`的`isa`指针指向所述的类，而类对象(`class object`)的`isa`指针指向元类对象(`metaClass object`),类对象包含了类的实例变量、实例方法的定义，是用来描述该类的对象的信息;元类对象中包含了类的类方法的定义，是用来描述类的信息（类名，版本，类方法）.
3. 元类(`meta class`)是`Class`对象的类。每个类（`Class`）都有自己独一无二的元类（每个类都有自己第一无二的方法列表）。这意味着所有的类对象都不同。所有的元类使用基类的元类作为自己的基类，对于顶层基类的元类也是一样，只是它指向自己而已。
4. 理解类与元类的关系有利理解OC面向对象的思想，了解类的继承关系。对类这个概念更加熟悉。

### 对isa、superclass总结

* instance的isa指向class
* class的isa指向meta-class
* meta-class的isa指向基类的meta-class，基类的isa指向自己
* class的superclass指向父类的class，如果没有父类，superclass指针为nil
* meta-class的superclass指向父类的meta-class，基类的meta-class的superclass指向基类的class
* instance调用对象方法的轨迹，isa找到class，方法不存在，就通过superclass找父类
* class调用类方法的轨迹，isa找meta-class，方法不存在，就通过superclass找父类

### 参考阅读

1. [Objective-C特性：Runtime](http://www.jianshu.com/p/25a319aee33d)
2. [Effective Objective C 2.0](https://book.douban.com/subject/25829244/)
3. [Objective-C Runtime](http://tech.glowing.com/cn/objective-c-runtime/)
4. [由 NSObject *obj 引发的一二事儿 - 掘金](https://juejin.im/post/5b63b857e51d455f5f4d1d74)
5. [Objective-C 中的元类（meta class）是什么？](http://ios.jobbole.com/81657/)
6. [What is a meta-class in Objective-C?](http://www.cocoawithlove.com/2010/01/what-is-meta-class-in-objective-c.html)
7. [iOS底层原理总结 - 探寻OC对象的本质 - 简书](https://www.jianshu.com/p/aa7ccadeca88#iOS%E5%BA%95%E5%B1%82%E5%8E%9F%E7%90%86%E6%80%BB%E7%BB%93%20-%20%E6%8E%A2%E5%AF%BBOC%E5%AF%B9%E8%B1%A1%E7%9A%84%E6%9C%AC%E8%B4%A8)
8. [将`super init`分配给self时意味着什么？](http://www.cocoawithlove.com/2009/04/what-does-it-mean-when-you-assign-super.html)
9. [Classes and metaclasses](http://www.sealiesoftware.com/blog/archive/2009/04/14/objc_explain_Classes_and_metaclasses.html) 这篇文章主要为我们阐述在OC面向对象思想中，对象，类和元类的关系，类作为对象的角度去看OC是如何管理对象、类、元类之间的关系的。
10. [Objective-C中的实例方法、类方法、Category、Protocol | 程序员说](http://www.devtalking.com/articles/method-category-protocol/)
11. [iOS分类(category),类扩展(extension)—史上最全攻略 - 简书](https://www.jianshu.com/p/9e827a1708c6)
12. [iOS底层原理总结 - Category的本质 - 简书](https://www.jianshu.com/p/fa66c8be42a2)
13. [Category的本质<一> - 简书](https://www.jianshu.com/p/da463f413de7)
14. [objc@interface的设计哲学与设计技巧 · sunnyxx的技术博客](https://blog.sunnyxx.com/2014/04/13/objc_dig_interface/)
