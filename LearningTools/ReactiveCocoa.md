
# ReactiveCocoa

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

