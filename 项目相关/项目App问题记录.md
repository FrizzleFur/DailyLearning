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

## 网页加载完返回的崩溃en

原因：加载网页会调用多次，每次去pop造成页面崩溃。

```objc
- (void)webViewDidFinishLoad:(UIWebView *)webView {
 // call request
     [[HttpClient sharedClient] postRequest:HTTP_COMMAND_HITS_BINDHITSACCOUNT serviceType:(HTTP_SERVICE_USER) params:params success:^(id responseObject) {
// success
    // 返回上个页面，web需要置空
    [self.navigationController popViewControllerAnimated:true];
```

## 隐藏导航的时候露出状态白线

```objc
 // 取消自动调整内容内间距
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
    」
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

科普Bitcode: 

说的是bitcode是被编译程序的一种中间形式的代码。包含bitcode配置的程序将会在App store上被编译和链接。bitcode允许苹果在后期重新优化程序的二进制文件，而不需要重新提交一个新的版本到App store上。
当提交程序到App store上时，Xcode会将程序编译为一个中间表现形式(bitcode)。然后App store会再将这个botcode编译为可执行的64位或32位程序。

所以，如果我们的工程需要支持bitcode，则必要要求所有引入的第三方库都支持bitcode。
* [Xcode7新特性之bitcode - 雅香小筑 - CSDN博客](https://blog.csdn.net/mylizh/article/details/50499689)
* [What is app thinning? (iOS, tvOS, watchOS) - Xcode Help](https://help.apple.com/xcode/mac/current/#/devbbdc5ce4f)

    bitcode是什么鬼？以前咋没听过，在经过与度娘多次交涉之后终于有点明白了。

    我们知道，计算机软件必须要经过编译和链接过程，生成可执行代码之后才能够在设备上运行，要想弄明白bitcode是什么，就需要从编译器入手。

    传统的静态编译器工作过程可分为三个阶段：前端、优化和后端。


    而iOS代码使用的编译器是LLVM（关于LLVM后面会有专门的文章详细介绍），LLVM的三个阶段如下图所示：

    由上图可以看出，LLVM编译生成中间码IR（Intermediate Representation）,而非目标代码，这里所说的中间码IR就是我们想要知道的bitcode。


    使用中间码有以下三个优点：


    1. 如果需要支持一种新的编程语言，只需要实现一种新的前端；
    2. 如果需要支持一种新的硬件，只需要实现一种新的后端；
    3. 无论增加对新语言的支持，还是增加对新硬件的支持，中间的优化阶段都不需要改变；


    这样就实现了前后端的分离。


    由于上述优点，中间码已经被越来越多的编译器所采用，传统的编译器多采用汇编语言作为自己的中间语言，而现在大一些的编译器都有了自己专属的中间码。


    弄明白了bitcode是何方神圣之后，错误原因就不难找出：
    Xcode 7要求提交到AppStore的代码必须包含中间码（bitcode），而OpenCV属于第三方库，是之前从官网下     载的，在编译时并没有生成bitcode，所以链接时候找不到OpenCV的bitcode，因而报错。

 
 ## NSMutableArray 深浅拷贝的类型问题

 把NSMutableArray用copy修饰有时就会crash，因为对这个数组进行了增删改操作，而copy后的数组变成了不可变数组NSArray，没有响应的增删改方法，所以对其进行增删改操作就会报错。


```objc
/** 商品列表 */
@property (nonatomic, copy) NSMutableArray <ProductModel *>*productModelList;

```

NSMutableArray用copy修饰之后，在使用addObjectsFromArray方法时崩溃

error：[__NSFrozenArrayM addObjectsFromArray:]: unrecognized selector

这个错误误导点：ArrayM这个让开发者认为是可变数组。但是因为你是用copy修饰的，所以这个数组其实是一个不可变数组。

这个问题主要是误写导致的，只需要把copy改成strong。

参考 [copy修饰可变数组造成的问题 - 简书](https://www.jianshu.com/p/29641ab41a39)


 
## 条件判断
 
 在比较数据的时候，一个判断条件

```
    if (lastList.count == currentList.count)

```
* 如果lastList.count为0. 就直接跳出了条件判断！
 
 
``` objc
/** 比较关注列表 */
- (BOOL)compareFocusListByLastList:(NSArray<StarModel *> *)lastList currentList:(NSArray<StarModel *> *)currentList{
    __block BOOL hasFocusListChanged = false;// 关注列表是否改变
    // 比较关注数量
    if (lastList.count == currentList.count){
        //个数相同的情况，比较每个的id是否一样
        [lastList enumerateObjectsUsingBlock:^(StarModel * _Nonnull lastModel, NSUInteger idx, BOOL * _Nonnull stop) {
            // 使用starId判断是否是同一个明星
            NSPredicate *starIdPredicate = [NSPredicate predicateWithFormat:@"starId = %@", lastModel.starId];
            // 是否含有相同starId的StarModel
            NSArray *sameStarModelArr = [currentList filteredArrayUsingPredicate:starIdPredicate];
            // 当前列表找到不到该starId的StarModel --> 发生了改变
            if (sameStarModelArr.count == 0){
                hasFocusListChanged = true;
                *stop = true;// 有变化则停止遍历
            }
        }];
    }else{
        // 关注数量发生变化
        hasFocusListChanged = true;
    }

```
 
 
 
 
 
## 参考

1. [iphone - EXC_BAD_ACCESS in UIWebView - Stack Overflow](https://stackoverflow.com/questions/1520674/exc-bad-access-in-uiwebview)