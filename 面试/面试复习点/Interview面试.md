# Interview面试

## `2017-12-27 年底面试`

### 必问的点：

1.   内存管理：ARC，循环引用，内存泄漏，野指针
2.  Block内存管理

### 进阶可能问的点

3. App性能优化
4. `UITableView`优化

#### 项目

5. 你做的比较值得满意的项目是什么？
6. 你项目目前遇到的比较难的问题，你是如何解决的?
7. 说下你最复杂项目的技术内容
8. 你平时是怎么做技术积累的

====================================================

## `2017-12-23  初步整理`

====================================================

## 面试题总结

### 阿里

#### 内存管理

* 阐述`@property`的属性特性有哪些，默认情况下属性的特性是哪些，以及这些特性的作用：
* 阐述`readwrite`、 `readonly`的作用
* 阐述`assign`的作用，当使用`assign`修饰`Objective-C`对象时，会怎么样？为什么`assIgn`用于基础类型时，不会发生基础类型丢失？
* 阐述引用循环发生的原因？由weak引起的引用循环，发生循环时一定会泄露吗？
* 阐述`copy`和` mutableCopy`的作用，以及深拷贝和浅拷贝的机制？

#### Block
* `Block`内存管理（白板上写出代码，画出堆栈内存示意图）
* 如何避免`Block`的循环引用？说说除了使用`__weak`还有什么方法吗？`__strong`什么时候使用？

####  Runloop & Runtime

* 什么是`Runloop`？,  `Runloop`和线程的关系
* `Runtime`有哪些应用？比如 `method swizzling`？介绍一下消息传递机制？

#### 优化和架构设计

*  如何优化一个`UITableView`？ （* 高度缓存；* 布局渲染优化， *图片缓存 *cell的缓存，滚动停止时取出Cell,  *减少Cell上的UI图层）
* 介绍下`MVVM`，`ViewModel`的作用？
* `APP`内组件间通信方式有哪些?
* 有用过组件化吗?如何实现?


#### 其他

* 熟悉`Web`和原生的JS交互吗？详细介绍下
* 混合开发`Hybird`的使用，是否会使用`Weex`或者`ReactNative`？


### 网易

#### 内存管理

* 内存管理, `MRC`和`ARC`，`@property`的本质
* `AutoReleasePool`的实现机制
* `Copy`的用法，深拷贝和浅拷贝
* `Block`有几种？如何管理内存的？
* 内存泄漏有几种方式？1.循环引用，2.定时器`NSTimer`的管理 3. 野指针？

*简单概括就是从  `property`的属性特性，引申出内存管理、对象模型、 `runloop`等知识，很杂很多，面试官从你对 property的属性特性的解释抓住重点，进而引申出对于内存管理的各种问题。3、 category和 extension的区别，比如 `category`.不能添加 property，怎么解决，用对象绑定等*

#### Runtime &  Runloop

* `Runloop`, 详细介绍下`Runloop`，`Runloop`有什么作用？
* `Runtime`： `Runtime`的对象管理的底层原理
* `Runtime`, 介绍`Runtime`，`Runtime`下的ARC是怎么管理的？
* 在支付流程中，如果用户切换到微信，复制口令，回到原来App继续支付，如何不被弹出的口令打断？（我这边是说使用通知去做，显然不好）

#### 设计模式优化
* App优化策略有哪些？你是如何实现的？
* 简述`Delegate`、`NSNotification`、`Block`、`KVO`之间的模式和优缺点，如何选择
* 什么是`KVO`？它的实现原理？
* 多线程有哪些？你是怎么用的?

#### 网络
* `Http`协议是怎么样的？
* 熟悉网络`Socket`吗?
* **请论述一个数据包从客户端到服务端的整个传输过程**
* `Http`和`Https`的区别

### 其他
    
* `SDWebImage`的原理，图片内存过大时候，如何管理内存的图片?
* 说说`Copy`的用法，深拷贝和浅拷贝
*  类`Category`和 `Extension`的区别
* `NSArray`和`NSSet`的使用和区别,性能效率？
* 你用过的文件存储方式有哪些？
* Feed流，`UITableView`显示图片如何优化显示和存储？
* `MVVM`和`MVC`的优缺点
* 多线程并发，有多个任务，如何让任务2在任务1完成后开始执行？

====================================================

### 重点问题

#### 网络

* `Http`协议是怎么样的？
* 熟悉网络`Socket`吗?
* **请论述一个数据包从客户端到服务端的整个传输过程**

#### 内存管理

* 内存管理, `MRC`和`ARC`，`@property`的本质
* `Copy`的用法，深拷贝和浅拷贝
* `Block`内存管理
* 内存泄露的场景
* 文件存储方式

#### 项目

* 详细谈谈你对做项目过程中你完成的最值得骄傲的地方（或者你克服的难题）

#### 设计模式

* `MVVM`和`MVC`的优缺点
* 简述`Delegate`、`NSNotification`、`Block`、`KVO`之间的模式和优缺点，如何选择

#### 知名框架

* `SDWebImage`的原理，图片内存过大时候，如何管理内存的图片?

#### 混合开发

* 混合开发`Hybird`的应用，是否会使用`Weex`或者`ReactNative`？


-------


## 2018-06-28


1. 杭州相芯科技有限公司

一面主要问题：

1. 自我介绍


2. 内存管理： 

* block的介绍
* 给`nil`对象发送消息会崩溃吗？


3. 多线程

* 常见多线程在项目中的应用？
* 多线程的死锁
* 控制并发线程的数量： 多线程的信号量`dispatch_semaphore`
* 线程的异步
* 任务进行分块： `dispatch_group_notify`.
iOS使用dispatch_group实现分组并发网络请求

#### 任务进行分块
```objc
dispatch_group_enter(group)和dispatch_group_leave(group)，这种方式使用更为灵活，enter和leave必须配合使用，有几次enter就要有几次leave

dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求1
        [网络请求:{
        成功：dispatch_group_leave(group);
        失败：dispatch_group_leave(group);
}];
    });
    dispatch_group_enter;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求2
        [网络请求:{
        成功：dispatch_group_leave;
        失败：dispatch_group_leave;
}];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求3
        [网络请求:{
        成功：dispatch_group_leave(group);
        失败：dispatch_group_leave(group);
}];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //界面刷新
        NSLog(@"任务均完成，刷新界面");
    });
dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

```

参考[iOS使用dispatch_group实现分组并发网络请求 - 简书](https://www.jianshu.com/p/657e994aeee2)

####  控制并发线程的数量： 多线程的信号量

`dispatch_semaphore`

##### 等待

```
// 返回0：表示正常。返回非0：表示等待时间超时
long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout);

```

##### 信号通知

```
long dispatch_semaphore_signal(dispatch_semaphore_t dsema);

```

##### 创建信号量

```
// 值得注意的是，这里的传入的参数value必须大于或等于0，否则dispatch_semaphore_create会返回NULL
dispatch_semaphore_t dispatch_semaphore_create(long value);

```

> *   当一个信号量被通知`dispatch_semaphore_signal`，计数会加1；
> *   如果一个线程等待一个信号量`dispatch_semaphore_wait`，线程会被阻塞，直到计数器>0，此时开始运行，并且对信号量减1。

这样我们就可以根据 初始值 ，来控制可以有多少个并发的线程在运行。关于信号量，可以用停车位来比喻，如果停车场有5个停车位，都停满了，如果此时来了第6辆车，就需要等待，信号量的值就相当于`剩余的车位的数量`。dispatch_semaphore_wait函数就相当于来了一辆车，dispatch_semaphore_signal就相当于走了一辆车。

dispatch_semaphore_wait中的参数timeout表示超时时间，如果等待期间没有获取到信号量或者信号量的值一直为0，那么等到timeout时，其所处线程自动执行其后语句。可取值为：`DISPATCH_TIME_NOW`和 `DISPATCH_TIME_FOREVER`，我们也可以自己设置一个dispatch_time_t的时间值，表示超时时间为这个时间之后。

> *   **DISPATCH_TIME_NOW**：超时时间为0，表示忽略信号量，直接运行
> *   ** DISPATCH_TIME_FOREVER**：超时时间为永远，表示会一直等待信号量为正数，才会继续运行



来看一个具体的例子：

![](http://oc98nass3.bkt.clouddn.com/15301534187605.jpg)
信号量的初始值设置为：1，即最多只能又一个线程在run，可以验证一下运行结果，除去最开始的三个，后面的是每三秒打印一个，并且保证运行的顺序按照添加的顺序。

![](http://oc98nass3.bkt.clouddn.com/15301534397789.jpg)

如果把创建信号量的值设置为4，即最多可以有4个线程同时运行，来看一下运行结果，是每三秒同时打印四个，且顺序不能保证。
![](http://oc98nass3.bkt.clouddn.com/15301535632720.jpg)


参考[dispatch_semaphore控制并发线程数 - 简书](https://www.jianshu.com/p/a5e75df26d9c)


4. 内存管理: weak和assign的区别？对于对象的修饰
weak可以修饰对象，assign是生成与栈上的，如果用于修饰对象就可能被编译器回收从而造成内存泄漏。

5. 性能优化

* 缓存
* 架构

6. 传值模式的介绍： 代理、通知、block
![](http://oc98nass3.bkt.clouddn.com/15301587846244.jpg)

7. `Runtime` & `RunLoop` 介绍
8. 有了解`OpenGL`吗？
9. 有Mac相关开发吗？

## 参考

1. [面试总结 · Issue #1 · FrizzleFur/DailyLearning](https://github.com/FrizzleFur/DailyLearning/issues/1)

### 多线程

2. [iOS开发系列--并行开发其实很容易 - KenshinCui - 博客园](http://www.cnblogs.com/kenshincui/p/3983982.html)