
## UIViewController分析

### 生命周期
![](http://oc98nass3.bkt.clouddn.com/15370956857629.jpg)


注意到其中的viewWillLayoutSubviews和viewDidLayoutSubviews，调用情况视具体的viewDidLoad和viewWillAppear等方法中的代码而定。

#### viewWillLayoutSubviews调用情况分析

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
