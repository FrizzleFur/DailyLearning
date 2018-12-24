
# ReactiveCocoa

> 对于一个应用来说，绝大部分的时间都是在等待某些事件的发生或响应某些状态的变化，比如用户的触摸事件、应用进入后台、网络请求成功刷新界面等等，而维护这些状态的变化，常常会使代码变得非常复杂，难以扩展。而 ReactiveCocoa 给出了一种非常好的解决方案，它使用信号来代表这些异步事件，提供了一种统一的方式来处理所有异步的行为，包括代理方法、block 回调、target-action 机制、通知、KVO 等：
> 然而，这些还只是 ReactiveCocoa 的冰山一角，它真正强大的地方在于我们可以对这些不同的信号进行任意地组合和链式操作，从最原始的输入 input 开始直至得到最终的输出 output 为止：



```objc
// 代理方法
[[self
    rac_signalForSelector:@selector(webViewDidStartLoad:)
    fromProtocol:@protocol(UIWebViewDelegate)]
    subscribeNext:^(id x) {
        // 实现 webViewDidStartLoad: 代理方法
    }];

// target-action
[[self.avatarButton
    rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(UIButton *avatarButton) {
        // avatarButton 被点击了
    }];

// 通知
[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kReachabilityChangedNotification object:nil]
    subscribeNext:^(NSNotification *notification) {
        // 收到 kReachabilityChangedNotification 通知
    }];

// KVO
[RACObserve(self, username) subscribeNext:^(NSString *username) {
    // 用户名发生了变化
}];

```

* [April 2014 Tech Talk: Reactive Cocoa - YouTube](https://www.youtube.com/embed/fWV7xyN5CR8?rel=0)
* [ReactiveCocoa 中 RACSignal 是如何发送信号的](https://halfrost.com/reactivecocoa_racsignal/)
* [iOS ReactiveCocoa 最全常用API整理（可做为手册查询） - 掘金](https://juejin.im/post/578f49fa5bbb50005b95fb80)


## 总结可以用图来表示

![](https://i.loli.net/2018/12/22/5c1de0224cd79.jpg)



* 信号源：RACStream 及其子类；
* 订阅者：RACSubscriber 的实现类及其子类；
* 调度器：RACScheduler 及其子类；
* 清洁工：RACDisposable 及其子类。

![](https://i.loli.net/2018/12/22/5c1e0e05d4e87.png)

[ReactiveCocoa v2.5 源码解析之架构总览 - 雷纯锋的技术博客](http://blog.leichunfeng.com/blog/2015/12/25/reactivecocoa-v2-dot-5-yuan-ma-jie-xi-zhi-jia-gou-zong-lan/)

#### 一. 什么是ReactiveCocoa？

[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)（其简称为RAC）是由[Github](https://github.com/blog/1107-reactivecocoa-for-a-better-world) 开源的一个应用于iOS和OS X开发的新框架。RAC具有函数式编程(FP)和响应式编程(RP)的特性。它主要吸取了.Net的 [Reactive Extensions](http://msdn.microsoft.com/en-us/data/gg577609)的设计和实现。

ReactiveCocoa 的宗旨是Streams of values over time ，随着时间变化而不断流动的数据流。

ReactiveCocoa 主要解决了以下这些问题：

*   UI数据绑定

UI控件通常需要绑定一个事件，RAC可以很方便的绑定任何数据流到控件上。

*   用户交互事件绑定

RAC为可交互的UI控件提供了一系列能发送Signal信号的方法。这些数据流会在用户交互中相互传递。

*   解决状态以及状态之间依赖过多的问题

有了RAC的绑定之后，可以不用在关心各种复杂的状态，isSelect，isFinish……也解决了这些状态在后期很难维护的问题。

*   消息传递机制的大统一

## ReactiveCocoa 源码解析

>对于一个应用来说，绝大部分的时间都是在等待某些事件的发生或响应某些状态的变化，比如用户的触摸事件、应用进入后台、网络请求成功刷新界面等等，而维护这些状态的变化，常常会使代码变得非常复杂，难以扩展。而 `ReactiveCocoa` 给出了一种非常好的解决方案，它使用信号来代表这些异步事件，提供了一种统一的方式来处理所有异步的行为，包括代理方法、`block` 回调、`target-action` 机制、通知、`KVO` 等：

![](http://oc98nass3.bkt.clouddn.com/15172043043569.png)


### 代码

```objc
// 代理方法
[[self
    rac_signalForSelector:@selector(webViewDidStartLoad:)
    fromProtocol:@protocol(UIWebViewDelegate)]
    subscribeNext:^(id x) {
        // 实现 webViewDidStartLoad: 代理方法
    }];

// target-action
[[self.avatarButton
    rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(UIButton *avatarButton) {
        // avatarButton 被点击了
    }];

// 通知
[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kReachabilityChangedNotification object:nil]
    subscribeNext:^(NSNotification *notification) {
        // 收到 kReachabilityChangedNotification 通知
    }];

// KVO
[RACObserve(self, username) subscribeNext:^(NSString *username) {
    // 用户名发生了变化
}];
```


##  RACSignal

> RACSignal 代表的是未来将会被传送的值，它是一种 push-driven 的流。RACSignal 可以向订阅者发送三种不同类型的事件：

* next ：RACSignal 通过 next 事件向订阅者传送新的值，并且这个值可以为 nil ；
* error ：RACSignal 通过 error 事件向订阅者表明信号在正常结束前发生了错误；
* completed ：RACSignal 通过 completed 事件向订阅者表明信号已经正常结束，不会再有后续的值传送给订阅者。

* ReactiveCocoa allows you to perform operations on
* signals

* map, filter, skip, take, throttle...

* Operations return RACSignal, allowing method chaining

![](https://i.loli.net/2018/12/22/5c1df9e8aed17.jpg)


![](https://i.loli.net/2018/12/22/5c1e02111f968.jpg)

![](https://i.loli.net/2018/12/22/5c1e063be039c.jpg)


### RACSubject

> RACSubject 代表的是可以手动控制的信号，我们可以把它看作是 RACSignal 的可变版本，就好比 NSMutableArray 是 NSArray 的可变版本一样。RACSubject 继承自 RACSignal ，所以它可以作为信号源被订阅者订阅，同时，它又实现了 RACSubscriber 协议，所以它也可以作为订阅者订阅其他信号源，这个就是 RACSubject 为什么可以手动控制的原因：

![](https://i.loli.net/2018/12/22/5c1e119f0720d.jpg)


根据官方的 Design Guidelines 中的说法，我们应该尽可能少地使用它。因为它太过灵活，我们可以在任何时候任何地方操作它，所以一旦过度使用，就会使代码变得非常复杂，难以理解。

### RACSequence

RACSequence 代表的是一个不可变的值的序列，与 RACSignal 不同，它是 pull-driven 类型的流。从严格意义上讲，RACSequence 并不能算作是信号源，因为它并不能像 RACSignal 那样，可以被订阅者订阅，但是它与 RACSignal 之间可以非常方便地进行转换。

从理论上说，一个 RACSequence 由两部分组成：

head ：指的是序列中的第一个对象，如果序列为空，则为 nil ；
tail ：指的是序列中除第一个对象外的其它所有对象，同样的，如果序列为空，则为 nil 。



##  RACStream


> `RACStream` 信号源,是 `ReactiveCocoa` 中最核心的类，代表的是任意的值流，它是整个 `ReactiveCocoa` 得以建立的基石，下面是它的继承结构图：

![](http://oc98nass3.bkt.clouddn.com/15172045550450.png)

> 你可以把它想象成水龙头中的水，当你打开水龙头时，水源源不断地流出来；你也可以把它想象成电，当你插上插头时，电静静地充到你的手机上；你还可以把它想象成运送玻璃珠的管道，当你打开阀门时，珠子一个接一个地到达。这里的水、电、玻璃珠就是我们所需要的值，而打开水龙头、插上插头、打开阀门就是订阅它们的过程。

![](https://i.loli.net/2018/12/22/5c1e104d85f5d.png)



## 使用场景

我大概总结了几个适用的场景。RAC 总结来说就是：数据随着时间而产生，所以能想到的三点比较适合用 RAC：

一、UI 操作，连续的动作与动画部分，例如某些控件跟随滚动。

二、网络库，因为数据是在一定时间后才返回回来，不是立刻就返回的。

三、刷新的业务逻辑，当触发点是多种的时候，业务往往会变得很复杂，用 delegate、notification、observe 混用，难以统一。这时用 RAC 可以保证上层的高度一致性，从而简化逻辑上分层。

雷纯锋说他们的使用还是比较多：

基本上异步的事件能用 RAC 的都用的 RAC。

不过代理方法用 RAC 的比较少，比如 UITableView 的代理方法一般都是直接写了。

用 RACSubject + RACComand 来简化和统一应用的错误处理逻辑，这个算比较经典的吧。

臧成威说：UI 交互上的点确实好多，比如下拉刷新、上拉导航条变透明。

实时响应用户的输入，控制按钮的可用性，这点用 RAC 来实现非常简单。


[ReactiveCocoa 讨论会 | 唐巧的博客](https://blog.devtang.com/2016/01/03/reactive-cocoa-discussion/)

### 调试 RAC 

的确很痛苦，跟断点有的时候计算堆栈都要等几分钟。

关于调试，RAC 源码下有 instruments 的两个插件，方便大家使用。
![](https://i.loli.net/2018/12/22/5c1e145311a2d.jpg)


## 总结


至此，我们介绍完了 `ReactiveCocoa` 的四大核心组件，对它的架构有了宏观上的认识。它建立于 Monad 的概念之上，然后围绕其搭建了一系列完整的配套组件，它们共同支撑了 `ReactiveCocoa` 的强大功能。尽管，`ReactiveCocoa` 是一个重型的函数式响应式框架，但是它并不会对我们现有的代码构成侵略性，我们完全可以在一个单独的类中使用它，哪怕只是简单的一行代码，也是没有问题的。所以，如果你对 ReactiveCocoa 感兴趣的话，不妨就从现在开始尝试吧，Let’s go ！


## 参考

1. [标签归档 | ReactiveCocoa - 美团点评技术团队](https://tech.meituan.com/tag/ReactiveCocoa)
