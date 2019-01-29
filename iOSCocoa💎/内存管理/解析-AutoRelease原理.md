# 解析-AutoRelease原理

> AutoreleasePool（自动释放池）是OC中的一种内存自动回收机制，它可以延迟加入AutoreleasePool中的变量release的时机。在正常情况下，创建的变量会在超出其作用域的时候release，但是如果将变量加入AutoreleasePool，那么release将延迟执行。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190129154525.png)

## Autoreleasepool 介绍

在开始每一个事件循环之前系统会在主线程创建一个自动释放池, 并且在事件循环结束的时候把前面创建的释放池释放, 回收内存。

### Autorelease /Autoreleasepool 基本用法及其优点

对象执行autorelease方法 或者直接在autoreleasepool中创建对象 ，会将对象添加到当前的autorelease pool中， 当自动释放池销毁时 自动释放池中 所有对象 作release操作。

### Autoreleasepool 什么时候释放

这个问题拿来做面试题，问很多人，很少能答对。很多答案都是“当前作用域大括号结束时释放”，显然没有正确理解Autorelease机制。
在没有手动加Autorelease Pool的情况下，Autorelease对象是在当前的runloop迭代结束时释放的，而它能够释放的原因是系统在每个runloop迭代中都加入了自动释放池Push和Pop

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190129161145.png)

程序运行 -> 开启事件循环 -> 发生触摸事件 -> 创建自动释放池 -> 处理触摸事件 -> 事件对象加入自动释放池 -> 一次事件循环结束, 销毁自动释放池.

## Autoreleasepool 栈

每一个线程(包括主线程)都有一个NSAutoreleasePool栈. 当一个新的池子被创建的时候, push进栈. 当池子被释放内存时, pop出栈. 对象调用autorelease方法进入栈顶的池子中. 当线程结束的时候, 它会自动地销毁掉所有跟它有关联的池子.

## AutoreleasePool作用域

也就是说AutoreleasePool创建是在一个RunLoop事件开始之前(push)，AutoreleasePool释放是在一个RunLoop事件即将结束之前(pop)。
AutoreleasePool里的Autorelease对象的加入是在RunLoop事件中，AutoreleasePool里的Autorelease对象的释放是在AutoreleasePool释放时。


出了 @autoreleasepool {} 的作用域时，当前 autoreleasepool 被 drain ，其中的 autoreleased 对象被 release 。


每一个线程的 autoreleasepool 其实就是一个指针的堆栈；
每一个指针代表一个需要 release 的对象或者 POOL_SENTINEL（哨兵对象，代表一个 autoreleasepool 的边界）；
一个 pool token 就是这个 pool 所对应的 POOL_SENTINEL 的内存地址。当这个 pool 被 pop 的时候，所有内存地址在 pool token 之后的对象都会被 release ；
这个堆栈被划分成了一个以 page 为结点的双向链表。pages 会在必要的时候动态地增加或删除；
Thread-local storage（线程局部存储）指向 hot page ，即最新添加的 autoreleased 对象所在的那个 page 。


## AutoreleasePool的结构

双向链表
AutoreleasePool并没有单独的结构，而是由若干个AutoreleasePoolPage以双向链表的形式组合而成的栈结构（分别对应结构中的parent指针和child指针）

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190129160839.png)


## 哨兵对象 POOL_SENTINEL

* POOL_SENTINEL 只是 nil 的别名。
* 在每个自动释放池初始化调用 objc_autoreleasePoolPush 的时候，都会把一个 POOL_SENTINEL push 到自动释放池的栈顶，并且返回这个 POOL_SENTINEL 哨兵对象。

而当方法 objc_autoreleasePoolPop 调用时，就会向自动释放池中的对象发送 release 消息，直到第一个 POOL_SENTINEL：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190129161509.png)

## Autoreleasepool 和 Runloop 的关系

ARC时代，系统自动管理自己的Autoreleasepool，Runloop就是iOS中的消息循环机制，当一个Runloop结束时系统才会一次性清理掉被Autoreleasepool处理过的对象，其实本质上说是在本次Runloop迭代结束时清理掉被本次迭代期间被放到Autoreleasepool中的对象的。至于何时Runloop结束并没有固定的duration。 


## Autoreleasepool 使用

* 写基于命令行的的程序时，就是没有UI框架，如AppKit等Cocoa框架时。
* 写循环，循环里面包含了大量临时创建的对象。（本文的例子）
* 创建了新的线程。（非Cocoa程序创建线程时才需要）
* 长时间在后台运行的任务。
* 不管这个对象是在自动释放池内还是外创建的，只要在自动释放池内写一个[p1 autorelease];p1就会被放到自动释放池中。注意autorelease是一个方法，且只有在自动释放池中使用才有效。

### 减少循环中临时变量的内存占用


可以在某些情况下，大幅度降低程序的内存占用，如下图:
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190129162500.png)

测试的内容：500000次循环，每次循环创建一个NSNumber实例和两个NSString实例。
图：红线表示没有用 @autoreleasepool 时的内存占用。
图：绿线表示用了 @autoreleasepool 优化后的内存占用！
效果是不是很明显！

```objc
//Apple 官方文档的示例代码
NSArray *urls = <# An array of file URLs #>;
for (NSURL *url in urls) {
 
    @autoreleasepool {
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfURL:url
                                         encoding:NSUTF8StringEncoding error:&error];
        /* Process the string, creating and autoreleasing more objects. */
    }
}
```

## Autorelease 方法

方法的调用栈：

```objc
- [NSObject autorelease]
└── id objc_object::rootAutorelease()
    └── id objc_object::rootAutorelease2()
        └── static id AutoreleasePoolPage::autorelease(id obj)
            └── static id AutoreleasePoolPage::autoreleaseFast(id obj)
                ├── id *add(id obj)
                ├── static id *autoreleaseFullPage(id obj, AutoreleasePoolPage *page)
                │   ├── AutoreleasePoolPage(AutoreleasePoolPage *newParent)
                │   └── id *add(id obj)
                └── static id *autoreleaseNoPage(id obj)
                    ├── AutoreleasePoolPage(AutoreleasePoolPage *newParent)
                    └── id *add(id obj)
```


## 参考

1. [AutoreleasePool底层实现原理 - 掘金](https://juejin.im/post/5b052282f265da0b7156a2aa#heading-1)
2. [Objective-C Autorelease Pool 的实现原理 - 雷纯锋的技术博客](http://blog.leichunfeng.com/blog/2015/05/31/objective-c-autorelease-pool-implementation-principle/)
3. [iOS基础 - autorelease 和 autoreleasepool - 简书](https://www.jianshu.com/p/97dd0ae27108)
4. [自动释放池的前世今生 ---- 深入解析 autoreleasepool](https://draveness.me/autoreleasepool)
