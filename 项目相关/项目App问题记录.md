## 项目App问题记录

### 首页下拉和吸顶的问题

首页先往上拉，在下拉，就无法获取ScrollView正确的contentOffset，造成MJ的Inset错误刷新失效！！在`handleSubScrollDidScroll`方法中有问题，可否KVO
1. child scrollview的bounce需要设置，以便在临界点触发过度阶段。
2. 下拉过程，快速滑动的过程中，child scrollview超过临界点后contentOffsetY每次被更新为0，然后main scrollview会停止滚动。
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

### 首页滚动右侧范围点击失去焦点

首页切换到明星主页，然后回到主页，往上滚动一点，右侧点击范围不到，点击左侧后又恢复了。修改了明星主页的Scroll特性后，发现是关闭全局的滚动调整后就会影响到滚动间距的问题`[[UIScrollView appearance] setContentInsetAdjustmentBehavior:(UIScrollViewContentInsetAdjustmentNever)];`

用于确定调整后的内容偏移的行为。
此属性指定如何使用安全区域insets来修改滚动视图的内容区域。此属性的默认值为UIScrollViewContentInsetAdjustmentAutomatic。


## 网页加载完返回的崩溃

原因：加载网页会调用多次，每次去pop造成页面崩溃。

```objc
- (void)webViewDidFinishLoad:(UIWebView *)webView {
 // call request
     [[HttpClient sharedClient] postRequest:HTTP_COMMAND_HITS_BINDHITSACCOUNT serviceType:(HTTP_SERVICE_USER) params:params success:^(id responseObject) {
// success
    // 返回上个页面，web需要置空
    [self.navigationController popViewControllerAnimated:true];
```

## 浮层的动画问题

```objc
// 在动画期间，对于要动画的视图暂时禁用用户交互
// 原因是对UIView的动画理解还不够，执行的时候，从之前的状态到动画终点的状态，然后是完成的回调。
// 之前的问题代码
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
        self->taskFloatView.bottom = self.view.bottom;
    } completion:^(BOOL finished) {
        self->taskFloatView.bottom = self.view.bottom;
        self->taskFloatView.hidden = false;
    }];

// 修改后的代码
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
        self->taskFloatView.hidden = false;
        self->taskFloatView.bottom = self.view.bottom;
    } completion:nil];

```

## hitTest方法的调用

 Tabbar中间Item按钮，二级页里也会触发.原因:检测tabbar中间点击范围的时候，调用hitTest方法中返回了starTabBarBtn，导致调用UITabBarController的点击事件代理。
 
 
 
## HTML转富文本

```objc
NSString * htmlString = @"<html><body> Some html string </body></html>";
NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

UILabel * myLabel = [[UILabel alloc] init];
myLabel.attributedText = attrStr;
```


```objc
- (NSAttributedString *)attributedStringWithHTMLString:(NSString *)htmlString

{

NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,

NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding) };

NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];

return [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];

}
```
 
- 参考：
    - 1. [How to show an HTML string on a UILabel in iOS? - Stack Overflow](https://stackoverflow.com/questions/19946251/how-to-show-an-html-string-on-a-uilabel-in-ios)
    - 2. [iOS 开发_NSAtrributeString与HTML之间的相互转换 - 简书](https://www.jianshu.com/p/aa92f597ed55)
 
 
## 打包问题

```objc
ld: could not reparse object file in bitcode bundle: 'Invalid bitcode version (Producer: '1000.11.45.2_0' Reader: '902.0.39.2_0')', using libLTO version 'LLVM version 9.1.0, (clang-902.0.39.2)' for architecture armv7
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

![](https://i.loli.net/2018/10/26/5bd2ac06c93f2.jpg)

分析：
项目中框架是使用Xcode 10编译的，但我使用的是Xcode 9.4.1（看起来像900.0.39.2_0是Xcode 9.2而902.0.39.2_0是Xcode 9.4）。我通过在Build Settings中暂时将Enable Bitcode设置为No来解决它。

解决： [ios - VSTS Build Generation throwing Invalid bitcode version error - Stack Overflow](https://stackoverflow.com/questions/51128462/vsts-build-generation-throwing-invalid-bitcode-version-error)

 
## 参考

1. [iphone - EXC_BAD_ACCESS in UIWebView - Stack Overflow](https://stackoverflow.com/questions/1520674/exc-bad-access-in-uiwebview)