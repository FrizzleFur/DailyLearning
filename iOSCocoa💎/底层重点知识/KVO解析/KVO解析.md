# KVO解析.md

* 监听方法本质:并不需要修改方法的实现,仅仅想判断下有没有调用
* // KV0怎么实现
* // KV0的本质就是监听一个对象有没有调用set方法，重写这个方法 
* 修改当前对象的isa指针,指向自定
// KV0底层实现
// 1.自定义NSKVONotifying_ Person子类
// 2.重写setName,在内部恢复父类做法,通知观察者
// 3.如何让外界调用自定义Person类的子类方法，修改当前对象的isa指针,指向
NSKVONotifying_ Person

## Apple用什么方式实现对一个对象的KVO？

[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)对 KVO 实现的描述：

> Automatic key-value observing is implemented using a technique called isa-swizzling... When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class ...

从[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)可以看出：Apple 并不希望过多暴露 KVO 的实现细节。不过，要是借助 runtime 提供的方法去深入挖掘，所有被掩盖的细节都会原形毕露：

> **当你观察一个对象时，一个新的类会被动态创建。这个类继承自该对象的原本的类，并重写了被观察属性的 setter 方法。重写的 setter 方法会负责在调用原 setter 方法之前和之后，通知所有观察对象值的更改**。最后通过 `isa 混写（isa-swizzling）` 把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例。我画了一张示意图，如下所示：

![](http://oc98nass3.bkt.clouddn.com/15335303051090.jpg)

# 一、KVO是什么？

*   KVO 是 Objective-C 对观察者设计模式的一种实现。【另外一种是：通知机制（notification）】；
*   KVO提供一种机制，指定一个被观察对象(例如A类)，当对象某个属性(例如A中的字符串name)发生更改时，监听对象会获得通知，并作出相应处理；【且不需要给被观察的对象添加任何额外代码，就能使用KVO机制】
    在MVC设计架构下的项目，KVO机制很适合实现mode模型和view视图之间的通讯。

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

[![enter image description here](https://camo.githubusercontent.com/154f30ca6e4fbb77af74b8186057b7f7c96221ff/687474703a2f2f6936362e74696e797069632e636f6d2f6e636d3774682e6a7067)](https://camo.githubusercontent.com/154f30ca6e4fbb77af74b8186057b7f7c96221ff/687474703a2f2f6936362e74696e797069632e636f6d2f6e636d3774682e6a7067)

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


	• KVO提供一种机制，指定一个被观察对象(例如A类)，当对象某个属性(例如A中的字符串name)发生更改时，监听对象会获得通知，并作出相应处理；【且不需要给被观察的对象添加任何额外代码，就能使用KVO机制】在MVC设计架构下的项目，KVO机制很适合实现mode模型和view视图之间的通讯。

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


## 参考

1. [kvo 实践使用总结](http://www.jianshu.com/p/b878aa3194c6)
2. [iOSInterviewQuestions/《招聘一个靠谱的iOS》面试题参考答案（下）.md at master · ChenYilong/iOSInterviewQuestions](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8B%EF%BC%89.md#51-apple%E7%94%A8%E4%BB%80%E4%B9%88%E6%96%B9%E5%BC%8F%E5%AE%9E%E7%8E%B0%E5%AF%B9%E4%B8%80%E4%B8%AA%E5%AF%B9%E8%B1%A1%E7%9A%84kvo)
3. [setValue和setObject的区别 - taylor的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/itianyi/article/details/8661997)
4. [Key-Value Observing - NSHipster](http://nshipster.cn/key-value-observing/)
5. [iOS 开发中，怎样用好 Notifications？](http://www.jianshu.com/p/f20b00c1fc24)




