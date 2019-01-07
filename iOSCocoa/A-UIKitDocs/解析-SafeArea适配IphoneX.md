## 解析-SafeArea适配Iphone


之前写了一篇适配 iOS 11 的文章[链接](https://www.jianshu.com/p/9be40fc3f059#comment-15387196)，如今 iPhone X 上市后，又要掀起一波适配潮了。对于开发者来说， iPhone X 并不像之前的产品那么容易适配。因为齐刘海、虚拟 HomeIndicator，可以说是相当有特点了。那么，X 到底做了哪些改变，怎么适配，下面我们就来详细谈谈。

### iPhone X 的一些改变

关于 iPhone X（后文中简称为 X）的屏幕尺寸，由于个性的刘海以及取消了物理 Home 按键而用虚拟按键 Home Indicator 取代，所以理所当然屏幕的高度会高一些。我们知道，6、7、8的尺寸都一样，是`375 * 667 pt`，而 X 的尺寸是 `375 * 812 pt`，宽度跟前者一样，由于是 @3x，所以像素尺寸是`1125 * 2436 px`。即加长版的 iPhone 8。具体见下图

![](https://i.loli.net/2019/01/04/5c2f278f447f3.jpg)


关于细节高度变化。Status Bar 的高度由之前的 20 pt 变为 44 pt，增加了 24 pt 是为了适应刘海对顶部空间的影响。
如果没有 Large Title，导航栏加状态栏的总体高度是 44 + 44 = 88 pt。如果有 Large Title，总体高度达到 44 + 52 = 96 pt。这跟之前的 64 pt 还是有很大差距的。
另外，底部的虚拟键 Home Indicator 的高度是 34 pt，适配的时候注意内容不能跟他有视图层叠，否则会很影响显示效果。底部的总高度为 49 + 34 pt = 83 pt。（其中 49 为 Tab Bar 高度）。

从上面数据不难看出，X 的改变甚至比之前的 4 -> 5 的差别都大。
好消息是，大多数使用标准的、系统提供的 UI 元素（如 UINavigationBar、UITableView、UICollectionView）将会自动适配 iPhone X。背景将会延伸到屏幕的边界，UI 元素将会被合适地放置。比如 Navigation Bar 的背景色会自动延伸到 Status Bar 中，Tab Bar 、Tool Bar 会被合适的放置在 Home Indicator 上面，其背景色也会延伸到屏幕底端。

当然，现在大多项目中的很多控件都是各种自定义，而且上述系统控件也不是百分百场景下都能适配的，所以为了完美适配 iPhone X，只能老老实实跟着笔者认识一下苹果的这套适配方案，适配工作才可能开展的顺利一些。

### 修改启动图

适配过 iPhone 4 到 iPhone 5 的开发者应该都知道，当年由于屏幕尺寸的较大变化，如果没做适配在 iPhone 5 运行就会有大大的黑边。解决方案就是配置启动图（LaunchScreen.storyboard 启动除外）。X 也是一样。
如果项目使用的是图集（Launch Images Asset），直接让设计师多做一张像素 1125 * 2436 px 的启动图即可。
如果是用的故事板启动图（Launch Screen.storyboard），则无需过多设置。
接下来，编译运行一下项目，就没有黑边了，但取而代之的会看到顶部和底部拥挤的布局，那么我们下面来具体谈一下怎么适配。

### 通过 Safe Area 来适配 X

谈到适配 iOS 11 || iPhone X，不得不认识一下 Safe Area。Safe Area 的出现也是为了给适配 iPhone X 工作提供方便。这部分我会尽可能详细介绍一下 Safe Area，掌握了 Safe Area，也就基本完成了 X 的 UI 适配工作。

认识 Safe Area 之前，我们先花两分钟时间复习一下 topLayoutGuide 和 bottomLayoutGuide。
iOS 7 之后苹果给 UIViewController 引入了 topLayoutGuide 和 bottomLayoutGuide，目的就是保护内容不被各种 Bar 遮挡，如（StatusBar, NavBar, ToolBar, TabBar）。这个属性有一个 length 值( 如 topLayoutGuide.length)，这个值可能由当前的 ViewController 或者 NavigationController 或者 TabbarController 决定。

> 一个独立的ViewController，不包含于任何其他的ViewController。如果状态栏可见，topLayoutGuide表示状态栏的底部，否则表示这个ViewController的上边缘。
> 包含于其他ViewController的ViewController不对这个属性起决定作用，而是由容器ViewController决定这个属性的含义：
> 如果导航栏（Navigation Bar）可见，topLayoutGuide表示导航栏的底部。
> 如果状态栏可见，topLayoutGuide表示状态栏的底部。
> 如果都不可见，表示ViewController的上边缘。
> 这部分还比较好理解，总之是屏幕上方任何遮挡内容的栏的最底部。

这两个属性是 VC 的属性，平常用的场景可能不是太多。但是仅仅描述上和下的安全内边距在 iPhone X 之前是足够使用的，因为不管横屏还是竖屏，只需知道上下安全内边距即可。但是在 X 上就行不通了，竖屏状态大多场景下还好，可是横屏情况下，要想适配酷酷的刘海和 Home Indicator，仅仅这两个属性就力不从心了。苹果只好重新构思这块代码，自然就有了SafeArea 的解决方案（相信如果让你来设计这块代码来帮助广大开发者适配 X ，也应该很快想到类似方案）。
SafeArea，顾名思义，是安全区域。原则上所有的控制视图都应该在这上面绘制，超出这个区域就会有可能被 NavBar 或 StatusBar 或 ToolBar 或 Home Indicator 等遮挡而影响交互体验。看下面这张官方文档的示例图：


SafeArea_AppleDoc.png

在 iOS 11 中，苹果置过期了上面的控制器 VC 属性 top/bottomLayoutGuide，取而代之的是 View 属性 `safeAreaLayoutGuide`，`safeAreaInsets`。下面就细细说一下苹果的这套 SafeArea 解决方案如何。
我们先说一下`safeAreaInsets`。

###### SafeAreaInsets

顾名思义，它就是安全区域的内边距。
简而言之，它的值是（StatusBarHeight + NavBarHeight, 0, HomeIndicatorHeight + TabBarHeight, 0）
在 X 上运行，即（44 + 44， 0， 34 + 49， 0）。（当然，上面的公式中的控件都没有隐藏。）
但是要注意，`SafeAreaInsets`这个属性的取用时机要当心。在`ViewDidLoad`中这个值是 zero 的，通过下面打印，可以看出端倪

```
viewDidLoad                              => {0, 0, 0, 0}
viewWillAppear:                         =>{0, 0, 0, 0}
viewSafeAreaInsetsDidChange =>{44, 0, 34, 0}
viewWillLayoutSubviews           =>{44, 0, 34, 0}
viewDidLayoutSubviews            =>{44, 0, 34, 0}
viewDidAppear:                          =>{44, 0, 34, 0}

```

综上，可以在`viewSafeAreaInsetsDidChange`方法中取值（view也有个类似方法，`safeAreaInsetsDidChange`），也可以在`viewWillLayoutSubviews`取值。

我们如果之前用过 top/bottomLayoutGuide，就会很自然就知道了`SafeAreaInsets`的用法。很类似，这个属性就是告诉开发者，添加的控件最好在这个安全内边距区域内。`view.safeAreaLayoutGuide.layoutFrame`就是通过该内边距计算获得。

*   用 Xib 创建视图的话，如果是 iOS 9 +，那么很简单直接将控件的相对布局对象改为`safe area`即可。
*   如果不是 Xib 视图，或者要支持 iOS 8 +，那么用代码也很简单。以控制器为例，向控制器视图中添加子控件布局的时候，布局不要直接以 View 为参照视图，要用到`SafeAreaInsets`

    ```
    UIEdgeInsets insets = self.view.safeAreaInsets;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            // ...
            make.bottom.mas_equalTo(-insets.bottom);
        }];

    ```

###### AdditionalSafeAreaInsets

当 view controller 的子视图覆盖了嵌入的子 view controller 的视图的时候。比如说， 当 UINavigationController 和 UITabbarController 中的 bar 是半透明(translucent) 状态的时候, 就有 additionalSafeAreaInsets。

```
You might use this property to extend the safe area to include custom content in your interface. For example, a drawing app might use this property to avoid displaying content underneath tool palettes.

```

官方文档举的例子是在一个画画 App 中通过该属性来延伸安全区域，从而避免画笔画到了画板上。
注意这个属性是在原来的基础上叠加多少，不是改为了多少。


## 参考

1. [关于 SafeArea 和 适配 iPhoneX - 简书](https://www.jianshu.com/p/d03e2704e91c)