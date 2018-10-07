#  UIKit综述

`iOS_Docs` `iOS知识点整理`

`2017-04-04` `iOS_Docs`

[通过实现一个TableView来理解IOS UI编程](https://yishuiliunian.gitbooks.io/implementate-tableview-to-understand-ios/content/index.html)

### UIKit提供的基础

这里会牵扯到一个另外一个问题，可能有些读者会问可不可以从最最底层的开始做起，来实现一个TableView呢，比如从写一个图形界面库开始。这个从技术上来说，完全可以实现，但是仔细想想在Apple为我们提供了UIKit之后，如果我们不是写游戏的话，貌似完全没有必要重新造这个轮子啊。当然你要写游戏的话，那令当别论，请出门左转有开源的Cocoa2d，作者要是针对从最底层开始构建感兴趣可以看一下Cocoa2d的开源代码，想必肯定大有收获。

![](http://oc98nass3.bkt.clouddn.com/15212689869106.jpg)

## UIApplication

UIApplication的编程接口让你能够管理一些硬件指定的行为。比如：

控制App来响应设备方向变化 
暂时终止接受触摸事件 
打开或者关闭接近用户脸部的感应 
注册远程消息通知 
打开或者关闭undo-redo UI 
决定你的程序是否能够支持某一类的URL 
扩展程序能力，让app能够在后台运行 
发布或者取消本地通知 
接受运程控制事件 
执行程序级别的复位操作 
UIApplication必须实现UIApplicationDelegate协议来实现他的一些协议。

### Windows&Views（窗口和视图）

窗口和视图是为iPhone应用程序构造用户界面的可视组件。窗口为内容显示提供背景平台，而视图负责绝大部分的内容描画，并负责响应用户的交互。虽然本章讨论的概念和窗口及视图都相关联，但是讨论过程更加关注视图，因为视图对系统更为重要。

视图对iPhone应用程序是如此的重要，以至于在一个章节中讨论视图的所有方面是不可能的。本章将关注窗口和视图的基本属性、各个属性之间的关系、以及在应用程序中如何创建和操作这些属性。本章不讨论视图如何响应触摸事件或如何描画定制内容，有关那些主题的更多信息，请分别参见“事件处理”和“图形和描画”部分。

虽然iPhone OS支持将一个窗口叠放在其它窗口的上方，但是您的应用程序永远不应创建多个窗口。系统自身使用额外的窗口来显示系统状态条、重要的警告、以及位于应用程序窗口上方的其它消息。如果您希望在自己的内容上方显示警告，可以使用UIKit提供的警告视图，而不应创建额外的窗口。

### UIView是作用视图

一个UIView类的实例，负责在屏幕上定义一个矩形区域。在iPhone的应用程序中，视图在展示用户界面及响应用户界面交互方面发挥关键作用。每个视图对象都要**负责渲染视图矩形区域中的内容，并响应该区域中发生的触碰事件。**这一双重行为意味着视图是应用程序与用户交互的重要机制。在一个基于模型-视图-控制器的应用程序中，视图对象明显属于视图部分。

![](http://oc98nass3.bkt.clouddn.com/15212690013459.jpg)

### 视图控制器

含有很多内容的应用程序可以将内容分为多个屏幕。在运行时，每个屏幕的背后都是一组视图对象，负责显示该屏幕的数据。一个屏幕的视图后面是一个视图控制器，其作用是管理那些视图上显示的数据，并协调它们和应用程序其它部分的关系。

UIViewController类负责创建其管理的视图及在低内存时将它们从内容中移出。视图控制器还为某些标准的系统行为提供自动响应。比如，在响应设备方向变化时，如果应用程序支持该方向，视图控制器可以对其管理的视图进行尺寸调整，使其适应新的方向。您也可以通过视图控制器来将新的视图以模式框的方式显示在当前视图的上方。

[Core Graphics快速入门——从一行代码说起](http://www.mamicode.com/info-detail-841887.html) 
[http://img.blog.csdn.net/20150606101320155](http://img.blog.csdn.net/20150606101320155)

![](http://oc98nass3.bkt.clouddn.com/15212690130905.jpg)

Core Graphics其实是一套基于C的API框架，使用了Quartz作为绘图引擎。这也就意味着Core Graphics不是面向对象的。 
Core Graphics需要一个图形上下文（Context）。所谓的图形上下文（Context），说白了就是一张画布。这一点非常容易理解，Core Graphics提供了一系列绘图API，自然需要指定在哪里画图。因此很多API都需要一个上下文（Context）参数。 
Core Graphics的图形上下文（Context）是堆栈式的。只能在栈顶的上下文（画布）上画图。 
Core Graphics中有一些API，名称不同却有着相似的功能，新手只需要掌握一种，并能够看懂其他的即可。

### 平面内布局

我们发现其实一个CGRect中包含了一个原点（point）和一组宽高的信息（size）。其实一个CGRect就是描述了一个长方形的块，就像下图的红色方块一样的东西，我们的每一个View在坐标系中都会被表示为一个长方形的块状物。

同时，你可以把整个UIKit的View布局系统看成一个递归的系统，一个view在父view中布局，父view又在其父view中布局，最后直到在UIWindow上布局。这样递归的布局开来，就能构建起我们看到的app的界面。

### Z-Order布局

那我们来看看UIKit给我们提供了哪些函数来做这个事情：

```
– addSubview:
– bringSubviewToFront:
– sendSubviewToBack:
– removeFromSuperview
– insertSubview:atIndex:
– insertSubview:aboveSubview:
– insertSubview:belowSubview:
– exchangeSubviewAtIndex:withSubviewAtIndex:
– isDescendantOfView:

//属性部分
 superview  property
 subviews  property
 window  property

```

### 如何布局

布局顾名思义，就是确定一个View的位置。也就是说我们要在布局中做的事情用一句话说就是：确定UIView的frame属性的值。给每一个UIView和其子类的实例确定frame的属性值。

objc构建一个对象使用的是两段式，首先分配内存alloc然后init，这样的好处就是将内存操作和初始化操作解耦合，让我们能够在初始化的时候对对象做一些必要的操作。这是个很好的思路，我们在做很多事情的时候都可以使用这种两段式的思路。比如布局一个UIView，我们可以分成两部，初始化必要的子view和变量，然后在合适的时机进行布局。

不得不说的是，千万不要被这个函数的名称withFrame给忽悠了，以为这个函数使用布局用的。在代码逻辑比较清晰的工程中，几乎很少看到在这个函数中进行界面布局的工作。因为UIKit给你提供了一个专门的函数layoutSubViews来干这个事情。而且，在这个函数中做的界面布局的工作，是一次性编码，你的界面布局没有任何复用性，如果父View的大小变了之后，这个View还是傻傻的保持原来的模样。同时也会造成，初始化函数臃肿，导致维护上的困难。

2、`layoutSubviews`和`setNeedsLayout` 
上面说了一些`initWithFrame`的事情，告诫了千万不要在里面做界面布局的事情，那应该在什么地方做呢？

`layoutSubviews` 
就是这个地方，这是苹果提供给你专门做界面布局的函数。

我们来看一下文档: 
`The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.`

`Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.`

`You should not call this method directly. If you want to force a layout update, call the setNeedsLayout method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the layoutIfNeeded method.` 
苹果都说了这个是子类化View的时候布局用的。那我们最好是老老实实的在里面做布局的工作。

2、`layoutSubviews`和`setNeedsLayout` 
上面说了一些`initWithFrame`的事情，告诫了千万不要在里面做界面布局的事情，那应该在什么地方做呢？

`layoutSubviews` 
就是这个地方，这是苹果提供给你专门做界面布局的函数。

我们来看一下文档:

`The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.`

`Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.`

`You should not call this method directly. If you want to force a layout update, call the setNeedsLayout method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the layoutIfNeeded method.`

苹果都说了这个是子类化View的时候布局用的。那我们最好是老老实实的在里面做布局的工作。

**什么时候布局**

这个就看功能需要了，不过有一点是肯定的就是不要直接调用layoutSubviews函数。UIKit和runtime是捆绑很密切的，apple为了防止界面重新布局过于频繁，所以只在runloop合适的实际来做布局的工作。里面具体的细节，可以google。

一般你需要重新布局的时候调用setNeedsLayout标记一下，“我需要重新布局了”。就行了，系统会在下次runloop合适的时机给你布局。

#### UpdateCircle

[https://yishuiliunian.gitbooks.io/implementate-tableview-to-understand-ios/content/uikit/imgs/update_circle.png](https://yishuiliunian.gitbooks.io/implementate-tableview-to-understand-ios/content/uikit/imgs/update_circle.png)

![](http://oc98nass3.bkt.clouddn.com/15212690506562.jpg)

### 一、Hit-Testing 返回触摸事件发生的视图

iOS 使用hit-testing来找到事件发生的视图。 Hit-testing包括检查触摸事件是否发生在任何相关视图对象的范围内， 如果是，则递归地检查所有视图的子视图。在视图层次中的最底层视图，如果它包含了触摸点，那么它就是hit-test视图。等 iOS决定了hit-test视图之后，它把触摸事件传递给该视图以便处理。

### 二、响应链由响应者对象组成

很多类型的事件都在事件传递中依赖响应链。 响应链是一系列相连的响应者对象。 它由第一个响应者开始，以应用对象结束。 如果第一响应者不能处理该事件，它把事件传递给响应链中的下一个响应者。

### 三、响应者链遵循一个特定的传递路径

如果初始对象—hit-test视图或者第一响应者链–不能处理一个事件， UIKit 把事件传递给响应者链中的下一个响应者。 每个响应者决定是否想要处理该事件或者调用nextResponder 方法把该事件传递给它的下个响应者。 该过程一直持续直到找到一个响应者来处理该事件或者没有任何其它响应者。

当iOS侦测到一个事件时，响应者链序列开始并把事件传递给一个初始对象，初始对象通常为一个视图。 初始视图首先可以处理一个事件。 图2-2显示了为两个应用程序配置的两个不同事件传递路径。 应用程序的事件传递路径依赖于它的特定结构， 但是所有的事件传递路径遵循同样的试探法(heuristics)。

![](http://oc98nass3.bkt.clouddn.com/15212690615897.jpg)

对于左边的应用程序，事件沿着以下路径：

初始视图尝试处理事件或消息。 如果它不能处理该事件，它把事件传递给它的父视图，因为初始视图在它的视图控制器的视图层次里不是最顶层视图。 
父视图尝试处理该事件。 如果父视图不能处理该事件，它把事件传递给父视图的父视图，因为该父视图还不是视图层次结构里的最顶层视图。 
视图控制器的视图层次结构中的最顶层视图尝试处理该事件。如果它还是不能处理该事件，它把事件传递给它的视图控制器。 
视图控制器尝试处理该事件，如果它不能处理，则把事件传递给窗口。 
如果窗口还是不能处理该事件，它把事件传递给单个应用程序对象。 
如果应用程序对象还是不能处理该事件，它把事件丢弃。 
右边的应用程序沿着稍稍不同的路径，但是所有的事件传递路径遵循这些探索法：

一个视图在它的视图控制器的视图层次中把事件向上传递，直到它达到最顶层视图。 
最顶层视图把事件传递给它的视图控制器。 
视图控制器把事件传递给它的最顶层视图的父视图。 重复步骤1-3 直到事件到达根视图控制器。 
根视图控制器把事件传递给窗口对象。 
窗口把事件传递给应用程序对象。

### UISCrollView详解

![](http://oc98nass3.bkt.clouddn.com/15212690700146.jpg)

当然，在scroll view中有很多具有代表性的视图。为了实现这个平移功能，当用户移动手指时，你需要时刻改变每个视图的frames。当我们提出组合一个view的光栅化图片到它父视图什么地方时，记住这个公式：


```
CompositedPosition.x = View.frame.origin.x - Superview.bounds.origin.x;

CompositedPosition.y = View.frame.origin.y - Superview.bounds.origin.y; 
```
我们减少Superview.bounds.origin的值(因为他们总是0)。但是如果他们不为0呢？我们用和前一个图例相同的frames，但是我们改变了紫色视图bounds的origin为{-30,-30}。得到下图：

![](http://oc98nass3.bkt.clouddn.com/15212690863825.jpg)




## iOS Rendering Process 概念

iOS Rendering Process 译为 iOS 渲染流程，本文特指 iOS 设备从设置将要显示的图元数据到最终在设备屏幕成像的整个过程。

### 基于平铺的渲染

iOS 设备的屏幕分为 N * N 像素的图块，每个图块都适合于 SoC 缓存，几何体在图块内被大量拆分，只有在所有几何体全部提交之后才可以进行光栅化（Rasterization）。
![](http://oc98nass3.bkt.clouddn.com/15246449976700.jpg)

> Note: 这里的光栅化指将屏幕上面被大量拆分出来的几何体渲染为像素点的过程。

![](http://oc98nass3.bkt.clouddn.com/15246450612857.jpg)

## iOS Rendering 技术框架

![](http://oc98nass3.bkt.clouddn.com/15246449709724.jpg)
    
其实 UIKit Framework 自身并不具备在屏幕成像的能力，它主要负责对用户操作事件的响应，事件响应的传递大体是经过逐层的**视图树**遍历实现的。

> 那么我们日常写的 UIKit 组件为什么可以呈现在 iOS 设备的屏幕上呢？

### Core Animation

Core Animation 其实是一个令人误解的命名。你可能认为它只是用来做动画的，但实际上它是从一个叫做 Layer Kit 这么一个不怎么和动画有关的名字演变而来的，所以做动画仅仅是 Core Animation 特性的冰山一角。

Core Animation 本质上可以理解为是一个复合引擎，旨在尽可能快的组合屏幕上不同的显示内容。这些显示内容被分解成独立的图层，即 CALayer，CALayer 才是你所能在屏幕上看见的一切的基础。

其实很多同学都应该知道 CALayer，UIKit 中需要在屏幕呈现的组件内部都有一个对应的 CALayer，也就是所谓的 Backing Layer。正是因为一一对应，所以 CALayer 也是树形结构的，我们称之为图层树。

视图的职责就是**创建并管理**这个图层，以确保当子视图在层级关系中**添加或者被移除**的时候，**他们关联的图层**也**同样对应在层级关系树当中有相同的操作**。


> 但是为什么 iOS 要基于 UIView 和 CALayer 提供两个平行的层级关系呢？为什么不用一个简单的层级关系来处理所有事情呢？

原因在于要做**职责分离**，这样也能**避免很多重复代码**。在 iOS 和 Mac OS X 两个平台上，事件和用户交互有很多地方的不同，基于多点触控的用户界面和基于鼠标键盘的交互有着本质的区别，这就是为什么 iOS 有 UIKit 和 UIView，而 Mac OS X 有 AppKit 和 NSView 的原因。他们功能上很相似，但是在实现上有着显著的区别。

> Note: 实际上，这里并不是两个层级关系，而是四个，每一个都扮演不同的角色，除了视图树和图层树之外，还存在呈现树和渲染树。

## UIViewController

### iOS导航控制器的注意事项

1. 导航控制器永远显示的是栈顶控制器的view

2. 导航控制器中做界面之间的跳转必须取到导航控制器

3. 调用pop方法并不会马上销毁当前控制器

4. popToViewController使用注意点：传入进去的控制器必须是导航控制器栈里面的控制器

5. 导航条的内容由栈顶控制器决定,一个导航控制器只有一个导航条,因此只能由一个控制器决定,谁先显示在最外面,谁就是栈顶控制器.

6. 在iOS7之后,默认会把导航条上的按钮的图片渲染成蓝色.

7. 导航条上的子控件位置不需要我们管理,只需要管理尺寸

8. UINavigationItem:是一个模型,决定导航条的内容(左边内容,中间,右边内容)

9. UIBarButtonItem:是一个模型,决定导航条上按钮的内容

10. 以后只要看到item,通常都是苹果提供的模型,只要改模型就能修改苹果的某些控件.

## 参考

1.[深入理解 iOS Rendering Process - 掘金](https://juejin.im/post/5ad3f1cc6fb9a028d9379c5f)

