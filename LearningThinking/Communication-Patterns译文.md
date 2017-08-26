#### # Communication-Patterns译文.md

-------
### 2017-08-17
> 原文：[Communication Patterns](https://www.objc.io/issues/7-foundation/communication-patterns/)
> Issue 7: Foundation · December 2013
> By Florian Kugler

每个应用程序由包含多个或多个松散耦合的对象，这些对象常常需要相互通信才能完成应用的任务。在本文中，我们将介绍所有可用的选项，看看它们在苹果框架中如何使用的示例，最后总结何时使用哪种机制的的最佳实践建议。

虽然这个问题是关于`Foundation`框架，我们将超出`Foundation`框架中的部分通信机制–` KVO`和`Notifications`，还准备谈谈`delegation`, `blocks`, 还有 `target-action`。

当然，在有些情况下，没有明确的答案说应该使用什么样的模式，而将选择归结为个人偏好问题，但也有很多情况（模式使用）是非常清晰明确的。

在本文中，我们经常使用“收件人”和“发件人”这两个术语，我们指的是在通信模式上下文中的意思，最好用几个例子来解释：表视图是发件人，而它的代理是收件人。一个核心数据管理对象上下文是它发布的通知的发件人，而不管它们是如何接收的。滑块是动作消息的发送者，实现这个动作的应答者是接收者。一个含有遵循`KVO`属性的对象，在变化的是发件人，而对应的观察者是收件人。明白窍门了吗？

<!--more-->

## 模式

首先，我们将了解每个可用通信模式的特定特性。基于此，我们将在下一节中构建一个流程图，帮助您选择合适的工具。最后，我们将讨论苹果框架中的一些例子，以及他们决定在特定用例中使用特定模式的原因。

### KVO

`KVO`是一种通知对象属性改变的机制。它是在`Foundation`框架上实现的，而且建立在`Foundation`框架之上的许多框架都依赖于它。如果需要阅读更多关于最佳实践的例子说明了如何使用`KVO`，请阅读丹尼尔的[KVO和KVC文章](https://www.objc.io/issues/7-foundation/key-value-coding-and-observing/)。

如果你只关心改变另一个对象的值,`KVO`是一种可行的通信模式。不过还有一些要求。首先，收件人(将接收变化消息的对象)——需要知道发件人（包含值变化的对象）。此外，收件人也需要知道发件人的寿命，因为它需要在发件人被释放者之前注销对其的观察。如果这些要求都满足，则这种通信可以是一对多，因为多个观察者可以注册来自己关心对象的更新。

如果你计划在`Core Data`对象上使用`KVO`，你需要知道，事情会有点不同。这与`Core Data`的`fault`机制。一旦所观察对象变成了`fault`，它将在其属性上触发观察者，尽管它们的值没有改变。

### 通知

通知是一种很好的工具，可以在代码中相对无关的部分之间广播消息，即是是消息内容比较丰富的时候，而且您不必考虑还需要其他人参与。

通知可以发送任意消息，他们甚至可以通过` UserInfo `词典或子类`NSNotification`中包含一个payload（消息载体）。使通知具有唯一性的是发件人和收件人不必互相了解。它们可以用来在非常松散耦合的模块之间发送信息。因此，通信是单向的——您无法对通知作出回复。

### 代理

在苹果的框架中，代理是一种普遍的模式。它允许我们定制对象的行为，并对某些事件进行通知。对于代理模式，消息发件人需要知道收件人（代理），而不是反过来。耦合进一步松了，因为发件人只知道它的代理符合某个协议。

由于代理协议可以定义任意的方法，所以可以精确地将消息通信建模在您的需求里。您可以以方法参数的形式传递payload，代理甚至可以根据代理方法的返回值作出响应。代理是一种非常灵活和直接的通信模式，如果您只需要在两个特定对象之间进行通信，它们在应用程序体系结构中的位置上彼此相对接近。

但也有过度使用的授权模式的危险。如果两个对象紧密耦合在一起，而没有另一个对象，那么就不需要定义代理协议了。在这些情况下，对象可以知道对方的类型并直接进行通信。；两个新例子是` uicollectionviewlayout `和` nsurlsessionconfiguration `。

### Blocks

`Block`是相对最近才添加到`Objective-C`，最早在`OSX 10.6`和`iOS 4`可用。`Blocks`通常可以作为之前使用代理模式实现的角色。然而，这两种模式都有一些优势和特别要求。

一个非常明确的标准：不要使用`Block`创建[保留环](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/memorymgmt/Articles/mmPractical.html#//apple_ref/doc/uid/TP40004447-1000810)。如果发件人需要保留这个`Block`，然而并不能保证对这个`Block`的引用将会置`nil`，那么每个从这个`Block`到`self`的引用，将成为一个潜在的保留环。

假设我们想实现一个表视图，但我们想用`Block`回调，而非它的代理方法来实现表视图的选择，比如这样：

```objc
self.myTableView.selectionHandler = ^void(NSIndexPath *selectedIndexPath) {
    // handle selection ...
};
```

这里的问题是`Self`保留了表视图，而表视图必须保留`Block`，用以稍后使用它。表视图不能把这个引用置`nil`，因为它不能告诉它什么时候不再需要它了。如果不能保证这个保留环将被打破，那么将会一直保留发件人，那么在这里使用`Block`不是一个好的选择。

这并不会成为一个问题，` NSOperation `是一个很好的例子，因为它在某个时刻打破了保持环：

```objc
self.queue = [[NSOperationQueue alloc] init];
MyOperation *operation = [[MyOperation alloc] init];
operation.completionBlock = ^{
    [self finishedOperation];
};
[self.queue addOperation:operation];
```
乍一看，这似乎是一个保留循环：`Self`保留队列，队列保留操作，操作保留完成块，`completion block`保留`Self`。但是，将操作添加到队列将导致在某个时间点上执行该操作，然后将它从队列中删除。（如果它不被执行，我们就有一个更大的问题。）一旦队列删除操作，保留循环就被破坏了。

另一个例子：假设我们实现视频编码器类，在我们称之为一个` encodewithcompletionhandler `方法中。为让这不出问题，我们必须保证编码器对象在某一刻对于这个`block`的引用置空。在内部，这应该是这个样子：

```objc
@interface Encoder ()
@property (nonatomic, copy) void (^completionHandler)();
@end

@implementation Encoder

- (void)encodeWithCompletionHandler:(void (^)())handler
{
    self.completionHandler = handler;
    // do the asynchronous processing...
}

// This one will be called once the job is done
- (void)finishedEncoding
{
    self.completionHandler();
    self.completionHandler = nil; // <- Don't forget this!
}

@end
```

一旦我们的工作完成了，会调用`completion block`，然后将其置空。

**如果我们所调用的消息必须返回该方法调用的一次性响应**，那么`Block`是非常合适的，因为这样我们可以打破潜在的保留循环。此外，如果有助于可读性，使处理消息与消息调用的代码写在一起，就不去使用`Block`。沿着这些线路，很常用的`Block`的情况下是（方法的）`completion handlers`，错误处理等等。

### Target-Action

`Target-Action`用于响应用户界面事件发送消息的典型模式。两` UIControl `在`iOS`和` NSControl/NSCell ` 在Mac上都支持这种模式。`Target-Action`建立了消息在发件人和收件人之间的松散耦合关系。该消息的收件人不知道发件人，甚至不需要知道将会接受什么消息。如果`Target`是`nil`空的，`Action`将顺着[响应链](https://developer.apple.com/library/ios/documentation/general/conceptual/devpedia-cocoaapp/responder.html)往上，直到找到响应它的对象。在`iOS`上，每个控件甚至可以与多个`Target`的`Action`对相关。

基于`target-action`的通信有一个限制，发送的消息不能携带任何自定义的payloads。在`Mac`上的操作方法总是发件者作为第一个参数接收。在`iOS`上，可以将发件者和触发动作的事件作为一种参数来接收。但除此之外，还没有办法让一个控件用`action`将消息发送给其他对象。

###  做出正确的抉择

根据上面所描述的不同模式的特点，我们构建了一个流程图，帮助您在某种情况下对使用哪种模式，做出良好的决策。作为提醒：这个图表不一定是最终的答案；可能还有其他同样有效的选择。但在大多数情况下，它应该指导你为这个场景选择合适的模式。

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029354257592.png)

本图值得进一步解释一些其他的细节：

（图中）其中的一个方块表示：发件人是支持`KVO`。这并不只是意味着当问题中的值发生变化时，发件人将发送`KVO`通知，而且观察者要知道发件人的生命周期。如果发件人存放的属性是`weak`，它可以在任意时间置空（nil）,而观察者会发生内存泄漏。

在底排另一方块表示，消息是直接响应方法调用的。这意味着，方法调用的接受者需要回应该方法的调用者，作为对这个方法调用的一个直接响应。这也意味着，当这个方法调用时，代码在同一个地方处理此消息是有意义的。

最后，在右下角有一个决策问题：发件人可以保证对`Block`的引用将会置空（nil）吗？这个联系到了[上面](https://www.objc.io/issues/7-foundation/communication-patterns/#blocks)的基于`block`的API和潜在的保留环的讨论。如果发件人无法保证这些`block`所持有的引用将在某个时刻置空（nil），那么你将会遇到保留环的麻烦。

## 框架示例

在本节中，我们将从苹果的框架中看一些例子，看看前面所说的决策流程是否有效，以及为什么苹果选择这些模式。

### KVO

`NSOperationQueue`使用`KVO`来观察它的操作状态（是否完成、是否在执行、是否取消）。当这个状态变化时，这个队列的得到一个`KVO`的通知，为什么操作队列对此用`KVO`呢？

收件人的消息（操作队列）清楚地知道发件人（该操作）和通过保留来控制其生命周期。此外，这种情况下，只需要一个单向的通信机制。说到如果操作队列中的操作值的变化只感兴趣，这个答案是不很清晰。但我们至少可以说，有什么要传递的（比如状态改变）可以封装成值的改变。由于状态属性已超出操作队列及时了解操作的状态的需求，在这种情况下使用`KVO`是一个合乎逻辑的方案。

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029354800480.png)

`KVO`是不是唯一有效的选择。我们还可以设想，操作队列成为操作的代理，然后操作将调用如` operationDidFinish` 或`operationDidBeginExecuting`的方法，将它状态信号的变化通知到队列。虽然这将不那么方便，因为操作除了调用这些方法之外还要保持其状态属性的更新。此外，队列必须跟踪所有操作的状态，因为它不能再请求它们了。

### 通知

`Core Data`使用`notifications`来通知对象内容的变化事件（`NSManagedObjectContextObjectsDidChangeNotification `）。

通知的变化是由托管对象的内容发送的，因此我们不能假定消息的收件人一定知道发件人。由于消息的起源显然不是UI事件，所以可能有多个收件人对它感兴趣，而它所需要的只是单向通信通道，这种场景中`notifications`是唯一可行的选择。

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029358561062.png)

### 代理

表视图的代理完成很多功能，从管理附属视图到编辑和跟踪屏幕上的单元格。在这个例子中，我们将看看` TableView：didselectrowatindexpath：`方法。为什么这个要作为代理方法来调用？为什么不适用`target-action`模式呢？

正如我们在上面的流程图中所概述的那样，`target-action`只有在不需要传输任何自定义有效载荷时才有效。在选择的情况下，`collection`视图告诉我们点击一个`cell`时不仅选择了一个`cell`，而且还通过传递索引路径选择了哪个`cell`。如果我们保持这个要求发送索引路径，我们的流程图指导我们直接进入代理模式。

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029358866130.png)

在选择`cell`的消息中，假如不发送索引路径，而是一旦我们收到的消息，通过询问表视图找回选定的`cell`呢？这将是非常不方便的，因为我们将不得不做记录目前选择的`cell`，在多个选择中以确定哪个`cell`是新选择。

类似地，我们可以通过观察选定的索引路径属性的更改，当表视图中点击的改变时, 得到相关的通知。然而，我们也遇到了同样的问题，正如上面提到的，如果我们自己的不做记录，将无法区分哪些`cell`是最近选择/取消选择的。

### Blocks

一个基于`block`的API，比如以` - [ NSURLSession dataTaskWithURL:completionHandler：] `为例。从调用者到URL加载系统间的通信是什么样的？首先，作为这个`API`调用者，我们熟悉消息的发送者，但我们不保留它。此外，它是一个单向的通信，直接连接到` dataTaskWithURL：`方法的调用。如果我们将这些因素纳入流程图中，那么将直接结束这个基于`block`的通信模式。

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029359464595.png)
还有其他选择吗？当然，苹果自己的` NSURLConnection`就是最好的例子。` NSURLConnection`在`Objective-C`有`block`之前就创建了，所以他们时需要采取不同的路线，并且使用代理模式实施通信。一旦`block`是可用的，在`OS X 10.7`和`iOS 5`中，苹果将方法` sendAsynchronousRequest:queue:completionHandler：`到` NSURLConnection `方法中，所以你不需要再为简单的任务设置代理了。

因为` NSURLSession `是刚刚在`OS X 10.9`和`iOS 7`上添加的一个非常新的`API`，而`block`现在是作为这种通信模式的选择（` NSURLSession `也有一个代理，但是是作为其他用途的）。

### Target-Action

对于`target-action`模式的一个明显的用例就是按钮。按钮不需要发送任何信息，除非他们已经点击（或轻拍）。从这个意义来说，`target-action`是UI事件通知App中非常灵活。

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029359755163.png)

如果目标是指定的，行动的消息将被直接发送到该对象。然而，如果目标是`nil`，行动消息会顺着事件链往上中寻找可以处理它的对象。在这种情况下，我们有一个完全解耦的通信机制，发件人不必知道收件人，而不是反过来。

`target-action`模式对UI事件来说是完美的。没有其他的通信方式可以提供这样的功能。`Notifications`是对发件人和收件人解耦方面最接近的，但使`target-action`特别的是对响应者链的使用。只有一个对象对得到的`action`作出反应，而且`action`顺着响应链通过定义好的路径，直到它被某个对象获取到。


## 总结

一开始，对象之间的通信模式看起来似乎很多，在选择哪种模式时经常感到模棱两可。但是一旦我们对每种模式进一步了解，它们都有非常独特的要求和功能。

决策流程图是一个很好的开始，你可以在选择特定模式时非常清晰，但当然不是所有问题的结束。如果它符合你使用这些模式的方式，或者你认为有什么遗漏或误导的话，我们将很高兴收到你的来信。

