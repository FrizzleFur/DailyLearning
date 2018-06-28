# Multithreading多线程

* 常见多线程在项目中的应用？
* 多线程的死锁
* 控制并发线程的数量： 多线程的信号量`dispatch_semaphore`
* 线程的异步
* 任务进行分块： `dispatch_group_notify`.
* iOS使用dispatch_group实现分组并发网络请求

## 多任务分块

```objc
dispatch_group_enter(group)和dispatch_group_leave(group)，这种方式使用更为灵活，enter和leave必须配合使用，有几次enter就要有几次leave

dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求1
        [网络请求:{
        成功：dispatch_group_leave(group);
        失败：dispatch_group_leave(group);
}];
    });
    dispatch_group_enter;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求2
        [网络请求:{
        成功：dispatch_group_leave;
        失败：dispatch_group_leave;
}];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求3
        [网络请求:{
        成功：dispatch_group_leave(group);
        失败：dispatch_group_leave(group);
}];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //界面刷新
        NSLog(@"任务均完成，刷新界面");
    });
dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

```

参考[iOS使用dispatch_group实现分组并发网络请求 - 简书](https://www.jianshu.com/p/657e994aeee2)

###  信号量

`dispatch_semaphore`

信号量就是一个资源计数器，对信号量有两个操作来达到互斥，分别是P和V操作。 一般情况是这样进行临界访问或互斥访问的： 设信号量值为1， 当一个进程1运行是，使用资源，进行P操作，即对信号量值减1，也就是资源数少了1个。这是信号量值为0。

系统中规定当信号量值为0是，必须等待，知道信号量值不为零才能继续操作。 这时如果进程2想要运行，那么也必须进行P操作，但是此时信号量为0，所以无法减1，即不能P操作，也就阻塞。这样就到到了进程1排他访问。 当进程1运行结束后，释放资源，进行V操作。资源数重新加1，这是信号量的值变为1. 这时进程2发现资源数不为0，信号量能进行P操作了，立即执行P操作。信号量值又变为0.次数进程2咱有资源，排他访问资源。 这就是信号量来控制互斥的原理

> * 如果一个线程等待一个信号量`dispatch_semaphore_wait`，线程会被阻塞，直到计数器>0，此时开始运行，并且对信号量减1。
> * 0表示没有资源, dispatch_semaphore_create会返回NULL,调用dispatch_semaphore_wait会立即等待。
> * 当一个信号量被通知`dispatch_semaphore_signal`，是发送一个信号，自然会让信号总量加1；
> Calls to dispatch_semaphore_signal must be balanced with calls to dispatch_semaphore_wait. Attempting to dispose of a semaphore with a count lower than value causes an EXC_BAD_INSTRUCTION exception.对 dispatch_semaphore_signal 的呼叫必须与对 dispatch_semaphore_wait 的呼叫保持平衡。试图用低于值的计数来处理信号量会导致 EXC_BAD_INSTRUCTION 异常。

参考[浅谈GCD中的信号量 - 简书](https://www.jianshu.com/p/04ca5470f212)

##### 创建信号量

```
// 值得注意的是，这里的传入的参数value必须大于或等于0，否则dispatch_semaphore_create会返回NULL
dispatch_semaphore_t dispatch_semaphore_create(long value);
```

##### 等待

```
// 返回0：表示正常。返回非0：表示等待时间超时
long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout);
```

##### 信号通知

```
long dispatch_semaphore_signal(dispatch_semaphore_t dsema);
```

这样我们就可以根据 初始值 ，来控制可以有多少个并发的线程在运行。关于信号量，可以用停车位来比喻，如果停车场有5个停车位，都停满了，如果此时来了第6辆车，就需要等待，信号量的值就相当于`剩余的车位的数量`。dispatch_semaphore_wait函数就相当于来了一辆车，dispatch_semaphore_signal就相当于走了一辆车。

dispatch_semaphore_wait中的参数timeout表示超时时间，如果等待期间没有获取到信号量或者信号量的值一直为0，那么等到timeout时，其所处线程自动执行其后语句。可取值为：`DISPATCH_TIME_NOW`和 `DISPATCH_TIME_FOREVER`，我们也可以自己设置一个dispatch_time_t的时间值，表示超时时间为这个时间之后。

> *   **DISPATCH_TIME_NOW**：超时时间为0，表示忽略信号量，直接运行
> *   ** DISPATCH_TIME_FOREVER**：超时时间为永远，表示会一直等待信号量为正数，才会继续运行

#### 例子

![](http://oc98nass3.bkt.clouddn.com/15301534187605.jpg)
信号量的初始值设置为：1，即最多只能又一个线程在run，可以验证一下运行结果，除去最开始的三个，后面的是每三秒打印一个，并且保证运行的顺序按照添加的顺序。

![](http://oc98nass3.bkt.clouddn.com/15301534397789.jpg)

如果把创建信号量的值设置为4，即最多可以有4个线程同时运行，来看一下运行结果，是每三秒同时打印四个，且顺序不能保证。
![](http://oc98nass3.bkt.clouddn.com/15301535632720.jpg)



## 其他


GCD执行任务的方法并非只有简单的同步调用方法和异步调用方法，还有其他一些常用方法：

* dispatch_apply():重复执行某个任务，但是注意这个方法没有办法异步执行（为了不阻塞线程可以使用dispatch_async()包装一下再执行）。
* dispatch_once():单次执行一个任务，此方法中的任务只会执行一次，重复调用也没办法重复执行（单例模式中常用此方法）。
* dispatch_time()：延迟一定的时间后执行。
* dispatch_barrier_async()：使用此方法创建的任务首先会查看队列中有没有别的任务要执行，如果有，则会等待已有任务执行完毕再执行；同时在此方法后添加的任务必须等待此方法中任务执行后才能执行。（利用这个方法可以控制执行顺序，例如前面先加载最后一张图片的需求就可以先使用这个方法将最后一张图片加载的操作添加到队列，然后调用dispatch_async()添加其他图片加载任务）
* dispatch_group_async()：实现对任务分组管理，如果一组任务全部完成可以通过dispatch_group_notify()方法获得完成通知（需要定义dispatch_group_t作为分组标识）。



## NSLock

iOS中对于资源抢占的问题可以使用同步锁NSLock来解决，使用时把需要加锁的代码（以后暂时称这段代码为”加锁代码“）放到NSLock的lock和unlock之间，一个线程A进入加锁代码之后由于已经加锁，另一个线程B就无法访问，只有等待前一个线程A执行完加锁代码后解锁，B线程才能访问加锁代码。需要注意的是lock和unlock之间的”加锁代码“应该是**抢占资源的读取和修改**代码，不要将过多的其他操作代码放到里面，否则一个线程执行的时候另一个线程就一直在等待，就无法发挥多线程的作用了。

另外，在上面的代码中”抢占资源“_imageNames定义成了成员变量，这么做是不明智的，应该定义为“原子属性”。对于被抢占资源来说将其定义为原子属性是一个很好的习惯，因为有时候很难保证同一个资源不在别处读取和修改。nonatomic属性读取的是内存数据（寄存器计算好的结果），而atomic就保证直接读取寄存器的数据，这样一来就不会出现一个线程正在修改数据，而另一个线程读取了修改之前（存储在内存中）的数据，永远保证同时只有一个线程在访问一个属性。

下面的代码演示了如何使用NSLock进行线程同步：


```objc
KCMainViewController.h

//
//  KCMainViewController.h
//  MultiThread
//
//  Created by Kenshin Cui on 14-3-22.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
// #import <UIKit/UIKit.h> @interface KCMainViewController : UIViewController

@property (atomic,strong) NSMutableArray *imageNames;
@end

KCMainViewController.m

//
//  线程同步
//  MultiThread
//
//  Created by Kenshin Cui on 14-3-22.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
// #import "KCMainViewController.h" #import "KCImageData.h" #define ROW_COUNT 5 #define COLUMN_COUNT 3 #define ROW_HEIGHT 100 #define ROW_WIDTH ROW_HEIGHT #define CELL_SPACING 10 #define IMAGE_COUNT 9

@interface KCMainViewController (){
    NSMutableArray *_imageViews;
    NSLock *_lock;
}

@end

@implementation KCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self layoutUI];
} #pragma mark 界面布局
-(void)layoutUI{ //创建多个图片控件用于显示图片 _imageViews=[NSMutableArray array]; for (int r=0; r<ROW_COUNT; r++) { for (int c=0; c<COLUMN_COUNT; c++) {
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(c*ROW_WIDTH+(c*CELL_SPACING), r*ROW_HEIGHT+(r*CELL_SPACING                           ), ROW_WIDTH, ROW_HEIGHT)];
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            [self.view addSubview:imageView];
            [_imageViews addObject:imageView];

        }
    }

    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(50, 500, 220, 25);
    [button setTitle:@"加载图片" forState:UIControlStateNormal]; //添加方法 [button addTarget:self action:@selector(loadImageWithMultiThread) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button]; //创建图片链接 _imageNames=[NSMutableArray array]; for (int i=0; i<IMAGE_COUNT; i++) {
        [_imageNames addObject:[NSString stringWithFormat:@"http://images.cnblogs.com/cnblogs_com/kenshincui/613474/o_%i.jpg",i]];
    } //初始化锁对象 _lock=[[NSLock alloc]init];

} #pragma mark 将图片显示到界面
-(void)updateImageWithData:(NSData *)data andIndex:(int )index{
    UIImage *image=[UIImage imageWithData:data];
    UIImageView *imageView= _imageViews[index];
    imageView.image=image;
} #pragma mark 请求图片数据
-(NSData *)requestData:(int )index{
    NSData *data;
    NSString *name; //加锁 [_lock lock]; if (_imageNames.count>0) {
        name=[_imageNames lastObject];
        [_imageNames removeObject:name];
    } //使用完解锁 [_lock unlock]; if(name){
        NSURL *url=[NSURL URLWithString:name];
        data=[NSData dataWithContentsOfURL:url];
    } return data;
} #pragma mark 加载图片
-(void)loadImage:(NSNumber *)index{ int i=[index integerValue]; //请求数据 NSData *data= [self requestData:i]; //更新UI界面,此处调用了GCD主线程队列的方法 dispatch_queue_t mainQueue= dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        [self updateImageWithData:data andIndex:i];
    });
} #pragma mark 多线程下载图片
-(void)loadImageWithMultiThread{ int count=ROW_COUNT*COLUMN_COUNT;

    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); //创建多个线程用于填充图片 for (int i=0; i<count; ++i) { //异步执行队列任务 dispatch_async(globalQueue, ^{
            [self loadImage:[NSNumber numberWithInt:i]];
        });
    }

}
@end
```

### @synchronized代码块

使用`@synchronized`解决线程同步问题相比较NSLock要简单一些，日常开发中也更推荐使用此方法。首先选择一个对象作为同步对象（一般使用self），然后将”加锁代码”（争夺资源的读取、修改代码）放到代码块中。@synchronized中的代码执行时先检查同步对象是否被另一个线程占用，如果占用该线程就会处于等待状态，直到同步对象被释放。下面的代码演示了如何使用@synchronized进行线程同步：


```objc
-(NSData *)requestData:(int )index{
    NSData *data;
    NSString *name; //线程同步 @synchronized(self){ if (_imageNames.count>0) {
            name=[_imageNames lastObject];
            [NSThread sleepForTimeInterval:0.001f];
            [_imageNames removeObject:name];
        }
    } if(name){
        NSURL *url=[NSURL URLWithString:name];
        data=[NSData dataWithContentsOfURL:url];
    } return data;
}

```


## 扩展--使用GCD解决资源抢占问题

在GCD中提供了一种信号机制，也可以解决资源抢占问题（和同步锁的机制并不一样）。GCD中信号量是dispatch_semaphore_t类型，支持信号通知和信号等待。每当发送一个信号通知，则信号量+1；每当发送一个等待信号时信号量-1,；如果信号量为0则信号会处于等待状态，直到信号量大于0开始执行。根据这个原理我们可以初始化一个信号量变量，默认信号量设置为1，每当有线程进入“加锁代码”之后就调用信号等待命令（此时信号量为0）开始等待，此时其他线程无法进入，执行完后发送信号通知（此时信号量为1），其他线程开始进入执行，如此一来就达到了线程同步目的。


```objc
//
//  GCD实现多线程--消息信号
//  MultiThread
//
//  Created by Kenshin Cui on 14-3-22.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//

#import "KCMainViewController.h"
#import "KCImageData.h"
#define ROW_COUNT 5
#define COLUMN_COUNT 3
#define ROW_HEIGHT 100
#define ROW_WIDTH ROW_HEIGHT
#define CELL_SPACING 10
#define IMAGE_COUNT 9

@interface KCMainViewController (){
    NSMutableArray *_imageViews;
    NSLock *_lock;
    dispatch_semaphore_t _semaphore;//定义一个信号量
}

@end

@implementation KCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

#pragma mark 界面布局
-(void)layoutUI{
    //创建多个图片控件用于显示图片
    _imageViews=[NSMutableArray array];
    for (int r=0; r<ROW_COUNT; r++) {
        for (int c=0; c<COLUMN_COUNT; c++) {
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(c*ROW_WIDTH+(c*CELL_SPACING), r*ROW_HEIGHT+(r*CELL_SPACING                           ), ROW_WIDTH, ROW_HEIGHT)];
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            [self.view addSubview:imageView];
            [_imageViews addObject:imageView];
            
        }
    }
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(50, 500, 220, 25);
    [button setTitle:@"加载图片" forState:UIControlStateNormal];
    //添加方法
    [button addTarget:self action:@selector(loadImageWithMultiThread) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //创建图片链接
    _imageNames=[NSMutableArray array];
    for (int i=0; i<IMAGE_COUNT; i++) {
        [_imageNames addObject:[NSString stringWithFormat:@"http://images.cnblogs.com/cnblogs_com/kenshincui/613474/o_%i.jpg",i]];
    }
    
    /*初始化信号量
     参数是信号量初始值
     */
    _semaphore=dispatch_semaphore_create(1);
    
}

#pragma mark 将图片显示到界面
-(void)updateImageWithData:(NSData *)data andIndex:(int )index{
    UIImage *image=[UIImage imageWithData:data];
    UIImageView *imageView= _imageViews[index];
    imageView.image=image;
}

#pragma mark 请求图片数据
-(NSData *)requestData:(int )index{
    NSData *data;
    NSString *name;
    
    /*信号等待
     第二个参数：等待时间
     */
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if (_imageNames.count>0) {
        name=[_imageNames lastObject];
        [_imageNames removeObject:name];
    }
    //信号通知
    dispatch_semaphore_signal(_semaphore);

    
    if(name){
        NSURL *url=[NSURL URLWithString:name];
        data=[NSData dataWithContentsOfURL:url];
    }
    
    return data;
}

#pragma mark 加载图片
-(void)loadImage:(NSNumber *)index{
    int i=[index integerValue];
    //请求数据
    NSData *data= [self requestData:i];
    //更新UI界面,此处调用了GCD主线程队列的方法
    dispatch_queue_t mainQueue= dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        [self updateImageWithData:data andIndex:i];
    });
}

#pragma mark 多线程下载图片
-(void)loadImageWithMultiThread{
    int count=ROW_COUNT*COLUMN_COUNT;
//    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    //这里创建一个并发队列（使用全局并发队列也可以）
    dispatch_queue_t queue=dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i=0; i<count; i++) {
        dispatch_async(queue, ^{
            [self loadImage:[NSNumber numberWithInt:i]];
        });
    }
}

@end
```

运行效果与前面使用同步锁是一样的。


##  参考

1. [iOS开发系列--并行开发其实很容易 - KenshinCui - 博客园](http://www.cnblogs.com/kenshincui/p/3983982.html)
2. [dispatch_semaphore控制并发线程数 - 简书](https://www.jianshu.com/p/a5e75df26d9c)
3. [浅谈GCD中的信号量 - 简书](https://www.jianshu.com/p/04ca5470f212)
4. [iOS使用dispatch_group实现分组并发网络请求 - 简书](https://www.jianshu.com/p/657e994aeee2)
