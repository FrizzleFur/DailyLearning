# 解析-UIScrollView

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190201204029.png)

当然，在scroll view中有很多具有代表性的视图。为了实现这个平移功能，当用户移动手指时，你需要时刻改变每个视图的frames。当我们提出组合一个view的光栅化图片到它父视图什么地方时，记住这个公式：

```objc
CompositedPosition.x = View.frame.origin.x - Superview.bounds.origin.x;
CompositedPosition.y = View.frame.origin.y - Superview.bounds.origin.y; 
```

我们减少Superview.bounds.origin的值(因为他们总是0)。但是如果他们不为0呢？我们用和前一个图例相同的frames，但是我们改变了紫色视图bounds的origin为{-30,-30}。得到下图：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190201204111.png)


### UIScrollView无法滚动

第一步：确定 UIScrollView 对象的 contentSize 属性是否大于父视图

```objc
// 设置 contentSize 属性为指定宽高
scrollView.contentSize = CGSizeMake(width, height)

```

第二步: 检查设置 contentSize 的语句在哪个方法中
上面的语句不能放在 viewDidLoad() 方法当里，在 iOS 8 以上可以放在 viewDidAppear() 方法中。而在 iOS 7 ，可以参考iOS7 下 UIScrollView 无法滑动 中提到的方法，放在 viewDidLayoutSubviews() 方法中。

