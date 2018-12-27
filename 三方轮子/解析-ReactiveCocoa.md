
# ReactiveCocoa

> 对于一个应用来说，绝大部分的时间都是在等待某些事件的发生或响应某些状态的变化，比如用户的触摸事件、应用进入后台、网络请求成功刷新界面等等，而维护这些状态的变化，常常会使代码变得非常复杂，难以扩展。而 ReactiveCocoa 给出了一种非常好的解决方案，它使用信号来代表这些异步事件，提供了一种统一的方式来处理所有异步的行为，包括代理方法、block 回调、target-action 机制、通知、KVO 等：
> 然而，这些还只是 ReactiveCocoa 的冰山一角，它真正强大的地方在于我们可以对这些不同的信号进行任意地组合和链式操作，从最原始的输入 input 开始直至得到最终的输出 output 为止：

## ReactiveCocoa解决的问题:

1. 传统iOS开发过程中,**状态以及状态之间依赖过多的问题**
2. 传统MVC架构的问题:Controller比较复杂,可测试性差
3. **提供统一的消息传递机制**

## ReactiveCocoa 的问题

RAC 在应用中大量使用了 block，由于 Objective-C 语言的内存管理是基于引用计数 的，为了避免循环引用问题，在 block 中如果要引用 self，需要使用@weakify(self)和@strongify(self)来避免强引用。另外，在使用时应该注意 block 的嵌套层数，不恰当的滥用多层嵌套 block 可能给程序的可维护性带来灾难。
ee
有些地方很容易被忽略，比如RACObserve(thing, keypath)，看上去并没有引用self，所以在subscribeNext时就忘记了weakify/strongify。但事实上RACObserve总是会引用self，即使target不是self，所以只要有RACObserve的地方都要使用weakify/strongify。

## ReactiveCocoa 的理解

[leezhong博客](http://limboy.me/ios/2013/06/19/frp-reactivecocoa.html)

　 可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的，不会出现并发情况)。水龙头的开关默认是关的，除非有了接收方(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给接收方。可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，也可以加一个改动装置，把球改变成符合自己的需求(map)。也可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球。　



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

## RACSubject的使用场景
 
一般不推荐使用RACSubject，因为它过于灵活，滥用的话容易导致复杂度的增加。但有一些场景用一下还是比较方便的，比如ViewModel的errors。



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


## 白话理解RAC

初学者总是容易被一堆概念搞得晕头转向，我想其实无非是这几种：

```objc
RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            [subscriber sendNext:@(1)];
            [subscriber sendCompleted];
            return nil;
        }];

```

  1、createSignal好难啊；2、subscriber是什么？3、这个block什么时候调用？

```objc
[signal subscribeNext:^(id x) {
        if ([x boolValue]) {
            _navView.hidden = YES;
        } else {
            _navView.hidden = NO;
            [UIView animateWithDuration:.5 animations:^{
                _navView.alpha = 1;
            }];
        }
    }];

```

  4、subscribeNext又是什么？5、这个block什么时候调用？

  6、看起来上面两段代码有关系，但是具体怎么作用的？

让我们先来解决上面的困惑吧！

### 第一部分 订阅者和信号

  1、隐藏的订阅者

  平时我们打交道的就是信号，但是总是说订阅，却不知道订阅到底是如何进行的，也无法解答上面的问题，让我们根据源码分析一下订阅过程。

  首先来认识一个对象：订阅者(RACSubscriber)。
订阅者订阅信号，就是这么简单的一件事情。只不过框架隐藏了这个对象，我们也不必要和订阅者打交道，只需要告诉信号一件事情，那就是如果发送了数据（三种事件：next、complete、error），我们需要做什么事情（类似回调的概念）。

  第一步是创建信号，看一下上面的第一段代码，createSignal类方法：
这里要说一下，信号RACSignal有一些子类，我们常用的是RACDynamicSignal和RACSubject，先不理会RACSubject。createSignal类方法创建的就是RACDynamicSignal对象。

```objc
-----RACDynamicSignal.h-----
@property (nonatomic, copy, readonly) RACDisposable * (^didSubscribe)(id<RACSubscriber> subscriber);

-----RACSignal.m-----
+ (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe {
    return [RACDynamicSignal createSignal:didSubscribe];
}

-----RACDynamicSignal.m-----
+ (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe {
    RACDynamicSignal *signal = [[self alloc] init];
    signal->_didSubscribe = [didSubscribe copy];
    return [signal setNameWithFormat:@"+createSignal:"];
}

```

  我们可以发现，RACDynamicSignal有一个属性，名字叫didSubscribe的block对象。createSignal方法传递的block参数，就是赋值给didSubscribe属性。
  **对于问题1，我们可以暂时这么回答，createSignal的意义是，创建一个signal对象，并且把参数赋值给signal的名为didSubscribe的属性，这个block的参数是subscriber，返回RACDisposable。**

  第二步是订阅信号，看一下第二段代码subscribeNext：

```objc
-----RACSubscriber.m-----
@property (nonatomic, copy) void (^next)(id value);

-----RACSignal.m-----
- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock {
    NSCParameterAssert(nextBlock != NULL);

    RACSubscriber *o = [RACSubscriber subscriberWithNext:nextBlock error:NULL completed:NULL];
    return [self subscribe:o];
}

-----RACDynamicSignal.m-----

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
    NSCParameterAssert(subscriber != nil);

    RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
    subscriber = [[RACPassthroughSubscriber alloc] initWithSubscriber:subscriber signal:self disposable:disposable];

    if (self.didSubscribe != NULL) {
        RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
            RACDisposable *innerDisposable = self.didSubscribe(subscriber);
            [disposable addDisposable:innerDisposable];
        }];

        [disposable addDisposable:schedulingDisposable];
    }

    return disposable;
}

```

  我们可以看到，subscribeNext方法第一步是创建了一个RACSubscriber，也就是创建了一个订阅者，而且把subscribeNext的参数传递给RACSubscriber对象，RACSubscriber会把参数赋值给自己一个名为next的Block类型的属性，**这里，我们可以回答上面第4个问题，subscribeNext方法创建一个订阅者，并且把block参数，传递给订阅者一个名字叫next的属性，block参数接收的是id类型，返回的是RACDisposable对象。**接下来执行［self subscribe：o］，也就是订阅操作。我们在看看订阅方法subscribe的实现：上面的代码很清晰，直接是self.didSubscribe(subscriber),我们可以知道，刚刚创建的subscriber对象，直接传递给上文中我们提到的signal的didSubscribe属性。**这样，我们可以解释上面的第二个和第三个问题，subscriber就是didSubscribe的形参，block对象是在subscribeNext的时候执行的，刚刚的订阅者对象作为参数传入，就是subscriber对象。**

  那么createSignal方法中，[subscriber sendNext:@(1)]是什么意思呢？
  看一下sendNext方法吧：

```objc
- (void)sendNext:(id)value {
    @synchronized (self) {
        void (^nextBlock)(id) = [self.next copy];
        if (nextBlock == nil) return;

        nextBlock(value);
    }
}

```

  我们可以发现，sendNext的实现，也就是直接执行上文中的nextBlock。**也就是回答了上面第五个问题。**

  总结一下，signal持有didSubscribe参数（createSignal传进来的那个block），subscriber持有nextBlock（就是subscribeNext传进来的那个block），当执行［signal subscribe：subscriber］的时候，signal的didSubscribe执行，内部有subscriber sendNext的调用，触发了subscriber的nextBlock的调用。到这里，我们基本把信号和订阅者，以及订阅过程分析完毕。

### 第二部分 信号和事件

  刚才我们说过，signal有几个子类，每一个类型的signal订阅过程其实大同小异，而且初期常见的也就是RACDynamicSignal，其实我们不需要太关心这个问题，因为无论是自定义信号，还是框架定义的一些category，例如，textFiled的rac_textSignal属性，大多数都是RACDynamicSignal。另一个常见的类型RACSubject可以以后理解。

  还有就是，我们刚刚谈到了三种事件，分别是next、error、complete，和分析next的订阅过程一样，举个例子，我们发送网络请求，希望在出错的时候，能给用户提示，那么首先，创建信号的时候，在网络请求失败的回调中，我们要[subscriber sendError:netError],也就是发送错误事件。然后在订阅错误事件，也就是subscriberError:...这样就完成了错误信号的订阅。

  complete事件比较特殊，它有终止订阅关系的意味，我们先大致了解一下RACDispoable对象吧，我们知道，订阅关系需要有终止的时候，比如，在tableViewCell的复用的时候，cell会订阅model类产生一个信号，但是当cell被复用的时候，如果不把之前的订阅关系取消掉，就会出现同时订阅了2个model的情况。我们可以发现，subscribeNext、subscribeError、subscribeComplete事件返回的都是RACDisopable对象，当我们希望终止订阅的时候，调用［RACDisposable dispose］就可以了。complete也是这个原理。

### 第三部分 进一步的深入

  RAC是一个非常庞大的框架，平时的一些教程会误导大家纠结flattenMap和map的区别，这些问题，让人找不到头绪，导致入门更加的困难。实际上，学习它需要一个循循渐进的过程，RAC有很多作用，解耦合，更高效的解决一类问题等等，总之，他是对常规的面向对象编程很好的补充。所以，在理解完订阅的过程之后，重要的是，投入实际的运用中，我观察了不少开源的项目，并结合自己的实践发现，其实flattenMap这样的操作，非常少，几乎没有，常用的无非就是以下几个：手动构建信号（createSignal）、订阅信号（subscribeNext）、使用框架的一些宏定义（RACObserve、RAC）、然后就是学习几个最简单的操作，例如map、merge等就可以开始了。如果希望深入研究，一定要把这些基础的东西吃透，然后在学习更多的操作，例如flattenMap，了解side effect和多播的概念，学会RACSubject的用法（这个也是非常重要的对象）等等。如果把这些操作比作武器的话，可能更重要的是内功，也就是理解他的思想，我们如何通过实战，知道恰当的利用他的强大，慢慢的熟悉和深入是水到渠成的事情。


## 总结


至此，我们介绍完了 `ReactiveCocoa` 的四大核心组件，对它的架构有了宏观上的认识。它建立于 Monad 的概念之上，然后围绕其搭建了一系列完整的配套组件，它们共同支撑了 `ReactiveCocoa` 的强大功能。尽管，`ReactiveCocoa` 是一个重型的函数式响应式框架，但是它并不会对我们现有的代码构成侵略性，我们完全可以在一个单独的类中使用它，哪怕只是简单的一行代码，也是没有问题的。所以，如果你对 ReactiveCocoa 感兴趣的话，不妨就从现在开始尝试吧，Let’s go ！


### 信号总结

* 首先在创建信号的时候，带进去一个已经订阅的Block（didSubscribe），把它保存在信号中，并没有执行；
* 在订阅信号的时候，带进去一个发送信号的Block（nextBlock），然后创建一个订阅者（RACSubscriber对象），订阅者会把nextBlock进行保存，
* 接着执行之前信号保存的didSubscribe这个Block，并将订阅者传递过去；
* 然后在didSubscribe回调里面，由订阅者发送信号，也就是执行之前保存的nextBlock；
最后在nextBlock（订阅回调）里面监听到发送的内容。

[iOS RAC学习之路（一） - 简书](https://www.jianshu.com/p/3331588c16ca)

RACSignal的2个方法

* 1. 创建信号: createSignal, 创建一个signal对象
    * 并且把createSignal方法的`didSubscribe`Block赋值给所创建的signal的`didSubscribe`属性，这个`didSubscribe`的入参是subscriber，返回RACDisposable。
    * RACSignal使用`didSubscribe`属性，封装了订阅者对这个信号的处理
    * RACSignal的类方法
* 2. 订阅信号: subscribeNext, 创建了一个RACSubscriber订阅者
    * 订阅者会把nextBlock赋值给自己的next的属性，
    * 然后，执行订阅操作［self subscribe：o］
    * didSubscribe是信号的invoke每个订阅者的Block属性, 订阅方法subscribe的实现：上面的代码很清晰，直接是self.didSubscribe(subscriber),
    * 我们可以知道，刚刚创建的subscriber对象，直接传递给上文中我们提到的signal的didSubscribe属性。这样，我们可以解释上面的第二个和第三个问题，subscriber就是didSubscribe的形参，block对象是在subscribeNext的时候执行的，刚刚的订阅者对象作为参数传入，就是subscriber对象。
    * RACSignal的实例方法


## RAC的作用

而RAC为MVVM带来很大的便利，比如RACCommand, UIKit的RAC Extension等等。**使用MVVM不一定能减少代码量，但能降低代码的复杂度。**
**


## 参考

1. [标签归档 | ReactiveCocoa - 美团点评技术团队](https://tech.meituan.com/tag/ReactiveCocoa)
2. [『状态』驱动的世界：ReactiveCocoa](https://draveness.me/racsignal)
3. [RAC基础学习一:信号和订阅者模式 - 简书](https://www.jianshu.com/p/4fee21fb05b3)

