## 代码技巧

### **1. 一种懒加载写法**

```   
if (!self.statusBar.superview) {
    [self.view addSubview:self.statusBar];
}

- (UIView *)statusBar {
    if (_statusBar == nil) {
        _statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUSBAR_HEIGHT)];
        _statusBar.backgroundColor = [UIColor blackColor];
    }
    return _statusBar;
}
```

### **2. UITableView的一种删除、添加cell后的刷新方法:**
```
[self.dataArray removeObjectsAtIndexes:indexs];
[self.tableView beginUpdates];
[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
   withRowAnimation:(UITableViewRowAnimationNone)];
[self.tableView endUpdates];
```

### **3. 字符串遍历**

```
（1） 通过查找的方式来(这方式适合所有格式的子符串，推荐使用)
   NSString *newStr =@"sdfdfs15dfdfdf15fdfdow们啊as阿达阿达打啊";
   NSString *temp =nil;
   for(int i =0; i < [newStr length]; i++)  
   {   
       temp = [newStr substringWithRange:NSMakeRange(i,1)];
       NSLog(@"第%d个字是:%@",i,temp);
   }  
NSRange hotTopicRange = [dynamicComplex.desc rangeOfString:hotTopicComplex.title];

```

### **4. 在解决tableView头部插入view的时候，SectionHeaderView的contentInset问题**

```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY < -bannerHeaderHeight) {
        topicDetailBannerView.top = contentOffsetY;
        topicDetailBannerView.height = -contentOffsetY;
    }
    //解决sectionHeader的问题
    if(contentOffsetY >= 0 ){
        scrollView.contentInset = UIEdgeInsetsZero;
    }else{
        scrollView.contentInset = UIEdgeInsetsMake(MIN(-contentOffsetY, bannerHeaderHeight), 0, 0, 0);
    }
}
```
![](http://oc98nass3.bkt.clouddn.com/2017-07-27-15011211526057.jpg)


### **5. 在计算UITableView中某个view在UITableView的位置，和tableHeaderView的联系**


发现获取`SectionHeaderView`的`y`坐标时，得减去`tableHeaderView`的高度，原因尚且未知。

```
    _tableView.contentInset = UIEdgeInsetsMake(bannerHeaderHeight, 0, 0, 0);

    CGFloat sectionHeaderBottom = sectionHeaderViewRect.origin.y + sectionHeaderViewRect.size.height - self.tableView.tableHeaderView.height;//减去tableHeaderView高度
```

![](http://oc98nass3.bkt.clouddn.com/2017-07-28-15012486582998.jpg)

### 6. **NSMutableArray addObject: -[__NSArrayI addObject:]: unrecognized selector sent to instance**


原因就是对`NSMutableArray`属性的定义没定好，

```
@property (nonatomic, strong) NSMutableArray *dynamicComplexList;/**< 动态列表 */
@property (nonatomic, copy) NSMutableArray *subscribeList;
```
`subscribeList`定义成`copy`的话是`immutable copy`不可变的数组 = = （还不是很知道）

```              
[self.subscribeList addObjectsFromArray:rsp.subscribeList];
```


参考 [iphone - NSMutableArray addObject: -[__NSArrayI addObject:]: unrecognized selector sent to instance - Stack Overflow](https://stackoverflow.com/questions/3220120/nsmutablearray-addobject-nsarrayi-addobject-unrecognized-selector-sent-t)

```
The synthesized setter for @property (copy) sends a copy message to the array, which results in an immutable copy.

You have no choice but the implement the setter yourself here, as detailed in the Objective-C guide.
```


### 7. 计算`SectionHeaderView`位置


```
        UIView *sectionHeaderView = [self.tableView headerViewForSection:0];
        CGRect sectionHeaderViewRect = [self.view convertRect:sectionHeaderView.frame toView:self.view];
        CGRect sectionHeaderViewRect = [self.view convertRect:sectionHeaderView.frame toView:self.view];
```

方式1：

```
        if (self.tableView.contentOffset.y >= self.sectionHeaderStayTop) {
            sectionHeaderBottom = self.naviBar.height + sectionHeaderView.height;
        }else{
            sectionHeaderBottom = self.tableView.contentInset.top + sectionHeaderViewRect.origin.y + sectionHeaderView.height;
        }

```


方式2：

```
        sectionHeaderBottom = self.tableView.contentInset.top + sectionHeaderView.height + ((self.tableView.contentOffset.y >= self.sectionHeaderStayTop)?0:sectionHeaderViewRect.origin.y);
```

参考代码：

```
/**< sectionHeader的悬停位置 */
- (CGFloat)sectionHeaderStayTop{
    return self.tableView.tableHeaderView.height - self.naviBar.height;
}
```

```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat naviAlpha = 0;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY < -bannerHeaderHeight) {
        topicDetailBannerView.top = contentOffsetY;
        topicDetailBannerView.height = -contentOffsetY;
    }
    if(contentOffsetY <= (self.naviBarScrollMargin - bannerHeaderHeight)){
        naviAlpha = (contentOffsetY + bannerHeaderHeight) / (self.naviBarScrollMargin);
    }else{
        naviAlpha = 1;
    }
    self.naviBar.backgroundColor = [UIColor colorWithWhite:0 alpha:naviAlpha];
    self.naviBar.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:naviAlpha];

    //解决sectionHeader的问题
    if(contentOffsetY >= self.sectionHeaderStayTop){
        scrollView.contentInset = UIEdgeInsetsMake(self.naviBar.height, 0, 0, 0);
    }else{
        scrollView.contentInset = UIEdgeInsetsMake(MIN(-contentOffsetY, bannerHeaderHeight), 0, 0, 0);
    }
    publishButton.hidden = (contentOffsetY >= tableContentOffset.y);
    tableContentOffset.y = contentOffsetY;
}
```

title滚动范围
```
- (CGFloat)naviBarScrollMargin{
    return (topicDetailBannerView.topicTitleLabelTop - self.naviBar.titleLabel.top);
}
```


### 8. 使用`KVO`监听`UIScrollView`的滚动方向

在一个排序的`View`中，需要在`UIScrollView`上下滚动时时，给予显示和隐藏。


```

static NSString * const WJSortKeyPathContentOffset = @"contentOffset"; //kvo

- (void)dealloc {
    if (scrollView) [self removeObservers];
    scrollView = nil;
}


- (void)initializeSubViewsWithAnimation:(UIScrollView *)view {
    [self initializeSubViews];
    if (!view || ![view isKindOfClass:[UIScrollView class]]) return;
    scrollView = view;
    [self addObservers];
}


#pragma mark - KVO监听
- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [scrollView addObserver:self forKeyPath:WJSortKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers {
    [scrollView removeObserver:self forKeyPath:WJSortKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.userInteractionEnabled || self.hidden) return;
    if ([keyPath isEqualToString:WJSortKeyPathContentOffset]) {
        NSValue *oldValue = change[NSKeyValueChangeOldKey];
        CGFloat oldY = [oldValue CGPointValue].y;
        CGFloat newY = scrollView.contentOffset.y ;
        if (newY == oldY) return;
        if (newY < oldY) {
            if (self.top != scrollView.top - self.height) return;
            UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer;
            CGPoint velocity = [pan velocityInView:pan.view];
            if (scrollView.contentOffset.y > self.height && velocity.y <= scrollVelocity) return;
            [UIView animateWithDuration:hiddenSortViewTime animations:^{
                self.top = scrollView.top;
            }];
        }else {
            if (scrollView.contentOffset.y <= self.height || self.top != scrollView.top) return;
            [UIView animateWithDuration:hiddenSortViewTime animations:^{
                self.top = scrollView.top - self.height;
            }];
        }
    }
}
```
效果看起来很自然


### 9.字符创过滤换行和空格


```
    self.validText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
```

### 10 .打开另一个APP（URL Scheme与openURL）
[【iOS开发】打开另一个APP（URL Scheme与openURL） - 简书](http://www.jianshu.com/p/0811ccd6a65d)
URL，我们都很清楚，http://www.apple.com
就是个 URL，我们也叫它链接或网址；
Schemes，表示的是一个 URL 中的一个位置——最初始的位置，即 ://
之前的那段字符。比如 http://www.apple.com
这个网址的 Schemes是 http。
根据我们上面对 URL Schemes 的使用，我们可以很轻易地理解，在以本地应用为主的 iOS 上，我们可以像定位一个网页一样，用一种特殊的 URL 来定位一个应用甚至应用里某个具体的功能。而定位这个应用的，就应该是这个应用的 URL 的 Schemes 部分，也就是开头儿那部分。
步骤：选中`WXApp`工程->Info->URL Types->点击“+”->在`URL Schemes`栏填上 `weixin`
![添加一个URL Schemes](http://oc98nass3.bkt.clouddn.com/2017-08-29-15039922130154.jpg)
![](http://oc98nass3.bkt.clouddn.com/2017-08-29-15039922451300.jpg)
MyApp打开WXApp
现在我们在MyApp里面打开WXApp。方法非常简单。
在ViewController里面添加一个方法
```
- (IBAction)openWXApp:(UIButton *)sender {
    [self demo1];
}
- (void)demo1 {
    //创建一个url，这个url就是WXApp的url，记得加上：//
    NSURL *url = [NSURL URLWithString:@"weixin://"];

    //打开url
    [[UIApplication sharedApplication] openURL:url];
}
```

### 11. [到底什么时候才需要在ObjC的Block中使用weakSelf/strongSelf](http://blog.lessfun.com/blog/2014/11/22/when-should-use-weakself-and-strongself-in-objc-block/)
解决 retain circle

Apple 官方的建议是，传进 Block 之前，把 ‘self’ 转换成 weak automatic 的变量，这样在 Block 中就不会出现对 self 的强引用。如果在 Block 执行完成之前，self 被释放了，weakSelf 也会变为 nil。

```
__weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [weakSelf doSomething];
});
```
clang 的文档表示，在 doSomething 内，weakSelf 不会被释放。但，下面的情况除外：
```
__weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [weakSelf doSomething];
    [weakSelf doOtherThing];
});
```
在 doSomething 中，weakSelf 不会变成 nil，不过在 doSomething 执行完成，调用第二个方法 doOtherThing 的时候，weakSelf 有可能被释放，于是，strongSelf 就派上用场了：
```
__weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __strong __typeof(self) strongSelf = weakSelf;
    [strongSelf doSomething];
    [strongSelf doOtherThing];
});
__strong 确保在 Block 内，strongSelf 不会被释放。
```
总结
在 Block 内如果需要访问 self 的方法、变量，建议使用 weakSelf。
如果在 Block 内需要多次 访问 self，则需要使用 strongSelf。
[Understanding weak self and strong self | Fantageek](http://www.fantageek.com/2014/06/27/understanding-weak-self-and-strong-self/)
然而，为了实现最佳实践，您应该使用弱函数创建对象的强引用。这不会创建一个保留循环，因为块中的强指针只在块完成之前才存在（它的范围仅是块本身）。

[使用Block时何时需要WeakSelf和StrongSelf? - 姚翔的部落格](http://sherlockyao.com/blog/2015/08/08/weakself-and-strongself-in-blocks/)

```
[UIView animateWithDuration:0.2 animations:^{
    self.myView.alpha = 1.0;
}];
```
在ARC环境下的，每个block在创建时，编译器会对里面用到的所有对象自动增加一个reference count，然后当block执行完毕时，再释放这些reference。针对上面的代码，在animations block执行期间，self（假设这里的self是个view controller）的引用数会被加1，执行完后再次减1。但这种情况下为什么我们一般不会去weakify self呢？因为这个block的生命周期是明确可知的，在这个block执行期间当前的view controller一般是不会被销毁的，所以不存在什么风险。现在我们看下面这个例子：
```
NSBlockOperation *op = [[[NSBlockOperation alloc] init] autorelease];
[op addExecutionBlock:^ {
    [self doSomething];
    [self doMoreThing];
}];
```
在这种情况下，我们并不知道这个execution block什么时候会执行完毕，所以很有可能发生的情况是，我在block还没执行完毕时就想销毁当前对象（比方说用户关闭了当前页面），这时就会因为block还对self有一个reference而没有立即销毁，这会引起很多问题，比方说你写在- (void)dealloc {}中的代码并不能马上得到执行。所以为了避免这种情况，我们会在block前加上__weak __typeof(self)weakSelf = self;的定义来使block对self获取一个弱引用（也就是refrence count不会加1）。

**在这种情况下，我们并不知道这个execution block什么时候会执行完毕，所以很有可能发生的情况是，我在block还没执行完毕时就想销毁当前对象（比方说用户关闭了当前页面），这时就会因为block还对self有一个reference而没有立即销毁，这会引起很多问题，比方说你写在- (void)dealloc {}中的代码并不能马上得到执行。所以为了避免这种情况，我们会在block前加上__weak __typeof(self)weakSelf = self;的定义来使block对self获取一个弱引用（也就是refrence count不会加1）。**
那block中的StrongSelf又是做什么的呢？还是上面的例子，当你加了WeakSelf后，block中的self随时都会有被释放的可能，所以会出现一种情况，在调用doSomething的时候self还存在，在doMoreThing的时候self就变成nil了，所以为了避免这种情况发生，我们会重新strongify self。一般情况下，我们都建议这么做，这没什么风险，除非你不关心self在执行过程中变成nil，或者你确定它不会变成nil（比方说所以block都在main thread执行）。

### 12.[iOS UITableView 使用小贴士 - 姚翔的部落格](http://sherlockyao.com/blog/2015/06/28/uitableview-tips/)
> 设置初始显示位置

在一些用例场景中，我们会要求当用户进入到一个列表页面时，他需要首先看到列表最底部的cell（或者其他一些位置不在top的cell）。通常我们第一反应便是在 UIViewController 的 viewWillAppear: 方法中用代码把table view滚动到需要的位置，但实际上这个方案并不奏效（造成这个的原因是，在viewWillAppear的这个阶段，view还没有真正地去layout，所以table view此时还不知道它真正的content size，也就无法滚动到正确的位置）；紧接着，我们会尝试把代码移动到 viewDidAppear: 方法中，结果确实起作用了，但是用户会在视觉上看到一个滚动的过程，所以并不理想。这里提供一种比较trick的解决方案来处理这个问题：


```
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (!self.hasFinishedLayoutView) {
        self.hasFinishedLayoutView = YES; // 这里用一个flag来避免多次执行

        [self.tableView layoutIfNeeded];

        NSIndexPath* indexPath = ...; // 定义要滚动到的位置
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

```
我们把滚动代码移到 viewDidLayoutSubviews 这个生命周期方法中去，这样就可以成功了。注意一点：我这里手动调用了一下table view的layoutIfNeeded方法，因为在我的实践中，我的view都是用autolayout来构建的，如果这里不手动layout一下，table view的内容大小在这个阶段还是不正确的。



### 13 Apple的框架命名：

![ARKit从入门到精通（2）-ARKit工作原理及流程介绍 - 简书](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041435972369.jpg)
在iOS框架中，凡是带session或者context后缀的，这种类一般自己不干活，作用一般都是两个：1.管理其他类，帮助他们搭建沟通桥梁，好处就是解耦 2.负责帮助我们管理复杂环境下的内存
context与session不同之处是：一般与硬件打交道，例如摄像头捕捉ARSession，网卡的调用NSURLSession等使用的都是session后缀。没有硬件参与，一般用context，如绘图上下文，自定义转场上下文等


### 14. 检测用户截屏

[iOS开发-检测用户截屏, 并获取所截图片 - CSDN博客](http://blog.csdn.net/hitwhylz/article/details/38386979)
```
//注册通知  
[[NSNotificationCenter defaultCenter] addObserver:self  
        selector:@selector(userDidTakeScreenshot:) 
        name:UIApplicationUserDidTakeScreenshotNotification 
        object:nil];  
```

关于淘口令的 读取，是在`UIApplicationDidBecomeActiveNotification`的时候，调用监听，检测黏贴板的链接，是否包含协议的格式，然后弹出口令，可以在`- (void)applicationDidBecomeActive:(UIApplication *)application `中定义，统一交给一个管理类来实现，或者在当前业务类中利用通知~
```
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(funUIApplicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(funUIApplicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
```


### 15. `UICollectionView` 滚动到指定的位置。

![](http://oc98nass3.bkt.clouddn.com/2017-09-06-15046576192380.jpg)


![](http://oc98nass3.bkt.clouddn.com/2017-09-06-15046575860803.jpg)

```
-(void) scrollToSectionHeader:(int)section {    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    //拿到第一个SectionHeader的`UICollectionViewLayoutAttributes`    UICollectionViewLayoutAttributes *attribs = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeaderatIndexPath:indexPath];
    //去掉contentInset    CGPoint topOfHeader = CGPointMake(0, attribs.frame.origin.y - self.collectionView.contentInset.top);    [self.collectionView setContentOffset:topOfHeader animated:YES];}
```


### 16.  属性对外只读

[ios - readonly public, readwrite private property - Stack Overflow](https://stackoverflow.com/questions/18979818/readonly-public-readwrite-private-property)

If you want to do this you re-declare the property in a class extension.

For example, if you have a class called MyClass:

MyClass.h

```
@property (nonatomic, copy, readonly) NSString *username;

```

MyClass.m

```
// Create a class extension before the @implementation section
@interface MyClass ()
@property (nonatomic, copy, readwrite) NSString *username;
@end
```


### 17. 什么时候调用`ViewDidLoad`

![](http://oc98nass3.bkt.clouddn.com/2017-09-07-15047776695308.jpg)

在做分享的时候,发现有个视图没初始化， 对比一下才发现，需要把子视图添加到父视图，才会调用`ViewDidLoad`

```
#pragma mark - ShareVC Function

- (void)showInWindow {
    isShareVCShowing = true;
    isShareVCPresented = true;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    shareView.top = self.view.height;
    shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
    } completion:^(BOOL finished) {
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
        isShareVCShowing = false;
    }];
}

//截屏
- (void)showShareCodeInfoInWindow{
    isShareVCShowing = true;
    isShareVCPresented = true;
    shareCodeInfoView.shareCodeInfoType = ShareCodeInfoType_ScreenShot;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    shareView.hidden = true;
    shareCodeInfoView.hidden = false;
    shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        shareCodeInfoView.bottom = self.view.height;
        shadowView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [shareView setHidden:true];
        [shareCodeInfoView setHidden:false];
        isShareVCShowing = false;
    }];
}
```


### 18 枚举和选项（Option）

![](http://oc98nass3.bkt.clouddn.com/2017-09-07-15047917939140.jpg)





### 19 iOS 类方法与实例方法的区别 

[iOS 类方法与实例方法的区别_小小外星人_新浪博客](http://blog.sina.com.cn/s/blog_b83e61c40102vu14.html)

静态方法在程序开始时生成内存,实例方法在程序运行中生成内存，

所以静态方法可以直接调用,实例方法要先成生实例,通过实例调用方法，静态速度很快，但是多了会占内存。

静态内存是连续的,因为是在程序开始时就生成了,而实例申请的是离散的空间,所以当然没有静态方法快，
而且静态内存是有限制的，太多了程序会启动不了。

#### 使用场景

如果需要访问或者修改某个实例的成员变量时，将该方法定义成实例方法。 

类方法正好相反，它不需要访问或者修改某个实例的成员变量。
类方法一般用于实现一些**工具方法**，比如对某个对象进行扩展，或者实现单例。 
 
类方法常驻内存，实例方法不是，所以类方法效率高但占内存。

```
类方法在堆上分配内存，实例方法在堆栈上。 
```
事实上所有的方法都不可能在堆或者堆栈上分配内存，方法作为代码是被加载到特殊的代码内存区域，这个内存区域是不可写的。 
 实例方法需要先创建实例才可以调用，比较麻烦，类方法不用，比较简单。 
 
事实上如果一个方法与他所在类型的实例无关，那么它就应该是静态的，决不会有人把它写成实例方法。所以所有的实例方法都与实例有关，既然与实例有关，那么创建实例就是必然的步骤，没有麻烦简单一说。实际上上你可以把所有的实例方法都写成静态的，将实例作为参数传入即可。 
 
类方法，也称静态方法，指的是用static关键字修饰的方法。此方法属类本身的方法，不属于类的某一个实例（对象）。类方法中不可直接使用实例变量。其调用方式有三种：可直接调用、类名.方法名、对象名.方法名。实例方法指的是不用static关键字修饰的方法。每个实例对象都有自身的实例方法，互相独立，不共享一个。其调用方式只能是对象名.方法名。


