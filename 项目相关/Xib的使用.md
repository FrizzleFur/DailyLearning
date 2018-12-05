## Xib的使用


“连线”是xib中最为重要的东西，在讲“连线”之前，先说一个很重要、但又不容易说清的东西：Files Owner。

Files Owner指这个xib文件的所属文件是谁，简单的说是xib文件和谁建立起交互，用户通与该xib呈现的页面进行交互的时候，谁来处理背后的逻辑。具体来讲xib文件能拖动“连线”到哪个源文件中去建立IBAction、IBOutlet、delegate、datasource等。
一般基于View创建的xib的Files Owner都指定为一个VC。基于VC创建的xib，创建的时候系统就已经把该xib文件的Files Owner指向了该VC，一般这种情况就不对Files Owner做修改了。


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


## 参考

1. [一天一点xib:2初识xib - 简书](https://www.jianshu.com/p/7d59b9420bba)
2. [一天一点xib:4简单使用xib - 简书](https://www.jianshu.com/p/a4e2066514f5)
3. [xib 原理、嵌套、可视化、继承 - 简书](https://www.jianshu.com/p/50ee2ce6d513)
4. [xib相关（十二） —— UIStackView之基本介绍（一） - 简书](https://www.jianshu.com/p/7a6ef3b21c9c)