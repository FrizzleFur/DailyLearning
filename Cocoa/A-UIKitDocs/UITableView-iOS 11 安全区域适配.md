# UITableView-iOS 11 安全区域适配



本文为作者原创，未经作者允许不得转载。该文同时发表在腾讯bugly公众号：[http://mp.weixin.qq.com/s/W1_0VrchCO50owhJNmJnuQ](https://link.jianshu.com?t=http://mp.weixin.qq.com/s/W1_0VrchCO50owhJNmJnuQ) 欢迎阅读

导语：本文主要是对iOS 11下APP中`tableView`内容下移20pt或下移64pt的问题适配的一个总结。内容包括五个部分：问题的原因分析、`adjustContentInset`属性的计算方式、什么情况下的`tableView`会发生内容下移、有哪些解决方法、解决这个问题时遇到的另外一个小问题。

### 一、iOS 11下APP中tableView内容下移20pt或下移64pt的原因分析

问题如下图所示：

![](//upload-images.jianshu.io/upload_images/927233-558062c2a3cd2ac9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/344/format/webp)

问题.png

#### 1\. 原因分析

原因是iOS 11中Controller的`automaticallyAdjustsScrollViewInsets`属性被废弃了，所以当tableView超出安全区域时系统自动调整了`SafeAreaInsets`值，进而影响`adjustedContentInset`值，在iOS 11中决定tableView的内容与边缘距离的是`adjustedContentInset`属性，而不是`contentInset`。`adjustedContentInset`的计算方式见本文第二部分内容。因为系统对`adjustedContentInset`值进行了调整，所以导致tableView的内容到边缘的距离发生了变化，导致tableView下移了20pt（statusbar高度）或64pt（navigationbar高度）。

如果你的APP中使用的是自定义的navigationbar，隐藏掉系统的navigationbar，并且tableView的frame为(0,0,SCREEN_WIDTH, SCREEN_HEIGHT)开始，那么系统会自动调整SafeAreaInsets值为(20,0,0,0)，如果使用了系统的navigationbar，那么`SafeAreaInsets`值为(64,0,0,0)，如果也使用了系统的tabbar，那么`SafeAreaInsets`值为(64,0,49,0)。关于什么情况下会发生内容下移的问题，本文第三部分有介绍。

#### 2\. 安全区域的概念

系统自动调整tableView内容偏移量，是根据安全区域来调整的。安全区域是iOS 11新提出的，如下图所示：

![](//upload-images.jianshu.io/upload_images/927233-a9933365dabc2532.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/655/format/webp)

SafeArea of an interface.png

安全区域帮助我们将view放置在整个屏幕的可视的部分。即使把navigationbar设置为透明的，系统也认为安全区域是从navigationbar的bottom开始的。
安全区域定义了view中可视区域的部分，保证不被系统的状态栏、或父视图提供的view如导航栏覆盖。可以使用`additionalSafeAreaInsets`去扩展安全区域去包括自定义的content在你的界面。每个view都可以改变安全区域嵌入的大小，Controller也可以。

`safeAreaInsets`属性反映了一个view距离该view的安全区域的边距。对于一个Controller的根视图而言，`SafeAreaInsets`值包括了被`statusbar`和其他可视的bars覆盖的区域和其他通过`additionalSafeAreaInsets`自定义的insets值。对于view层次中得其他view，`SafeAreaInsets`值反映了view被覆盖的部分。如果一个view全部在它父视图的安全区域内，则`SafeAreaInsets`值为(0,0,0,0)。

### 二、 adjustContentInset属性的计算方式

首先看scrollView在iOS11新增的两个属性：`adjustContentInset` 和 `contentInsetAdjustmentBehavior`。

```
/* Configure the behavior of adjustedContentInset.
Default is UIScrollViewContentInsetAdjustmentAutomatic.
*/
@property(nonatomic) UIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior

```

`adjustContentInset`表示contentView.frame.origin偏移了scrollview.frame.origin多少；是系统计算得来的，计算方式由`contentInsetAdjustmentBehavior`决定。有以下几种计算方式：

1.  `UIScrollViewContentInsetAdjustmentAutomatic`：如果scrollview在一个automaticallyAdjustsScrollViewInsets = YES的controller上，并且这个Controller包含在一个navigation controller中，这种情况下会设置在top & bottom上 adjustedContentInset = safeAreaInset + contentInset不管是否滚动。其他情况下与`UIScrollViewContentInsetAdjustmentScrollableAxes`相同

2.  `UIScrollViewContentInsetAdjustmentScrollableAxes`: 在可滚动方向上adjustedContentInset = safeAreaInset + contentInset，在不可滚动方向上adjustedContentInset = contentInset；依赖于scrollEnabled和alwaysBounceHorizontal / vertical = YES，scrollEnabled默认为yes，所以大多数情况下，计算方式还是adjustedContentInset = safeAreaInset + contentInset

3.  `UIScrollViewContentInsetAdjustmentNever`: adjustedContentInset = contentInset

4.  `UIScrollViewContentInsetAdjustmentAlways`: adjustedContentInset = safeAreaInset + contentInset

当`contentInsetAdjustmentBehavior`设置为UIScrollViewContentInsetAdjustmentNever的时候，adjustContentInset值不受`SafeAreaInset`值的影响。

### 三、什么情况下的tableView会发生上述问题

如果设置了automaticallyAdjustsScrollViewInsets = YES，那么不会发生问题，一直都是由系统来调整内容的偏移量。

接下来排查下自己的项目中哪些页面会发生以上问题。

当tableView的frame超出安全区域范围时，系统会自动调整内容的位置，`SafeAreaInsets`值会不为0，于是影响tableView的`adjustContentInset`值，于是影响tableView的内容展示，导致tableView的content下移了`SafeAreaInsets`的距离。`SafeAreaInsets`值为0时，是正常的情况。

需要了解每个页面的结构，看tableView是否被系统的statusbar或navigationbar覆盖，如果被覆盖的话，则会发生下移。也可以通过`tableview.safeAreaInsets`的值来确认是因为安全区域的问题导致的内容下移。

如下代码片段，可以看出系统对tableView向下调整了20pt的距离，因为tableView超出了安全区域范围，被statusbar覆盖。

```
tableview.contentInset: {64, 0, 60, 0}
tableview.safeAreaInsets: {20, 0, 0, 0}
tableview.adjustedContentInset: {84, 0, 60, 0}

```

### 四、这个问题的解决方法有哪些？

#### 1\. 重新设置tableView的contentInset值，来抵消掉SafeAreaInset值，因为内容下移偏移量 = contentInset + SafeAreaInset；

如果之前自己设置了`contentInset`值为(64,0,0,0),现在系统又设置了`SafeAreaInsets`值为(64,0,0,0)，那么tableView内容下移了64pt，这种情况下，可以设置`contentInset`值为(0,0,0,0)，也就是遵从系统的设置了。

#### 2\. 设置tableView的contentInsetAdjustmentBehavior属性

如果不需要系统为你设置边缘距离，可以做以下设置：

```
 //如果iOS的系统是11.0，会有这样一个宏定义“#define __IPHONE_11_0  110000”；如果系统版本低于11.0则没有这个宏定义
#ifdef __IPHONE_11_0   
if ([tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
    tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}
#endif

```

`contentInsetAdjustmentBehavior`属性也是用来取代`automaticallyAdjustsScrollViewInsets`属性的，推荐使用这种方式。

#### 3\. 通过设置iOS 11新增的属性addtionalSafeAreaInset；

iOS 11之前，大家是通过将Controller的`automaticallyAdjustsScrollViewInsets`属性设置为NO，来禁止系统对tableView调整`contentInsets`的。如果还是想从Controller级别解决问题，那么可以通过设置Controller的`additionalSafeAreaInsets`属性，如果`SafeAreaInset`值为(20,0,0,0)，那么设置`additionalSafeAreaInsets`属性值为(-20,0,0,0)，则`SafeAreaInsets`不会对`adjustedContentInset`值产生影响，tableView内容不会显示异常。这里需要注意的是`addtionalSafeAreaInset`是Controller的属性，要知道`SafeAreaInset`的值是由哪个Controller引起的，可能是由自己的Controller调整的，可能是navigationController调整的。是由哪个Controller调整的，则设置哪个Controller的`addtionalSafeAreaInset`值来抵消掉`SafeAreaInset`值。

### 五、遇到的另外一个与安全区域无关的tableView内容下移的问题

我的作品页面的tableView下移了约40pt，这里是否跟安全区域有关呢？

查了下页面结构，tableView的父视图的frame在navigationbar的bottom之下，tableView在父视图的安全区域内，打印出来tableView的SafeAreaInset值也是(0，0，0，0);所以不是安全区域导致的内容下移。

经过查看代码，发现tableView的`style:UITableViewStyleGrouped`类型，默认tableView开头和结尾是有间距的，不需要这个间距的话，可以通过实现heightForHeaderInSection方法（返回一个较小值：0.1）和viewForHeaderInSection（返回一个view）来去除头部的留白，底部同理。

iOS 11上发生tableView顶部有留白，原因是代码中只实现了heightForHeaderInSection方法，而没有实现viewForHeaderInSection方法。那样写是不规范的，只实现高度，而没有实现view，但代码这样写在iOS 11之前是没有问题的，iOS 11之后应该是由于开启了估算行高机制引起了bug。添加上viewForHeaderInSection方法后，问题就解决了。或者添加以下代码关闭估算行高，问题也得到解决。

```
self.tableView.estimatedRowHeight = 0;
self.tableView.estimatedSectionHeaderHeight = 0;
self.tableView.estimatedSectionFooterHeight = 0;
```

### 解决iOS11，仅实现heightForHeaderInSection，没有实现viewForHeaderInSection方法时,section间距大的问题

```
//解决iOS11，仅实现heightForHeaderInSection，没有实现viewForHeaderInSection方法时,section间距大的问题
[UITableView appearance].estimatedRowHeight = 0;
[UITableView appearance].estimatedSectionHeaderHeight = 0;
[UITableView appearance].estimatedSectionFooterHeight = 0;

//iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
if (@available(iOS 11, *)) {
[UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; //iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
}

```
## 参考

1. [iOS 11 安全区域适配总结 - 简书](https://www.jianshu.com/p/efbc8619d56b?utm_campaign=hugo&utm_medium=reader_share&utm_content=note&utm_source=weixin-friends)