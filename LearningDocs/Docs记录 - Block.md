
#  Docs记录 - Block
@(iOS_Docs)[iOS知识点整理]

`2017-04-17` `iOS_Docs`


[《Objective-C 高级编程》干货三部曲（二）：Blocks篇](http://www.jianshu.com/p/f3ee592e57f5)


### Block的循环引用
```
typedef void(^blk_t)(void);
@interface Person : NSObject
{
    blk_t blk_;
    id obj_;
}
@implementation Person
- (instancetype)init
{
    self = [super init];
    blk_ = ^{
        NSLog(@"obj_ = %@",obj_);//循环引用警告
    };
    return self;
}
```
Block语法内的obj截获了self,因为ojb是self的成员变量，因此，block如果想持有obj_，就必须引用先引用self，所以同样会造成循环引用。就好比你如果想去某个商场里的咖啡厅，就需要先知道商场在哪里一样。

如果某个属性用的是weak关键字呢？
```
@interface Person()
@property (nonatomic, weak) NSArray *array;
@end
@implementation Person
- (instancetype)init
{
    self = [super init];
    blk_ = ^{
        NSLog(@"array = %@",_array);//循环引用警告
    };
    return self;
}
```

**还是会有循环引用的警告提示，因为循环引用的是self和block之间的事情，这个被Block持有的成员变量是strong还是weak都没有关系,而且即使是基本类型（assign）也是一样。**

>可以作为一个很好的面试题


我们可以看到，这个结构体最后的成员变量就相当于原来自动变量。
这里有两个成员变量需要特别注意：

val：保存了最初的val变量，也就是说原来单纯的int类型的val变量被__block修饰后生成了一个结构体。这个结构体其中一个成员变量持有原来的val变量。
forwarding：通过forwarding，可以实现无论block变量配置在栈上还是堆上都能正确地访问block变量，也就是说__forwarding是指向自身的。
用一张图来直观看一下：


图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

怎么实现的？

最初，block变量在栈上时，它的成员变量forwarding指向栈上的__block变量结构体实例。
在__block被复制到堆上时，会将forwarding的值替换为堆上的目标block变量用结构体实例的地址。而在堆上的目标block变量自己的forwarding的值就指向它自己。
我们可以看到，这里面增加了指向Block_byref_val_0结构体实例的指针。这里//by ref这个由clang生成的注释，说明它是通过指针来引用Block_byref_val_0结构体实例val的。

因此Block_byref_val_0结构体并不在main_block_impl_0结构体中，目的是为了使得多个Block中使用__block变量。

举个例子：
```
int main()
{
    __block int val = 10;

    void (^blk0)(void) = ^{
        val = 12;
    };

    void (^blk1)(void) = ^{
        val = 13;
    };
    return 0;
}
```

```
int main()
{
    __attribute__((__blocks__(byref))) __Block_byref_val_0 val = {(void*)0,(__Block_byref_val_0 *)&val, 0, sizeof(__Block_byref_val_0), 10};

    void (*blk0)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_val_0 *)&val, 570425344));

    void (*blk1)(void) = ((void (*)())&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA, (__Block_byref_val_0 *)&val, 570425344));
    return 0;
}
```

我们可以看到，在main函数里，两个block都引用了__Block_byref_val_0结构体的实例val。

那么__block修饰对象的时候是怎么样的呢？

__block修饰对象

__block可以指定任何类型的自动变量。下面来指定id类型的对象:

看一下__block变量的结构体：

```
struct __Block_byref_obj_0 {
  void *__isa;
__Block_byref_obj_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 id obj;
};
被__strong修饰的id类型或对象类型自动变量的copy和dispose方法：

static void __Block_byref_id_object_copy_131(void *dst, void *src) {
 _Block_object_assign((char*)dst + 40, *(void * *) ((char*)src + 40), 131);
}


static void __Block_byref_id_object_dispose_131(void *src) {
 _Block_object_dispose(*(void * *) ((char*)src + 40), 131);
}
```
同样，当Block持有被__strong修饰的id类型或对象类型自动变量时：

如果__block对象变量从栈复制到堆时，使用_Block_object_assign函数，
当堆上的__block对象变量被废弃时，使用_Block_object_dispose函数。
```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_obj_0 *obj; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_obj_0 *_obj, int flags=0) : obj(_obj->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```
可以看到，obj被添加到了main_block_impl_0结构体中，它是Block_byref_obj_0类型。

三种Block

细心的同学会发现，在上面Block的构造函数__main_block_impl_0中的isa指针指向的是&_NSConcreteStackBlock，它表示当前的Block位于栈区中。实际上，一共有三种类型的Block：

Block的类	存储域	拷贝效果
_NSConcreteStackBlock	栈	从栈拷贝到堆
_NSConcreteGlobalBlock	程序的数据区域	什么也不做
_NSConcreteMallocBlock	堆	引用计数增加
全局Block：_NSConcreteGlobalBlock

因为全局Block的结构体实例设置在程序的数据存储区，所以可以在程序的任意位置通过指针来访问，它的产生条件：

记述全局变量的地方有block语法时。
block不截获的自动变量时。
以上两个条件只要满足一个就可以产生全局Block，下面分别用C++来展示一下第一种条件下的全局Block：

c代码：

```
void (^blk)(void) = ^{printf("Global Block\n");};
int main()
{
    blk();
}
```
C++代码：
```
struct __blk_block_impl_0 {
  struct __block_impl impl;
  struct __blk_block_desc_0* Desc;
  __blk_block_impl_0(void *fp, struct __blk_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteGlobalBlock;//全局
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __blk_block_func_0(struct __blk_block_impl_0 *__cself) {
printf("Global Block\n");}

static struct __blk_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __blk_block_desc_0_DATA = { 0, sizeof(struct __blk_block_impl_0)};

static __blk_block_impl_0 __global_blk_block_impl_0((void *)__blk_block_func_0, &__blk_block_desc_0_DATA);
void (*blk)(void) = ((void (*)())&__global_blk_block_impl_0);

int main()
{
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
}
```
我们可以看到Block结构体构造函数里面isa指针被赋予的是&_NSConcreteGlobalBlock，说明它是一个全局Block。
栈Block：_NSConcreteStackBlock

在生成Block以后，如果这个Block不是全局Block，那么它就是为_NSConcreteStackBlock对象，但是如果其所属的变量作用域名结束，该block就被废弃。在栈上的__block变量也是如此。

但是，如果Block变量和__block变量复制到了堆上以后，则不再会受到变量作用域结束的影响了，因为它变成了堆Block：

堆Block：_NSConcreteMallocBlock

将栈block复制到堆以后，block结构体的isa成员变量变成了_NSConcreteMallocBlock。
其他两个类型的Block在被复制后会发生什么呢？

Block类型	存储位置	copy操作的影响
_NSConcreteGlobalBlock	程序的数据区域	什么也不做
_NSConcreteStackBlock	栈	从栈拷贝到堆
_NSConcreteMallocBlock	堆	引用计数增加
而大多数情况下，编译器会进行判断，自动将block从栈上复制到堆：

block作为函数值返回的时候
部分情况下向方法或函数中传递block的时候
Cocoa框架的方法而且方法名中含有usingBlock等时。
Grand Central Dispatch 的API。
除了这两种情况，基本都需要我们手动复制block。

那么__block变量在Block执行copy操作后会发生什么呢？

任何一个block被复制到堆上时，__block变量也会一并从栈复制到堆上，并被该Block持有。
如果接着有其他Block被复制到堆上的话，被复制的Block会持有block变量，并增加block的引用计数，反过来如果Block被废弃，它所持有的__block也就被释放（不再有block引用它）。

### Block循环引用

如果在Block内部使用__strong修饰符的对象类型的自动变量，那么当Block从栈复制到堆的时候，该对象就会被Block所持有。

所以如果这个对象还同时持有Block的话，就容易发生循环引用。

```
typedef void(^blk_t)(void);

@interface Person : NSObject
{
    blk_t blk_;
}

@implementation Person

- (instancetype)init
{
    self = [super init];
    blk_ = ^{
        NSLog(@"self = %@",self);
    };
    return self;
}

@end
```

扩展文献：

深入研究Block捕获外部变量和__block实现原理
让我们来深入浅出block吧
谈Objective-C block的实现


