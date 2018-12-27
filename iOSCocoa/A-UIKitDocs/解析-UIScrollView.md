# 解析-UIScrollView



### UIScrollView无法滚动

第一步：确定 UIScrollView 对象的 contentSize 属性是否大于父视图
    // 设置 contentSize 属性为指定宽高
    scrollView.contentSize = CGSizeMake(width, height)

第二步: 检查设置 contentSize 的语句在哪个方法中
上面的语句不能放在 viewDidLoad() 方法当里，在 iOS 8 以上可以放在 viewDidAppear() 方法中。而在 iOS 7 ，可以参考iOS7 下 UIScrollView 无法滑动 中提到的方法，放在 viewDidLayoutSubviews() 方法中。

