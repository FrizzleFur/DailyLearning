# KVO解析.md


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190214152631.png)

* 监听方法本质:并不需要修改方法的实现,仅仅想判断下有没有调用
* KV0的本质就是监听一个对象有没有调用set方法，重写这个方法 
* 修改当前对象的isa指针,指向自定义子类
* 在添加观察者的时候，观察者对象与被观察属性所属的对象都不会被retain，然而在这些对象被释放后，相关的监听信息却还存在，KVO做的处理是直接让程序崩溃。
* addObserver:forKeyPath:options:context:方法,调用这个方法时，两个对象(即观察者对象及属性所属的对象)都不会被retain。
* 可以多次调用addObserver:forKeyPath:options:context:方法，将同一个对象注册为同一属性的观察者(所有参数可以完全相同)。这时，即便在所有参数一致的情况下，新注册的观察者并不会替换原来观察者，而是会并存。这样，当属性被修改时，两次监听都会响应
* 可以看到KVO为每次注册都调用了一次监听处理操作。所以多次调用同样的注册操作会产生多个观察者。另外，多个观察者之间的observeValueForKeyPath:ofObject:change:context:方法调用顺序是按照先进后出的顺序来的(所有的监听信息都是放在一个数组中的，我们将在下面了解到)。




## Apple用什么方式实现对一个对象的KVO？

[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)对 KVO 实现的描述：

> Automatic key-value observing is implemented using a technique called isa-swizzling... When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class ...

从[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)可以看出：Apple 并不希望过多暴露 KVO 的实现细节。不过，要是借助 runtime 提供的方法去深入挖掘，所有被掩盖的细节都会原形毕露：

> **当你观察一个对象时，一个新的类会被动态创建。这个类继承自该对象的原本的类，并重写了被观察属性的 setter 方法。重写的 setter 方法会负责在调用原 setter 方法之前和之后，通知所有观察对象值的更改**。最后通过 `isa 混写（isa-swizzling）` 把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例。我画了一张示意图，如下所示：

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15335303051090.jpg)

# 一、KVO是什么？

* KVO 是 Objective-C 对观察者设计模式的一种实现。【另外一种是：通知机制（notification）】；
* KVO提供一种机制，指定一个被观察对象(例如A类)，当对象某个属性(例如A中的字符串name)发生更改时，监听对象会获得通知，并作出相应处理；【且不需要给被观察的对象添加任何额外代码，就能使用KVO机制】
* 在MVC设计架构下的项目，KVO机制很适合实现mode模型和view视图之间的通讯。

例如：代码中，在模型类A创建属性数据，在控制器中创建观察者，一旦属性数据发生改变就收到观察者收到通知，通过KVO再在控制器使用回调方法处理实现视图B的更新；

> Apple 使用了 `isa 混写（isa-swizzling）`来实现 KVO 。

下面做下详细解释：

键值观察通知依赖于 NSObject 的两个方法: `willChangeValueForKey:` 和 `didChangevlueForKey:` 。在一个被观察属性发生改变之前， `willChangeValueForKey:` 一定会被调用，这就会记录旧的值。而当改变发生后， `observeValueForKey:ofObject:change:context:` 会被调用，继而 `didChangeValueForKey:` 也会被调用。可以手动实现这些调用，但很少有人这么做。一般我们只在希望能控制回调的调用时机时才会这么做。大部分情况下，改变通知会自动调用。

比如调用 `setNow:` 时，系统还会以某种方式在中间插入 `wilChangeValueForKey:` 、 `didChangeValueForKey:` 和 `observeValueForKeyPath:ofObject:change:context:` 的调用。大家可能以为这是因为 `setNow:` 是合成方法，有时候我们也能看到有人这么写代码:

```source-objc
- (void)setNow:(NSDate *)aDate {
   [self willChangeValueForKey:@"now"]; // 没有必要
   _now = aDate;
   [self didChangeValueForKey:@"now"];// 没有必要
}
```

这完全没有必要，不要这么做，这样的话，KVO代码会被调用两次。KVO在调用存取方法之前总是调用 `willChangeValueForKey:` ，之后总是调用 `didChangeValueForkey:` 。怎么做到的呢?答案是通过 isa 混写（isa-swizzling）。第一次对一个对象调用 `addObserver:forKeyPath:options:context:` 时，框架会创建这个类的新的 KVO 子类，并将被观察对象转换为新子类的对象。在这个 KVO 特殊子类中， Cocoa 创建观察属性的 setter ，大致工作原理如下:

```source-objc
- (void)setNow:(NSDate *)aDate {
   [self willChangeValueForKey:@"now"];
   [super setValue:aDate forKey:@"now"];
   [self didChangeValueForKey:@"now"];
}
```

这种继承和方法注入是在运行时而不是编译时实现的。这就是正确命名如此重要的原因。只有在使用KVC命名约定时，KVO才能做到这一点。

## KV0底层实现


* 自定义NSKVONotifying_ Person子类
* 重写setName,在内部恢复父类做法,通知观察者
* 如何让外界调用自定义Person类的子类方法，修改当前对象的isa指针,指向NSKVONotifying_Person


KVO 在实现中通过 `isa 混写（isa-swizzling）` 把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例。这在[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)可以得到印证：

> Automatic key-value observing is implemented using a technique called isa-swizzling... When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class ...

然而 KVO 在实现中使用了 `isa 混写（ isa-swizzling）` ，这个的确不是很容易发现：Apple 还重写、覆盖了 `-class` 方法并返回原来的类。 企图欺骗我们：这个类没有变，就是原本那个类。。。

但是，假设“被监听的对象”的类对象是 `MYClass` ，有时候我们能看到对 `NSKVONotifying_MYClass` 的引用而不是对 `MYClass`的引用。借此我们得以知道 Apple 使用了 `isa 混写（isa-swizzling）`。具体探究过程可参考[ 这篇博文 ](https://www.mikeash.com/pyblog/friday-qa-2009-01-23.html)。

那么 `wilChangeValueForKey:` 、 `didChangeValueForKey:` 和 `observeValueForKeyPath:ofObject:change:context:` 这三个方法的执行顺序是怎样的呢？

`wilChangeValueForKey:` 、 `didChangeValueForKey:` 很好理解，`observeValueForKeyPath:ofObject:change:context:`的执行时机是什么时候呢？

先看一个例子：

代码已放在仓库里。

```source-objc
- (void)viewDidLoad {
   [super viewDidLoad];
   [self addObserver:self forKeyPath:@"now" options:NSKeyValueObservingOptionNew context:nil];
   NSLog(@"1");
   [self willChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
   NSLog(@"2");
   [self didChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
   NSLog(@"4");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   NSLog(@"3");
}

```

![enter image description here](https://camo.githubusercontent.com/154f30ca6e4fbb77af74b8186057b7f7c96221ff/687474703a2f2f6936362e74696e797069632e636f6d2f6e636d3774682e6a7067)

如果单单从下面这个例子的打印上，

顺序似乎是 `wilChangeValueForKey:` 、 `observeValueForKeyPath:ofObject:change:context:` 、 `didChangeValueForKey:` 。

其实不然，这里有一个 `observeValueForKeyPath:ofObject:change:context:` , 和 `didChangeValueForKey:` 到底谁先调用的问题：如果 `observeValueForKeyPath:ofObject:change:context:` 是在 `didChangeValueForKey:` 内部触发的操作呢？ 那么顺序就是： `wilChangeValueForKey:` 、 `didChangeValueForKey:` 和 `observeValueForKeyPath:ofObject:change:context:`

不信你把 `didChangeValueForKey:` 注视掉，看下 `observeValueForKeyPath:ofObject:change:context:` 会不会执行。

了解到这一点很重要，正如 [46\. 如何手动触发一个value的KVO](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8B%EF%BC%89.md#46-%E5%A6%82%E4%BD%95%E6%89%8B%E5%8A%A8%E8%A7%A6%E5%8F%91%E4%B8%80%E4%B8%AAvalue%E7%9A%84kvo) 所说的：

“手动触发”的使用场景是什么？一般我们只在希望能控制“回调的调用时机”时才会这么做。

而“回调的调用时机”就是在你调用 `didChangeValueForKey:` 方法时。


## KVC与KVO的不同

KVC(键值编码)，即Key-Value Coding，一个非正式的Protocol，使用字符串(键)访问一个对象实例变量的机制。而不是通过调用Setter、Getter方法等显式的存取方式去访问。
KVO(键值监听)，即Key-Value Observing，它提供一种机制,当指定的对象的属性被修改后,对象就会接受到通知，前提是执行了setter方法、或者使用了KVC赋值。

## 和notification(通知)的区别

notification比KVO多了发送通知的一步。
两者都是一对多，但是对象之间直接的交互，notification明显得多，需要notificationCenter来做为中间交互。而KVO如我们介绍的，设置观察者->处理属性变化，至于中间通知这一环，则隐秘多了，只留一句“交由系统通知”，具体的可参照以上实现过程的剖析。

notification的优点是监听不局限于属性的变化，还可以对多种多样的状态变化进行监听，监听范围广，例如键盘、前后台等系统通知的使用也更显灵活方便。

*   推荐文章：[通知机制](https://link.jianshu.com?t=http://www.cnblogs.com/azuo/p/5416825.html)

## 与delegate的不同

和delegate一样，KVO和NSNotification的作用都是类与类之间的通信。但是与delegate不同的是：
这两个都是负责发送接收通知，剩下的事情由系统处理，所以不用返回值；而delegate 则需要通信的对象通过变量(代理)联系；
delegate一般是一对一，而这两个可以一对多。

## 处理属性修改通知


当被监听的属性修改时，KVO会发出一个通知以告知所有监听这个属性的观察者对象。而观察者对象必须实现

-observeValueForKeyPath:ofObject:change:context:方法，来对属性修改通知做相应的处理。这个方法的声明如下：

```objc

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context

```

这个方法有四个参数，描述如下：

* keyPath：即被观察的属性，与参数object相关。
* object：keyPath所属的对象。
* change：这是一个字典，它包含了属性被修改的一些信息。这个字典中包含的值会根据我们在添加观察者时设置的options参数的不同而有所不同。
* context：这个值即是添加观察者时提供的上下文信息。
* 在我们的示例中，这个方法的实现是打印一些基本的信息。如代码清单1所示。

对于第三个参数，我们通常称之为变化字典(Change Dictionary)，它记录了被监听属性的变化情况。我们可以通过以下key来获取我们想要的信息：


```objc
// 属性变化的类型，是一个NSNumber对象，包含NSKeyValueChange枚举相关的值
NSString *const NSKeyValueChangeKindKey;
// 属性的新值。当NSKeyValueChangeKindKey是 NSKeyValueChangeSetting，
// 且添加观察的方法设置了NSKeyValueObservingOptionNew时，我们能获取到属性的新值。
// 如果NSKeyValueChangeKindKey是NSKeyValueChangeInsertion或者NSKeyValueChangeReplacement，
// 且指定了NSKeyValueObservingOptionNew时，则我们能获取到一个NSArray对象，包含被插入的对象或
// 用于替换其它对象的对象。
NSString *const NSKeyValueChangeNewKey;
// 属性的旧值。当NSKeyValueChangeKindKey是 NSKeyValueChangeSetting，
// 且添加观察的方法设置了NSKeyValueObservingOptionOld时，我们能获取到属性的旧值。
// 如果NSKeyValueChangeKindKey是NSKeyValueChangeRemoval或者NSKeyValueChangeReplacement，
// 且指定了NSKeyValueObservingOptionOld时，则我们能获取到一个NSArray对象，包含被移除的对象或
// 被替换的对象。
NSString *const NSKeyValueChangeOldKey;
// 如果NSKeyValueChangeKindKey的值是NSKeyValueChangeInsertion、NSKeyValueChangeRemoval
// 或者NSKeyValueChangeReplacement，则这个key对应的值是一个NSIndexSet对象，
// 包含了被插入、移除或替换的对象的索引
NSString *const NSKeyValueChangeIndexesKey;
// 当指定了NSKeyValueObservingOptionPrior选项时，在属性被修改的通知发送前，
// 会先发送一条通知给观察者。我们可以使用NSKeyValueChangeNotificationIsPriorKey
// 来获取到通知是否是预先发送的，如果是，获取到的值总是@(YES)
NSString *const NSKeyValueChangeNotificationIsPriorKey;

```


其中，NSKeyValueChangeKindKey的值取自于NSKeyValueChange，它的值是由以下枚举定义的：

```objc
enum {
	// 设置一个新值。被监听的属性可以是一个对象，也可以是一对一关系的属性或一对多关系的属性。
   	NSKeyValueChangeSetting = 1,
   	
   	// 表示一个对象被插入到一对多关系的属性。
   	NSKeyValueChangeInsertion = 2,
   	
   	// 表示一个对象被从一对多关系的属性中移除。
   	NSKeyValueChangeRemoval = 3,
   	
   	// 表示一个对象在一对多的关系的属性中被替换
   	NSKeyValueChangeReplacement = 4
};
typedef NSUInteger NSKeyValueChange;

```


# 二、kvo简单使用

### 1:注册观察者，实施监听；

*   被观察对象必须能支持kvc机制——所有NSObject的子类都支持这个机制
*   必须用 被观察对象 的 addObserver:forKeyPath:options:context: 方法注册观察者
*   观察者 必须实现 observeValueForKeyPath:ofObject:change:context: 方法

```
[self.model addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];

- observer 指观察者

- keyPath 表示被观察者的属性

- options 决定了提供给观察者change字典中的具体信息有哪些。 【见options解析】

- context 这个参数可以是一个 C指针，也可以是一个 对象引用，它可以作为这个context的唯一标识，也可以提供一些数据给观察者。因为你传进去是啥，回调时候还是回传的还是啥

```

#### ：options解析

```
typedef NS_OPTIONS(NSUInteger, NSKeyValueObservingOptions) {
    表示监听对象的新值（变化后的值），change字典中会包含有该key的键值对，通过该key，就可以取到属性变化后的值
    NSKeyValueObservingOptionNew = 0x01,

    表示监听对象的旧值（变化前的值），change字典中会包含有该key的键值对，通过该key，就可以取到属性变化前的值
    NSKeyValueObservingOptionOld = 0x02,

    在注册观察者的方法return的时候就会发出一次通知。比如：在viewDidLoad中注册的监听，那viewDidLoad方法运行完，通知就发出去了
    NSKeyValueObservingOptionInitial NS_ENUM_AVAILABLE(10_5, 2_0) = 0x04,

    会在值发生改变前发出一次通知，当然改变后的通知依旧还会发出，也就是每次change都会有两个通知
    NSKeyValueObservingOptionPrior NS_ENUM_AVAILABLE(10_5, 2_0) = 0x08
};
```


## 键值监听KVO


	• KVO提供一种机制，指定一个被观察对象(例如A类)，当对象某个属性(例如A中的字符串name)发生更改时，监听对象会获得通知，并作出相应处理；【且不需要给被观察的对象添加任何额外代码，就能使用KVO机制】
在MVC设计架构下的项目，KVO机制很适合实现mode模型和view视图之间的通讯。

我们知道在WPF、Silverlight中都有一种双向绑定机制，如果数据模型修改了之后会立即反映到UI视图上，类似的还有如今比较流行的基于 MVVM设计模式的前端框架，例如Knockout.js。其实在ObjC中原生就支持这种机制，它叫做Key Value Observing（简称KVO）。KVO其实是一种观察者模式，利用它可以很容易实现视图组件和数据模型的分离，当数据模型的属性值改变之后作为监听器 的视图组件就会被激发，激发时就会回调监听器自身。在ObjC中要实现KVO则必须实现NSKeyValueObServing协议，不过幸运的是 NSObject已经实现了该协议，因此几乎所有的ObjC对象都可以使用KVO。
在ObjC中使用KVO操作常用的方法如下：
	• 注册指定Key路径的监听器： addObserver: forKeyPath: options:  context:
	• 删除指定Key路径的监听器： removeObserver: forKeyPath、removeObserver: forKeyPath: context:
	• 回调监听： observeValueForKeyPath: ofObject: change: context:
 

```objc
//  GoodsSortView.m
static NSString * const WJSortKeyPathContentOffset = @"contentOffset"; //kvo

static CGFloat const hiddenSortViewTime = 0.3;//动画时间
static CGFloat const scrollVelocity = 900;//拖动速度

#pragma mark - KVO监听
- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [scrollView addObserver:self forKeyPath:WJSortKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers {
    [scrollView removeObserver:self forKeyPath:WJSortKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.userInteractionEnabled || self.hidden) return;
    if ([keyPath isEqualToString:WJSortKeyPathContentOffset]) {
        NSValue *oldValue = change[NSKeyValueChangeOldKey];
        CGFloat oldY = [oldValue CGPointValue].y; //旧值
        CGFloat newY = scrollView.contentOffset.y ; //新值
        if (newY == oldY) return;
        if (newY < oldY) {  //往下拖动
		 //过滤在控件不在顶部隐藏的时候
            if (self.top != scrollView.top - self.height) return;
            UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer; //获取scrollView的平移手势
            CGPoint velocity = [pan velocityInView:pan.view];//获取scrollView的平移手势的平移速度
		   // 过滤 内容已偏下的时候 &  为达标的平移速度，
            if (scrollView.contentOffset.y > self.height && velocity.y <= scrollVelocity) return;
            [UIView animateWithDuration:hiddenSortViewTime animations:^{
                self.top = scrollView.top;//显示隐藏控件
            }];
        }else {//往上拖动
		 //过滤往上偏移未超过控件高度，& 控件收缩的时候
            if (scrollView.contentOffset.y <= self.height || self.top != scrollView.top) return;
		 //超过了就保持在顶部，
            [UIView animateWithDuration:hiddenSortViewTime animations:^{
                self.top = scrollView.top - self.height;//收缩隐藏控件
            }];
        }
    }
}
# 
```

	1. 这两个判断很给力

```objc
        //过滤在控件不在顶部隐藏的时候
            if (self.top != scrollView.top - self.height) return;

            if (scrollView.contentOffset.y <= self.height || self.top != scrollView.top) return;
		 //超过了就保持在顶部，
```

#### KVO的使用步骤：

	1. 通过addObserver: forKeyPath: options: context:为被监听对象（它通常是数据模型）注册监听器
	2. 重写监听器的observeValueForKeyPath: ofObject: change: context:方法
 
由于我们还没有介绍过IOS的界面编程，这里我们还是在上面的例子基础上继续扩展，假设当我们的账户余额balance变动之后我们希望用户可以及 时获得通知。那么此时Account就作为我们的被监听对象，需要Person为它注册监听（使用addObserver: forKeyPath: options: context:）;而人员Person作为监听器需要重写它的observeValueForKeyPath: ofObject: change: context:方法，当监听的余额发生改变后会回调监听器Person监听方法（observeValueForKeyPath: ofObject: change: context:）。下面通过代码模拟上面的过程：

```objc
  Account.h 
#import <Foundation/Foundation.h> 
@interface Account : NSObject
#pragma mark - 属性
#pragma mark 余额
@property (nonatomic,assign) float balance;
@end

Account.m
#import "Account.h"
 
@implementation Account
 
@end
```

```objc
Person.h
 
#import <Foundation/Foundation.h>
@class Account;
 
@interface Person : NSObject{
@private
    int _age;
}
#pragma mark - 属性
#pragma mark 姓名
@property (nonatomic,copy) NSString *name;
#pragma mark 账户
@property (nonatomic,retain) Account *account;
 
#pragma mark - 公共方法
#pragma mark 显示人员信息
-(void)showMessage;
@end

Person.m
  Person.m
  KVCAndKVO
 #import "Person.h"
#import "Account.h"
 
@implementation Person
#pragma mark - 公共方法
#pragma mark 显示人员信息
-(void)showMessage{
 
    NSLog(@"name=%@,age=%d",_name,_age);
}

#pragma mark 设置人员账户
-(void)setAccount:(Account *)account{
    _account=account;
 
    添加对Account的监听
    [self.account addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionNew context:nil];
}
 
#pragma mark - 覆盖方法
#pragma mark 重写observeValueForKeyPath方法，当账户余额变化后此处获得通知
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
 
    if([keyPath isEqualToString:@"balance"]){//这里只处理balance属性
        NSLog(@"keyPath=%@,object=%@,newValue=%.2f,context=%@",keyPath,object,[[change objectForKey:@"new"] floatValue],context);
 
    }
}
 
#pragma mark 重写销毁方法
-(void)dealloc{
    [self.account removeObserver:self forKeyPath:@"balance"]; 移除监听
    [super dealloc]; 注意启用了ARC，此处不需要调用
}
@end
 
main.m
 
#import <Foundation/Foundation.h>
#import "Person.h"
#import "Account.h"
 
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Person *person1=[[Person alloc]init];
        person1.name=@"Kenshin";
        Account *account1=[[Account alloc]init];
        account1.balance=100000000.0;
        person1.account=account1;
        
        account1.balance=200000000.0; 注意执行到这一步会触发监听器回调函数observeValueForKeyPath: ofObject: change: context:
结果：keyPath=balance,object=<Account: 0x100103aa0>,newValue=200000000.00,context=(null)
        
    }
    return 0;
}

```

在上面的代码中我们在给人员分配账户时给账户的balance属性添加了监听，并且在监听回调方法中输出了监听到的信息，同时在对象销毁时移除监听，这就构成了一个典型的KVO应用。

### 注意

* `setValue：forKey：`中key的参数只能够是`NSString`类型，而`setObject：forKey：`的可以是任何类型
这个是不对的，`setValue：forKey`和`setObject：forKey`都可以是`objectType`。

在使用NSMutableDictionary的时候经常会使用setValue forKey与setObject forKey，他们经常是可以交互使用的，代码中经常每一种的使用都有。
1.先看看`setValue： forKey：`的定义

扩展NSMutableDictionary的一个类别，上面注释说的很清楚，发送setObject:forKey 给接收者，也就是调用setObject:forKey方法，除非value为nil的时候，调用方法removeObject:forKey
2.看看setObject：forKey：的定义

注意：setObject：forKey：中Key的对象是一个id类型，并不是NSString，只不过我们经常使用NSString而已。
3.总结两者的区别：

* setObject：forked：中object是不能够为nil的，不然会报错。
* setValue：forKey：中value能够为nil，但是当value为nil的时候，会自动调用removeObject：forKey方法
* setValue：forKey：中key的参数只能够是NSString类型，而setObject：forKey：的可以是任何类型
注意：setObject：forKey：对象不能存放nil要与下面的这种情况区分：


```
[imageDictionary setObject:[NSNullnull] forKey:indexNumber];
```

[NSNull null]表示的是一个空对象，并不是nil，注意这点
setObject：forKey：中Key是NSNumber对象的时候，如下：

```
[imageDictionary setObject:obj forKey:[NSNumber numberWithInt：10]];
```

上面说的区别是针对调用者是dictionary而言的。setObject:forKey:方法`NSMutabledictionary`特有的,`而setValue:forKey`:方法是KVC（键-值编码）的主要方法。
当 setValue:forKey:方法调用者是对象的时候： setValue:forKey:方法是在NSObject对象中创建的，也就是说所有的oc对象都有这个方法，所以可以用于任何类。
4.使用:

```
SomeClass *someObj = [[SomeClass alloc] init];
[someObj setValue:self forKey:@"delegate"];
```

表示的意思是：对象someObj设置他的delegate属性的值为当前类，当然调用此方法的对象必须要有delegate属性才能设置，不然调用了也没效果


### KVO

顾名思义，键值观察就是说当某个属性发生变化，其对应的值也发生变化。它一般用于单个 object 内部的情况。举个具体的例子，ViewController 一开始 UIImageView 没有图片的时候，我们用 activityIndicator 显示加载状态，当 Network 下载好图片并给 UIImageView 赋值之后，我们停止 activityIndicator 的加载状态。也就是说我们观察 image 这个属性，当它由 nil 变成非 nil 时，程序作出关闭 activityIndicator 动画的相应操作


所以基本流程如下：

ViewController 给 UIImageView 添加 activityIndicator，启动动画效果
ViewController 观察 UIImageView 的 image 属性
ViewController 通过上面提到的跨 object 通知，从 Network 里下载 image，并给 UIImageView 赋值
ViewController 观察到 UIImageView 的 image 属性已经被赋值，所以启动相应方法，关闭 activityIndicator 的动画
这里我们可以看出来，这是针对单个 object 的某个属性变化而设计出来的通知框架。所以我们不妨用 extension 的形式对 NSObject 添加通知方法。

```objectivec
extension NSObject {
  /* 注册观察
   * observer：说明谁是观察者，此例中是 UIImageView
   * property: 指出被观察的属性，此例中是 UIImageView 中的 image
   * options：通知中应该传递的信息，比如 UIImageView 中新的 image 信息
   */
  func add​Observer(observer: NSObject, property: String, ​options: ObservingOptions) 

  /* 响应观察
   * property: 指出被观察的属性，此例中是 UIImageView 中的 image
   * object: 观察属性对应的 object，此例中是 UIImageView
   * change: 表明属性的相应变化，如果表示任何变化都可以接受，可以传入 nil
   */
  func observeValue(forProperty property: String, 
                                 ofObject object: Any, 
                                 change: [NSKeyValueChangeKey : Any]?) 
}
```
同是不要忘记 deinit 的时候 removeObserver，防止 App 崩溃。对比 Apple 官方的 addObserver API 和 observeValue API，我们发现苹果还引入了一个参数context来更加灵活的处理通知观察机制。你可以定义不同的 context 并根据这些 context 来对属性变化做出处理。比如下面这样：

```objectivec
let myContext = UnsafePointer<()>()

observee.addObserver(observer, forKeyPath: …, options: nil, context: myContext)

override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafePointer<()>) {
    if context == myContext {
        …
    } else {
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
}
```




## 使用Block实现KVO



* [SJKVOController](https://github.com/knightsj/SJKVOController)

* [使用Block实现KVO | J_Knight_](https://knightsj.github.io/2017/05/15/%E4%BD%BF%E7%94%A8Block%E5%AE%9E%E7%8E%B0KVO/)


## 总结

iOS 10中苹果的本地推送和远程推送 API 达到了高度统一，都使用 UserNotifications 这个框架来实现，学习曲线大幅下降。功能也得到了大幅度扩展，多媒体文件添加、扩展包、分类别响应、3D Touch 都使得推送功能更加灵活。

至于苹果自己设计的 KVO 和 NotificationCenter 机制，笔者认为有很大的局限性。因为对应的通知和相应代码段之间有一定距离，代码量很大的时候非常容易找不到对应的相应。同时这种观察者模式又难以测试，代码维护和质量很难得到保证。正是因为这些原因，响应式编程才日渐兴起，大家不妨去看看 RxSwift 和 ReactCocoa，其对应的 MVVM 架构也在系统解耦上要优于原生的 MVC。



## KVO

1. KVO 是 Key-Value-Observing 的简称。

2. KVO 是一个观察者模式。观察一个对象的属性，注册一个指定的路径，若这个对象的的属性被修改，则 KVO 会自动通知观察者。

3. 更通俗的话来说就是任何对象都允许观察其他对象的属性，并且可以接收其他对象状态变化的通知。

### KVO 基本使用

```objc
1.// 注册观察者，实施监听；
[self.person addObserver:self
              forKeyPath:@"age"
                 options:NSKeyValueObservingOptionNew
                 context:nil];

2.// 回调方法，在这里处理属性发生的变化；
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context


3.// 移除观察者；
[self removeObserver:self forKeyPath:@“age"];
```

KVO 在 Apple 中的 API 文档如下： 

> Automatic key-value observing is implemented using a technique called isa-swizzling… When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class …

Apple 使用了 isa 搅拌技术（isa-swizzling）来实现的 KVO 。当一个观察者注册对象的一个属性 isa 观察对象的指针被修改，指着一个中间类而不是在真正的类。

isa 指针的作用：每个对象都有 isa 指针，指向该对象的类，它告诉 runtime 系统这个对象的类是什么。

注：如果对 runtime 不很清楚的话可以看下这篇文章[Objective-C 中的 Runtime](http://www.jianshu.com/p/3e050ec3b759)

举个栗子：

```objc
_person = [[Person alloc] init];
    
/**
 *  添加观察者
 *
 *  @param observer 观察者
 *  @param keyPath  被观察的属性名称
 *  @param options  观察属性的新值、旧值等的一些配置（枚举值，可以根据需要设置，例如这里可以使用两项）
 *  @param context  上下文，可以为nil。
 */
[_person addObserver:self
          forKeyPath:@"age"
             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
             context:nil];
```

```objc
/**
 *  KVO回调方法
 *
 *  @param keyPath 被修改的属性
 *  @param object  被修改的属性所属对象
 *  @param change  属性改变情况（新旧值）
 *  @param context context传过来的值
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    NSLog(@"%@对象的%@属性改变了：%@",object,keyPath,change);
 }
```

```objc
/**
 *  移除观察者
 */
- (void)dealloc
{
    [self.person removeObserver:self forKeyPath:@"age"];
}
```


### KVO 实现原理

* 当某个类的对象**第一次被观察时，系统就会在运行期动态地创建该类的一个派生类，在这个派生类中重写基类中任何被观察属性的 setter 方法**。
* 派生类在被重写的 setter 方法实现真正的通知机制，就如前面手动实现键值观察那样。这么做是基于设置属性会调用 setter 方法，而通过**重写就获得了 KVO 需要的通知机制**。当然前提是要通过遵循 KVO 的属性设置方式来变更属性值，如果仅是直接修改属性对应的成员变量，是无法实现 KVO 的。
* 同时派生类还重写了 class 方法以“欺骗”外部调用者它就是起初的那个类。然后系统将这个对象的 isa 指针指向这个新诞生的派生类，因此这个对象就成为该派生类的对象了，因而在该对象上对 setter 的调用就会调用重写的 setter，从而激活键值通知机制。此外，派生类还重写了 dealloc 方法来释放资源。

**派生类 NSKVONotifying_Person 剖析：**

在这个过程，被观察对象的 isa 指针从指向原来的 Person 类，被 KVO 机制修改为指向系统新创建的子类 NSKVONotifying_Person 类，来实现当前类属性值改变的监听。

所以当我们从应用层面上看来，完全没有意识到有新的类出现，这是系统“隐瞒”了对 KVO 的底层实现过程，让我们误以为还是原来的类。但是此时如果我们创建一个新的名为 NSKVONotifying_Person 的类()，就会发现系统运行到注册 KVO 的那段代码时程序就崩溃，因为系统在注册监听的时候动态创建了名为 NSKVONotifying_Person 的中间类，并指向这个中间类了。

因而在该对象上对 setter 的调用就会调用已重写的 setter，从而激活键值通知机制。这也是 KVO 回调机制，为什么都俗称 KVO 技术为黑魔法的原因之一吧：内部神秘、外观简洁。

**子类 setter 方法剖析：**

KVO 在调用存取方法之前总是调用 willChangeValueForKey:，通知系统该 keyPath 的属性值即将变更。
当改变发生后，didChangeValueForKey: 被调用，通知系统该 keyPath 的属性值已经变更。
之后，observeValueForKey:ofObject:change:context: 也会被调用。

重写观察属性的 setter 方法这种方式是在运行时而不是编译时实现的。
KVO 为子类的观察者属性重写调用存取方法的工作原理在代码中相当于：

```objc
- (void)setName:(NSString *)newName
{
    [self willChangeValueForKey:@"name"];    // KVO在调用存取方法之前总调用
    [super setValue:newName forKey:@"name"]; // 调用父类的存取方法
    [self didChangeValueForKey:@"name"];     // KVO在调用存取方法之后总调用
}
```

![KVO 实现原理图](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190214155925.png)


## 未移除观察者的影响

```objc
- (void)testKVO {
    
    PersonObject *personInstance = [[PersonObject alloc] init];
    BankObject *bankInstance = [[BankObject alloc] init];
    
    [bankInstance addObserver:personInstance forKeyPath:@"accountBalance" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    bankInstance.accountBalance = 20;
}

```

其输出结果如下所示：

```objc
keyPath = accountBalance, change = {
    kind = 1;
    new = 20;
    old = 0;
}, context = (null)
*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'An instance 0x7fc88047e7e0 of class BankObject was deallocated while key value observers were still registered with it. Current observation info: <NSKeyValueObservationInfo 0x7fc880770fa0> (
<NSKeyValueObservance 0x7fc880771850: Observer: 0x7fc8804737a0, Key path: accountBalance, Options: <New: YES, Old: YES, Prior: NO> Context: 0x0, Property: 0x7fc88076edd0>
)'
......
    
```
程序在调用一次KVO后，很爽快地崩溃了。给我们的解释是`bankInstance`被释放了，但KVO中仍然还有关于它的注册信息。实际上，我们上面说过，在添加观察者的时候，观察者对象与被观察属性所属的对象都不会被`retain`，然而在这些对象被释放后，相关的监听信息却还存在，KVO做的处理是直接让程序崩溃。


KVO (Key Value Observering) 是iOS用于监听某个对象某个变量一种简洁便利的机制。但是，对于KVO的稳定性苹果却做得没有那么好，在以下三种情况下会无情Crash：

1. 监听者dealloc时，监听关系还存在。当监听值发生变化时，会给监听者的野指针发送消息，报野指针Crash。（猜测底层是保存了unsafe_unretained指向监听者的指针）；
2. 被监听者dealloc时，监听关系还存在。在监听者内存free掉后，直接会报监听者还存在监听关系而Crash；
3. 移除监听次数大于添加监听次数。报出多次移除的错误；


## 优雅地使用 KVO


### KVO问题


* 需要手动移除观察者，且移除观察者的时机必须合适；
* 注册观察者的代码和事件发生处的代码上下文不同，传递上下文是通过 void * 指针；
* 需要覆写 -observeValueForKeyPath:ofObject:change:context: 方法，比较麻烦；
* 在复杂的业务逻辑中，准确判断被观察者相对比较麻烦，有多个被观测的对象和属性时，需要在方法中写大量的 if 进行判断；


如何优雅地解决上一节提出的几个问题呢？我们在这里只需要使用 Facebook 开源的 KVOController 框架就可以优雅地解决这些问题了。

如果想要实现同样的业务需求，当使用 KVOController 解决上述问题时，只需要以下代码就可以达到与上一节中完全相同的效果：


```objc
[self.KVOController observe:self.fizz
                    keyPath:@"number"
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString    *,id> * _Nonnull change) {
                          NSLog(@"%@", change);
                      }];

```


使用 KVOController 进行键值观测可以说完美地解决了在使用原生 KVO 时遇到的各种问题。

* 不需要手动移除观察者；
* 实现 KVO 与事件发生处的代码上下文相同，不需要跨方法传参数；
* 使用 block 来替代方法能够减少使用的复杂度，提升使用 KVO 的体验；
* 每一个 keyPath 会对应一个属性，不需要在 block 中使用 if 判断 keyPath；

## 手动操控改变通知

在一些情况,你可能想要控制一个处理的通知,比如最少的不必要的通知,或把一组通知集合在一个通知里.
你要重写`NSObject`的类方法`automaticallyNotifiesObserversForKey:`.
以下代码把"balance"的通知给排除了.

```
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {

    BOOL automatic = NO;
    if ([theKey isEqualToString:@"balance"]) {
        automatic = NO;
    }
    else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

```

```
    class override func automaticallyNotifiesObservers(forKey key:String) -> Bool{
        <#Code#>
    }

```

为了实现手动通知,你要在改变对象之前调用`willChangeValueForKey:`,并且在改变对象之后调用`didChangeValueForKey:`.

```
- (void)setBalance:(double)theBalance {
    if (theBalance != _balance) {
        [self willChangeValueForKey:@"balance"];
        _balance = theBalance;
        [self didChangeValueForKey:@"balance"];
    }
}

```

如果一个操作引起来了多个keys的变化,你要去嵌套改变通知:

```
- (void)setBalance:(double)theBalance {
    [self willChangeValueForKey:@"balance"];
    [self willChangeValueForKey:@"itemChanged"];
    _balance = theBalance;
    _itemChanged = _itemChanged+1;
    [self didChangeValueForKey:@"itemChanged"];
    [self didChangeValueForKey:@"balance"];
}

```

如果是在一个有序的to-many的关系(比如:Array),你不仅要指出key,还要指出改变的类型和被改地方的索引.

```
- (void)removeTransactionsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval
        valuesAtIndexes:indexes forKey:@"transactions"];

    // Remove the transaction objects at the specified indexes.

    [self didChange:NSKeyValueChangeRemoval
        valuesAtIndexes:indexes forKey:@"transactions"];
}

```


## 总结：

KVO 的本质就是监听对象的属性进行赋值的时候有没有调用 setter 方法 

1. 系统会动态创建一个继承于 Person 的 NSKVONotifying_Person
2. person 的 isa 指针指向的类 Person 变成 NSKVONotifying_Person，所以接下来的 person.age = newAge 的时候，他调用的不是 Person 的 setter 方法，而是 NSKVONotifying_Person（子类）的 setter 方法
3. 重写`NSKVONotifying_Person的setter方法：[super setName:newName]`
4. 通知观察者告诉属性改变。

### KVO 应用

监听 ScrollView 的 contentOffSet 属性，采取相应的措施：

```objc
[scrollview addObserver:self
             forKeyPath:@“contentOffset                   
                options:NSKeyValueObservingOptionNew
                context:nil];
```      

下面是用 KVO 写的一个通过监听 scrollview 的 contentOffSet 实现的一个小刷新功能，感兴趣的可以看下。

![gif](http://upload-images.jianshu.io/upload_images/1321491-e55e4dbf2efda347.gif?imageMogr2/auto-orient/strip)  

### KVO 总结

KVO 是一个对象能观察另一个对象属性的值，KVO 适合任何对象监听另一个对象的改变，这是一个对象与另外一个对象保持同步的一种方法。KVO 只能对属性做出反应，不会用来对方法或者动作做出反应。

优点：

1. 提供一个简单的方法来实现两个对象的同步。
2. 能够提供观察的属性的新值和旧值。
3. 每一次属性值改变都是自动发送通知，不需要开发者手动实现。
4. 用 keypath 来观察属性，因此也可以观察嵌套对象。

缺点：

1. 观察的属性必须使用字符串来定义，因此编译器不会出现警告和检查
2. 只能重写回调方法来后去通知，不能自定义 selector。当观察多个对象的属性时就要写"if"语句，来判断当前的回调属于哪个对象的属性的回调。


## 参考


1. [Foundation: NSKeyValueObserving(KVO) | 南峰子的技术博客](http://southpeak.github.io/2015/04/23/cocoa-foundation-nskeyvalueobserving/)
2. [《招聘一个靠谱的 iOS》—参考答案（三）](http://www.jianshu.com/p/20655f394736)
3. [如何优雅地使用 KVO](https://draveness.me/kvocontroller)
4. [iOSInterviewQuestions/《招聘一个靠谱的iOS》面试题参考答案（下）.md at master · ChenYilong/iOSInterviewQuestions](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8B%EF%BC%89.md#51-apple%E7%94%A8%E4%BB%80%E4%B9%88%E6%96%B9%E5%BC%8F%E5%AE%9E%E7%8E%B0%E5%AF%B9%E4%B8%80%E4%B8%AA%E5%AF%B9%E8%B1%A1%E7%9A%84kvo)
5. [KVC/KVO原理详解及编程指南](http://blog.csdn.net/wzzvictory/article/details/9674431?utm_source=tuicool)
6. [kvo 实践使用总结](http://www.jianshu.com/p/b878aa3194c6)
7. [setValue和setObject的区别 - taylor的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/itianyi/article/details/8661997)
8. [Key-Value Observing - NSHipster](http://nshipster.cn/key-value-observing/)
9. [iOS 开发中，怎样用好 Notifications？](http://www.jianshu.com/p/f20b00c1fc24)
10. [leejayID/KVC-KVO: KVC 与 KVO 使用姿势和原理解析](https://github.com/leejayID/KVC-KVO)




