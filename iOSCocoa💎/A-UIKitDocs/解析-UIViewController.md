## UIViewController分析

### 生命周期

![](http://oc98nass3.bkt.clouddn.com/15370956857629.jpg)

单个viewController的生命周期
* initWithCoder:(NSCoder *)aDecoder：（如果使用storyboard或者xib）
* loadView：加载view
* viewDidLoad：view加载完毕
* viewWillAppear：控制器的view将要显示
* viewWillLayoutSubviews：控制器的view将要布局子控件
* viewDidLayoutSubviews：控制器的view布局子控件完成
* 这期间系统可能会多次调用viewWillLayoutSubviews 、 viewDidLayoutSubviews 俩个方法
* viewDidAppear:控制器的view完全显示
* viewWillDisappear：控制器的view即将消失的时候
* 这期间系统也会调用viewWillLayoutSubviews 、viewDidLayoutSubviews 两个方法
* viewDidDisappear：控制器的view完全消失的时候

* 注意到其中的viewWillLayoutSubviews和viewDidLayoutSubviews，调用情况视具体的viewDidLoad和viewWillAppear等方法中的代码而定。

## load

Apple文档是这样描述的

```
Invoked whenever a class or category is added to the Objective-C runtime; implement this method to perform class-specific behavior upon loading.

当类（Class）或者类别（Category）加入Runtime中时（就是被引用的时候）。
实现该方法，可以在加载时做一些类特有的操作。

Discussion

The load message is sent to classes and categories that are both dynamically loaded and statically linked, but only if the newly loaded class or category implements a method that can respond.

The order of initialization is as follows:

All initializers in any framework you link to.
调用所有的Framework中的初始化方法

All +load methods in your image.
调用所有的+load方法

All C++ static initializers and C/C++ attribute(constructor) functions in your image.
调用C++的静态初始化方及C/C++中的attribute(constructor)函数

All initializers in frameworks that link to you.
调用所有链接到目标文件的framework中的初始化方法

In addition:

A class’s +load method is called after all of its superclasses’ +load methods.
一个类的+load方法在其父类的+load方法后调用

A category +load method is called after the class’s own +load method.
一个Category的+load方法在被其扩展的类的自有+load方法后调用

In a custom implementation of load you can therefore safely message other unrelated classes from the same image, but any load methods implemented by those classes may not have run yet.
在+load方法中，可以安全地向同一二进制包中的其它无关的类发送消息，但接收消息的类中的+load方法可能尚未被调用。

```

文档地址:[https://developer.apple.com/reference/objectivec/nsobject/1418815-load?language=objc](https://developer.apple.com/reference/objectivec/nsobject/1418815-load?language=objc)

#### load函数调用特点如下:

> 当类被引用进项目的时候就会执行load函数(在main函数开始执行之前）,与这个类是否被用到无关,每个类的load函数只会自动调用一次.由于load函数是系统自动加载的，因此不需要调用父类的load函数，否则父类的load函数会多次执行。

*   1.当父类和子类都实现load函数时,父类的load方法执行顺序要优先于子类
*   2.当子类未实现load方法时,不会调用父类load方法
*   3.类中的load方法执行顺序要优先于类别(Category)
*   4.当有多个类别(Category)都实现了load方法,这几个load方法都会执行,但执行顺序不确定(其执行顺序与类别在Compile Sources中出现的顺序一致)
*   5.当然当有多个不同的类的时候,每个类load 执行顺序与其在Compile Sources出现的顺序一致


## initialize:

Apple文档是这样描述的

```
Initializes the class before it receives its first message.

在这个类接收第一条消息之前调用。

Discussion

The runtime sends initialize to each class in a program exactly one time just before the class, or any class that inherits from it, is sent its first message from within the program. (Thus the method may never be invoked if the class is not used.) The runtime sends the initialize message to classes in a thread-safe manner. Superclasses receive this message before their subclasses.

Runtime在一个程序中每一个类的一个程序中发送一个初始化一次，或是从它继承的任何类中，都是在程序中发送第一条消息。（因此，当该类不使用时，该方法可能永远不会被调用。）运行时发送一个线程安全的方式初始化消息。父类的调用一定在子类之前。

```

文档地址:[https://developer.apple.com/reference/objectivec/nsobject/1418639-initialize?language=objc](https://developer.apple.com/reference/objectivec/nsobject/1418639-initialize?language=objc)

#### initialize函数调用特点如下:

> initialize在类或者其子类的第一个方法被调用前调用。即使类文件被引用进项目,但是没有使用,initialize不会被调用。由于是系统自动调用，也不需要再调用 [super initialize] ，否则父类的initialize会被多次执行。假如这个类放到代码中，而这段代码并没有被执行，这个函数是不会被执行的。

*   1.父类的initialize方法会比子类先执行
*   2.当子类未实现initialize方法时,会调用父类initialize方法,子类实现initialize方法时,会覆盖父类initialize方法.
*   3.当有多个Category都实现了initialize方法,会覆盖类中的方法,只执行一个(会执行Compile Sources 列表中最后一个Category 的initialize方法
 
### load和initialize的共同点

1.如果父类和子类都被调用,父类的调用一定在子类之前

#### +load方法要点

当类被引用进项目的时候就会执行load函数(在main函数开始执行之前）,与这个类是否被用到无关,每个类的load函数只会自动调用一次.由于load函数是系统自动加载的，因此不需要再调用[super load]，否则父类的load函数会多次执行。

*   1.当父类和子类都实现load函数时,父类的load方法执行顺序要优先于子类
*   2.当一个类未实现load方法时,不会调用父类load方法
*   3.类中的load方法执行顺序要优先于类别(Category)
*   4.当有多个类别(Category)都实现了load方法,这几个load方法都会执行,但执行顺序不确定(其执行顺序与类别在Compile Sources中出现的顺序一致)
*   5.当然当有多个不同的类的时候,每个类load 执行顺序与其在Compile Sources出现的顺序一致

注意: load调用时机比较早,当load调用时,其他类可能还没加载完成,运行环境不安全. load方法是线程安全的，它使用了锁，我们应该避免线程阻塞在load方法.

* * *

#### +initialize方法要点

initialize在类或者其子类的第一个方法被调用前调用。即使类文件被引用进项目,但是没有使用,initialize不会被调用。由于是系统自动调用，也不需要显式的调用父类的initialize，否则父类的initialize会被多次执行。假如这个类放到代码中，而这段代码并没有被执行，这个函数是不会被执行的。

*   1.父类的initialize方法会比子类先执行
*   2.当子类不实现initialize方法，会把父类的实现继承过来调用一遍。在此之前，父类的方法会被优先调用一次
*   3.当有多个Category都实现了initialize方法,会覆盖类中的方法,只执行一个(会执行Compile Sources 列表中最后一个Category 的initialize方法)

注意: 在initialize方法收到调用时,运行环境基本健全。 initialize内部也使用了锁，所以是线程安全的。但同时要避免阻塞线程，不要再使用锁

## viewDidLoad

* viewDidLoad用于配置您未在XIB或Storyboard中配置的任何内容。在视图控制器将其视图层次结构从XIB或Storyboard加载到内存后调用它。当在loadView方法中以编程方式创建视图时也会调用它，但是在使用loadView时，您不需要使用viewDidLoad，因为您已经以编程方式创建了视图，并且不需要将该代码的一部分分成viewDidLoad。
* 调用此方法时，**您知道IBOutlets现在已连接，但视图尚未布局**，因此此时您应该在Interface Builder中执行任何无法完成的视图自定义
* 重要的是要记住，一旦您的视图被加载并在导航堆栈中，从视图移动到另一个屏幕并再次返回不会导致再次调用viewDidLoad，因此不要在此处放置需要在视图时更新的代码控制器即将变得活跃。

## isViewLoaded

控制器的View是否已经加载完，在判断子控制器view加载的时候使用。
A Boolean value indicating whether the view is currently loaded into memory.

```objc
ViewController.isViewLoaded
```


## viewWillAppear

调用此方法以告知视图控制器使其视图准备好在屏幕上显示。您应该覆盖此方法以执行与应用程序状态和将为视图显示的数据相关的任何设置。一些示例包括控件的数据值，UI自定义（如依赖于数据的颜色或文本）以及控件的选择状态。


## viewWillLayoutSubviews

当视图边界发生变化时，视图会调整其子视图的位置。在视图布局其子视图之前，视图控制器可以覆盖此方法以进行更改。 

viewWillLayoutSubviews在视图控制器的视图边界发生更改时调用（通常在视图加载或旋转更改时发生，或者如果它是子视图控制器，并且其视图由父视图控制器更改），但在其子视图的边界或位置更改之前调用。您可以覆盖此方法，以便在视图布局之前对子视图的边界或位置进行一些更改。

只要视图控制器的视图更改了边界，就会调用viewWillLayoutSubviews。加载视图，发生旋转事件或子视图控制器的大小由其父级更改时，会发生这种情况。 （也可能还有其他一些情况）。如果在视图自行放置之前需要更新任何内容（并且在重新应用约束之前），则应在此处执行此操作。你通常不应该在这里更新约束，因为更新约束会导致另一个布局传递。


## viewDidLayoutSubviews

通过前面两个方法（viewDidLoad，viewWillAppear）我们可以实现的一切，viewDidLayoutSubviews的原因是什么，为什么我们会覆盖它？当视图控制器的视图边界发生变化时，在子视图的位置和大小发生变化后调用此方法。这是我们在布局子视图之后但在屏幕上显示之前对视图进行更改的机会。**这里的关键是改变边界**。依赖于需要对视图执行的边界的任何内容都必须在此方法中，而不是在viewDidLoad或viewWillAppear中，因为在Auto Layout完成布局主视图的工作之前，视图的边框和边界才会完成。子视图，然后调用此方法。

布局完所有子视图后，将调用viewDidLayoutSubviews。例如，如果您需要通过手动调整框架来微调该布局，那么这就是完成它的地方。


## layoutSubviews调用情况分析

*   init初始化不会触发layoutSubviews
*   addSubview会触发layoutSubviews
*   设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化
*   滚动一个UIScrollView会触发layoutSubviews
*   旋转Screen会触发父UIView上的layoutSubviews事件
*   改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件


##  UIViewController 设置导航栏和标签栏不同 title 的问题

查了苹果文档中关于 UIViewController 中 title 属性的定义，有如下一段描述：

If the view controller has a valid navigation item or tab-bar item, assigning a value to this property updates the title text of those objects.

也就是说，如果一个 VC 同时有导航栏和标签栏，那么当给 title 赋值时，会同时修改这两个地方的标题。所以如果我们只想设置导航栏的标题，可以通过 self.navigationItem.title = xxx 的方式来实现。

因此，在一个 VC 中设置相关标题简单总结如下：

* self.navigationItem.title: 设置 VC 顶部导航栏的标题
* self.tabBarItem.title: 设置 VC 底部标签栏的标题
* self.title: 同时修改上述两处的标题

### window

其实显示或者旋转的回调的触发的源头来自于window,一个app首先有一个主window，初始化的时候需要给这个主window指定一个rootViewController，window会将显示相关的回调(viewWillAppear:, viewWillDisappear:, viewDidAppear:, or viewDidDisappear: )以及旋转相关的回调(willRotateToInterfaceOrientation:duration: ,willAnimateRotationToInterfaceOrientation:duration:, didRotateFromInterfaceOrientation:)传递给rootViewController。rootViewController需要再将这些callbacks的调用传递给它的Child View Controllers。


## 子控制器

* 控制器的view在,控制器被销毁。
* 控制器不存在,控制器的view也是可以存在
* 当控制器view存在,控制器不存在，会导致控制器view上面的所有事件都不能处理
* ARC管理原则;只要一个对象没有被强引用,就会被销毁

![](http://oc98nass3.bkt.clouddn.com/15388740190329.jpg)

由于创建的VC都是局部变量，因此在创建方法走完之后，局部变量VC被销毁，但是VC的view加入到self.view的subviews数组中，被当前VC强引用。因此没有被释放。

### 建立“父子关系”

[Custom Container View Controller - CocoaChina 苹果开发中文站 - 最热的iPhone开发社区 最热的苹果开发社区 最热的iPad开发社区](http://www.cocoachina.com/industry/20140523/8528.html)

一. 父子关系范式

实现一个Custom Container View Controller并不是一个简单的事情，主要分为两个阶段：父子关系的建立以及父子关系的解除。如果pVC将cVC的view添加为自己的subview，那么cVC必须为pVC的Child View Controller，而反过来则不一定成立，比如UINavigationController，一个View Controller被push进来后便和navigationController建立父子关系了,但是只有最上面的View Controller 是显示着的，底下的View Controller的view则被移出了容器的view的显示层级，当一个View Controller被pop之后，便和navigationController解除了父子关系了。

 

展示一个名为content的child view controller：

[self addChildViewController:content];  //1 
content.view.frame = [self frameForContentController];  
[self.view addSubview:self.currentClientView]; //2 
[content didMoveToParentViewController:self]; //3 
1.将content添加为child view controller，addChildViewController:接口建立了逻辑上的父子关系，子可以通过parentViewController，访问其父VC，addChildViewController:接口的逻辑中会自动调用 [content willMoveToParentViewController:self];

2.建立父子关系后，便是将content的view加入到父VC的view hierarchy上，同时要决定的是 content的view显示的区域范围。 

3.调用child的 didMoveToParentViewController: ，以通知child，完成了父子关系的建立

 

移除一个child view controller：

[content willMoveToParentViewController:nil]; //1 
[content.view removeFromSuperview]; //2 
[content removeFromParentViewController]; //3 
1.通知child，即将解除父子关系，从语义上也可以看出 child的parent即将为nil

2.将child的view从父VC的view的hierarchy中移除 

3.通过removeFromParentViewController的调用真正的解除关系，removeFromParentViewController会自动调用 [content didMoveToParentViewController:nil]


```objc
    [self addChildViewController:childVc];
```

### 子控制器和父控制器的交互

#### push模式

* 子控制器可以拿到父控制器的导航控制器
    * self.navigationController:首先去寻找自己是不是导航控制器子控制器
    * 就会去看自己的父控制是不是导航控制器子控制器
 
#### modal模式

* 子控制器可以dismiss父控制器
    * dismissViewControllerAnimated: 谁调用, dismiss谁
    * 子控制器首先会判断下自己是不是modal出来
    * 子控制器会去找父控制器有没有Modal,如果Modal,就会dismiss父控制器

### 网易新闻例子

网易新闻实现步骤:
1. 搭建结构(导航控制器)
    * 自定义导航控制器根控制器NewsViewController
    * 搭建NewsViewController界面(上下滚动条)
    * 确定NewsViewController有多少个子控制器,添加子控制器
2. 设置上面滚动条标题
    * 遍历所有子控制器
3. 监听滚动条标题点击
    * 3.1 让标题选中，文字变为红色 
    * 3.2 滚动到对应的位置
    * 3.3 在对应的位置添加子控制器view
4. 监听滚动完成时候
    * 4.1 在对应的位置添加子控制器view
    * 4.2 选中子控制器对应的标题
    
    
    
[willMoveToParentViewController和didMoveToParentViewController - yongyinmg的专栏 - CSDN博客](https://blog.csdn.net/yongyinmg/article/details/40619727)
    
```objc
- (void)addChildViewController:(UIViewController *)childController

- (void) removeFromParentViewController

- (void)transitionFromViewController：：：：：：

- (void)willMoveToParentViewController:(UIViewController *)parent

- (void)didMoveToParentViewController:(UIViewController *)parent

```
    
[父视图控制器 addChildViewController:子视图控制器];

在此，**图控制器A**添加了另一个**图控制器B**，那么A充当父视图控制器，B充当子视图控制器。父视图控制器充当了视图控制器容器的角色。

#### addChildViewController

- (void)addChildViewController:(UIViewController *)childController

向视图控制器容器中添加子视图控制器

childController：子视图控制器

当要添加的子视图控制器已经包含在视图控制器容器中，那么，相当于先从父视图控制器中删除，然后重新添加到父视图控制器中。

#### removeFromParentViewController 

- (void)removeFromParentViewController

从父视图控制器中删除。

#### transitionFromViewController 

- (void)transitionFromViewController:(UIViewController *)fromViewControllertoViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion

交换两个子视图控制器的位置（由于添加的顺序不同，所以子试图控制器在父视图控制器中存在层次关系）

fromViewController：当前显示的子试图控制器，将被替换为非显示状态

toViewController：将要显示的子视图控制器

duration：交换动画持续的时间，单位秒

options：动画的方式

animations：动画Block

completion：完成后执行的Block

#### willMoveToParentViewController

- (void)willMoveToParentViewController:(UIViewController *)parent

当一个视图控制器从视图控制器容器中被添加或者被删除之前，该方法被调用

parent：父视图控制器，如果没有父视图控制器，将为nil

注意点：

1. **当我们向我们的视图控制器容器中调用removeFromParentViewController方法时，必须要先调用该方法，且parent参数为nil**：

[将要删除的视图控制器 willMoveToParentViewController:nil];

2. 当我们调用addChildViewController方法时，在添加子视图控制器之前将自动调用该方法。所以，就不需要我们显示调用了。

#### didMoveToParentViewController 

```objc
- (void)didMoveToParentViewController:(UIViewController *)parent
```

* 当从一个视图控制容器中添加或者移除viewController后，该方法被调用。

parent：父视图控制器，如果没有父视图控制器，将为nil

* 当我们向我们的视图控制器容器（就是父视图控制器，它调用addChildViewController方法加入子视图控制器，它就成为了视图控制器的容器）中添加（或者删除）子视图控制器后，必须调用该方法，告诉iOS，已经完成添加（或删除）子控制器的操作。

removeFromParentViewController 方法会自动调用了该方法，所以，删除子控制器后，不需要在显示的调用该方法了。

其实，这几个方法中的API说明，看的还懂。

最后，

#### 关于willMoveToParentViewController方法和 didMoveToParentViewController方法的使用

1. 这两个方法用在子试图控制器交换的时候调用！即调用transitionFromViewController 方法时，调用。

2. 当调用willMoveToParentViewController方法或didMoveToParentViewController方法时，要注意他们的参数使用：

当某个子视图控制器将从父视图控制器中删除时，parent参数为nil。

即：[将被删除的子试图控制器 willMoveToParentViewController:nil];

当某个子试图控制器将加入到父视图控制器时，parent参数为父视图控制器。

即：[将被加入的子视图控制器 didMoveToParentViewController:父视图控制器];

3. 无需调用[子视图控制器 willMoveToParentViewController:父视图控制器]方法。因为我们调用[父视图控制器 addChildViewController:子视图控制器]时，已经默认调用了。

只需要在transitionFromViewController方法后，调用[子视图控制器didMoveToParentViewController:父视图控制器];

4. 无需调用[子视图控制器 didMoveToParentViewController:父视图控制器]方法。因为我们调用

[子视图控制器 removeFromParentViewController]时，已经默认调用了。

只需要在transitionFromViewController方法之前调用：[子视图控制器 willMoveToParentViewController:nil]。
    

### appearance callbacks的传递

上面的实现中有一个问题，就是没看到那些appearance callbacks是如何传递的，答案就是appearance callbacks默认情况下是自动调用的，苹果框架底层帮你实现好了，也就是在上面的addSubview的时候，在subview真正加到父view之前，child的viewWillAppear将被调用，真正被add到父view之后，viewDidAppear会被调用。移除的过程中viewWillDisappear，viewDidDisappear的调用过程也是类似的。

 

有时候自动的appearance callbacks的调用并不能满足需求，比如child view的展示有一个动画的过程，这个时候我们并不想viewDidAppear的调用在addSubview的时候进行，而是等展示动画结束后再调用viewDidAppear。

 

也许你可能会提到 transitionFromViewController:toViewController:duration:options:animations:completion: 这个方法，会帮你自动处理view的add和remove，以及支持animations block，也能够保证在动画开始前调用willAppear或者willDisappear，在调用结束的时候调用didAppear，didDisappear，但是此方式也存在局限性，必须是两个新老子VC的切换，都不能为空，因为要保证新老VC拥有同一个parentViewController，且参数中的viewController不能是系统中的container，比如不能是UINavigationController或者UITabbarController等。

 

所以如果你要自己写一个界面容器往往用不了appearence callbacks自动调用的特性，需要将此特性关闭，然后自己去精确控制appearance callbacks的调用时机。


## 参考

1. [View Controller Programming Guide for iOS: The Role of View Controllers](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457)
2. [When Should You Override viewDidLayoutSubviews? | iOS Insight](http://www.iosinsight.com/override-viewdidlayoutsubviews/)
3. [ios - Difference between layoutSubviews() and viewWillLayoutSubviews() - Stack Overflow](https://stackoverflow.com/questions/39606077/difference-between-layoutsubviews-and-viewwilllayoutsubviews?rq=1)
