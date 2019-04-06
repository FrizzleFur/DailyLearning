


## iOS和安卓


还需要补充说明的是，作为苹果这样一个使用闭源框架和设计主导的公司，其特点其实在控件中有所体现。Google的感觉就是扔给你一堆控件你可以随意组合，自由搭配。虽然都是给你一堆控件，但是苹果已经给你制定好了一些规范，并推荐应该怎样做。例如用UINavigationController创建一个需要层次化流程的界面，用UITarBarController创建我们大多数App 的主要功能页，用UIPageControl创建引导页或者广告栏，用UISearchBar创建搜索栏。Android中虽然有类似的比如TabHost这种控件，但是想要创造UITarBarController和UINavigationController搭配的效果，还是需要很多代码的。就这点来看，iOS方便了很多，只需要一些简单的官方控件就能构建起一个App。

[Android & iOS 开发全面对比分析 - AT弄潮儿 - CSDN博客](https://blog.csdn.net/z4909801/article/details/75003870)


学习Android 的过程中，扑面而来的概念是Android的四大组件，而最重要的组件莫非Activity，强调一个Activity就是一个界面，而笔者在IOS 的学习过程中（看了《疯狂iOS》、《精通iOS开发》）都没有强调这个概念，而且对界面的跳转也没有做详细说明，也没有对UIViewController的管理做说明，笔者很是笔者一直在iOS 中寻找与Android对应的四大组件，首先UIViewController其实就是对应的Activity，UIViewController生命周期也与Activity的很类似。

Activity在onCreate()中初始化操作, 在onResume()中可以加一些改变界面和状态的操作。 
UIViewController在 -viewDidLoad中初始化操作, 在-viewWillAppear 中可以加一些改变界面和状态的操作。

UIViewController整个生命周期：-viewDidLoad–> -viewWillAppear–> -viewDidAppear –> 运行态–> -viewWillDisAppear–> -viewDidDisAppear-> -viewDidUnload。

Android的Activity是由Activity栈进管理，当来到一个新的Activity后，此Activity将被加入到Activity栈顶，之前的Activity位于此Activity底部。可以设置Activity的taskAffinity和launchMode，以改变Activity入栈的形式。

iOS没有UIViewController启动模式，但提供有三种对视图的管理方式：

UITabBarController：以平行的方式管理视图，各个视图之间往往关系并不大，每个加入到UITabBarController的视图都会进行初始化即使当前不显示在界面上，相对比较占用内存。
UINavigationController：以栈的方式管理视图，各个视图的切换就是压栈和出栈操作，出栈后的视图会立即销毁
UIModalController：以模态窗口的形式管理视图，当前视图关闭前其它视图上的内容无法操作。调用presentViewController进入一个新的视图，调用dismissViewControllerAnimated会回到上一个视图。
另外Android可以自由控制一个Activity ，想要销毁一个Activity的时候，就调用finish函数。而iOS 使用了ARC，并不主动提供销毁UIViewController的方法，只有等内存不足时，自动销毁非前台的UIViewController，这点是不一样的。但是我们可以让通过以下操作UIViewController提前自动释放。 
1) 将任何引用到该controller的变量设置为空。 
2) [controller.view removeFromSuperview] 
3) controller.view = nil 
4) controller = nil

