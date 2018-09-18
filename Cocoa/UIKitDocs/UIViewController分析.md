
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
