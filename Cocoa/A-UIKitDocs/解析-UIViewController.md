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

## isViewLoaded

控制器的View是否已经加载完，在判断子控制器view加载的时候使用。
A Boolean value indicating whether the view is currently loaded into memory.

```objc
ViewController.isViewLoaded
```

## viewWillLayoutSubviews

当视图边界发生变化时，视图会调整其子视图的位置。在视图布局其子视图之前，视图控制器可以覆盖此方法以进行更改。 

viewWillLayoutSubviews在视图控制器的视图边界发生更改时调用（通常在视图加载或旋转更改时发生，或者如果它是子视图控制器，并且其视图由父视图控制器更改），但在其子视图的边界或位置更改之前调用。您可以覆盖此方法，以便在视图布局之前对子视图的边界或位置进行一些更改。

只要视图控制器的视图更改了边界，就会调用viewWillLayoutSubviews。加载视图，发生旋转事件或子视图控制器的大小由其父级更改时，会发生这种情况。 （也可能还有其他一些情况）。如果在视图自行放置之前需要更新任何内容（并且在重新应用约束之前），则应在此处执行此操作。你通常不应该在这里更新约束，因为更新约束会导致另一个布局传递。


[ios - Difference between layoutSubviews() and viewWillLayoutSubviews() - Stack Overflow](https://stackoverflow.com/questions/39606077/difference-between-layoutsubviews-and-viewwilllayoutsubviews?rq=1)

## viewDidLayoutSubviews


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

## 子控制器

* 控制器的view在,控制器被销毁。
* 控制器不存在,控制器的view也是可以存在
* 当控制器view存在,控制器不存在，会导致控制器view上面的所有事件都不能处理
* ARC管理原则;只要一个对象没有被强引用,就会被销毁

![](http://oc98nass3.bkt.clouddn.com/15388740190329.jpg)

由于创建的VC都是局部变量，因此在创建方法走完之后，局部变量VC被销毁，但是VC的view加入到self.view的subviews数组中，被当前VC强引用。因此没有被释放。

### 建立“父子关系”

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
    
## 参考

1. [View Controller Programming Guide for iOS: The Role of View Controllers](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457)