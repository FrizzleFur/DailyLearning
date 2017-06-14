
# iOS 避免循环引用【译】.md

> 今天看文章发现一片关于`RetainCycle`的老生常谈的问题,但是作者从开发常见场景的代理和`Block`分析了原因，分析的不错，加深了理解，索性小译一下，加上了一些自己的图解，分享出来。欢迎转载评论，注明[原文地址]()即可~

## Avoid Strong Reference Cycles

>随着`ARC`的引入，内存管理变得更容易了。然而，即使您不必担心何时保留和释放，但仍然有一些规则需要您知道，以避免内存问题。在这篇文章中，我们将讨论强引用循环。

什么是一个强引用循环？假设你有两个对象，对象A和对象B。如果对象A于对象B持有强引用，对象B于对象A有强引用，那么就形成了一个强引用循环。我们将讨论两种非常常见，需要注意循环引用的场景：Block和Delegate。

```sequence
A->B: strong reference
B->A: strong reference
```

### 1. delegate

委托是OC中常用的模式。在这种情况下，一个对象代表另一个对象或与另一个对象协调。委派对象保留对另一个对象（委托）的引用，并在适当的时候向其发送消息。委托可以通过更新应用程序的外观或状态来响应。

（苹果的）`API`的一个典型例子是`UITableView`及其`Delegate`。在本例中，`UITableView`对其`Delegate`有一个引用，`Delegate`有一个返回`UITableView`的引用，按照规则，每一个都是（指向对方），保持对方活着，所以即使没有其他对象指向`Delegate`或`UITableView`，内存也不会被释放。（所以需要弱引用）

```objc
#import <Foundation/Foundation.h>
 
@class ClassA;

@protocol ClassADelegate <NSObject>
 
-(void)classA:(ClassA *)classAObject didSomething:(NSString *)something;
 
@end
 
@interface ClassA : NSObject
 
@property (nonatomic, strong) id<ClassADelegate> delegate;
```
这将在`ARC`世界中生成一个保留循环。为了防止这一点，我们需要做的只是将对委托的引用更改为弱引用~

```objc
@property (nonatomic, weak) id<ClassADelegate> delegate;
```

![Delegate模式](http://oc98nass3.bkt.clouddn.com/2017-06-14-14974262077874.jpg)

弱引用并未实现对象间的拥有权或职责，并不能使一个对象存活在内存中。如果没有其他对象指向`delegate`代理或者委托对象，那么`delegate`代理将被释放，随之`delegate`代理释放对委托对象的强引用。如果没有其他对象指向委托对象，则委托对象也将被释放。

### 2. Blocks

>块`Block`是类似于C函数的代码块，但除了可执行代码外，它们还可能包含堆栈中的变量。因此，`Block`可以维护一组数据，用于在执行时影响行为。因为`Block`保持代码的执行所需要的数据，他们是非常有用的回调。

>官方文档：![](http://oc98nass3.bkt.clouddn.com/2017-06-14-14974270759179.jpg)

`Block`是`Objective-C`对象，但是有些内存管理规则只适用于`Block`，而非其他`Objective-C`对象。

`Block`内对任何所捕获对象的保持强引用，包括`Block`自身，因此`Block`很容易引起强引用循环。如果一个类有这样一个`Block`的属性：

```
@property (copy) void (^block)(void);
```

在它的实现中，你有一个这样的方法：

```
- (void)methodA {
 
    self.block = ^{
 
        [self methodB];
    };
}
```

```sequence
self->block: strong reference
block->self: strong reference
```

然后你就得到了一个强引用循环：对象`self`对`block`有强引用，而`block`正好持有一个`self`的强引用。

Note: For block properties its a good practice to use copy, because a block needs to be copied to keep track of its captured state outside of the original scope.

注意：关于`block`的属性设置，使用`copy`是一个很好的方式，因为`block`需要被复制后用以在原始作用域外来捕获状态。

为了避免这种强引用循环，我们需要再次使用弱引用。下面就是代码的样子:


```
- (void)methodA {
 
    ClassB * __weak weakSelf = self;
 
    self.block = ^{
 
        [weakSelf methodB];
    };
}
```

通过捕获对自身的弱引用，`block`不会保持与对象的强引用。如果对象被释放之前的`block`称为`weakself`指针将被设置为`nil`。虽然这很好，因为不会出现内存问题，如果指针为`nil`，那么`block`内的方法就不会被调用，所以`block`不会有预期的行为。为了避免这种情况，我们将进一步修改我们的示例：

```
- (void)methodA {
 
    __weak ClassB *weakSelf = self;
 
    self.block = ^{
 
        __strong ClassB *strongSelf = weakSelf;
 
        if (strongSelf) {
 
            [strongSelf methodB];
        }
    };
}
```

我们在`block`内部创建一个`Self`对象的强引用。此引用将属于`block`，只要`block`还在，它将存活内存中。这不会阻止`Self`对象被释放，我们仍然可以避免强引用循环。

并不是所有的强引用循环都很容易看到，正如示例中的那样，当您的块代码变得更复杂时，您可能需要考虑使用弱引用。

这是两种常见的模式，它们可以出现强引用循环。正如您所看到的，只要您能够正确地识别它们，就很容易用弱引用来破坏这些循环。即便`ARC`让我们更容易管理内存，但是你仍需要注意。

>附注：翻译中，为了靠近原文意思，`强引用循环`就是大家经常说的循环引用。

#### 附：Block的一点碎碎念

1. `block`要用`copy`修饰,还是用`strong`？

NSString、NSArray、NSDictionary 等等经常使用copy关键字，是因为他们有对应的可变类型：NSMutableString、NSMutableArray、NSMutableDictionary；
block 也经常使用 copy 关键字，具体原因见官方文档：[Objects Use Properties to Keep Track of Blocks：](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html#//apple_ref/doc/uid/TP40011210-CH8-SW12)
block 使用 copy 是从 MRC 遗留下来的“传统”,在 MRC 中,方法内部的 block 是在栈区的,使用 copy 可以把它放到堆区.在 ARC 中写不写都行：对于 block 使用 copy 还是 strong 效果是一样的，但写上 copy 也无伤大雅，还能时刻提醒我们：编译器自动对 block 进行了 copy 操作。如果不写 copy ，该类的调用者有可能会忘记或者根本不知道`编译器会自动对 block 进行了 copy 操作`，他们有可能会在调用之前自行拷贝属性值。这种操作多余而低效。你也许会感觉我这种做法有些怪异，不需要写依然写。如果你这样想，其实是你`日用而不知`，

![](http://oc98nass3.bkt.clouddn.com/2017-06-14-14974279552231.jpg)

## 参考

1. [Avoid strong reference cycles](http://masteringios.com/blog/2014/03/06/avoid-strong-r0eference-cycles/)
2. [ChenYilong/iOSInterviewQuestions](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8A%EF%BC%89.md#3-%E6%80%8E%E4%B9%88%E7%94%A8-copy-%E5%85%B3%E9%94%AE%E5%AD%97)


