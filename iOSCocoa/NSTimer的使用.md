# NSTimer的使用
　　
　　一、什么是NSTimer

　　官方给出解释是“A timer provides a way to perform a delayed action or a periodic action. The timer waits until a certain time interval has elapsed and then fires, sending a specified message to a specified object. ” 翻译过来就是timer就是一个能在从现在开始的后面的某一个时刻或者周期性的执行我们指定的方法的对象。

二、NSTimer和它调用的函数对象间到底发生了什么

 　　从前面官方给出的解释可以看出timer会在未来的某个时刻执行一次或者多次我们指定的方法，这也就牵扯出一个问题，如何保证timer在未来的某个时刻触发指定事件的时候，我们指定的方法是有效的呢？


昨天有个小伙伴问我NSTimer有很多种创建方式，他们有什么区别吗?其实想想NSTimer有8种创建方式，但是总的说起来就三种timerWithTimeInterval、scheduledTimerWithTimeInterval和initWithFireDate，但是又细分起来就两种，一种是需要手动加入NSRunLoop，一种是自动加入NSRunLoop中。NSTimer的八种方法如下：


```objc
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
 
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block 
 
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;
 
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
 
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
 
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;
 
- (instancetype)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(nullable id)ui repeats:(BOOL)rep;
 
- (instancetype)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

```


# 方法介绍

## 1.timerWithTimeInterval

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

Interval:设置时间间隔,以秒为单位,一个>0的浮点类型的值，如果该值<0,系统会默认为0.1 

target:表示发送的对象，如self 

selector:方法选择器，在时间间隔内，选择调用一个实例方法 

userInfo:此参数可以为nil，当定时器失效时，由你指定的对象保留和释放该定时器。 

repeats:当YES时，定时器会不断循环直至失效或被释放，当NO时，定时器会循环发送一次就失效。 

使用示例：

```objc
NSTimer *timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerRequest) userInfo:nil repeats:YES];    [[NSRunLoop currentRunLoop] addTimer:timer1 forMode:NSRunLoopCommonModes]; - (void)timerRequest{    NSLog(@"定时器开始。。。");}
```

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block 

block:使用block的方法就直接在block里面写延时后要执行的代码就可以了

使用示例： 

```objc
NSTimer *timer2 = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {        NSLog(@"定时器开始。。。");    }];    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSRunLoopCommonModes];
```

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;

invocation:需要执行的方法

使用示例：

```objc
NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(timerRequest)];    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: sgn];    [invocation setTarget: self];    [invocation setSelector:@selector(timerRequest)];    NSTimer *timer3 = [NSTimer timerWithTimeInterval:1.0 invocation:invocation repeats:YES];    [[NSRunLoop currentRunLoop] addTimer:timer3 forMode:NSRunLoopCommonModes];
```

## 2.scheduledTimerWithTimeInterval

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

使用示例：

```objc
NSTimer *timer4 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerRequest) userInfo:nil repeats:YES];
```

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

使用示例：

```objc
NSTimer *timer5 = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {        NSLog(@"定时器开始。。。");    }];
```

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;

使用示例：

```objc
NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(timerRequest)];    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: sgn];    [invocation setTarget: self];    [invocation setSelector:@selector(timerRequest)];    NSTimer *timer6 = [NSTimer scheduledTimerWithTimeInterval:1.0 invocation:invocation repeats:YES];
```

## 3.initWithFireDate

- (instancetype)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(nullable id)ui repeats:(BOOL)rep;

使用示例：

```objc
NSTimer *timer7 = [[NSTimer alloc]initWithFireDate:[NSDate distantPast] interval:1.0 target:self selector:@selector(timerRequest) userInfo:nil repeats:YES];    [[NSRunLoop mainRunLoop]addTimer:timer7 forMode:NSDefaultRunLoopMode];
```

- (instancetype)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

使用示例： 

```objc
NSTimer *timer8 = [[NSTimer alloc]initWithFireDate:[NSDate distantPast] interval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {        NSLog(@"定时器开始。。。");    }];
```

参数说明：

```objc
启动定时器
[NSDate distantPast];
停止定时器
[NSDate distantFuture];
```



## 例子总结

从上面的栗子我们可以看出，通过`timerWithTimeInterval`和`initWithFireDate`方法创建出来的定时器，都需要手动加入到RunLoop中才会执行，否则不会执行；但是通过`scheduledTimerWithTimeInterval`创建出来的定时器是自动加入到RunLoop，而且会自动执行。



## NSTimer会准时触发事件吗

答案是否定的，而且有时候你会发现实际的触发时间跟你想象的差距还比较大。NSTimer不是一个实时系统，因此不管是一次性的还是周期性的timer的实际触发事件的时间可能都会跟我们预想的会有出入。差距的大小跟当前我们程序的执行情况有关系，**比如可能程序是多线程的，而你的timer只是添加在某一个线程的runloop的某一种指定的runloopmode中，由于多线程通常都是分时执行的，而且每次执行的mode也可能随着实际情况发生变化**。

假设你添加了一个timer指定2秒后触发某一个事件，但是恰好那个时候当前线程在执行一个连续运算(例如大数据块的处理等)，这个时候timer就会延迟到该连续运算执行完以后才会执行。**重复性的timer遇到这种情况，如果延迟超过了一个周期，则会和后面的触发进行合并，即在一个周期内只会触发一次。但是不管该timer的触发时间延迟的有多离谱，他后面的timer的触发时间总是倍数于第一次添加timer的间隙**。
原文如下“A repeating timer reschedules itself based on the scheduled firing time, not the actual firing time. For example, if a timer is scheduled to fire at a particular time and every 5 seconds after that, the scheduled firing time will always fall on the original 5 second time intervals, even if the actual firing time gets delayed. If the firing time is delayed so far that it passes one or more of the scheduled firing times, the timer is fired only once for that time period; the timer is then rescheduled, after firing, for the next scheduled firing time in the future.”
下面请看一个简单的例子:

3. NSTimer为什么要添加到RunLoop中才会有作用
前面的例子中我们使用的是一种便利方法，它其实是做了两件事：首先创建一个timer，然后将该timer添加到当前runloop的default mode中。也就是这个便利方法给我们造成了只要创建了timer就可以生效的错觉，我们当然可以自己创建timer，然后手动的把它添加到指定runloop的指定mode中去。

NSTimer其实也是一种资源，如果看过多线程文档的话，我们会发现所有的source如果要起作用，就得加到runloop中去。**同理timer这种资源要想起作用，那肯定也需要加到runloop中才会有效。如果一个runloop里面不包含任何资源的话，运行该runloop时会立马退出**。你可能会说那我们APP的主线程的runloop我们没有往其中添加任何资源，为什么它还好好的运行。我们不添加，不代表框架没有添加，如果有兴趣的话你可以打印一下main thread的runloop，你会发现有很多资源。

4.NSTimer加到了RunLoop中但迟迟的不触发事件
a.runloop是否运行
每一个线程都有它自己的runloop，程序的主线程会自动的使runloop生效，但对于我们自己新建的线程，它的runloop是不会自己运行起来，当我们需要使用它的runloop时，就得自己启动。
那么如果我们把一个timer添加到了非主线的runloop中，它还会按照预期按时触发吗？下面请看一段测试程序:
测试把timer加到不运行的runloop上的情况

```objc
- (void)SimpleExampleThree{    NSLog(@"定时器开始创建");    NSTimer *timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerRequest) userInfo:nil repeats:YES];    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];    self.timer = timer1;    NSLog(@"定时器创建完成");}
```

运行结果

![](https://img-blog.csdn.net/20170414112509874?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvdTAxNDIyMDUxOA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
解决办法：

```objc
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        //创建定时器    });	
```

b.mode是否正确
我们前面自己动手添加runloop的时候，可以看到有一个参数runloopMode，这个参数是干嘛的呢？
前面提到了要想timer生效，我们就得把它添加到指定runloop的指定mode中去，通常是主线程的defalut mode。但有时我们这样做了，却仍然发现timer还是没有触发事件。这是为什么呢？
这是因为timer添加的时候，我们需要指定一个mode，因为同一线程的runloop在运行的时候，任意时刻只能处于一种mode。所以只能当程序处于这种mode的时候，timer才能得到触发事件的机会。
举个不恰当的例子，我们说兄弟几个分别代表runloop的mode，timer代表他们自己的才水桶，然后一群人去排队打水，只有一个水龙头，那么同一时刻，肯定只能有一个人处于接水的状态。也就是说你虽然给了老二一个桶，但是还没轮到它，那么你就得等，只有轮到他的时候你的水桶才能碰上用场。



### 循环引用

NSTimer在构造函数会对target强引用，在调用invalidate时，会移除去target的强引用

```objc
NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));

NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerTest:) userInfo:@"ghi" repeats:YES];

NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));

[timer invalidate];

NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
输出如下
2017-05-09 10:41:45.071 NSTimerTest[6861:914021] Retain count is 6
2017-05-09 10:41:46.056 NSTimerTest[6861:914021] Retain count is 7
2017-05-09 10:41:47.848 NSTimerTest[6861:914021] Retain count is 6
NSTimer被加到Runloop的时候，会被runloop强引用持有，在调用invalidate的时候，会从runloop删除

NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerTest:) userInfo:@"ghi" repeats:YES];

NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)timer));

[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)timer));

[timer invalidate];

NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)timer));

```




6. NSTimer准确性
通常我们使用NSTimer的时候都是在主线程使用的，主线程负责很多复杂的操作，例如UI处理，UI时间响应，并且iOS上的主线程是优先响应UI事件的，而NSTimer的优先级较低，有时候NSTimer的触发并不准确，例如当我们在滑动UIScrollView的时候，NSTimer就会延迟触发，主线优先响应UI的操作，只有UIScrollView停止了才触发NSTimer的事件
解决方案
NSTimer加入到runloop默认的Mode为NSDefaultRunLoopMode， 我们需要手动设置Mode为NSRunLoopCommonModes
这时候，NSTimer即使在UI持续操作过程中也能得到触发，当然，会降低流畅度

NSTimer触发是不精确的，如果由于某些原因错过了触发时间，例如执行了一个长时间的任务，那么NSTimer不会延后执行，而是会等下一次触发，相当于等公交错过了，只能等下一趟车，tolerance属性可以设置误差范围

NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerTest:) userInfo:nil repeats:YES];
// 误差范围1s内
timer.tolerance = 1;
如果对精度有要求，可以使用GCD的定时器



# [GCD实现多个定时器，完美避过NSTimer的三大缺陷（RunLoop、Thread、Leaks）](https://www.cnblogs.com/beckwang0912/p/7027484.html)

定时器在我们每个人做的iOS项目里面必不可少，如登录页面倒计时、支付期限倒计时等等，一般来说使用NSTimer创建定时器：

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo; + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

**But** 使用NSTimer需要注意一下几点：

      1、必须保证有一个活跃的RunLoop。

     系统框架提供了几种创建NSTimer的方法，其中以scheduled开头的方法会自动把timer加入当前RunLoop，到了设定时间就会触发selector方法，而没有scheduled开头的方法则需要手动添加timer到一个RunLoop中才会有效。程序启动时，会默认启动主线程的RunLoop并在程序运行期内有效，所以把timer放入主线程时不需要启动RunLoop，但现实开发中主线程更多的是处理UI事物，把耗时且耗能的操作放在子线程中，这就需要将子线程的RunLoop激活。

     我们不难知道RunLoop在运行时一般有两个:NSDefaultRunLoopMode、NSEventTrackingRunLoopMode，scheduled生成的timer会默认添加到NSDefaultRunLoopMode，当某些UI事件发生时，如页面滑动RunLoop切换到NSEventTrackingRunLoopMode运行，我们会发现定时器失效，为了解决timer失效的问题，我们需要在scheduled一个定时器的时候，设置它的运行模式为：

[[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];

     注意：NSRunLoopCommonModes并不是一种正在存在的运行状态，这个模式等效于NSDefaultRunLoopMode和NSEventTrackingRunLoopMode的结合，相当于它标记了timer可以在这两种模式下都有效。

     2.NSTimer的创建与撤销必须在同一个线程操作，不能跨越线程操作。

     3.存在内存泄漏的风险（这个问题需要引起重视）

     scheduledTimerWithTimeInterval方法将target设为A对象时，A对象会被这个timer所持有，也就是会被retain一次，timer又会被当前的runloop所持有。使用NSTimer时，timer会保持对target和userInfo参数的强引用。只有当调取了NSTimer的invalidate方法时，NSTimer才会释放target和userInfo。生成timer的方法中如果repeats参数为NO，则定时器触发后会自动调取invalidate方法。如果repeats参数为YES，则需要手动调取invalidate方法才能释放timer对target和userIfo的强引用。

    - (void)cancel{
          [_timer invalidate];
           _timer = nil;
     }

    这里要特别注意的一点是，按照各种资料显示，我们在销毁或者释放对象时，大部分都是在dealloc方法中，然后我们高高兴兴的在dealloc里写上

- (void)dealloc{
         [self cancel];
    }

   以为这样就可以释放timer了，不幸的是，dealloc方法永远不会被调用。因为timer的引用，对象A的引用计数永远不会降到0，这时如果不调用cancel，对象X将永远无法释放，造成内存泄露。**所以我建议在使用定时器的事件完成后立即将timer进行cancel，如果是比较长时间的定时器，可以在页面消失事件中调用**，如：

   - (void)viewWillDisappear:(BOOL)animated{
       [super viewWillDisappear:animated];
       [self cancel];
   }

   看到这里，你会不会发现使用NSTimer实现定时器这么麻烦，又是RunLoop，又是线程的，一会儿还得考虑内存泄露，So , 如果在一个页面需要同时显示多个计时器的时候，NSTimer简直就是灾难了。那么有没有高逼格的办法实现呢？答案就是GCD!  以下5点是使用dispatch_source_t创建timer的主要知识点：

   1.获取全局子线程队列 

 dispatch_queue_t  queue ＝ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

   2.创建timer添加到队列中

dispatch_source_t  timer =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    3.设置首次执行事件、执行间隔和精确度

dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);

   4.处理事件block

    dispatch_source_set_event_handler(timer, ^{ // doSomething()
    });

    5.激活timer ／ 取消timer

dispatch_resume(timer);   ／    dispatch_source_cancel(timer);

     写到这里，自然要问如果我只是想执行一次，不需要循环实现定时器那怎么办呢？那也没问题，参考NSTimer,我们可以集成repeats选项，当repeats = No时，在激活timer并回调block事件后dispatch_source_cancel掉当前dispatch_source_t  timer即可，如下所示：      

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0); "复制代码")

- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(double)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(ActionOption)option
                                action:(dispatch_block_t)action{ if (nil == timerName) return; if (nil == queue)
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_source_t timer = [self.timerContainer objectForKey:timerName]; if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [self.timerContainer setObject:timer forKey:timerName];
    } /* timer精度为0.1秒 */ dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);

    __weak typeof(self) weakSelf = self; switch (option) { case AbandonPreviousAction:
        { /* 移除之前的action */ [weakSelf removeActionCacheForTimer:timerName];

            dispatch_source_set_event_handler(timer, ^{
                action(); if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        } break; case MergePreviousAction:
        { /* cache本次的action */ [self cacheAction:action forTimer:timerName];

            dispatch_source_set_event_handler(timer, ^{
                NSMutableArray *actionArray = [self.actionBlockCache objectForKey:timerName];
                [actionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    dispatch_block_t actionBlock = obj;
                    actionBlock();
                }];
                [weakSelf removeActionCacheForTimer:timerName]; if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        } break;
    }
} - (void)cancelTimerWithName:(NSString *)timerName{

    dispatch_source_t timer = [self.timerContainer objectForKey:timerName]; if (!timer) { return;
    }

    [self.timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);

    [self.actionBlockCache removeObjectForKey:timerName];
}

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0); "复制代码")

    上面的代码就创建了一个timer，如果repeats ＝ NO，在一个周期完成后，系统会自动cancel掉这个timer；如果repeats=YES，那么timer会一个周期接一个周期的执行，直到你手动cancel掉这个timer，你可以在dealloc方法里面做cancel，这样timer恰好运行于整个对象的生命周期中。这里不必要担心NSTimer因dealloc始终无法调而产生的内存泄漏问题，你也可以通过queue参数控制这个timer所添加到的线程，也就是action最终执行的线程。传入nil则会默认放到子线程中执行。UI相关的操作需要传入dispatch_get_main_queue()以放到主线程中执行。

    写到这里，基本上可以满足开发要求，然而我们可以更加变态，假设这样的场景，每次开始新一次的计时前，需要取消掉上一次的计时任务 或者 将上一次计时的任务，合并到新的一次计时中，最终一并执行！针对这两种场景，也已经集成到上面的接口scheduleGCDTimerWithName中。具体代码请看demo！

github地址：[https://github.com/BeckWang0912/ZTGCDTimer](https://github.com/BeckWang0912/ZTGCDTimer)  如果文章对您有帮助的话，请star，谢谢！ [](http://www.baidu.com/)


#### 定时器不准时的问题及解决
通过上文的叙述，我们大致了解了定时器不准时的原因，总结一下主要是

当前RunLoop过于繁忙
RunLoop模式与定时器所在模式不同
上面解释了GCD更加准时的原因，所以解决方案也不难得出:

避免过多耗时操作并发
采用GCD定时器
创建新线程并开启RunLoop，将定时器加入其中(适度使用)
将定时器添加到NSRunLoopCommonModes(使用不当会阻塞UI响应)



1、纳秒级精度的Timer
使用mach_absolute_time()来实现更高精度的定时器。
iPhone上有这么一个均匀变化的东西来提供给我们作为时间参考，就是CPU的时钟周期数（ticks）。
通过mach_absolute_time()获取CPU已运行的tick数量。将tick数经过转换变成秒或者纳秒，从而实现时间的计算。

以下代码实现来源于网络：

#include <mach/mach.h>
#include <mach/mach_time.h>
 
static const uint64_t NANOS_PER_USEC = 1000ULL;
static const uint64_t NANOS_PER_MILLISEC = 1000ULL * NANOS_PER_USEC;
static const uint64_t NANOS_PER_SEC = 1000ULL * NANOS_PER_MILLISEC;
 
static mach_timebase_info_data_t timebase_info;

static uint64_t nanos_to_abs(uint64_t nanos) {
    return nanos * timebase_info.denom / timebase_info.numer;
}

void waitSeconds(int seconds) {
    mach_timebase_info(&timebase_info);
    uint64_t time_to_wait = nanos_to_abs(seconds * NANOS_PER_SEC);
    uint64_t now = mach_absolute_time();
    mach_wait_until(now + time_to_wait);
}
理论上这是iPhone上最精准的定时器，可以达到纳秒级别的精度，但是怎样去验证呢？

由于日志的输出需要消耗时间，CPU线程之间的调度也需要消耗时间，所以无法从Log中输出的系统时间来验证其更高的精度，根据我测试的系统时间来看，时间偏差也是在1毫秒以内。

2、CADisplayLink
CADisplayLink是一个频率能达到屏幕刷新率的定时器类。iPhone屏幕刷新频率为60帧/秒，也就是说最小间隔可以达到1/60s。

基本使用：

CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(logInfo)];
[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];


## 参考

1. [NSTimer你真的会用了吗 - 一片-枫叶 - 博客园](https://www.cnblogs.com/smileEvday/archive/2012/12/21/NSTimer.html)
2. [iOS-NSTimer的前世今生（NSTimer不同创建方式的区别） - CSDN博客](https://blog.csdn.net/u014220518/article/details/70170006)
3. [GCD实现多个定时器，完美避过NSTimer的三大缺陷（RunLoop、Thread、Leaks） - 贝克的飞机 - 博客园](https://www.cnblogs.com/beckwang0912/p/7027484.html)
4. [iOS趣味篇：NSTimer到底准不准？ - 简书](https://www.jianshu.com/p/d5845842b7d3)