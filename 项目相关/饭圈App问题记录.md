## 饭圈App问题记录



### 首页下拉和吸顶的问题


#### 需求： 

需要一个包含头视图的类似网易新闻的tabBar，下面是列表的结构.

* tabbar在顶部顶部下面的时候，整体外部滚动。
* tabbar在滚动到顶部的时候吸顶，切换到子视图滚动。
* 支持整体下拉刷新。

![](http://oc98nass3.bkt.clouddn.com/15393193121117.jpg)

这里使用了通知来监听内外层ScrollView滚动的偏移量


1. 

在用户点击内层scrollView进行拉去的时候，需要让外层也获取到滚动，所以外层的scrollView需要接受到内层的滚动范围。

```objc

@interface GestureScrollView : UIScrollView

/** 同时识别多个手势
 @param gestureRecognizer gestureRecognizer description
 @param otherGestureRecognizer otherGestureRecognizer description
 @return return value description
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

```




在主视图中，保存子视图的滑动视图。



```objc
/** 子VC的滚动视图scrollView */
@property (nonatomic, strong) UIScrollView *childVCScrollView;
#pragma mark - NSNotification

- (void)handleSubScrollDidScroll:(NSNotification *)notification{
    UIScrollView *subScroll = notification.userInfo[kPostSubScrollView];
    if (![subScroll isKindOfClass:[UIScrollView class]]) return;
    self.childVCScrollView = subScroll;
    BOOL mainScrollEnable = (self.mScrollView.mj_offsetY < self.tabBar.top);
    if (mainScrollEnable) [subScroll setContentOffset:CGPointZero];
}
```
1. 主视图滚动时


```objc
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = self.mScrollView.contentOffset.y;
    // 主视图是否偏移到临界点
    BOOL mainScrollOffInChild = offsetY > self.tabBar.top;
    // 子视图是否偏移
    BOOL childScrollOffs = (self.childVCScrollView && _childVCScrollView.contentOffset.y > 0);
    
    if (mainScrollOffInChild || childScrollOffs) {
        // 滚到子视图范围内
        [self.mScrollView setContentOffset:CGPointMake(0, self.tabBar.top)];
    }else{
        // 在外主视图范围内
        [[NSNotificationCenter defaultCenter] postNotificationName:kPostSubScrollViewScrollToTop object:nil];
    }
}
```

1. 子视图添加监听，如果主视图通知子视图，滚动在外主视图范围内，则让视图的scroll滚动到顶部

```objc
/** 让视图的scroll滚动到顶部 */
- (void)childScrollViewScrollToTop {
    _collectionView.contentOffset = CGPointZero;
}

```

参考 [Avenger-10-12首页滚动问题未改动备份](https://github.com/SPStore/HVScrollView)