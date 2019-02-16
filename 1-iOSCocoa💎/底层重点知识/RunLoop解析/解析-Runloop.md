# 解析RunLoop


## RunLoop简介（Introduction）

1. RunLoop是线程基础架构的一部分。RunLoop存在的目的是让线程在没有任务处理的时候进入休眠，在有任务处理的时候运行。

2. RunLoop不是完全自管理的，需要你在适当的时候启动。

3. Cocoa和Core Foundation框架都提供了RunLoop相关的API。

4. 你不需要自己创建RunLoop对象。每个线程，包括主线程都有一个对应的RunLoop对象。

5. 只有子线程的RunLoop需要手动启动，主线程的RunLoop在App启动调用Main函数时就已运行。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216141120.png)

<!-- more -->


### RunLoop的结构

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216133449.png)

1. NSRunloop：最上层的NSRunloop层实际上是对C语言实现的CFRunloop的一个封装，实际上它没干什么事，比如CFRunloop有一个过期时间是double类型，NSRunloop把它变成了NSDate类型；
2. CFRunloop：这是真正干事的一层，源代码是开源的，并且是跨平台的；
3. 系统层：底层实现用到了GCD，**mach kernel是苹果的内核，比如runloop的睡眠和唤醒就是用mach kernel来实现的**。
    下面是跟Runloop有关的，我们平时用到的一些模块，功能等等：
    1）NSTimer计时器；
    2）UIEvent事件；
    3）Autorelease机制；
    4）NSObject（NSDelayedPerforming）：比如这些方法：performSelector:withObject:afterDelay:，performSelector:withObject:afterDelay:inModes:，cancelPreviousPerformRequestsWithTarget:selector:object:等方法都是和Runloop有关的；
    5）NSObject（NSThreadPerformAddition）：比如这些方法：performSelectorInBackground:withObject:，performSelectorOnMainThread:withObject:waitUntilDone:，performSelector:onThread:withObject:waitUntilDone:等方法都是和Runloop有关的；
4. Core Animation层的一些东西：CADisplayLink，CATransition，CAAnimation等；
5. dispatch_get_main_queue()；
6. NSURLConnection；



### 从调用堆栈来看Runloop

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216153840.png)

从下往上一层层的看，最开始的start是dyld干的，然后是main函数，main函数接着调用UIApplicationMain，然后的GSEventRunModal是Graphics Services是处理硬件输入，比如点击，所有的UI事件都是它发出来的。紧接着的就是Runloop了，从图中的可以看到从13到10的4调用都是Runloop相关的。再上面的就是事件队列处理，以及UI层的事件分发了。

* dyld（the dynamic link editor）是苹果的动态链接器，是苹果操作系统一个重要组成部分，在系统内核做好程序准备工作之后，交由dyld负责余下的工作。而且它是开源的，任何人可以通过苹果官网下载它的源码来阅读理解它的运作方式，了解系统加载动态库的细节。



几乎所有线程的所有函数都是从下面六个函数之一调起：


```objc
static void __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__();  
static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__();  
static void __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__();  
static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__();  
static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__();  
static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__();

```


## Runloop的构成

* Core Foundation中的CFRunLoopRef
* NSRunLoop是基于CFRunLoopRef的一层OC包装，所以要了解RunLoop内部结构，需要多研究CFRunLoopRef层面的API（Core Foundation层面）

![RunLoop结构](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359081423883.png)

1. Runloop与Thread是一一绑定的，但是并不是一个Thread只能起一个Runloop，它可以起很多，但是必须是嵌套结构，根Runloop只有一个；
2. **RunloopMode是指的一个事件循环必须在某种模式下跑，系统会预定义几个模式。一个Runloop有多个Mode**；
3. **CFRunloopSource，CFRunloopTimer，CFRunloopObserver这些元素是在Mode里面的，Mode与这些元素的对应关系也是1对多的**；
CFRunloopTimer：比如下面的方法都是CFRunloopTimer的封装：

### CFRunLoop 结构

```objc
typedef struct __CFRunLoop * CFRunLoopRef;

struct __CFRunLoop {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;			/* locked for accessing mode list */
    __CFPort _wakeUpPort;			// used for CFRunLoopWakeUp 
    Boolean _unused;
    volatile _per_run_data *_perRunData;              // reset for runs of the run loop
    pthread_t _pthread;
    uint32_t _winthread;
    CFMutableSetRef _commonModes; // 字符串，记录所有标记为common的mode
    CFMutableSetRef _commonModeItems; // 所有commonMode的item(source、timer、observer)
    CFRunLoopModeRef _currentMode;
    CFMutableSetRef _modes; // CFRunLoopModeRef set
    struct _block_item *_blocks_head;
    struct _block_item *_blocks_tail;
    CFTypeRef _counterpart;
}
```
* CFRunLoop 里面包含了线程，若干个 mode。
* CFRunLoop 和线程是一一对应的。
* _blocks_head 是 perform block 加入到里面的


## RunLoop 的 Mode

一个 RunLoop 包含若干个 Mode，每个 Mode 又包含若干个 Source/Timer/Observer。每次调用 RunLoop 的主函数时，只能指定其中一个 Mode，这个Mode被称作 CurrentMode。如果需要切换 Mode，只能退出 Loop，再重新指定一个 Mode 进入。这样做主要是为了分隔开不同组的 Source/Timer/Observer，让其互不影响。

* Runloop同一时间只能且必须在一种特定Mode下Run
* 更换Mode需要停止当前Mode,停止当前Loop, 重启Loop
* Mode是iOS流畅的关键(滑动的时候，切换了Mode,不会被其他Mode干扰)

CFRunLoopMode 和 CFRunLoop 的结构大致如下：

```objc
struct __CFRunLoopMode {
    CFStringRef _name;            // Mode Name, 例如 @"kCFRunLoopDefaultMode"
    CFMutableSetRef _sources0;    // Set
    CFMutableSetRef _sources1;    // Set
    CFMutableArrayRef _observers; // Array
    CFMutableArrayRef _timers;    // Array
    ...
};
 
struct __CFRunLoop {
    CFMutableSetRef _commonModes;     // Set
    CFMutableSetRef _commonModeItems; // Set<Source/Observer/Timer>
    CFRunLoopModeRef _currentMode;    // Current Runloop Mode
    CFMutableSetRef _modes;           // Set
    ...
};
```

### CFRunLoopMode 

```objc
// 定义 CFRunLoopModeRef 为指向 __CFRunLoopMode 结构体的指针
typedef struct __CFRunLoopMode *CFRunLoopModeRef;

struct __CFRunLoopMode {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;	/* must have the run loop locked before locking this */
    CFStringRef _name;
    Boolean _stopped;
    char _padding[3];
    CFMutableSetRef _sources0; // source0 set ，非基于Port的，接收点击事件，触摸事件等APP 内部事件
    CFMutableSetRef _sources1; // source1 set，基于Port的，通过内核和其他线程通信，接收，分发系统事件
    CFMutableArrayRef _observers; // observer 数组
    CFMutableArrayRef _timers; // timer 数组
    CFMutableDictionaryRef _portToV1SourceMap;// source1 对应的端口号
    __CFPortSet _portSet;
    CFIndex _observerMask;
#if USE_DISPATCH_SOURCE_FOR_TIMERS
    dispatch_source_t _timerSource;
    dispatch_queue_t _queue;
    Boolean _timerFired; // set to true by the source when a timer has fired
    Boolean _dispatchTimerArmed;
#endif
#if USE_MK_TIMER_TOO
    mach_port_t _timerPort;
    Boolean _mkTimerArmed;
#endif
#if DEPLOYMENT_TARGET_WINDOWS
    DWORD _msgQMask;
    void (*_msgPump)(void);
#endif
    uint64_t _timerSoftDeadline; /* TSR */
    uint64_t _timerHardDeadline; /* TSR */
};

```

#### CommonModes

这里有个概念叫 “CommonModes”：一个 Mode 可以将自己标记为”Common”属性（通过将其 ModeName 添加到 RunLoop 的 “commonModes” 中）。每当 RunLoop 的内容发生变化时，RunLoop 都会自动将 _commonModeItems 里的 Source/Observer/Timer 同步到具有 “Common” 标记的所有Mode里。

#### Mode列表

* NSDefaultRunLoopMode：App的默认Mode，通常主线程是在这个Mode下运行
* UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
* UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用
* GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode，通常用不到
* NSRunLoopCommonModes: 这是一个占位用的Mode，不是一种真正的Mode commonModes:
* 一个Mode 可以将自己标记成”Common”属性（通过将其ModelName 添加到RunLoop的"commonModes" 中）。每当 RunLoop 的内容发生变化时，RunLoop 都会自动将 _commonModeItems 里的 Source/Observer/Timer 同步到具有 "Common" 标记的所有Mode里。
* 应用场景举例：主线程的 RunLoop 里有两个预置的 Mode：kCFRunLoopDefaultMode 和 UITrackingRunLoopMode。这两个 Mode 都已经被标记为"Common"属性。**DefaultMode 是 App 平时所处的状态**，TrackingRunLoopMode 是追踪 ScrollView 滑动时的状态。当你创建一个 Timer 并加到 DefaultMode 时，Timer 会得到重复回调，但此时滑动一个TableView时，RunLoop 会将 mode 切换为 TrackingRunLoopMode，这时 Timer 就不会被回调，并且也不会影响到滑动操作。
* 有时你需要一个 Timer，在两个 Mode 中都能得到回调，一种办法就是将这个 Timer 分别加入这两个 Mode。还有一种方式，**就是将 Timer 加入到commonMode 中。那么所有被标记为commonMode的mode（defaultMode和TrackingMode）都会执行该timer。这样你在滑动界面的时候也能够调用time**。


可以用表格来说明不同的mode:

| mode | name | description |
| --- | --- | --- |
| Default | NSDefaultRunLoopMode (Cocoa) kCFRunLoopDefaultMode (Core Foundation) | 用的最多的模式，大多数情况下应该使用该模式开始 RunLoop并配置 input source |
| Connection | NSConnectionReplyMode (Cocoa) | Cocoa用这个模式结合 NSConnection 对象监测回应，我们应该很少使用这种模式 |
| Modal | NSModalPanelRunLoopMode (Cocoa) | Cocoa用此模式来标识用于模态面板的事件 |
| Event tracking | NSEventTrackingRunLoopMode (Cocoa) | Cocoa使用此模式在鼠标拖动loop和其它用户界面跟踪 loop期间限制传入事件 |
| Common modes | NSRunLoopCommonModes (Cocoa) kCFRunLoopCommonModes (Core Foundation) | 这是一组可配置的常用模式。将输入源与些模式相关联会与组中的每个模式相关联。Cocoa applications 里面此集包括Default、Modal和Event tracking。Core Foundation只包括默认模式，你可以自己把自定义mode用CFRunLoopAddCommonMode函数加入到集合中. |

### CFRunLoopSourceRef

* Source是RunLoop的数据源抽象类 (protocol形式)

**CFRunLoopSourceRef 是事件产生的地方**。Source有两个版本：Source0 和 Source1。
• Source0 只包含了一个回调（函数指针），它并不能主动触发事件。使用时，你需要先调用 CFRunLoopSourceSignal(source)，将这个 Source 标记为待处理，然后手动调用 CFRunLoopWakeUp(runloop) 来唤醒 RunLoop，让其处理这个事件。
• Source1 包含了一个 mach_port 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。这种 Source 能主动唤醒 RunLoop 的线程，其原理在下面会讲到。

1. Source0：处理App内部事件，App自己负责管理（触发），如UIEvent，CFSocket；
2. Source1：由Runloop和内核管理，mach port驱动，如CFMachPort（轻量级的进程间通信的方式，NSPort就是对它的封装，还有Runloop的睡眠和唤醒就是通过它来做的），CFMessagePort；

### CFRunLoopTimerRef


CFRunLoopTimerRef 是基于时间的触发器，它和 NSTimer 是toll-free bridged 的，可以混用。其包含一个时间长度和一个回调（函数指针）。当其加入到 RunLoop 时，RunLoop会注册对应的时间点，当时间点到时，RunLoop会被唤醒以执行那个回调。


### RunLoopObserver

CFRunLoopObserver 是观察者，可以观察RunLoop的各种状态，并抛出回调。可以监听得状态如下：

```objc
/* Run Loop Observer Activities */
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
 kCFRunLoopEntry = (1UL << 0), //即将进入run loop
 kCFRunLoopBeforeTimers = (1UL << 1), //即将处理timer
 kCFRunLoopBeforeSources = (1UL << 2), //即将处理source
 kCFRunLoopBeforeWaiting = (1UL << 5), //即将进入休眠
 kCFRunLoopAfterWaiting = (1UL << 6), //被唤醒但是还没开始处理事件
 kCFRunLoopExit = (1UL << 7), //run loop已经退出
 kCFRunLoopAllActivities = 0x0FFFFFFFU
};
```

* Source0：非基于Port的。只包含了一个回调（函数指针），它并不能主动触发事件。使用时，你需要先调用 CFRunLoopSourceSignal(source)，将这个 Source 标记为待处理，然后手动调用 CFRunLoopWakeUp(runloop) 来唤醒 RunLoop，让其处理这个事件。
* Source1：基于Port的，通过内核和其他线程通信，接收、分发系统事件。这种 Source 能主动唤醒 RunLoop 的线程。后面讲到的创建常驻线程就是在线程中添加一个NSport来实现的。


上面的 Source/Timer/Observer 被统称为 mode item，一个 item 可以被同时加入多个 mode。但一个 item 被重复加入同一个 mode 时是不会有效果的。如果一个 mode 中一个 item 都没有，则 RunLoop 会直接退出，不进入循环。


## RunLoop的内部逻辑

应用场景举例：主线程的 RunLoop 里有两个预置的 Mode：kCFRunLoopDefaultMode 和 UITrackingRunLoopMode。这两个 Mode 都已经被标记为”Common”属性。DefaultMode 是 App 平时所处的状态，TrackingRunLoopMode 是追踪 ScrollView 滑动时的状态。当你创建一个 Timer 并加到 DefaultMode 时，Timer 会得到重复回调，但此时滑动一个TableView时，RunLoop 会将 mode 切换为 TrackingRunLoopMode，这时 Timer 就不会被回调，并且也不会影响到滑动操作。

有时你需要一个 Timer，在两个 Mode 中都能得到回调，一种办法就是将这个 Timer 分别加入这两个 Mode。还有一种方式，就是将 Timer 加入到顶层的 RunLoop 的 “commonModeItems” 中。”commonModeItems” 被 RunLoop 自动更新到所有具有”Common”属性的 Mode 里去。


## Runloop一次loop执行过程

执行过程大致描述如下：

* 通知 observers 即将进入 run loop
* 通知 observes 即将开始处理 timer source
* 通知 observes 即将开始处理 source0 事件
* 执行 source0 事件
* 如果处于主线程有 dispatchPort 消息，跳转到第9步
* 通知 observes 线程即将进入休眠
* 内循环阻塞等待接收系统消息，包括：
* 收到内核发送过来的消息 （source1消息）
* 定时器事件需要执行
* run loop 的超时时间到了
* 手动唤醒 run loop
* 通知 observes 线程被唤醒
* 处理通过端口收到的消息：
* 如果自定义的 timer 被 fire，那么执行该 timer 事件并重新开始循环，完成后跳转到第2步
* 如果 input source 被 fire，则处理该事件
* 如果 run loop 被手动唤醒，并且没有超时，完成后跳转到第2步
* 通知 observes run loop 已经退出

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359105264831.png)

注意：

CFRunLoopDoBlocks 是执行 perform block 中的 block
绿色的是RunLoopRun()
第一次循环 CFRunLoopServiceMachPort 是不走的
handle_msg 处理 timer 事件，处理 main queue block 事件，处理 source1 事件
中间的红色CFRunLoopServiceMachPort是监听 GCD 的端口事件，只监听一个端口，左下角的CFRunLoopServiceMachPort是坚挺 source1,timer 的，是一个 MutableSet

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190203193235.png)


### NSTimer 与 GCD Timer

* NSTimer 是通过 RunLoop 的 RunLoopTimer 把时间加入到 RunLoopMode 里面。官方文档里面也有说 CFRunLoopTimer 和 NSTimer 是可以互相转换的。由于 NSTimer 的这种机制，因此 NSTimer 的执行必须依赖于 RunLoop，如果没有 RunLoop，NSTimer 是不会执行的。

* GCD 则不同，GCD 的线程管理是通过系统来直接管理的。GCD Timer 是通过 dispatch port 给 RunLoop 发送消息，来使 RunLoop 执行相应的 block，如果所在线程没有 RunLoop，那么 GCD 会临时创建一个线程去执行 block，执行完之后再销毁掉，因此 GCD 的 Timer 是不依赖 RunLoop 的。

* 至于这两个 Timer 的准确性问题，如果不再 RunLoop 的线程里面执行，那么只能使用 GCD Timer，由于 GCD Timer 是基于 MKTimer(mach kernel timer)，已经很底层了，因此是很准确的。

* 异步的回调如果存在延时操作，那么就要放到有 RunLoop 的线程里面，否则回调没有着陆点无法执行
* NSTimer 必须得在有 RunLoop 的线程里面才能执行，另外，使用 NSTimer 的时候会出现滑动 TableView，Timer 停止的问题，是由于 RunLoopMode 切换的问题，只要把 NSTimer 加到 common mode 就好了。
* 滚动过程中延迟加载，可以利用滚动时 RunLoopMode 切换到 NSEventTrackingRunLoopMode 模式下这个机制，在 Default mode 下添加加载图片的方法，在滚动时就不会触发。
* 崩溃后处理 DSSignalHandlerDemo


## RunLoop 与线程的关系

> 一般来讲，一个线程一次只能执行一个任务，执行完成后线程就会退出。如果我们需要一个机制，让线程能随时处理事件但并不退出，通常的代码逻辑是这样的：

* 每条线程都有唯一的一个与之对应的RunLoop对象
* 主线程的RunLoop已经自动创建好了，子线程的RunLoop需要主动创建，只要调用currentRunLoop方法, 系统就会自动创建一个RunLoop, 添加到当前线程中
* 线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。RunLoop 的创建是发生在第一次获取时，RunLoop 的销毁是发生在线程结束时。你只能在一个线程的内部获取其 RunLoop（主线程除外）

```swift
function loop() {
    initialize();
    do {
        var message = get_next_message();
        process_message(message);
    } while (message != quit);
}

function loop() {
    initialize();
    do {
        var message = get_next_message();
        process_message(message);
    } while (message != quit);
}
```

这种模型通常被称作 `Event Loop`。 `Event Loop` 在很多系统和框架里都有实现，比如 Node.js 的事件处理，比如 Windows 程序的消息循环，再比如 OSX/iOS 里的 RunLoop。**实现这种模型的关键点在于：如何管理事件/消息，如何让线程在没有处理消息时休眠以避免资源占用、在有消息到来时立刻被唤醒。
**
所以，RunLoop 实际上就是一个对象，这个对象管理了其需要处理的事件和消息，并提供了一个入口函数来执行上面 Event Loop 的逻辑。线程执行了这个函数后，就会一直处于这个函数内部 “接受消息->等待->处理” 的循环中，直到这个循环结束（比如传入 quit 的消息），函数返回。

首先，iOS 开发中能遇到两个线程对象: pthread_t 和 NSThread。过去苹果有份文档标明了 NSThread 只是 pthread_t 的封装，但那份文档已经失效了，现在它们也有可能都是直接包装自最底层的 mach thread。苹果并没有提供这两个对象相互转换的接口，但不管怎么样，可以肯定的是 pthread_t 和 NSThread 是一一对应的。比如，你可以通过 pthread_main_thread_np() 或 [NSThread mainThread] 来获取主线程；也可以通过 pthread_self() 或 [NSThread currentThread] 来获取当前线程。CFRunLoop 是基于 pthread 来管理的。

苹果不允许直接创建 RunLoop，它只提供了两个自动获取的函数：CFRunLoopGetMain() 和 CFRunLoopGetCurrent()。 这两个函数内部的逻辑大概是下面这样:

## AutoreleasePool & Runloop 

自动释放池的创建和释放，销毁的时机如下所示

*   kCFRunLoopEntry; // 进入runloop之前，创建一个自动释放池
*   kCFRunLoopBeforeWaiting; // 休眠之前，销毁自动释放池，创建一个新的自动释放池
*   kCFRunLoopExit; // 退出runloop之前，销毁自动释放池

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216163450.png)


### 事件响应

* 苹果注册了一个 Source1 (基于 mach port 的) 用来接收系统事件，当一个硬件事件(触摸/锁屏/摇晃等)发生后，首先由 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收。SpringBoard 只接收按键(锁屏/静音等)，触摸，加速，接近传感器等几种 Event，随后用 mach port 转发给需要的App进程。

* 随后苹果注册的那个 Source1 就会触发回调，并调用 _UIApplicationHandleEventQueue() 进行应用内部的分发。

* _UIApplicationHandleEventQueue() 会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发，其中包括识别 UIGesture/处理屏幕旋转/发送给 UIWindow 等。通常事件比如 UIButton 点击、touchesBegin/Move/End/Cancel 事件都是在这个回调中完成的。

## 手势识别 & Runloop 

当上面的 _UIApplicationHandleEventQueue() 识别了一个手势时，其首先会调用 Cancel 将当前的 touchesBegin/Move/End 系列回调打断。随后系统将对应的 UIGestureRecognizer 标记为待处理。苹果注册了一个 Observer 监测 BeforeWaiting (Loop即将进入休眠) 事件，这个Observer的回调函数是 _UIGestureRecognizerUpdateObserver()，其内部会获取所有刚被标记为待处理的 GestureRecognizer，并执行GestureRecognizer的回调。当有 UIGestureRecognizer 的变化(创建/销毁/状态改变)时，这个回调都会进行相应处理。

## 界面更新 & Runloop 

当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次时，或者手动调用了 UIView/CALayer 的 setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去。苹果注册了一个 Observer 监听 BeforeWaiting(即将进入休眠) 和 Exit (即将退出Loop) 事件，回调去执行一个很长的函数：_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()。这个函数里会遍历所有待处理的 UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面。

## 定时器 & Runloop 

NSTimer 其实就是 CFRunLoopTimerRef，他们之间是 toll-free bridged 的。一个 NSTimer 注册到 RunLoop 后，RunLoop 会为其重复的时间点注册好事件。例如 10:00, 10:10, 10:20 这几个时间点。RunLoop为了节省资源，并不会在非常准确的时间点回调这个Timer。Timer 有个属性叫做 Tolerance (宽容度)，标示了当时间点到后，容许有多少最大误差。

如果某个时间点被错过了，例如执行了一个很长的任务，则那个时间点的回调也会跳过去，不会延后执行。就比如等公交，如果 10:10 时我忙着玩手机错过了那个点的公交，那我只能等 10:20 这一趟了。

CADisplayLink 是一个和屏幕刷新率一致的定时器（但实际实现原理更复杂，和 NSTimer 并不一样，其内部实际是操作了一个 Source）。如果在两次屏幕刷新之间执行了一个长任务，那其中就会有一帧被跳过去（和 NSTimer 相似），造成界面卡顿的感觉。在快速滑动TableView时，即使一帧的卡顿也会让用户有所察觉。Facebook 开源的 AsyncDisplayLink 就是为了解决界面卡顿的问题，其内部也用到了 RunLoop

## RunLoop剖析

Run Loop Modes

1\. RunLoop mode中包含了sources、timers和observers。

2. 每次启动RunLoop都必须指定一个Mode。

3. 在RunLoop运行过程中，只有当前Mode中的事件会被处理，其他Mode中的事件会被暂停，直到该RunLoop在该Mode下运行。

4. 你可以通过name来标识Mode，name是一个字符串。

5. 你可以用你喜欢的名字来自定义一个Mode，但是为了确保这个Mode生效，你要确保至少添加一个souce或者timer或者observer到该Mode中。

6. 下表列出了Cocoa框架和Core Foundation框架中定义的标准的Mode，还有简单的描述。你可以通过Name那一列的字符串找到对应的Mode（这里我做一些改动，原文档表格中写的都是OS X中RunLoop的Mode，我改为iOS中的Mode）。

| **Mode** | **Name** | **Description** |
| --- | --- | --- |
| Default | NSDefaultRunLoopMode(Cocoa) kCFRunLoopDefaultMode (Core Foundation) | 默认Mode，APP运行起来之后，主线程的RunLoop默认在该Mode下运行 |
|  | GSEventReceiveRunLoopMode(Cocoa) | 接收系统内部事件 |
| App Init | UIInitializationRunLoopMode(Cocoa) | APP初始化的时候运行在该Mode下 |
| Event tracking | UITrackingRunLoopMode(Cocoa) | 追踪触摸手势，确保界面刷新不会卡顿，滑动tableview，scrollview等都运行在这个Mode下 |
| Common modes | NSRunLoopCommonModes(Cocoa) kCFRunLoopCommonModes (Core Foundation)  | commonModes很特殊，稍后在下一章阅读源码的时候细说 |

**事件源（Input Sources）**

1.输入源分2种，一种是内核通过端口发送消息产生的(Port-Based Sources)，另一种是开发者自定义的(Custom Input Sources)。这两种时间只在标记方面有所区别，内核消息由内核自动标记，开发者自定义的事件由开发者手动标记。

**基于内核端口的事件源（Port-Based Sources）**

1.Cocoa和Core Foundation都提供了Port-Based source的支持，比如Cocoa中的NSPort，Core Foundation中的CFMachPortRef等。

**自定义事件源（Custom Input Sources）**

1\. 使用Core Foundation中的CFRunLoopSourceRef来创建一个自定义的source。

**Perform Selector接口（Cocoa Perform Selector Sources）**

1.使用performSelector系列API往某个线程添加事件的时候，你必须要确保目标线程的RunLoop是运行的。否则该事件不会被执行，这里要格外注意一下，子线程的RunLoop不是默认启动的。

定时器（Timer Sources）

1.这里的定时器事件并一定时间到了就会执行。就像input source一样，timer需要被加入到指定的Mode中，并且RunLoop要运行在这个Mode下，timer才有效。

2.Runloop中的定时器也不是精准定时器。RunLoop是一个循环一直跑，在某次循环运行中途加入的定时器事件，只有等到下一次循环才会被执行。

观察者（Run Loop Observers）

1.RunLoop在状态改变的时候回发出通知，你可以监听这些通知来做一些有用的事情。比如在线程运行前、要休眠之前等时候做一些准备工作。

2.可以监听的RunLoop状态有这些：

*   即将进入RunLoop
*   RunLoop即将处理timer source
*   RunLoop即将处理input source
*   RunLoop即将进入休眠
*   RunLoop被唤醒，但还没开始处理事件
*   RunLoop退出

3.你可以通过Core Foundation框架中的[CFRunLoopObserverRef](https://developer.apple.com/library/mac/documentation/CoreFoundation/Reference/CFRunLoopObserverRef/index.html#//apple_ref/c/tdef/CFRunLoopObserverRef)相关API来操作observer

The Run Loop Sequence of Events

1.RunLoop每次循环的执行步骤大概如下：

1.  通知observers 已经进入RunLoop
2.  通知observes 即将开始处理timer source
3.  通知observes 即将开始处理input sources（不包括port-based source）
4.  开始处理input source（不包括port-based source）
5.  如果有port-based source待处理，则开始处理port-based source，跳转到第9步
6.  通知observes线程即将进入休眠
7.  让线程进入休眠状态，直到有以下事件发生：
    *   收到内核发送过来的消息
    *   定时器事件需要执行
    *   RunLoop的超时时间到了
    *   手动唤醒RunLoop
8.  通知observes 线程被唤醒
9.  处理待处理的事件：
    *   如果自定义的timer被fire，那么执行该timer事件并重新开始循环，跳转到第2步
    *   如果input source被fire，则处理该事件
    *   如果RunLoop被手动唤醒，并且没有超时，那么重新开始循环，跳转到第2步
10.  通知observes RunLoop已经退出

2.RunLoop可以被手动唤醒。你可以在增加一个input source之后唤醒RunLoop以确保input source可以被立即执行，而不用等到RunLoop被其他事件唤醒。


## RunLoop 作用

总结下来，RunLoop 的作用主要体现在三方面：

* 保持程序的持续运行
* 处理App中的各种事件(比如触摸事件、定时器事件、Selector事件)
* 节省CPU资源，提高程序性能：该做事的时候做事，该休息的时候休息
* 就是说，如果没有 RunLoop 程序一运行就结束了，你根本不可能看到持续运行的 app。

iOS中有2套API访问和使用RunLoop

Foundation：NSRunLoop
Core Foundation: CFRunLoopRef
NSRunLoop是基于CFRunLoopRef的一层OC包装，因此我们需要研究CFRunLoopRef层面的API(Core Foundation层面)

### 什么时候使用RunLoop？（When Would You Use a Run Loop?）

1.只有在创建一个子线程的时候，开发者才必要显式的手动的把RunLoop run起来。主线程的RunLoop是自动启动的，不需要手动run。

2.你需要考量，是否有必要开启子线程的RunLoop，可以参考以下几种情况

*   需要和其他线程通信时
*   需要在子线程中使用timer
*   使用了performSelector…系列API（比如线程初始化了之后，使用了performSelector: onThread: withObject:..让子线程执行某个任务，子线程RunLoop并没有被开启，所以检测不到该input source，这个任务就一直不会被执行）
*   需要线程持续执行某个周期性的任务

### 操作RunLoop对象（Using Run Loop Objects）

1.每个线程都对应一个RunLoop。一个RunLoop对象提供了添加、运行各种source的接口。

2.在Cocoa框架中，RunLoop对象是[NSRunLoop](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSRunLoop_Class/index.html#//apple_ref/occ/cl/NSRunLoop)类的实例，在Core Foundation框架中是指向[CFRunLoopRef](https://developer.apple.com/library/mac/documentation/CoreFoundation/Reference/CFRunLoopRef/index.html#//apple_ref/c/tdef/CFRunLoopRef)的指针。NSRunLoop是基于CFRunLoopRef的封装。

3.可以使用以下方法来获取当前线程的RunLoop:

*   使用NSRunLoop中的[currentRunLoop](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSRunLoop_Class/index.html#//apple_ref/occ/clm/NSRunLoop/currentRunLoop)函数
*   使用CFRunLoopGetCurrent函数

4.NSRunLoop和CFRunLoopRef不是toll-free的，但是NSRunLoop提供了一个getCFRunLoop函数来获取CFRunLoopRef。

5.在你打算启动一个子线程的RunLoop之前，你一定要增加至少一个input source或者timer到RunLoop中。如果RunLoop中没有任何source，它会马上退出。

6.此外，添加一个observes也可以让RunLoop不至于马上退出。你可以使用[CFRunLoopObserverRef](https://developer.apple.com/library/mac/documentation/CoreFoundation/Reference/CFRunLoopObserverRef/index.html#//apple_ref/c/tdef/CFRunLoopObserverRef)来创建observe，并使用[CFRunLoopAddObserver](https://developer.apple.com/library/mac/documentation/CoreFoundation/Reference/CFRunLoopRef/index.html#//apple_ref/c/func/CFRunLoopAddObserver)函数来添加到RunLoop中

7.是否是线程安全的取决于你用什么API来操作RunLoop。Core Foundation框架中CFRunLoop相关的API都是线程安全的，并且可以在任何线程中调用。Cocoa框架中的NSRunLoop相关的API不是线程安全的。你最好在某个线程中只操作该线程的RunLoop。如果你在线程1中用NSRunLoop的API向线程2的RunLoop添加source，可能会引起crash。

### 配置各种事件源（Configuring Run Loop Sources）

这里主要是一些如何配置input source、Port-based input source的示例代码。具体想看可以直接看文档，代码里面都带有注释。

### 常驻线程保活

**常说的AFNetworking常驻线程保活是什么原理？**
我们知道，当子线程中的任务执行完毕之后就被销毁了，那么如果我们需要开启一个子线程，在程序运行过程中永远都存在，那么我们就会面临一个问题，如何让子线程永远活着，答案就是给子线程开启一个RunLoop，下面是AFNetworking相关源码：

```objc
+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"AFNetworking"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    return _networkRequestThread;
}
```


* 使程序一直运行并接受用户输入：我们的app必然不能像命令式执行一样，执行完就退出了，我们需要app在我们不杀死它的时候**一直运行着，并在由用户事件的时候能够响应**，比如网络输入，用户点击等等，这是Runloop的首要任务；
* 决定程序在何时应该处理哪些事件：实际上程序会有很多事件，**Runloop会有一定的机制来管理时间的处理时机等**；
* **调用解耦**（Message Queue）：比方说手指点击滑动会产生UIEvent事件，对于主调方来说，我不可能等到这个事件被执行了才去产生下一个事件，也就是主调方不能被被调方卡住。那么在实际实现中，被调方会有一个消息队列，**主调方会把消息扔到消息队列中，然后不管了，消息的处理是由被调方不断去从消息队列中取消息，然后执行的。**这样的好处是主调方不需要知道消息是具体是怎么执行的，只要产生消息即可，从而实现了解耦；

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216092831.png)

如果没有RunLoop

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190203173545.png)

有了RunLoop

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190203173638.png)

## RunLoop的应用

[RunLoop在实际开发过程中的应用(二) - 简书](https://www.jianshu.com/p/46d91ae65f60)

1. UIImageView延迟加载照片
2. 线程保活
3. 子线程中执行NSTimer
4. performSelector
5. 自动释放池

  
### 让UITableView、UICollectionView等延迟加载图片。

下面就拿UITableView来举例说明： 

UITableView 的 cell 上显示网络图片，一般需要两步，第一步下载网络图片；第二步，将网络图片设置到UIImageView上。 

* 第一步，我们一般都是放在子线程中来做，这个不做赘述。 
* 第二步，一般是回到主线程去设置。有了前两篇文章关于Mode的切换，想必你已经知道怎么做了。 
就是在为图片视图设置图片时，在主线程设置，并调用performSelector:withObject:afterDelay:inModes:方法。最后一个参数，仅设置一个NSDefaultRunLoopMode。

```objc
UIImage *downloadedImage = ....;
[self.myImageView performSelector:@selector(setImage:) withObject:downloadedImage afterDelay:0 inModes:@[NSDefaultRunLoopMode]];

```
当然，即使是读取沙盒或者bundle内的图片，我们也可以运用这一点来改善视图的滑动。但是如果UITableView上的图片都是默认图，似乎也不是很好，你需要自己来权衡了。



#### 线程保活

可能你的项目中需要一个线程，一直在后台做些耗时操作，但是不影响主线程，我们不要一直大量的创建和销毁线程，因为这样太浪费性能了，我们只要保留这个线程，只要对他进行“保活”就行

```
//继承了一个NSTread 线程，然后使用vc中创建和执行某个任务，查看线程的情况
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    WXThread *thread = [[WXThread alloc] initWithTarget:self
                                               selector:@selector(doSomeThing)
                                                 object:nil];
    [thread start];
}
- (void)doSomeThing{
    NSLog(@"doSomeThing");
}

```

```
//每一次点击屏幕的时候，线程执行完方法，直接释放掉了，下一次创建了一个新的线程；
//子线程存活的时间很短，只要执行完毕任务，就会被释放
2017-04-19 16:03:10.686 WXAllTest[14928:325108] doSomeThing
2017-04-19 16:03:10.688 WXAllTest[14928:325108] WXTread - dealloc - <WXThread: 0x600000276780>{number = 3, name = (null)}
2017-04-19 16:03:18.247 WXAllTest[14928:325194] doSomeThing
2017-04-19 16:03:18.249 WXAllTest[14928:325194] WXTread - dealloc - <WXThread: 0x608000271340>{number = 4, name = (null)}
2017-04-19 16:03:23.780 WXAllTest[14928:325236] doSomeThing
2017-04-19 16:03:23.781 WXAllTest[14928:325236] WXTread - dealloc - <WXThread: 0x608000270e00>{number = 5, name = (null)}

```

如果我每隔一段时间就像在线程中执行某个操作，好像现在不行
如果我们将线程对象强引用，也是不行的，会崩溃

```objc
1.成为基本属性
/** 线程对象 */
@property(strong,nonatomic)  WXThread *thread;

2.创建线程之后，直接将入到RunLoop中
- (void)viewDidLoad {
    [super viewDidLoad];
    _thread = [[WXThread alloc] initWithTarget:self
                                      selector:@selector(doSomeThing)
                                        object:nil];
    [_thread start];
}

3.执行doSomeThing函数
- (void)doSomeThing{
    //一定要加入一个timer，port，或者是obervers，否则RunLoop启动不起来
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

4.在点击屏幕的时候，执行一个方法，线程之间的数据通信

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(test) onThread:_thread withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
}

5.将test方法写清楚
- (void)test{
    NSLog(@"current thread - %@",[NSThread currentThread]);
}

//打印结果:同一个线程，线程保活成功
2017-04-19 18:21:07.660 WXAllTest[16145:382366] current thread - <WXThread: 0x60800007c180>{number = 3, name = (null)}
2017-04-19 18:21:07.843 WXAllTest[16145:382366] current thread - <WXThread: 0x60800007c180>{number = 3, name = (null)}
2017-04-19 18:21:08.015 WXAllTest[16145:382366] current thread - <WXThread: 0x60800007c180>{number = 3, name = (null)}
2017-04-19 18:21:08.194 WXAllTest[16145:382366] current thread - <WXThread: 0x60800007c180>{number = 3, name = (null)}
2017-04-19 18:21:08.398 WXAllTest[16145:382366] current thread - <WXThread: 0x60800007c180>{number = 3, name = (null)}
2017-04-19 18:21:08.598 WXAllTest[16145:382366] current thread - <WXThread: 0x60800007c180>{number = 3, name = (null)}
2017-04-19 18:21:08.770 WXAllTest[16145:382366] current thread - <WXThread: 0x60800007c180>{number = 3, name = (null)}

```

## RunLoop 实战

### 滚动scrollview导致定时器失效

* 产生的原因：因为当你滚动textview的时候，runloop会进入UITrackingRunLoopMode 模式，而定时器运行在defaultMode下面，**系统一次只能处理一种模式的runloop**，所以导致defaultMode下的定时器失效。

* 解决办法1：把定时器的runloop的model改为NSRunLoopCommonModes 模式，这个模式是一种占位mode，并不是真正可以运行的mode，它是用来标记一个mode的。默认情况下default和tracking这两种mode 都会被标记上NSRunLoopCommonModes 标签。改变定时器的mode为commonMode，可以让定时器运行在defaultMode和trackingModel两种模式下，不会出现滚动scrollview导致定时器失效的故障

```objc
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
```

* 解决办法2： 使用GCD创建定时器，**GCD创建的定时器不会受runloop的影响**

```objc 
// 获得队列
dispatch_queue_t queue = dispatch_get_main_queue();

// 创建一个定时器(dispatch_source_t本质还是个OC对象)
self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

// 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
// GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
// 比当前时间晚1秒开始执行
dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));

//每隔一秒执行一次
uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
dispatch_source_set_timer(self.timer, start, interval, 0);

// 设置回调
dispatch_source_set_event_handler(self.timer, ^{
NSLog(@"------------%@", [NSThread currentThread]);

});

// 启动定时器
dispatch_resume(self.timer);
```

### 图片下载

由于图片渲染到屏幕需要消耗较多资源，为了提高用户体验，当用户滚动tableview的时候，**只在后台下载图片，但是不显示图片，当用户停下来的时候才显示图片**。

```objc
- (void)viewDidLoad { 
[super viewDidLoad];
 self.thread = [[XMGThread alloc] initWithTarget:self selector:@selector(run) object:nil][self.thread start]; 
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
[self performSelector:@selector(useImageView) onThread:self.thread withObject:nil waitUntilDone:NO]; }

- (void)useImageView { 
    // 只在NSDefaultRunLoopMode模式下显示图片 
    [self.imageView performSelector:@selector(setImage:) withObject:
    [UIImage imageNamed:@"placeholder"] afterDelay:3.0 
    inModes:@[NSDefaultRunLoopMode]]; 
}
```

* 上面的代码可以达到如下效果：用户点击屏幕，在主线程中，三秒之后显示图片，但是当用户点击屏幕之后，如果此时用户又开始滚动textview，那么就算过了三秒，图片也不会显示出来，当用户停止了滚动，才会显示图片。

* 这是因为限定了方法setImage只能在NSDefaultRunLoopMode 模式下使用。而滚动textview的时候，程序运行在tracking模式下面，所以方法setImage不会执行。

### 常驻线程

* 需要创建一个在后台一直存在的程序，来做一些需要频繁处理的任务。比如检测网络状态等。**默认情况一个线程创建出来，运行完要做的事情，线程就会消亡**。而程序启动的时候，就创建的主线程已经加入到runloop，所以主线程不会消亡。这个时候我们就需要把自己创建的线程加到runloop中来，就可以实现线程常驻后台。

* 如果没有实现添加NSPort或者NSTimer，会发现执行完run方法，线程就会消亡，后续再执行touchbegan方法无效。我们必须保证线程不消亡，才可以在后台接受时间处理

RunLoop 启动前内部必须要有至少一个 Timer/Observer/Source，所以在 [runLoop run] 之前先创建了一个新的 NSMachPort 添加进去了。通常情况下，调用者需要持有这个 NSMachPort (mach_port) 并在外部线程通过这个 port 发送消息到 loop 内；但此处添加 port 只是为了让 RunLoop 不至于退出，并没有用于实际的发送消息。

可以发现执行完了run方法，这个时候再点击屏幕，可以不断执行test方法，因为线程self.thread一直常驻后台，等待事件加入其中，然后执行。

### 在所有UI相应操作之前处理任务

比如我们点击了一个按钮，在ui关联的事件开始执行之前，我们需要执行一些其他任务，可以在observer中实现

![btnClikc](https://github.com/miaoqiu/RunLoop/raw/master/883F2856-D3FD-4093-84AF-00BD3C35917F.png)

可以看到在按钮点击之前，先执行的observe方法里面的代码。这样可以拦截事件，让我们的代码先UI事件之前执行。


### Demo代码

```swift
//
//  ViewController.swift
//  RunLoop
//shui
//  Created by 邱淼 on 16/8/31.
//  Copyright © 2016年 txcap. All rights reserved.
//
import UIKit
import Foundation
class ViewController: UIViewController {
    
     var thread :NSThread?
    let runTextView = UIScrollView()
    let btn = UIButton()
    
 
      override func viewDidLoad() {
              super.viewDidLoad()
        runTextView.frame = CGRectMake(100, 100, 200, 300)
        runTextView.backgroundColor = UIColor.redColor()
        self.view.addSubview(runTextView)
        btn.frame = CGRectMake(100, 0, 100, 100)
        btn.backgroundColor = UIColor.yellowColor()
        btn.addTarget(self, action: #selector(ViewController.btnclick), forControlEvents: .TouchUpInside)
        self.view.addSubview(btn)
        self.observer()
  
//        self.thread = NSThread.init(target: self, selector:#selector(ViewController.run), object: nil)
//         self.thread?.start()
      }
//*****************************************************在所有UI相应操作之前处理任务**********************
    func btnclick() {
    
      
        print("点击了Btn")
        
    }
    
    
    func observer()  {
    
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,CFRunLoopActivity.AllActivities.rawValue , true, 0) { (observer, activity) in
            print("监听到RunLoop状态发生变化----\(activity)")
        }
        
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode)
        
    }
        
//*****************************************************常驻线程**********************
     func run() {
        
        print("run===========\(NSThread.currentThread())")
        //方法一
//        NSRunLoop.currentRunLoop().addPort(NSPort.init(), forMode:NSDefaultRunLoopMode)
        //方法二
//        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
        //方法三
//        NSRunLoop.currentRunLoop().runUntilDate(NSDate.distantFuture())
        //方法四 添加NSTimer
//        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(ViewController.test), userInfo: nil, repeats: true)
//        
     
//        NSRunLoop.currentRunLoop().run()
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//         self.performSelector(#selector(ViewController.test), onThread: self.thread!, withObject: nil, waitUntilDone: false)
//        
//    }
//    
//    func test()  {
//             print("test---------------\(NSThread.currentThread())")
//     }
//    
    /*
     如果没有实现添加NSPort或者NSTimer，会发现执行完run方法，线程就会消亡，后续再执行touchbegan方法无效。
     
     我们必须保证线程不消亡，才可以在后台接受时间处理
     
     RunLoop 启动前内部必须要有至少一个 Timer/Observer/Source，所以在 [runLoop run] 之前先创建了一个新的 NSMachPort 添加进去了。通常情况下，调用者需要持有这个 NSMachPort (mach_port) 并在外部线程通过这个 port 发送消息到 loop 内；但此处添加 port 只是为了让 RunLoop 不至于退出，并没有用于实际的发送消息。
     
     可以发现执行完了run方法，这个时候再点击屏幕，可以不断执行test方法，因为线程self.thread一直常驻后台，等待事件加入其中，然后执行。
 */
    
//*****************************************************常驻线程**********************
        
 //*****************************************************图片下载**********************
 
//    
//    //由于图片渲染到屏幕需要消耗较多资源，为了提高用户体验，当用户滚动tableview的时候，只在后台下载图片，但是不显示图片，当用户停下来的时候才显示图片。
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//        self.performSelector(#selector(ViewController.userImageView), onThread: self.thread!, withObject: nil, waitUntilDone: false)
//        
//    }
//    
//    func userImageView()  {
//    
   self.imageView.performSelector(#selector(ViewController.setImage), withObject: UIImage(named: "qiyerongzi"), afterDelay: 3, inModes:[NSDefaultRunLoopMode])
//        
//    }
//    
//    //设置图片
//    func setImage()  {
 
//        self.imageView.image = UIImage(named: "tianxingjiangtang")
//        
//    }
//    
//    /*
//     上面的代码可以达到如下效果：
//     
//     用户点击屏幕，在主线程中，三秒之后显示图片
//     
//     但是当用户点击屏幕之后，如果此时用户又开始滚动textview，那么就算过了三秒，图片也不会显示出来，当用户停止了滚动，才会显示图片。
//     
//     这是因为限定了方法setImage只能在NSDefaultRunLoopMode 模式下使用。而滚动textview的时候，程序运行在tracking模式下面，所以方法setImage不会执行。
// */
//    
//    
//*****************************************************图片下载**********************
    
    
    /**
     解决滚动scrollView导致定时器失效
     */
    func scrollerTimer()  {
        //RunLoop 解决滚动scrollView导致定时器失效
        //原因：因为当你滚动textview的时候，runloop会进入UITrackingRunLoopMode 模式，而定时器运行在defaultMode下面，系统一次只能处理一种模式的runloop，所以导致defaultMode下的定时器失效。
        //解决办法1：把定时器的runloop的model改为NSRunLoopCommonModes 模式，这个模式是一种占位mode，并不是真正可以运行的mode，它是用来标记一个mode的。默认情况下default和tracking这两种mode 都会被标记上NSRunLoopCommonModes 标签。改变定时器的mode为commonmodel，可以让定时器运行在defaultMode和trackingModel两种模式下，不会出现滚动scrollview导致定时器失效的故障
        //[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        //解决办法2：使用GCD创建定时器，GCD创建的定时器不会受runloop的影响
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
```


## 参考

1. [miaoqiu/RunLoop: 深入理解RunLoop](https://github.com/miaoqiu/RunLoop/blob/master/README.md)
2. [深入理解RunLoop | Garan no dou](https://blog.ibireme.com/2015/05/18/runloop/)
3. [RunLoop运行循环机制 - 博客吧](http://www.blogs8.cn/posts/A4Ib785)
4. [深入理解 RunLoop | 独 奏](https://honglu.me/2017/03/30/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3RunLoop/)
5. [孙源的Runloop视频整理 - 简书](https://www.jianshu.com/p/519baeebf35b#3%E3%80%81Runloop%E7%9A%84%E5%B0%81%E8%A3%85%E7%BB%93%E6%9E%84)
