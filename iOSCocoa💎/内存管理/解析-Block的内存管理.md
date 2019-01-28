# Block的内存管理

block本质上也是一个oc对象，他内部也有一个isa指针。block是封装了函数调用以及函数调用环境的OC对象。

## block 定义

block是iOS4.0+ 和Mac OS X 10.6+ 引进的对C语言的扩展，用来实现匿名函数的特性。

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15321623412835.jpg)

* 等号左侧的代码表示了这个Block的类型：它接受一个int参数，返回一个int值。
* 等号右侧的代码是这个Block的值：它是等号左侧定义的block类型的一种实现。

如果我们在项目中经常使用某种相同类型的block，我们可以用typedef来抽象出这种类型的Block：

```objc
typedef int(^AddOneBlock)(int count);
AddOneBlock block = ^(int count){
        return count + 1;//具体实现代码
};
```

这样一来，block的赋值和传递就变得相对方便一些了, 因为block的类型已经抽象了出来。

### Block语法的省略

Block语法可以省略返回值类型。当省略返回值类型时，如果表达式中有return语句，则使用该返回值类型；如果有多个return语句，则每个语句的返回值类型必须一致；如果没有返回值，则使用void类型：

```objc
^ (int count) { return count + 1; }// 返回值类型为int
^ (int count) { NSLog(@"Hello World!"); }// 返回值类型为void
^ (int count) {
                if(count > 1)
                    return count;
                else
                    return --count;}// 返回值类型为int
^ (int count) {
                if(count > 1)
                    return count;
                else
                    return @"11";}// 错误       
```

如果不使用参数，参数列表也可以省略

```objc
^ { NSLog(@"Hello World!");}
```
对应的结构体定义如下：


```objc
struct Block_descriptor {
    unsigned long int reserved;
    unsigned long int size;
    void (*copy)(void *dst, void *src);
    void (*dispose)(void *);
};
struct Block_layout {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor *descriptor;
    /* Imported variables. */
};
```
通过该图，我们可以知道，一个 block 实例实际上由 6 部分构成：

* isa 指针，所有对象都有该指针，用于实现对象相关的功能。
* flags，用于按 bit 位表示一些 block 的附加信息，本文后面介绍 block copy 的实现代码可以看到对该变量的使用。
* reserved，保留变量。
* invoke，函数指针，指向具体的 block 实现的函数调用地址。
* descriptor， 表示该 block 的附加描述信息，主要是 size 大小，以及 copy 和 dispose 函数的指针。
* variables，capture 过来的变量，block 能够访问它外部的**局部变量**，就是因为将这些**变量（或变量的地址）复制到了结构体中**。

## block源码探究

一个简单block

```objc
int main()
{
    void (^blk)(void) = ^{
        printf("Block\n");
    };
    return 0;
}
```

以一个简单block为例，Clang提供了中间代码展示的选项供我们进一步了解block的原理。
在Terminal，使用-rewrite-objc选项编译:

得到一份main.cpp文件，open这份文件中可以看到如下代码片段:

```objc
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;//可以看到是指向__main_block_func_0函数的指针
};

//block结构体
struct __main_block_impl_0 {
    
  struct __block_impl impl;
    
  struct __main_block_desc_0* Desc;
  
  //Block构造函数
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;//isa指针
    impl.Flags = flags;
    impl.FuncPtr = fp; //查看调用block的源码，可以看到是指向__main_block_func_0函数的指针
    Desc = desc;
  }
};

//将来被调用的block内部的代码：block值被转换为C的函数代码
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

        printf("Block\n");
}

static struct __main_block_desc_0 {
    
  size_t reserved;
  size_t Block_size;
    
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

//main 函数
int main()
{
    void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    return 0;
}
```

这里，*__cself 是指向Block的值的指针，也就相当于是Block的值它自己（相当于C++里的this，OC里的self）。

而且很容易看出来，__cself 是指向__main_block_impl_0结构体实现的指针。
结合上句话，也就是说Block结构体就是__main_block_impl_0结构体。**Block的值就是通过__main_block_impl_0构造出来的。**

### __main_block_impl_0结构体有三个部分：

#### 成员变量impl

第一个是成员变量impl，它是实际的函数指针，它指向__main_block_func_0。来看一下它的结构体的声明：

```objc
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;  //今后版本升级所需的区域
  void *FuncPtr; //函数指针
};
```

#### 指向___main_block_desc_0结构体的Desc指针

第二个是成员变量是指向__main_block_desc_0结构体的Desc指针，是用于描述当前这个block的附加信息的，包括结构体的大小等等信息

```objc
static struct __main_block_desc_0 {

  size_t reserved;  //今后升级版本所需区域
  size_t Block_size;//block的大小

} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

```

#### __main_block_impl_0结构体的构造函数

第三个部分是__main_block_impl_0结构体的构造函数，**__main_block_impl_0 就是该 block 的实现**

```objc
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
```

这里，block的类型用_NSConcreteStackBlock来表示，表明这个block位于栈中。同样地，还有_NSConcreteMallocBlock和_NSConcreteGlobalBlock。


## Block 变量类型

 在 block 的主体代码里面，变量可以被使用五种方法来处理。
 你可以引用三种标准类型的变量，就像你在函数里面引用那样:
z 全局变量，包括静态局部变量。
z 全局函数（在技术上而言这不是变量）。
z 封闭范围内的局部变量和参数。

Blocks 同样支持其他两种类型的变量:
1. 在函数级别是__block 变量。这些在 block 里面是可变的(和封闭范围)，并任何引
用 block 的都被保存一份副本到堆里面。
2. 引入 const。
3. 最后，在实现方法里面，blocks 也许会引用 Objective-C 的实例变量。参阅“对象
和 Block 变量”部分。
 在 block 里面使用变量遵循以下规则:
1. 全局变量可访问，包括在相同作用域范围内的静态变量。
2. 传递给 block 的参数可访问（和函数的参数一样）。
3. 程序里面属于同一作用域范围的堆（非静态的）变量作为 const 变量(即只读)。
它们的值在程序里面的 block 表达式内使用。在嵌套 block 里面，该值在最近的
封闭范围内被捕获。
4. 属于同一作用域范围内并被__block 存储修饰符标识的变量作为引用传递因此是
可变的。
5. 属于同一作用域范围内 block 的变量，就和函数的局部变量操作一样。
 每次调用 block 都提供了变量的一个拷贝。这些变量可以作为 const 来使用，或在
block 封闭范围内作为引用变量。 

## Block截获自动变量

```objc
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_k, int _val, int flags=0) : static_k(_static_k), val(_val)
```

* 这个构造函数中，自动变量和静态变量被捕获为成员变量追加到了构造函数中。
* __main_block_impl_0结构体就是这样把自动变量捕获进来的。也就是说，在执行Block语法的时候，Block语法表达式所使用的自动变量的值是被保存进了Block的结构体实例中，也就是Block自身中。
* Block捕获外部变量仅仅只捕获Block闭包里面会用到的值，其他用不到的值，它并不会去捕获。
* 我们可以发现，系统自动给我们加上的注释，bound by copy，自动变量val虽然被捕获进来了，但是是用 __cself->val来访问的。Block仅仅捕获了val的值，并没有捕获val的内存地址。所以在__main_block_func_0这个函数中即使我们重写这个自动变量val的值，依旧没法去改变Block外面自动变量val的值。
* 自动变量是以值传递方式传递到Block的构造函数里面去的。Block只捕获Block中会用到的变量。由于只捕获了自动变量的值，并非内存地址，所以Block内部不能改变自动变量的值。Block捕获的外部变量可以改变值的是静态变量，静态全局变量，全局变量。

> **Blocks中Block表达式截获所使用的自动变量的值，即保存该自动变量的瞬间值**。因为Block表达式保存了自动变量的值，所以在执行Block语法后，即使改写Block中使用的自动变量的值也不会影响Block执行时的自动变量的值。
> 在 ARC 开启的情况下，将只会有 NSConcreteGlobalBlock 和 NSConcreteMallocBlock 类型的 block。

我们知道，Block可以截获自动变量，但是实现原理是什么呢？我们先把Block截获自动变量源代码通过clang转换一下。
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15341973496169.jpg)

转换后的代码：

```objc
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  char *str;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, char *_str, int flags=0) : str(_str) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  char *str = __cself->str; // bound by copy

        printf("%s",str);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main(int argc, const char * argv[]) {
    int a = 1;
    int c = 2;
    char *str = "Hello,World!";
    void (*blk) (void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, str));
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}
```

**不难发现，截获的自动变量`str`被追加到了__main_block_impl_0结构体中，而没有使用的变量则没有截获**。看看初始化后结构体的构造函数：

```objc
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, char *_str, int flags=0) : str(_str)
```

* 在非 ARC 下，LLVM 编译下没有访问局部变量的 Block 应该是 NSConcreteGlobalBlock 类型的，访问了局部变量的 Block 是 NSConcreteStackBlock 类型的。

* 在 ARC 下，访问了局部变量的 Block 是 NSConcreteMallocBlock 类型的，未访问局部变量的 Block 是 NSConcreteGlobalBlock 类型的。


### _NSConcreteGlobalBlock

是设置在程序的全局数据区域（.data区）中的Block对象。**在全局声明实现的block或者没有用到自动变量的block为_NSConcreteGlobalBlock**，生命周期从创建到应用程序结束。

* 定义在函数外面的block是global的，
* block在函数内部，**但是没有捕获任何自动变量**，那么它也是全局的。

比如下面这样的代码：

*   全局block：

    ```objc
    void (^glo_blk)(void) = ^{
        NSLog(@"global");
    };

    int main(int argc, const char * argv[]) {
        glo_blk();
        NSLog(@"%@",[glo_blk class]);
    }
    ```

    运行结果：

    ```objc
    global
    __NSGlobalBlock__

    ```

    同时，clang编译后isa指针为_NSConcreteGlobalBlock。


* _NSConcreteGlobalBlock:  如果一个Block没有引入外部变量，那么这个Block就是全局Block，全局Block在编译时期就已经确定大小了，如同宏一样

例子：
```objc
void(^p)() = ^(){ 
    printf("Hello, World!\n"); 
 } 
```
NSConcreteGlobalBlock类型的Block要么是空的Block，要么是不访问任何外部变量的block。它既不在栈中，也不在堆中，我理解为它可能在内存的全局区。

### _NSConcreteStackBlock

* _NSConcreteStackBlock: 当引入了外部变量时，这种Block就是栈block了
    - NSConcreteStackBlock内部会有一个结构体__main_block_impl_0，这个结构体会保存外部变量，使其体积变大。而这就导致了NSConcreteStackBlock并不像宏一样，而是一个动态的对象。而它由于没有被持有，所以在它的内部，它也不会持有其外部引用的对象。（注意，栈Block是不会持有外部变量的）
* 只要block没有引用外部局部变量，block放在全局区。
* 在ARC下
    - 只要Block引用外部局部变量, block放在堆里面（因为ARC的局部变量都是强指针，都放在堆里面）
* 在MRC下
    - 只要Block引用外部局部变量, block放在栈里面。
    - block只能使用copy,不能使用retain,因为如果使用retain修饰，block内存分配在栈里面，超出作用域后就会被回收，造成野指针。
 
 例子：
```objc
int a;
void(^p)() = ^(){ 
    printf("int a = %d\n",a); 
}    
```
  
* _NSConcreteStackBlock类型的block有闭包行为，也就是有访问外部变量，并且该block只且只有有一次执行，因为栈中的空间是可重复使用的，所以当栈中的block执行一次之后就被清除出栈了，所以无法多次使用。

* NSStackBlock在函数返回后，Block内存将被回收。即使retain也没用。容易犯的错误是[[mutableArray addObject:stackBlock]，在函数出栈后，从mutableAarry中取到的stackBlock已经被回收，变成了野指针。正确的做法是先将stackBlock copy到堆上，然后加入数组：

### _NSConcreteMallocBlock

* _NSConcreteMallocBlock：	堆Block就是一个Block被copy到堆上，堆Block会持有外部引用对象，所以会导致可能的对象延迟释放，或者循环引用的问题。（在MRC下，局部变量如果没有用_Block，在Block中会对其进行copy操作，而用了__block则只会引用其地址，这也就是为什么改变局部变量需要用__block修饰了）

例子：

```objc
void exampleB_addBlockToArray(NSMutableArray *array) {
    char b = 'B';
    //将block 放入到数组中
    [array addObject:^{
            printf("%c\n", b);
    }];
}
void exampleB() {
    NSMutableArray *array = [NSMutableArray array];
    exampleB_addBlockToArray(array);
    //复制行为导致block 是从栈中复制到堆中。
    void (^block)() = [array objectAtIndex:0];
    block();
}
```

* _NSConcreteMallocBlock类型的block有闭包行为，并且该block需要被多次执行。**当需要多次执行时，就会把该block从栈中复制到堆中，供以多次执行**。

* **Block作为返回值，超出了变量作用域，Block被拷贝至堆，那么Block也将配置为_NSConcreteMallocBlock**

*   在函数栈上创建但没有截获自动变量

    ```objc
    int glo_a = 1;
    static int sglo_b =2;
    int main(int argc, const char * argv[]) {
        void (^glo_blk1)(void) = ^{//没有使用任何外部变量
            NSLog(@"glo_blk1");
        };
        glo_blk1();
        NSLog(@"glo_blk1 : %@",[glo_blk1 class]);

        static int c = 3;
        void(^glo_blk2)(void) = ^() {//只用到了静态变量、全局变量、静态全局变量
            NSLog(@"glo_a = %d,sglo_b = %d,c = %d",glo_a,sglo_b,c);
        };
        glo_blk2();
        NSLog(@"glo_blk2 : %@",[glo_blk2 class]);

    ```

    运行结果：

    ```objc
    glo_blk1
    glo_blk1 : __NSGlobalBlock__
    glo_a = 1,sglo_b = 2,c = 3
    glo_blk2 : __NSGlobalBlock__

    ```

然而，从clang编译结果来看，这两个block的isa的指针值都是_NSConcreteStackBlock。
Block作为返回值时，编译器会自动将变量拷贝至堆，有时候编译器无法判断，需要手动调用copy方法，将Block拷贝至堆

```

typedef void (^Block)();

id foo(){
    int i = 0;
    return [[NSArray alloc] initWithObjects:
            ^{printf("blk:%d", i);},
            nil];
}

NSArray *arr = foo();
Block blk = (Block)[arr firstObject];
blk();//此处执行报错

```

该段代码执行将会报错，因为`foo()`执行结束后，栈上的Block就被释放了，所以需要手动copy 下`Block`

```
id foo(){
    int i = 0;
    return [[NSArray alloc] initWithObjects:
           [^{printf("blk:%d", i);} copy],//手动copy block到堆
            nil];
}
```

### block的自动拷贝和手动拷贝

在ARC有效时，大多数情况下编译器会进行判断，自动生成将Block从栈上复制到堆上的代码，以下几种情况栈上的Block会自动复制到堆上：

* 调用Block的copy方法
* 将Block作为函数返回值时
* 将Block赋值给__strong修饰的变量或Block类型成员变量时
* 向Cocoa框架含有usingBlock的方法或者GCD的API传递Block参数时
* 因此ARC环境下多见的是MallocBlock，但StackBlock也是存在的：
* 不要进行任何copy、赋值等等操作，直接使用block


## Block内修改外部变量

在block内如何修改block外部变量引发的思考

上文已经说过：Block不允许修改外部变量的值，这里所说的外部变量的值，指的是栈中指针的内存地址。栈区是红灯区，堆区才是绿灯区。

我们都知道：Block不允许修改外部变量的值，这里所说的外部变量的值，指的是**栈中指针的内存地址**。`__block` 所起到的作用就是只要观察到该变量被 block 所持有，就将“外部变量”在栈中的内存地址放到了堆中。进而在block内部也可以修改外部变量的值。

Block不允许修改外部变量的值。Apple这样设计，应该是考虑到了block的特殊性，block也属于“函数”的范畴，变量进入block，实际就是已经改变了作用域。在几个作用域之间进行切换时，如果不加上这样的限制，变量的可维护性将大大降低。又比如我想在block内声明了一个与外部同名的变量，此时是允许呢还是不允许呢？只有加上了这样的限制，这样的情景才能实现。于是栈区变成了红灯区，堆区变成了绿灯区。

当我们想要修改Block内截获的自动变量的值的时候，可以有三种方法：

* 静态变量
* 静态全局变量
* 全局变量
* 添加__block说明符


```objc
#import <Foundation/Foundation.h>
int globalVal = 1;
static int globalStatic = 1;
int main(int argc, const char * argv[]) {
    static int staticVal = 1;
    __block int blockVal = 1;
    void (^blk) (void) = ^{
        globalVal = 2;
        globalStatic = 3;
        staticVal = 4;
        blockVal = 5;
        printf("globalVal is :%d\nglobalStatic is :%d\nstaticVal is :%d\nblockVal is %d\n",globalVal,globalStatic,staticVal,blockVal);
    };
    blk();
    return 0;
}
```

运行结果 
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15342032355709.jpg)
代码转换后如下：


```objc
int globalVal = 1;
static int globalStatic = 1;
struct __Block_byref_blockVal_0 {
  void *__isa;
__Block_byref_blockVal_0 *__forwarding;
 int __flags;
 int __size;
 int blockVal;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int *staticVal;
  __Block_byref_blockVal_0 *blockVal; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_staticVal, __Block_byref_blockVal_0 *_blockVal, int flags=0) : staticVal(_staticVal), blockVal(_blockVal->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_blockVal_0 *blockVal = __cself->blockVal; // bound by ref
  int *staticVal = __cself->staticVal; // bound by copy

        globalVal = 2;
        globalStatic = 3;
        (*staticVal) = 4;
        (blockVal->__forwarding->blockVal) = 5;
        printf("globalVal is :%d\nglobalStatic is :%d\nstaticVal is :%d\nblockVal is %d\n",globalVal,globalStatic,(*staticVal),(blockVal->__forwarding->blockVal));
    }
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->blockVal, (void*)src->blockVal, 8/*BLOCK_FIELD_IS_BYREF*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->blockVal, 8/*BLOCK_FIELD_IS_BYREF*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
int main(int argc, const char * argv[]) {
    static int staticVal = 1;
    __attribute__((__blocks__(byref))) __Block_byref_blockVal_0 blockVal = {(void*)0,(__Block_byref_blockVal_0 *)&blockVal, 0, sizeof(__Block_byref_blockVal_0), 1};
    void (*blk) (void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &staticVal, (__Block_byref_blockVal_0 *)&blockVal, 570425344));
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}
```


### 局部变量的捕获

局部变量因为跨函数访问所以需要捕获，全局变量在哪里都可以访问 ，所以不用捕获。

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15342294438554.jpg)

总结：局部变量都会被block捕获，自动变量是值捕获，静态变量为地址捕获。全局变量则不会被block捕获

不论对象方法还是类方法都会默认将self作为参数传递给方法内部，既然是作为参数传入，那么self肯定是局部变量。上面讲到局部变量肯定会被block捕获。

// __NSGlobalBlock__ : __NSGlobalBlock : NSBlock : NSObject
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15342314010039.jpg)

### block变量的复制

对于 block 外的变量引用，block 默认是将其复制到其数据结构中来实现访问的，如下图所示（图片来自 这里）：
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15342438003584.jpg)

对于用 __block 修饰的外部变量引用，block 是复制其引用地址来实现访问的，如下图所示（图片来自 这里）：
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15342438036044.jpg)

### __weak

__weak添加之后，person在作用域执行完毕之后就被销毁了。


```objc
__block typeof(self)weakSelf = self;  MRC
__weak typeof(self)weakSelf = self; ARC
等同于
__weak UIViewController * weakSelf = self;
__strong typeof(self)strongSelf = weakSelf; ARC
```

### __block

* __weak 是ARC下使用
* __block 在ARC和MRC下都可以使用

* __weak 只能修饰对象信息 不能修饰基本类型
* __block 对象和基本类型都可以修饰

* __block修饰的对象可以再block里面重新被赋值__weak不可以。

* __block修饰对象会增加引用(ARC)
* __weak修饰对象不会增加引用
* MRC下__block不会增加引用计数，但ARC会，ARC下必须用__weak指明不增加引用计数
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359389595221.jpg)

#### _Block_object_assign函数调用时机及作用

当block进行copy操作的时候就会自动调用`__main_block_desc_0`内部的`__main_block_copy_0`函数，`__main_block_copy_0`函数内部会调用`_Block_object_assign`函数。

`_Block_object_assign`函数会自动根据`__main_block_impl_0`结构体内部的`person`是什么类型的指针，对`person`对象产生强引用或者弱引用。可以理解为`_Block_object_assign`函数内部会对`person`进行引用计数器的操作，如果`__main_block_impl_0`结构体内`person`指针是`__strong`类型，则为强引用，引用计数+1，如果`__main_block_impl_0`结构体内`person`指针是`__weak`类型，则为弱引用，引用计数不变。

### 循环引用

系统的某些block api中，UIView的block版本写动画时不需要考虑，但也有一些api 需要考虑：

所谓“引用循环”是指双向的强引用，所以那些“单向的强引用”（block 强引用 self ）没有问题，比如这些：

```objc
[UIView animateWithDuration:duration animations:^{ [self.superview layoutIfNeeded]; }]; 
[[NSOperationQueue mainQueue] addOperationWithBlock:^{ self.someProperty = xyz; 
}]; 
[[NSNotificationCenter defaultCenter]               addObserverForName:@"someNotification"  
 object:nil 
                          queue:[NSOperationQueue mainQueue]                                         usingBlock:^(NSNotification * notification) {
    self.someProperty = xyz; 
}]; 
```

这些情况不需要考虑“引用循环”。

但如果你使用一些参数中可能含有 ivar 的系统 api ，如 GCD 、NSNotificationCenter就要小心一点：比如GCD 内部如果引用了 self，而且 GCD 的其他参数是 ivar，则要考虑到循环引用：

```objc
__weak __typeof__(self) weakSelf = self;
dispatch_group_async(_operationsGroup, _operationsQueue, ^
{
    __typeof__(self) strongSelf = weakSelf;
    [strongSelf doSomething];
    [strongSelf doSomethingElse];
} );
```

类似的：


```objc
 __weak __typeof__(self) weakSelf = self;
 _observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"testKey" object:nil queue:nil
usingBlock:^(NSNotification *note) {
     __typeof__(self) strongSelf = weakSelf;
     [strongSelf dismissModalViewControllerAnimated:YES];
 }];
self --> _observer --> block --> self 显然这也是一个循环引用。
```


```objc
#import "ViewController.h"
#import "Student.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    Student *student = [[Student alloc]init];
    student.name = @"Hello World";

    student.study = ^{
        NSLog(@"my name is = %@",student.name);
    };
}
```

到这里，大家应该看出来了，这里肯定出现了循环引用了。**student的study的Block里面强引用了student自身。根据上篇文章的分析，可以知道，_NSConcreteMallocBlock捕获了外部的对象，会在内部持有它**。retainCount值会加一。


```objc
#import "ViewController.h"
#import "Student.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Student *student = [[Student alloc]init];
    student.name = @"Hello World";

    student.study = ^(NSString * name){
        NSLog(@"my name is = %@",name);
    };
    student.study(student.name);
}
```

我把block新传入一个参数，传入的是student.name。这个时候会引起循环引用么？
答案肯定是不会。
并不会出现内存泄露。原因是因为，student是作为形参传递进block的，**block并不会捕获形参到block内部进行持有**。所以肯定不会造成循环引用。


## 探寻block的本质

首先写一个简单的block
```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int age = 10;
        void(^block)(int ,int) = ^(int a, int b){
            NSLog(@"this is block,a = %d,b = %d",a,b);
            NSLog(@"this is block,age = %d",age);
        };
        block(3,5);
    }
    return 0;
}
```
使用命令行将代码转化为c++查看其内部结构，与OC代码进行比较
```objc
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m
```

![block的c++代码与oc代码对比](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15341516793332.jpg)



### 定义block变量

```objc
// 定义block变量代码
void(*block)(int ,int) = ((void (*)(int, int))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, age));
```

上述定义代码中，可以发现，block定义中调用了__main_block_impl_0函数，并且将__main_block_impl_0函数的地址赋值给了block。那么我们来看一下__main_block_impl_0函数内部结构。

#### __main_block_imp_0结构体

![__main_block_imp_0结构体](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15341517504423.jpg)

__main_block_imp_0结构体内有一个同名构造函数__main_block_imp_0，构造函数中对一些变量进行了赋值最终会返回一个结构体。

那么也就是说最终将一个__main_block_imp_0结构体的地址赋值给了block变量

__main_block_impl_0结构体内可以发现__main_block_impl_0构造函数中传入了四个参数。(void *)__main_block_func_0、&__main_block_desc_0_DATA、age、flags。其中flage有默认值，也就说flage参数在调用的时候可以省略不传。而最后的 age(_age)则表示传入的_age参数会自动赋值给age成员，相当于age = _age。

#### (void *)__main_block_func_0

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15341520265815.jpg)

在__main_block_func_0函数中首先取出block中age的值，紧接着可以看到两个熟悉的NSLog，可以发现这两段代码恰恰是我们在block块中写下的代码。

**__main_block_func_0函数中其实存储着我们block中写下的代码**。而__main_block_impl_0函数中传入的是(void *)__main_block_func_0，也就说将我们写在block块中的代码封装成__main_block_func_0函数，并将__main_block_func_0函数的地址传入了__main_block_impl_0的构造函数中保存在结构体内。

### 局部变量

age也就是我们定义的局部变量。因为在block块中使用到age局部变量，所以在block声明的时候这里才会将age作为参数传入，也就说block会捕获age，如果没有在block中使用age，这里将只会传入(void *)__main_block_func_0，&__main_block_desc_0_DATA两个参数。

这里可以根据源码思考一下为什么当我们在定义block之后修改局部变量age的值，在block调用的时候无法生效。

```objc
int age = 10;
void(^block)(int ,int) = ^(int a, int b){
     NSLog(@"this is block,a = %d,b = %d",a,b);
     NSLog(@"this is block,age = %d",age);
};
     age = 20;
     block(3,5); 
     // log: this is block,a = 3,b = 5
     //      this is block,age = 10
```

因为block在定义的之后**已经将age的值传入存储在__main_block_imp_0结构体中**，并在调用的时候将age从block中取出来使用，因此在block定义之后对局部变量进行改变是无法被block捕获的。

此时回过头来查看__main_block_impl_0结构体
![__main_block_impl_0结构体](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15341524633892.jpg)

首先我们看一下__block_impl第一个变量就是__block_impl结构体。
来到__block_impl结构体内部

![__block_impl结构体内部](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15341550978667.jpg)

我们可以发现__block_impl结构体内部就有一个isa指针。因此可以证明block本质上就是一个oc对象。而在构造函数中将函数中传入的值分别存储在__main_block_impl_0结构体实例中，最终将结构体的地址赋值给block。

接着通过上面对__main_block_impl_0结构体构造函数三个参数的分析我们可以得出结论：

* __block_impl结构体中isa指针存储&_NSConcreteStackBlock地址，可以暂时理解为其类对象地址，block就是_NSConcreteStackBlock类型的。

* block代码块中的代码被封装成__main_block_func_0函数，FuncPtr则存储着__main_block_func_0函数的地址。

* Desc指向__main_block_desc_0结构体对象，其中存储__main_block_impl_0结构体所占用的内存。

### 调用block执行内部代码

```objc
// 执行block内部的代码
((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 3, 5);
```

通过上述代码可以发现调用block是通过block找到FunPtr直接调用，通过上面分析我们知道block指向的是__main_block_impl_0类型结构体，但是我们发现__main_block_impl_0结构体中并不直接就可以找到FunPtr，而FunPtr是存储在__block_impl中的，为什么block可以直接调用__block_impl中的FunPtr呢？

重新查看上述源代码可以发现，(__block_impl *)block将block强制转化为__block_impl类型的，因为__block_impl是__main_block_impl_0结构体的第一个成员，相当于将__block_impl结构体的成员直接拿出来放在__main_block_impl_0中，那么也就说明__block_impl的内存地址就是__main_block_impl_0结构体的内存地址开头。所以可以转化成功。并找到FunPtr成员。

上面我们知道，FunPtr中存储着通过代码块封装的函数地址，那么调用此函数，也就是会执行代码块中的代码。并且回头查看__main_block_func_0函数，可以发现第一个参数就是__main_block_impl_0类型的指针。也就是说将block传入__main_block_func_0函数中，便于重中取出block捕获的值。

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15341565978735.jpg)


### 优劣简介

####  block优势:

    a.最⼤大限度地使⽤用上下⽂文变量和环境,便于参数灵活传递。

    b.内存安全(避免delegate弱引⽤用可能带来的野指针问题)。

    c.使⽤方便，inline声明。



####  block的劣势:

    a.容易造成内存循环引⽤；

    b.如果是跨越栈帧的调⽤用，需要有copy操作(栈->堆)；

    c.__block带来的野指针问题。
    
## 循环利用

block造成循环利用: Block会对里面所有强指针变量都强引用一次

```objc
__weak typeof(self) weakSelf = self;
_block = ^{
     NSLog (@"weakSelf = %@" ,weakSelf);
};

_block();
```


## 总结

* Block执行的代码，这是在编译的时候已经生成好的；
* 一个包含Block执行时需要的所有外部变量值的数据结构。 Block将使用到的、作用域附近到的变量的值建立一份快照拷贝到栈上。
* Block与函数另一个不同是，Block类似ObjC的对象，可以使用自动释放池管理内存（但Block并不完全等同于ObjC对象，后面将详细说明）。
* 
在我们创建Block的时候，会生成`__main_block_impl_0`结构体变量赋值给Block变量。由于该结构体中存在isa指针，所以使block成为了OC对象，即该结构体相当于基于objc_object结构体的OC类对象结构体。(关于isa指针请参见：[关于oc运行时 isa指针详解](https://link.jianshu.com?t=http://www.cnblogs.com/zhangdashao/p/4438540.html))我们以`__main_block_func_0`函数指针（其指向我们自定义的代码块所在函数）和`__main_block_desc_0_DATA`结构体（其保存了今后升级所需区域和Block大小）来初始化`__main_block_impl_0`结构体。通过过函数指针的调用，我们就实现了Block的使用。


## 参考

1. [iOS底层原理总结 - 探寻block的本质（一） - 简书](https://www.jianshu.com/p/c99f4974ddb5#%E6%8E%A2%E5%AF%BBblock%E7%9A%84%E6%9C%AC%E8%B4%A8)
2. [block内部实现原理(一) - 折半 - 博客园](https://www.cnblogs.com/yoon/p/4953618.html)
3. [在block内如何修改block外部变量引发的思考](https://www.jianshu.com/p/a1c8532e172d)
4. [iOS基础深入补完计划--Block相关原理探究 - 简书](https://www.jianshu.com/p/083315ba7671)
5. [正确使用Block避免Cycle Retain和Crash - Cooper's Blog](http://tanqisen.github.io/blog/2013/04/19/gcd-block-cycle-retain/)
6. [《Objective-C 高级编程》干货三部曲（二）：Blocks篇](http://www.jianshu.com/p/f3ee592e57f5)
7. [Objective-C之Blocks（三） - 简书](https://www.jianshu.com/p/df9e08646094)
8. [iOS Block原理探究以及循环引用的问题 - 简书](https://www.jianshu.com/p/9ff40ea1cee5?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation#3.1%E5%AD%98%E5%82%A8%E5%9F%9F)
9. [深入研究Block捕获外部变量和__block实现原理 - 简书](https://www.jianshu.com/p/ee9756f3d5f6)
