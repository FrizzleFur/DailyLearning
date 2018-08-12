
# NSOperation解析.md


NSOperation和NSOperationQueue为我们提供面向对象方式的多线程编程方式。

NSOperation
NSOperation是一个抽象类，我们可以用它来封装一系列操作的代码和数据。因为它是抽象，我们无法直接使它，而是使用它的子类。这个子类要么你自己定义，要么使用系统定义好的（NSInvocationOperation或者NSBlockOperation）。尽管它是抽象的，但是，NSOperation可以让我们只需要关心任务的实现过程，而不必关心它是如何确保与其他系统对象正确运转的。

NSOperation对象是"一次性"的，它一旦执行了它的任务之后，就不能被用来再次执行了。将NSOperation的对象添加到一个操作队列中（NSOperationQueue的一个实例）。这个队列会自动执行它所包含的操作，可能直接开辟一个线程执行，也可能间接地使用libdispatch库。

如果不想使用队列，可以调用NSOperation的实例方法start来执行操作。如果手动控制操作的执行，我们需要考虑更多的内容。因为如果执行一个没有处在ready状态的操作，系统会抛出异常。

Operation之间的依赖
依赖可以很好地控制操作的执行先后顺序。我们可以通过调用addDependency:和removeDependency:来为一个操作添加或移除依赖。默认地，如果一个操作的依赖都没有执行完，那么它不会进入ready状态。一旦它的依赖执行完成，它就可以立即被执行。

一个操作不会判断它的依赖是否成功地执行。（取消一个操作近似于标记这个操作已经完成。）一个有依赖的操作在它的依赖被取消或者未执行成功的情况下是否被继续执行取决于我们自己。这需要我们给操作加入一些错误跟踪能力，以保证我们及时发现问题。

KVO相关的属性
NSOperation类提供了一系列可用于KVO编程的属性。

isCancelled - 只读
isAsynchronous - 只读
isExecuting - 只读
isFinished - 只读
isReady - 只读
dependencies - 只读
queuePriority - 可读可写
completionBlock - 可读可写
虽然给这些属性添加观察者，但是我们不要它们和UI元素进行捆绑。UI相关的代码只能在主线程执行，而NSOperation对象的操作可能在任一线程中执行，所以通知也会出现在任一线程里。如果和UI元素捆绑，那就会造成主线程的阻塞。

NSOperation的一些方法和属性
方法：

start。可以让NSOperation直接执行。
cancel。取消NSOperation的操作。
addDependency: 和 removeDependency:。为NSOperation添加依赖或移除依赖。
属性：

queuePriority。在队列中的优先级。有NSOperationQueuePriorityVeryLow，NSOperationQueuePriorityLow，NSOperationQueuePriorityNormal，NSOperationQueuePriorityHigh，NSOperationQueuePriorityVeryHigh5个值。如果没有明确设置，默认是NSOperationQueuePriorityNormal。
qualityOfService。表示当前NSOperation的相对重要性，以获取不同程度的系统资源。
Operation的状态
NSOperation类还提供一系列属性表示操作目前的状态。

cancelled。表示是否被取消。默认值是NO。可以通过调用cancel方法取消操作的执行，这个属性的值被置为YES。一旦取消，操作就会进入finished状态。
executing。表示操作是否正在执行。
finished。表示操作是否执行完毕。
concurrent、asynchronous。这两个属性都表示操作是否是异步的。
ready。表示当前的操作是否可以开始执行。
注意：上面的几个属性都是只读的。

当我们继承NSOperation，实现子类的时候，在main函数的开头要判断cancelled的值，以尽快退出一个已经取消的操作。同时，必须要重新实现executing、finished、asynchronous、ready这几个属性。

目前，系统提供的NSInvocationOperation和NSBlockOperation两个子类基本可以满足我的需求，还没有深入研究重写时的注意点，会在以后补充上。

NSInvocationOperation
这是系统提供的一个NSOperation的子类。通过@selector，将操作包含到自身。

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)sel
                        object:(id)arg
target表示在那个类中实现了SEL的方法。SEL可以带0或1个参数。如果参数为0个，arg置为nil，否则就设为SEL所带的参数。

直接给个简单的例子。

//定义一个方法，输出“One”。
- (void)outputOne {
    NSLog(@"One");
}
//返回值为"Two"。
- (NSString*)returnTwo {
    return @"Two";
}
//用上面的两个方法分别创建NSInvocationOperation实例
NSInvocationOperation *outputOne = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(outputOne) object:nil];
NSInvocationOperation *returnTwo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(returnTwo) object:nil];
NSBlockOperation
这是系统提供的另一个NSOperation的子类，将要包含的操作放到block中。

//这是一个类方法，而创建NSInvocationOperation实例是一个实例方法
+ (instancetype)blockOperationWithBlock:(void (^)(void))block
这里同样直接给出一个例子。

//联系上一段代码，这个NSBlockOperation的实例输出`returnTwo`的`返回值`和`target`。
NSBlockOperation *outputTwo = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[returnTwo result]);
    }];
[outputTwo addExecutionBlock:^{
    NSLog(@"%@",[[returnTwo invocation] target]);
}];
对于NSBlockOperation对象，可以调用- addExecutionBlock:来添加一些操作。

NSOperationQueue
NSOperationQueue管理队列中NSOperation的执行顺序。当一个NSOperation被添加到队列中后，除非它被取消或者执行完操作，否则会一直存在于队列中。存在于队列中NSOperation根据它们自身的优先级和依赖关系，确定执行的顺序。一个应用可以创建多个队列，NSOperation可以添加到任意一个队列中。

NSOperation的依赖决定NSOperation执行的绝对顺序，即使它们不在同一个队列中。当NSOperation的依赖没有完全执行结束时，它是不会进入ready状态。对于那些进入ready状态的NSOperation，队列会选择一个优先级相对最高的那个NSOperation来执行。

队列中的NSOperation不能直接被移除，直到它被标记成finished。即使NSOperation被标记为finished，也不意味着它被执行完成。因为它是可以被取消的。对于在队列中处于ready，还没被执行的NSOperation，会自动调用start方法将操作执行完毕。

NSOperationQueue总是开辟一个新的线程来执行队列里的NSOperation。NSOperationQueue使用libdispatch库来初始化执行NSOperation的队列。因此，NSOperation总是在不同的线程里被执行，无论它是否被指定是同步或异步。

可以用于KVO的一些属性
NSOperationQueue同样有一些属性，可以用于KVO编程。

operations - 只读
operationCount - 只读
maxConcurrentOperationCount - 可读可写
suspended - 可读可写
name - 可读可写
同样地，这些属性不要和UI元素进行观察者绑定。

常用的方法和属性
方法：

+ mainQueue
+ currentQueue
这两个方法可以分别获取到主线程和当前正在执行的线程。

//添加一个NSOperation对象到队列中
- (void)addOperation:(NSOperation *)operation
如果被添加的NSOperation对象已经存在于其他的队列中，会抛出NSInvalidArgumentException异常。如果一个NSOperation对象的isExecuting或者isFinished为YES，同样会抛出NSInvalidArgumentException异常。

- cancelAllOperations
取消当前队列中所有的NSOperation。

属性：

@property NSInteger maxConcurrentOperationCount
队列一次性可以执行的NSOperation的最大数目。默认值是NSOperationQueueDefaultMaxConcurrentOperationCount。系统会根据当前的设备装备的状况动态设置最大执行数目。

这个属性只影响当前队列一次性可执行的NSOperation最大个数，其他队列按照其自己的最大可执行数目进行。

@property(getter=isSuspended) BOOL suspended
这个属性可以使当前队列中的NSOperation延迟执行。默认值是NO。当被设为YES时，当前队列中还未执行的NSOperation就会延时执行，直到这个值重新被设为NO。

一个简单的例子
这里，我们继续使用上面给出的代码。

首先，定义几个操作

//输出`One`
- (void)outputOne {
    NSLog(@"One");
}
//返回`Two`
- (NSString*)returnTwo {
    return @"Two";
}
//显示一个背景色为红色的Button
- (void)displayButton {
    //    [[NSOperationQueue mainQueue] waitUntilAllOperationsAreFinished];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [button setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:button];
}
再实例化NSOperation对象

//用NSInvocationOperation实例化操作对象
NSInvocationOperation *outputOne = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(outputOne) object:nil];
NSInvocationOperation *returnTwo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(returnTwo) object:nil];
NSInvocationOperation *display = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayButton) object:nil];
//用NSBlockOperation实例化操作对象
NSBlockOperation *outputTwo = [NSBlockOperation blockOperationWithBlock:^{
    NSLog(@"%@",[returnTwo result]);
}];
[outputTwo addExecutionBlock:^{
    NSLog(@"%@",[[returnTwo invocation] target]);
}];
然后给操作设置依赖

[outputTwo addDependency:outputOne];
[outputTwo addDependency:returnTwo];
[display addDependency:outputTwo];
//定义之后，几个操作的执行顺序`可能`是 outputOne -> returnTwo -> outputTwo -> display。对于outputOne和returnTwo这两个操作，因为它们的优先级是默认值，也没有其他的依赖，所以谁先谁后是随机的。
最后，将这些NSOperation的对象添加到相应的队列中去。

//初始化一个自定义的队列
NSOperationQueue *customQueue = [[NSOperationQueue alloc] init];
//获取到主线程队列
NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//好像主线程设置suspended属性为YES后，依然会执行主线程中的操作
mainQueue.suspended = YES;
//将display添加到主线程中
[mainQueue addOperation:display];  
//将outputOne，returnTwo，outputTwo添加到自定义的队列中
[customQueue addOperation:returnTwo];
//这里设置为YES，如果没有再次将`suspended`设为NO，那么只会在控制台输出`One`
customQueue.suspended = YES;
[customQueue addOperation:outputOne];
[customQueue addOperation:outputTwo];
//customQueue.suspended = NO;
参考文档： 
NSOperationQueue Class Reference 
NSOperation Class Reference 
NSBlockOperation 
NSInvocationOperation


### 参考 
1. [NSOperation 和 NSOperationQueue](https://segmentfault.com/a/1190000004522337)

