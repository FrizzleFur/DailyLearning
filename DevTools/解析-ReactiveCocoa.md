
# ReactiveCocoa


* [ReactiveCocoa 中 RACSignal 是如何发送信号的](https://halfrost.com/reactivecocoa_racsignal/)
* [iOS ReactiveCocoa 最全常用API整理（可做为手册查询） - 掘金](https://juejin.im/post/578f49fa5bbb50005b95fb80)


## 总结可以用图来表示

![](https://i.loli.net/2018/12/22/5c1de0224cd79.jpg)


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


###  RACStream
`RACStream` 是 `ReactiveCocoa` 中最核心的类，代表的是任意的值流，它是整个 `ReactiveCocoa` 得以建立的基石，下面是它的继承结构图：

![](http://oc98nass3.bkt.clouddn.com/15172045550450.png)


## 总结

至此，我们介绍完了 `ReactiveCocoa` 的四大核心组件，对它的架构有了宏观上的认识。它建立于 Monad 的概念之上，然后围绕其搭建了一系列完整的配套组件，它们共同支撑了 `ReactiveCocoa` 的强大功能。尽管，`ReactiveCocoa` 是一个重型的函数式响应式框架，但是它并不会对我们现有的代码构成侵略性，我们完全可以在一个单独的类中使用它，哪怕只是简单的一行代码，也是没有问题的。所以，如果你对 ReactiveCocoa 感兴趣的话，不妨就从现在开始尝试吧，Let’s go ！

