#### # Communication-Patterns译文.md

-------
### 2017-08-17
> Issue 7: Foundation · December 2013
> By Florian Kugler

每个应用程序由包含多个或多个松散耦合的对象，这些对象常常需要相互通信才能完成应用的任务。在本文中，我们将介绍所有可用的选项，看看它们在苹果框架中如何使用的示例，最后总结何时使用哪种机制的的最佳实践建议。

虽然这个问题是关于`Foundation`框架，我们将超出`Foundation`框架中的部分通信机制–` KVO`和`Notifications`，还准备谈谈`delegation`, `blocks`, 还有 `target-action`。

当然，在有些情况下，没有明确的答案说应该使用什么样的模式，而将选择归结为个人偏好问题，但也有很多情况（模式使用）是非常清晰明确的。

在本文中，我们经常使用“收件人”和“发件人”这两个术语，我们指的是在通信模式上下文中的意思，最好用几个例子来解释：表视图是发件人，而它的代理是收件人。一个核心数据管理对象上下文是它发布的通知的发送者，而不管它们是如何接收的。滑块是动作消息的发送者，实现这个动作的应答者是接收者。一个含有遵循`KVO`属性的对象，在变化的是发件人，而对应的观察者是收件人。明白窍门了吗？

## 模式

首先，我们将了解每个可用通信模式的特定特性。基于此，我们将在下一节中构建一个流程图，帮助您选择合适的工具。最后，我们将讨论苹果框架中的一些例子，以及他们决定在特定用例中使用特定模式的原因。

## KVO

`KVO`是一种通知对象属性改变的机制。它是在`Foundation`框架上实现的，而且建立在`Foundation`框架之上的许多框架都依赖于它。如果需要阅读更多关于最佳实践的例子说明了如何使用`KVO`，请阅读丹尼尔的[KVO和KVC文章](https://www.objc.io/issues/7-foundation/key-value-coding-and-observing/)。

如果你只关心改变另一个对象的值,`KVO`是一种可行的通信模式。不过还有一些要求。首先，收件人(将接收变化消息的对象)——需要知道发件人（包含值变化的对象）。此外，收件人也需要知道发件人的寿命，因为它需要在发件人被释放者之前注销对其的观察。如果这些要求都满足，则这种通信可以是一对多，因为多个观察者可以注册来自己关心对象的更新。

如果你计划在`Core Data`对象上使用`KVO`，你需要知道，事情会有点不同。这与`Core Data`的`fault`机制。一旦所观察对象变成了`fault`，它将在其属性上触发观察者，尽管它们的值没有改变。

## 通知

通知是一种很好的工具，可以在代码中相对无关的部分之间广播消息，即是是消息内容比较丰富的时候，而且您不必考虑还需要其他人参与。

通知可以发送任意消息，他们甚至可以通过` UserInfo `词典或子类`NSNotification`中包含一个payload（消息载体）。使通知具有唯一性的是发送方和接收方不必互相了解。它们可以用来在非常松散耦合的模块之间发送信息。因此，通信是单向的——您无法对通知作出回复。

## 代理

在苹果的框架中，代理是一种普遍的模式。它允许我们定制对象的行为，并对某些事件进行通知。对于代理模式，消息发送方需要知道接收方（代理），而不是反过来。耦合进一步松了，因为发送方只知道它的代理符合某个协议。

由于代理协议可以定义任意的方法，所以可以精确地将消息通信建模在您的需求里。您可以以方法参数的形式传递payload，代理甚至可以根据代理方法的返回值作出响应。代理是一种非常灵活和直接的通信模式，如果您只需要在两个特定对象之间进行通信，它们在应用程序体系结构中的位置上彼此相对接近。

但也有过度使用的授权模式的危险。如果两个对象紧密耦合在一起，而没有另一个对象，那么就不需要定义代理协议了。在这些情况下，对象可以知道对方的类型并直接进行通信。；两个新例子是` uicollectionviewlayout `和` nsurlsessionconfiguration `。

## Blocks

`Block`是相对最近才添加到`Objective-C`，最早在`OSX 10.6`和`iOS 4`可用。`Blocks`通常可以作为之前使用代理模式实现的角色。然而，这两种模式都有一些优势和特别要求。

一个非常明确的标准：不要使用`Block`创建[保留环](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/memorymgmt/Articles/mmPractical.html#//apple_ref/doc/uid/TP40004447-1000810)。如果发件人需要保留这个`Block`，然而并不能保证对这个`Block`的引用将会置`nil`，那么每个从这个`Block`到`self`的引用，将成为一个潜在的保留环。

Let’s assume we wanted to implement a table view, but we want to use block callbacks instead of a delegate pattern for the selection methods, like this:

假设我们想实现一个表视图，但我们想用`Block`回调，而非它的代理方法来实现表视图的选择，比如这样：

```objc
self.myTableView.selectionHandler = ^void(NSIndexPath *selectedIndexPath) {
    // handle selection ...
};
```

这里的问题是`Self`保留了表视图，而表视图必须保留`Block`，用以稍后使用它。表视图不能把这个引用置`nil`，因为它不能告诉它什么时候不再需要它了。如果不能保证这个保留环将被打破，那么将会一直保留发件人，那么在这里使用`Block`不是一个好的选择。

`NSOperation` is a good example of where this does not become a problem, because it breaks the retain cycle at some point:

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

## Target-Action

`Target-Action`用于响应用户界面事件发送消息的典型模式。两` UIControl `在`iOS`和` NSControl/NSCell ` 在Mac上都支持这种模式。`Target-Action`建立了消息在发件人和收件人之间的松散耦合关系。该消息的收件人不知道发件人，甚至不需要知道将会接受什么消息。如果`Target`是`nil`空的，`Action`将顺着[响应链](https://developer.apple.com/library/ios/documentation/general/conceptual/devpedia-cocoaapp/responder.html)往上，直到找到响应它的对象。在`iOS`上，每个控件甚至可以与多个`Target`的`Action`对相关。


A limitation of target-action-based communication is that the messages sent cannot carry any custom payloads. On the Mac action methods always receive the sender as first argument. On iOS they optionally receive the sender and the event that triggered the action as arguments. But beyond that, there is no way to have a control send other objects with the action message.

基于`target-action`的通信有一个限制，发送的消息不能携带任何自定义的payloads。在`Mac`上的操作方法总是发件者作为第一个参数接收。在`iOS`上，可以将发件者和触发动作的事件作为一种参数来接收。但除此之外，还没有办法让一个控件用`action`将消息发送给其他对象。

## 做出正确的抉择

Based on the characteristics of the different patterns outlined above, we have constructed a flowchart that helps to make good decisions of which pattern to use in what situation. As a word of warning: the recommendation of this chart doesn’t have to be the final answer; there might be other alternatives that work equally well. But in most cases it should guide you to the right pattern for the job.

根据上面所描述的不同模式的特点，我们构建了一个流程图，有助于在何种情况下对使用哪种模式做出良好的决策。一个提醒：这个图表不一定是最终的答案；可能还有其他同样有效的选择。但在大多数情况下，它应该指导你选择合适的模式。

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029354257592.png)


本图值得进一步解释一些其他的细节：

One of the boxes says, sender is **KVO** compliant. This doesn’t mean only that the sender sends **KVO** notifications when the value in question changes, but also that the observer knows about the lifespan of the sender. If the sender is stored in a weak property, it can get nilled out at any time and the observer will leak.

Another box in the bottom row says, message is direct response to method call. This means that the receiver of the method call needs to talk back to the caller of the method as a direct response of the method call. It mostly also means that it makes sense to have the code processing this message in the same place as the method call.

Lastly, in the lower right, a decision question states, sender can guarantee to nil out reference to block?. This refers to the discussion [above](https://www.objc.io/issues/7-foundation/communication-patterns/#blocks) about block-based APIs and potential retain cycles. If the sender cannot guarantee that the reference to the block it’s holding will be nilled out at some point, you’re asking for trouble with retain cycles.


## Framework Examples

In this section, we will go through some examples from Apple’s frameworks to see if the decision flow outlined before actually makes sense, and why Apple chose the patterns as they are.


## KVO

`NSOperationQueue` uses **KVO** to observe changes to the state properties of its operations (`isFinished, isExecuting, isCancelled`). When the state changes, the queue gets a **KVO** notification. Why do operation queues use **KVO** for this?
The recipient of the messages (the operation queue) clearly knows the sender (the operation) and controls its lifespan by retaining it. Furthermore, this use case only requires a one-way communication mechanism. When it comes to the question of if the operation queue is only interested in value changes of the operation, the answer is less clear. But we can at least say that what has to be communicated (the change of state) can be modeled as value changes. Since the state properties are useful to have beyond the operation queue’s need to be up to date about the operation’s status, using **KVO** is a logical choice in this scenario.

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029354800480.png)

**KVO** is not the only choice that would work though. We could also imagine that the operation queue becomes the operation’s delegate, and the operation would call methods like `operationDidFinish`: or `operationDidBeginExecuting`: to signal changes in its state to the queue. This would be less convenient though, because the operation would have to keep its state properties up to date in addition to calling these methods. Furthermore, the queue would have to keep track of the state of all its operations, because it cannot ask for them anymore.


## Notifications

Core Data uses notifications to communicate events like changes within a managed object context (`NSManagedObjectContextObjectsDidChangeNotification`).
The change notification is sent by managed object contexts, so that we cannot assume that the recipient of this message necessarily knows about the sender. Since the origin of the message is clearly not a UI event, multiple recipients might be interested in it, and all it needs is a one-way communication channel, notifications are the only feasible choice in this scenario.

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029358561062.png)


## Delegation

Table view delegates fulfill a variety of functions, from managing accessory views over editing to tracking the cells that are on screen. For the sake of this example, we’ll look at the `tableView:didSelectRowAtIndexPath:` method. Why is this implemented as a delegate call? Why not as a target-action pattern?
As we’ve outlined in the flowchart above, target-action only works if you don’t have to transport any custom payloads. In the selection case, the collection view tells us not only that a cell got selected, but also which cell got selected by handing over its index path. If we maintain this requirement to send the index path, our flowchart guides us straight to the delegation pattern.

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029358866130.png)

What about the option to not send the index path with the selection message, but rather retrieve it by asking the table view about the selected cells once we’ve received the message? This would be pretty inconvenient, because then we would have to do our own bookkeeping of which cells are currently selected in order to tell which cell was newly selected in the case of multiple selection.
Similarly, we could envision being notified about a changed selection by simply observing a property with selected index paths on the table view. However, we would run into the same problem as outlined above, where we couldn’t distinguish which cell was recently selected/deselected without doing our own bookkeeping of it.


## Blocks

For a block-based API we’re going to look at `-[NSURLSession dataTaskWithURL:completionHandler:]` as an example. What is the communication back from the URL loading system to the caller of it like? First, as caller of this API, we know the sender of the message, but we don’t retain it. Furthermore, it’s a one way-communication that is a directly coupled to the `dataTaskWithURL:` method call. If we apply all these factors into the flowchart, we directly end up at the block-based communication pattern.

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029359464595.png)

Are there other options? For sure, Apple’s own `NSURLConnection` is the best example. `NSURLConnection` was crafted before Objective-C had blocks, so they needed to take a different route and implemented this communication using the delegation pattern. Once blocks were available, Apple added the method `sendAsynchronousRequest:queue:completionHandler:` to `NSURLConnection` in OS X 10.7 and iOS 5, so that you didn’t need the delegate any longer for simple tasks.
Since `NSURLSession` is a very modern API that was just added in OS X 10.9 and iOS 7, blocks are now the pattern of choice to do this kind of communication (`NSURLSession` still has a delegate, but for other purposes).


## Target-Action

An obvious use case for the target-action pattern are buttons. Buttons don’t have to send any information except that they have been clicked (or tapped). For this purpose, target-action is a very flexible pattern to inform the application of this user interface event.

![Decision flow chart for communication patterns in Cocoa](http://oc98nass3.bkt.clouddn.com/2017-08-17-15029359755163.png)

If the target is specified, the action message gets sent straight to this object. However, if the target is `nil`, the action message bubbles up the responder chain to look for an object that can process it. In this case, we have a completely decoupled communication mechanism where the sender doesn’t have to know the recipient, and the other way around.

The target-action pattern is perfect for user interface events. No other communication pattern can provide the same functionality. Notifications come the closest in terms of total decoupling of sender and recipient, but what makes target-action special is the use of the responder chain. Only one object gets to react to the action, and the action travels a well-defined path through the responder hierarchy until it gets picked up by something.


## Conclusion

The number of patterns available to communicate information between objects can be overwhelming at first. The choice of which pattern to use often feels ambiguous. But once we investigate each pattern more closely, they all have very unique requirements and capabilities.

The decision flowchart is a good start to create clarity in the choice of a particular pattern, but of course it’s not the end to all questions. We’re happy to hear from you if it matches up with the way you’re using these patterns, or if you think there’s something missing or misleading.

