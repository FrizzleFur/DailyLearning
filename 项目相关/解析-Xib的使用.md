## Xib的使用

## awakeFromNib 和 initWithCoder

* initWithCoder ：do init stuff
    *  使用文件加载的对象调用（如从xib或stroyboard中创建）
    *  为了同时**兼顾从文件和从代码解析的对象初始化，要同时在initWithCoder: 和 initWithFrame: 中进行初始化**

* awakeFromNib ： Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.    
    * nib加载基础结构将awakeFromNib消息发送到从nib归档重新创建的每个对象，但仅在归档中的所有对象都已加载并初始化之后。当一个对象收到一个awakeFromNib消息时，它保证已经建立了所有的插座和动作连接。
    * 从xib或者storyboard加载完毕就会调用


[ios - Should I be using awakeFromNib or initWithCoder here? - Stack Overflow](https://stackoverflow.com/questions/15508041/should-i-be-using-awakefromnib-or-initwithcoder-here)


## loadNibNamed 和 UINib

在table中加载xib的对比

![](https://i.loli.net/2018/12/08/5c0b73f4c4029.jpg)


## Xib的嵌套

* 在xib中加载另一个xib，书上说貌似不能直接指定子xib的Class来关联，所以可以使用loadNib方式来加载子xib。


## IBOutlet属性用weak还是strong

Apple目前推荐的最佳做法是IBOutlets强劲，除非特别需要弱以避免保留周期

## 1.知识点

如果IBOutlet对象是nib/storyboard scene的拥有者（File’s owner）所直接持有的对象，那么很显然拥有者必须直接拥有对象的指针，因此属性应设置为strong。而其他的IBOutlet对象的属性需要设置为weak，因为拥有者并不需要直接拥有它们的指针。控制器需要直接控制某一个子视图并且将子视图添加到其他的view tree上去，此时需要strong。

#### 1.IBOutlet属性是Weak还是Strong？

1）我们将控件subview拖到xib/storyboard的view上，view持有了subview（强引用）。
2）当我们使用IBOutlet属性控件的时候，我们是在viewController里面使用，而这个IBOutlet属性控件并不一定直接归控制器所有。当他属于VC的时候，我们要用Strong修饰符；当他属于View时，我们要用Weak修饰**（避免View和VC同时拥有控件的强引用**）。
即使使用Strong，也不会出现循环引用。在一般场景下，也不会发生内存泄露。VC释放的时候，**view也会被释放，它们2个持有的subView也会被释放。但是，涉及到多层View的场景时，这么做是非常容易引起bug的。所以，请根据实际场景，确认IBOutlet属性的修饰符。
**

#### 2.控件和IBOutlet的对应关系是？

1）一个控件可以对应多个IBOutlet，所以他也可以对应多个Action事件
场景：一个基类的xib中有一个通用性的控件，所有的子类中都有一个IBOutlet连接到该控件
2）一个IBOutlet只能对应一个控件

[iOS日记10-IBOutlet属性用weak还是strong - 简书](https://www.jianshu.com/p/4663fe7ef0b8)



## 分类方法

```objc
+(id)viewFromNibNamed:(NSString*)nibName owner:(id)owner{
    NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    return [nibView firstObject];
}
```

## Xib的加载



记在 UIView 的 xib 文件方式有一下几种:

一 .直接加载 xib 文件, 没有.h.m 文件

1. NSBundle 方式

```objc
NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"XibView" owner:nil options:nil];

UIView *xibView = objs[0];

xibView.backgroundColor = [UIColor redColor];

[self.view addSubview:xibView];
```
 

2. UINib

//一个nib 对象就代表一个 xib 文件


　   //UINib *nib = [UINib nibWithNibName:@"XibView" bundle:[NSBundle mainBundle]];

 

    //一般 bundle 传nil,默认就是 mainbundle

    UINib *nib = [UINib nibWithNibName:@"XibView" bundle:nil];

 

    NSArray *objs = [nib instantiateWithOwner:nil options:nil];

 

    [self.view addSubview:objs[0]];


方式二. 在一个 xib 中使用另一xib  OtherView文件


### VC加载Xib文件


加载xib的init方法是：


```objc
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
```


###  View加载Xib文件


注：一般的UIView对象，代码初始化的时候都会调用initWithFrame:方法，但是用xib创建的UIView对象是不会调用此方法的，因为该对象的Frame在xib文件中就可以确定了。以xib的形式保存控件对象的过程其实叫做固化(archive)，通过xib文件创建控件的过程叫做解固(unarchive)，固化是iOS持久化的一种比较好的解决方案，以后有机会会说说iOS持久化的各种方式的优劣，这里不再深入，而与固化相关的初始化函数是：

```objc
- (instancetype)initWithCoder:(NSCoder *)aDecoder

```
所以，当以xib创建UIView对象的时候这个函数会调用，之前在initWithFrame:中要做的事情，可以放在initWithCoder:中，或者放在：


```objc
- (void)awakeFromNib
{
    [super awakeFromNib];
    //...
}

```

### Constrain to margin


What is Margins in iOS8

![](https://i.loli.net/2018/12/09/5c0beab9b0052.png)

By default, a UIView has layout margins of 8 points on each side, and this can not be changed in Interface Builder. However, by setting the UIView.layoutMargins property in the code, which is only available on iOS8, you are able to adjust these values.


[ios - What is "Constrain to margin" in Storyboard in Xcode 6 - Stack Overflow](https://stackoverflow.com/questions/25807545/what-is-constrain-to-margin-in-storyboard-in-xcode-6)




## 小技巧

预览Xib

![](https://i.loli.net/2018/12/09/5c0c65029cd2b.jpg)
![](https://i.loli.net/2018/12/09/5c0c6589f21ff.jpg)

## 参考

1. [一天一点xib:2初识xib - 简书](https://www.jianshu.com/p/7d59b9420bba)
2. [一天一点xib:4简单使用xib - 简书](https://www.jianshu.com/p/a4e2066514f5)
3. [xib 原理、嵌套、可视化、继承 - 简书](https://www.jianshu.com/p/50ee2ce6d513)
4. [xib相关（十二） —— UIStackView之基本介绍（一） - 简书](https://www.jianshu.com/p/7a6ef3b21c9c)
