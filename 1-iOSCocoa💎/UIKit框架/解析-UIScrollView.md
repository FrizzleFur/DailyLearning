# 解析-UIScrollView

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190201204029.png)

当然，在scroll view中有很多具有代表性的视图。为了实现这个平移功能，当用户移动手指时，你需要时刻改变每个视图的frames。当我们提出组合一个view的光栅化图片到它父视图什么地方时，记住这个公式：

```objc
CompositedPosition.x = View.frame.origin.x - Superview.bounds.origin.x;
CompositedPosition.y = View.frame.origin.y - Superview.bounds.origin.y; 
```

我们减少Superview.bounds.origin的值(因为他们总是0)。但是如果他们不为0呢？我们用和前一个图例相同的frames，但是我们改变了紫色视图bounds的origin为{-30,-30}。得到下图：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190201204111.png)


## UIScrollView代理delegate

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190202113101.png)


```objc
 // scrollView 正在滚动的时候调用  偏移量一直变化
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
 // scrollView正在缩放
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
   // 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
 // 即将停止拖拽的时候调用
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0);
 // 已经停止拖拽调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
 // scrollView即将开始减速
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
  // scrollView 停止减速  停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
  // scrollView 停止滚的的动画
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
  // 在scrollView中  哪些控件是需要缩放的
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
  // scrollView即将开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2);
  // scrollView结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;
  // scrollView 即将滚动到顶部
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;
  // scrollView 已经滚动到顶部
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;
```


## 内容缩放

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190202113441.png)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190202113505.png)

### 缩放实现步骤


跟缩放相关的其他代理方法
准备开始缩放的时候调用 

```objc
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
``` 
正在缩放的时候调用
```objc
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
 
   核心代码:设置内容大小
     contentSize.height == 0 设置为0仅仅代表竖直方向上不能滚动
    self.scrollView.contentSize = CGSizeMake(count * w, 0);
    
     分页
     每一页的尺寸都是跟scrollView的frame.size一样的
    self.scrollView.pagingEnabled = YES; 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
     --四舍五入为整数的方法--  (int)(小数 + 0.5)
     0.3  -> (int)(0.3 + 0.5) == 0
     0.4 -> (int)(0.4 + 0.5) == 0
     1.5 -> (int)(1.5 + 0.5) == 2
     0.7 -> (int)(0.7 + 0.5) == 1
     小数加上0.5再转换成整数,这样页码显示的就是正确的页数(仔细想)
    int page = (int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5);
    self.pageControl.currentPage = page;
}
 
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}
``` 

## 分页


只要将UIScrollView的pageEnabled属性设置为YES，UIScrollView会被分割成多个独立页面，里面的内容就能进行分页展示
一般会配合UIPageControl增强分页效果，UIPageControl常用属性如下 
 
 ```objc
一共有多少页
@property(nonatomic) NSInteger numberOfPages;
当前显示第几页
@property(nonatomic) NSIntegercurrentPage; 
只有一页时，是否需要隐藏页码指示器
@property(nonatomic) BOOL hidesForSinglePage; 
其他页码指示器的颜色
@property(nonatomic,retain) UIColor *pageIndicatorTintColor;
当前页码指示器的颜色
@property(nonatomic,retain) UIColor *currentPageIndicatorTintColor;
```

## 滚动方向

scrollViewDidScroll: 方法中，先获取 scrollView 的 panGestureRecognizer（拖拽/移动动作）手势，然后把手势滑动的相对偏移在当前 view 上转换成一个 point，最后根据 point 的 x 或 y 来判©断左右/上下滚动方向，代码如下：


```objc
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint point = [scrollView.panGestureRecognizer translationInView:self.view];
    if (point.y > 0) {
        // 向下滚动
    } else {
        // 向上滚动
    }
}
```
老方法：

```objc
// @property (nonatomic, assign) CGFloat lastContentOffset;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        // 向下滚动
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        // 向上滚动
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}
```



## 减速速率

`UIScrollViewDecelerationRate`

decelerationRate: 手指滑动后抬起，页面的减速速率。可以使用UIScrollViewDecelerationRateNormal和UIScrollViewDecelerationRateFast常量值来设置合理的减速速率。

```objc

@property(nonatomic)         UIScrollViewDecelerationRate decelerationRate NS_AVAILABLE_IOS(3_0);

typedef CGFloat UIScrollViewDecelerationRate NS_TYPED_ENUM;

UIKIT_EXTERN const UIScrollViewDecelerationRate UIScrollViewDecelerationRateNormal NS_AVAILABLE_IOS(3_0);
UIKIT_EXTERN const UIScrollViewDecelerationRate UIScrollViewDecelerationRateFast NS_AVAILABLE_IOS(3_0);
```



## 问题

### UIScrollView无法滚动

第一步：确定 UIScrollView 对象的 contentSize 属性是否大于父视图

```objc
// 设置 contentSize 属性为指定宽高
scrollView.contentSize = CGSizeMake(width, height)

```

第二步: 检查设置 contentSize 的语句在哪个方法中
上面的语句不能放在 viewDidLoad() 方法当里，在 iOS 8 以上可以放在 viewDidAppear() 方法中。而在 iOS 7 ，可以参考iOS7 下 UIScrollView 无法滑动 中提到的方法，放在 viewDidLayoutSubviews() 方法中。

