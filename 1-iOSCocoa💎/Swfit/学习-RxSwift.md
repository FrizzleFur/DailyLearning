# 学习-RxSwift

[RxSwift/Documentation at master · ReactiveX/RxSwift](https://github.com/ReactiveX/RxSwift/tree/master/Documentation)

## 写代码熟悉RxSwift

一些好用的用法：
1. bind(to:), 使用bind(to:),可以将一些不同的RxCocoa的信号关联起来，如一个UILabel监听UITextField的文本输入，可以将UITextField的信号绑定在UILabel上，直接更新UILabel


## RxSwift 的作用

（1）在编写代码时我们经常会需要检测某些值的变化（比如：textFiled 输入值的变化、数据请求完成或失败的变化），然后进行相应的处理。
过去针对不同的情况，我们需要采用不同的事件传递方法去处理，比如：delegate、notification、target-action、KVO 等等。
而 RectiveX 机制（由 RxSwift 实现）的出现，让程序里的事件传递响应方法做到统一。将之前那些常用的事件传递方法（比如：delegate、notification、target-action 等等），全部替换成 Rx 的“信号链”方式。

（2）如果我们平时使用的是 MVVM 开发模式的话，通过 RxSwift 可以获得更加方便的数据绑定的方法，使得 MVVM 开发更加如虎添翼。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190406205443.png)


1）首先我们定义一个Observable，在某些情况下我们会在闭包内提供一些代码，该部分代码会执行相应的工作并且发送值（elements）给任意的观察者（observer）。当我们使用create操作符创建了该Observable，闭包内的代码就被存储起来用于后续的执行，而不是马上执行。如果当前没有观察者（observer），那么Observable仅仅是等待被订阅，不会执行任何操作。

2）当我们使用不同的操作符（operators）来处理被发送的值（elements），比如像：map,filter等等，这时候闭包仍然没有执行任何操作，我们这里仅仅是对Observable进行了部分的转换和过滤，相当于创建了一个更特别的Observable，而不是最初的Observable。

3）一直到我们调用subscribe(...)方法，这时候Observable开始工作起来。调用subscribe(...)方法将执行我们之前在闭包中所编写的代码。



对于上面的内容，有俩点需要明白：

1）订阅部分的代码（subscription code），该部分内容是位于上图的Observable.create{...}中的代码，在我们调用subscribe()之后会执行代码并产生值（elements）

2）观察部分的代码（observation code），是我们观察到被发送值（elements）的地方,这部分代码，我们经常使用，如：onNext: {...}, onCompleted: {...}等，这些地方就是我们进行观察中的地方。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190406205742.png)

## RxSwift 与 RxCocoa

* RxSwift：它只是基于 Swift 语言的 Rx 标准实现接口库，所以 RxSwift 里不包含任何 Cocoa 或者 UI 方面的类。
* RxCocoa：是基于 RxSwift 针对于 iOS 开发的一个库，它通过 Extension 的方法给原生的比如 UI 控件添加了 Rx 的特性，使得我们更容易订阅和响应这些控件的事件。


## ViewModel的Rx

* 这里我们将 data 属性变成一个可观察序列对象（Observable Squence），而对象当中的内容和我们之前在数组当中所包含的内容是完全一样的。
* 关于可观察序列对象在后面的文章中我会详细介绍。简单说就是“序列”可以对这些数值进行“订阅（Subscribe）”，有点类似于“通知（NotificationCenter）”
* 回顾一下我之前说的，Observable实质上就是一条数据流，所有的创建方法所传入的参数都是这条数据流上的元素。


[Swift - RxSwift的使用详解2（响应式编程与传统式编程的比较样例）](http://www.hangge.com/blog/cache/detail_1918.html)


## Observable

* Observable<T> 这个类就是 Rx 框架的基础，我们可以称它为可观察序列。它的作用就是可以异步地产生一系列的 Event（事件），即一个 Observable<T> 对象会随着时间推移不定期地发出 event(element : T) 这样一个东西。
* 而且这些 Event 还可以携带数据，它的泛型 <T> 就是用来指定这个 Event 携带的数据的类型。
* 有了可观察序列，我们还需要有一个 Observer（订阅者）来订阅它，这样这个订阅者才能收到 Observable<T> 不时发出的 Event。


任何 'Observable' 序列都可以被转换为'Driver', 只要他满足一下三点：

1.不能出错   2.观察主线程  3.共享资源

如何确保这些属性都满足呢？只需要使用 'asDriver(onErrorJustReturn: [])' ,相当于如下代码:


```swift

let safeSequence = xs

  .observeOn(MainScheduler.instance) // 切换到主线程

  .catchErrorJustReturn(onErrorJustReturn) // 不能出错

  .shareReplayLatestWhileConnected         // 共享资源

return Driver(raw: safeSequence)           // 返回

```



### Event

查看 RxSwift 源码可以发现，事件 Event 的定义如下：

```swift
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)
 
    /// Sequence terminated with an error.
    case error(Swift.Error)
 
    /// Sequence completed successfully.
    case completed
}
```

可以看到 Event 就是一个枚举，也就是说一个 Observable 是可以发出 3 种不同类型的 Event 事件：

* next：next 事件就是那个可以携带数据 <T> 的事件，可以说它就是一个“最正常”的事件。

* error：error 事件表示一个错误，它可以携带具体的错误内容，一旦 Observable 发出了 error event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。

* completed：completed 事件表示 Observable 发出的事件正常地结束了，跟 error 一样，一旦 Observable 发出了 completed event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。



## Sequence



### Observable 与 Sequence比较

（1）为更好地理解，我们可以把每一个 Observable 的实例想象成于一个 Swift 中的 Sequence：
即一个 Observable（ObservableType）相当于一个序列 Sequence（SequenceType）。
ObservableType.subscribe(_:) 方法其实就相当于 SequenceType.generate()

（2）但它们之间还是有许多区别的：
Swift 中的 SequenceType 是同步的循环，而 Observable 是异步的。
Observable 对象会在有任何 Event 时候，自动将 Event 作为一个参数通过 ObservableType.subscribe(_:) 发出，并不需要使用 next 方法。


## Subject

[RxSwift的学习之路（二）——Subjects - 简书](https://www.jianshu.com/p/6ce9cae4f410)

因为不知道怎么用中文称呼subject相关的类，但是它的功能有点像一个针对于Observable数据流的观察者，所以我就称它为观察者吧！

### PublishSubject——一个只会收发新元素的观察者


顾名思义，PublishSubject就像个出版社，到处收集内容，此时它是一个Observer，然后发布给它的订阅者，此时，它是一个Observable。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190627113132.png)

[RxSwift-四种Subject的基本用法 - 简书](https://www.jianshu.com/p/02795ee5b222)

### BehaviorSubject——一个会向每次订阅发出最近接收到的一个元素的观察者

如果你希望Subject从“会员制”变成“试用制”，就需要使用BehaviorSubject。它和PublisherSubject唯一的区别，就是只要有人订阅，它就会向订阅者发送最新的一次事件作为“试用”。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190627113246.png)

### ReplaySubject

ReplaySubject和前两个subjects不太一样，它有一个缓冲区来装载最近接收的元素。在它接收到completed或者error事件的时候，他会向既订阅者发送该事件；对于新的订阅，它将先发出缓冲区的元素，接着再将导致数据流终结的对象也发送出去。它也有和前两个subjects一样的地方，那就是它被终结后，不会再接收新的元素。

* PublishSubject：**总是发出最新的信息**，你可以在你仅仅需要用到新数据的地方使用它，并且在你订阅的时候，如果没有新的信息，它将不会回调，在利用它来和界面绑定的时候，你得有一个默认的字段放在你界面上，以免界面上什么都没有。
* BehaviorSubject：**除了发出新的信息，还会首先发出最近接收到的最后一个元素**。这里我们可以以微信（没有收广告费的）举个例子，譬如微信首页的tableview的cell里会显示最近的一条信息，而在这你就可以通过BehaviorSubject来订阅，从而用这条最近的信息作展示，而不需要等到新的信息到来，才做展示。
* ReplaySubject：可是如果你现在订阅，却要获取最近的一批数据——譬如朋友圈，那该怎么办？显然只能依赖于ReplaySubject了吧？

1，Subjects 基本介绍
（1）Subjects 既是订阅者，也是 Observable：
说它是订阅者，是因为它能够动态地接收新的值。
说它又是一个 Observable，是因为当 Subjects 有了新的值之后，就会通过 Event 将新值发出给他的所有订阅者。

（2）一共有四种 Subjects，分别为：PublishSubject、BehaviorSubject、ReplaySubject、Variable。他们之间既有各自的特点，也有相同之处：
首先他们都是 Observable，他们的订阅者都能收到他们发出的新的 Event。
直到 Subject 发出 .complete 或者 .error 的 Event 后，该 Subject 便终结了，同时它也就不会再发出 .next 事件。
对于那些在 Subject 终结后再订阅他的订阅者，也能收到 subject 发出的一条 .complete 或 .error 的 event，告诉这个新的订阅者它已经终结了。
**他们之间最大的区别只是在于：当一个新的订阅者刚订阅它的时候，能不能收到 Subject 以前发出过的旧 Event，如果能的话又能收到多少个。
**

（3）Subject 常用的几个方法：
onNext(:)：是 on(.next(:)) 的简便写法。该方法相当于 subject 接收到一个 .next 事件。
onError(:)：是 on(.error(:)) 的简便写法。该方法相当于 subject 接收到一个 .error 事件。
onCompleted()：是 on(.completed) 的简便写法。该方法相当于 subject 接收到一个 .completed 事件。

### Subscribe

订阅一个Observable实例主要有两个方法，talk is cheap, show you the code.


### BehaviorRelay

* BehaviorRelay 是作为 Variable 的替代者出现的。它的本质其实也是对 BehaviorSubject 的封装，所以它也必须要通过一个默认的初始值进行创建。
* BehaviorRelay 具有 BehaviorSubject 的功能，能够向它的订阅者发出上一个 event 以及之后新创建的 event。
* 与 BehaviorSubject 不同的是，不需要也不能手动给 BehaviorReply 发送 completed 或者 error 事件来结束它（BehaviorRelay 会在销毁时也不会自动发送 .complete© 的 event）。
* BehaviorRelay 有一个 value 属性，我们通过这个属性可以获取最新值。而通过它的 accept() 方法可以对值进行修改。
* BehaviorRelay 将取代 Variable，因为 Variable 很容易会引导我们使用命令式编程，而不是声明式编程。

* 有点啰嗦，所以BehaviorRelay就是可以永久持有一个能量，并且你做任何改动，能量都会被永久变化的东西，用他来做数据源再好不过。
* [很好懂的Swift MVVM in Rx - 简书](https://www.jianshu.com/p/91dc64c9d86e)
* [RxRelay · RxSwift 中文文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/recipes/rxrelay.html)


## dispose和DisposeBag——让订阅者释放


如果你足够细心的话，你会发现每次subscribe方法调用后都会返回一个Disposable对象，代表着每一次订阅都是需要被释放的，遗憾的是，这并不由ARC进行管理，而是由RxSwift来管理。然而，RxSwift也没有提供自动释放的机制，始终是需要你手动释放的。

所以RxSwift提供了一个类似于Auto Release Pool的释放机制，称为DisposeBag。被加到DisposeBag的Disposable对象会在DisposeBag将要释放的时候被逐一调用dispose()。

### dispose() 方法

* 使用dispose()方法我们可以手动取消一个订阅行为。
（2）如果我们觉得这个订阅结束了不再需要了，就可以调用 dispose() 方法把这个订阅给销毁掉，防止内存泄漏。
（2）当一个订阅行为被 dispose 了，那么之后 observable 如果再发出 event，这个已经 dispose 的订阅就收不到消息了。下面是一个简单的使用样例。

```swift
let observable = Observable.of("A", "B", "C")
         
//使用subscription常量存储这个订阅方法
let subscription = observable.subscribe { event in
    print(event)
}
         
//调用这个订阅的dispose()方法
subscription.dispose()
```

## Bind

binding 意思是连接 Observable 和 Subject。


## Binder

Binder 可以只处理 next 事件，并且保证响应 next 事件的代码一定会在给定 Scheduler 上执行，这里采用默认的 MainScheduler。
（1）相较于 AnyObserver 的大而全，Binder 更专注于特定的场景。Binder 主要有以下两个特征：
不会处理错误事件
确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）


## Schedulers - 调度器

（1）调度器（Schedulers）是 RxSwift 实现多线程的核心模块，它主要用于控制任务在哪个线程或队列运行。
（2）RxSwift 内置了如下几种 Scheduler：
CurrentThreadScheduler：表示当前线程 Scheduler。（默认使用这个）
MainScheduler：表示主线程。如果我们需要执行一些和 UI 相关的任务，就需要切换到该 Scheduler 运行。
SerialDispatchQueueScheduler：封装了 GCD 的串行队列。如果我们需要执行一些串行任务，可以切换到这个 Scheduler 运行。
ConcurrentDispatchQueueScheduler：封装了 GCD 的并行队列。如果我们需要执行一些并发任务，可以切换到这个 Scheduler 运行。
OperationQueueScheduler：封装了 NSOperationQueue。

http://www.hangge.com/blog/cache/detail_1940.html


## Driver

> 将监听的数据信号驱动UI更新

* observer.onNext() 可以触发 drive(onNext: {})
* observer.onError() 也可触发 drive(onNext: {}), 但是返回的不是error信息，是onErrorJustReturn的值
* observer.onError() 和 observer.onCompleted() 都会触发 .drive(onCompleted:{})


[Swift - RxSwift的使用详解18（特征序列2：Driver）](http://www.hangge.com/blog/cache/detail_1942.html)

* Driver（司机？） 是一个精心准备的特征序列。它主要是为了简化 UI 层的代码。不过如果你遇到的序列具有以下特征，你也可以使用它：

* Driver的出现是为了让我们在写UI层的响应式代码的时候更加直观。

* 为什么它的名字叫Driver？它意图更好的通过数据去驱动我们的应用程序。

任何可被监听的序列都可以被转换为 Driver，只要他满足 3 个条件：

* 不会产生 error 事件
* 一定在 MainScheduler 监听（主线程监听）
* 共享状态变化



## 操作符

### merge

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190627112254.png)

* 通过使用 merge 操作符你可以将多个 Observables 合并成一个，当某一个 Observable 发出一个元素时，他就将这个元素发出。
* 如果，某一个 Observable 发出一个 onError 事件，那么被合并的 Observable 也会将它发出，并且立即终止序列。






## 结合Alamofire & Moya

[Swift - RxSwift的使用详解49（结合Moya使用1：数据请求）](http://www.hangge.com/blog/cache/detail_2012.html)




## 总结


* Subject - 可观察的和观察者。它可以观察和被观察。
* BehaviorSubject - 当你订阅它，你将得到它已发出的最新的值，以及此后发出的值。
* PublishSubject - 当你订阅它，你只能得到此后它发出的值。
* ReplaySubject - 当你订阅它，你将得到此后发出的值，但也能得到此前发出的值。可以得到多早以前发出的值呢？这取决于你所订阅的 ReplaySubject 的缓存大小（buffer size）。


## 参考

1. [Binder · RxSwift 中文文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/rxswift_core/observer/binder.html)
