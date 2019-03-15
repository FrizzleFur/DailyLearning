# 解析-MJRefresh


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190129150451.png)

## MJRefreshComponent

这个类作为该控件的基类，涵盖了基类所具备的一些：状态，回调block等，大致分成下面这5种职能：

### 有哪些职能?

1.  声明控件的所有状态。
2.  声明控件的回调函数。
3.  添加监听。
4.  提供刷新，停止刷新接口。
5.  提供子类需要实现的方法。

### 职能如何实现？

#### 1\. 声明控件的所有状态

```
/** 刷新控件的状态 */
typedef NS_ENUM(NSInteger, MJRefreshState) {
    /** 普通闲置状态 */
    MJRefreshStateIdle = 1,
    /** 松开就可以进行刷新的状态 */
    MJRefreshStatePulling,
    /** 正在刷新中的状态 */
    MJRefreshStateRefreshing,
    /** 即将刷新的状态 */
    MJRefreshStateWillRefresh,
    /** 所有数据加载完毕，没有更多的数据了 */
    MJRefreshStateNoMoreData
};

```

#### 2\. 声明控件的回调函数

```
/** 进入刷新状态的回调 */
typedef void (^MJRefreshComponentRefreshingBlock)();
/** 开始刷新后的回调(进入刷新状态后的回调) */
typedef void (^MJRefreshComponentbeginRefreshingCompletionBlock)();
/** 结束刷新后的回调 */
typedef void (^MJRefreshComponentEndRefreshingCompletionBlock)();

```

#### 3\. 添加监听

监听的声明：

```
- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:MJRefreshKeyPathContentOffset options:options context:nil];//contentOffset属性
    [self.scrollView addObserver:self forKeyPath:MJRefreshKeyPathContentSize options:options context:nil];//contentSize属性
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:MJRefreshKeyPathPanState options:options context:nil];//UIPanGestureRecognizer 的state属性
}

```

对于监听的处理：

```
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;

    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:MJRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }

    // 看不见
    if (self.hidden) return;

    if ([keyPath isEqualToString:MJRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    } else if ([keyPath isEqualToString:MJRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}

```

#### 4\. 提供刷新，停止刷新接口

```
#pragma mark 进入刷新状态

- (void)beginRefreshingWithCompletionBlock:(void (^)())completionBlock
{
    self.beginRefreshingCompletionBlock = completionBlock;

    [self beginRefreshing];
}

- (void)beginRefreshing
{
    [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
    self.pullingPercent = 1.0;
    // 只要正在刷新，就完全显示
    if (self.window) {
        //将状态切换为正在刷新
        self.state = MJRefreshStateRefreshing;
    } else {
        // 预防正在刷新中时，调用本方法使得header inset回置失败
        if (self.state != MJRefreshStateRefreshing) {
            //将状态切换为即将刷新
            self.state = MJRefreshStateWillRefresh;
            // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
            [self setNeedsDisplay];
        }
    }
}

#pragma mark 结束刷新状态
- (void)endRefreshing
{
    self.state = MJRefreshStateIdle;
}

- (void)endRefreshingWithCompletionBlock:(void (^)())completionBlock
{
    self.endRefreshingCompletionBlock = completionBlock;

    [self endRefreshing];
}

#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return self.state == MJRefreshStateRefreshing || self.state == MJRefreshStateWillRefresh;
}


```

交给子类实现的方法：

```
- (void)prepare NS_REQUIRES_SUPER;
/** 摆放子控件frame */
- (void)placeSubviews NS_REQUIRES_SUPER;
/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

```

#### 5\. 提供子类需要实现的方法

```
#pragma mark - 交给子类们去实现
/** 初始化 */
- (void)prepare NS_REQUIRES_SUPER;
/** 摆放子控件frame */
- (void)placeSubviews NS_REQUIRES_SUPER;
/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

```

从上面等结构图可以看出，紧接着这个基类，下面分为`MJRefreshHeader`和`MJRefreshFooter`,这里顺着`MJRefreshHeader`这个分支向下展开：

## MJRefreshHeader

`MJRefreshHeader`继承于`MJRefreshComponent`，它做了这几件事：

### 有哪些职能？

1.  初始化。
2.  设置header高度。
3.  重新调整y值。
4.  根据`contentOffset`的变化，来切换状态（默认状态，可以刷新的状态，正在刷新的状态），实现方法是：`scrollViewContentOffsetDidChange:`。
5.  在切换状态时，执行相应的操作。实现方法是：`setState:`。

### 职能如何实现？

####1\. 初始化

初始化有两种方法：

```
+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
    MJRefreshHeader *cmp = [[self alloc] init];
    //传入block
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}
+ (instancetype)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    MJRefreshHeader *cmp = [[self alloc] init];
    //设置self.refreshingTarget 和 self.refreshingAction
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}


```

#### 2\. 设置header高度

通过重写`prepare`方法来设置header的高度：

```
- (void)prepare
{
    [super prepare];

    // 设置用于在NSUserDefaults里存储时间的key
    self.lastUpdatedTimeKey = MJRefreshHeaderLastUpdatedTimeKey;

    // 设置header的高度
    self.mj_h = MJRefreshHeaderHeight;
}

```

#### 3\. 重新调整y值

通过重写`placeSubviews`方法来重新调整y值：

```
- (void)placeSubviews
{
    [super placeSubviews];

    // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
    self.mj_y = - self.mj_h - self.ignoredScrollViewContentInsetTop;
    //self.ignoredScrollViewContentInsetTop 如果是10，那么就向上移动10
}

```

#### 4\. 状态切换的代码：

```
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];

    // 正在刷新的状态
    if (self.state == MJRefreshStateRefreshing) {

        if (self.window == nil) return;

        //- self.scrollView.mj_offsetY：-（-54-64）= 118 ： 刷新的时候，偏移量是不动的。偏移量 = 状态栏 + 导航栏 + header的高度
        //_scrollViewOriginalInset.top：64 （状态栏 + 导航栏）
        //insetT 取二者之间大的那一个
        CGFloat insetT = - self.scrollView.mj_offsetY > _scrollViewOriginalInset.top ? - self.scrollView.mj_offsetY : _scrollViewOriginalInset.top;

        //118
        insetT = insetT > self.mj_h + _scrollViewOriginalInset.top ? self.mj_h + _scrollViewOriginalInset.top : insetT;

        //设置contentInset
        self.scrollView.mj_insetT = insetT;

        // 记录刷新的时候的偏移量 -54 = 64 - 118
        self.insetTDelta = _scrollViewOriginalInset.top - insetT;

        return;
    }

    // 跳转到下一个控制器时，contentInset可能会变
     _scrollViewOriginalInset = self.scrollView.contentInset;

    // 记录当前的contentOffset
    CGFloat offsetY = self.scrollView.mj_offsetY;

    // 头部控件刚好全部出现的offsetY,默认是-64（20 + 44）
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;

    // 向上滚动，直接返回
    if (offsetY > happenOffsetY) return;

    // 从普通 到 即将刷新 的临界距离
    CGFloat normal2pullingOffsetY = happenOffsetY - self.mj_h;// -64 - 54 = -118

    //下拉的百分比：下拉的距离与header高度的比值
    CGFloat pullingPercent = (happenOffsetY - offsetY) / self.mj_h;

    if (self.scrollView.isDragging) {

        //记录当前下拉的百分比
        self.pullingPercent = pullingPercent;

        if (self.state == MJRefreshStateIdle && offsetY < normal2pullingOffsetY) {
            // 如果当前为默认状态 && 下拉的距离大于临界距离（将tableview下拉得很低），则将状态切换为可以刷新
            self.state = MJRefreshStatePulling;

        } else if (self.state == MJRefreshStatePulling && offsetY >= normal2pullingOffsetY) {
            // 如果当前状态为可以刷新 && 下拉的距离小于临界距离，则将状态切换为默认
            self.state = MJRefreshStateIdle;
        }
    } else if (self.state == MJRefreshStatePulling) {// 即将刷新 && 手松开
        // 手松开 && 状态为可以刷新（MJRefreshStatePulling）时 开始刷新
        [self beginRefreshing];

    } else if (pullingPercent < 1) {
        //手松开后，默认状态时，恢复self.pullingPercent
        self.pullingPercent = pullingPercent;        
    }
}


```

> 需要注意三点：
> 
> 1.  这里的状态有三种：默认状态（MJRefreshStateIdle），可以刷新的状态（MJRefreshStatePulling）以及正在刷新的状态（MJRefreshStateRefreshing）。
> 2.  状态切换的因素有两个：一个是下拉的距离是否超过临界值，另一个是 手指是否离开屏幕。
> 3.  注意:**可以刷新的状态**和**正在刷新的状态**是不同的。因为在手指还贴在屏幕的时候是不能进行刷新的。所以即使在下拉的距离超过了临界距离（状态栏 + 导航栏 + header高度），如果手指没有离开屏幕，那么也不能马上进行刷新，而是将状态切换为：可以刷新。一旦手指离开了屏幕，马上将状态切换为正在刷新。

这里提供一张图来体现三个状态的不同：

![三个状态](https://user-gold-cdn.xitu.io/2017/12/16/1605ff315be1f379?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

#### 5\. 状态切换时的相应操作：

```
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState

    if (state == MJRefreshStateIdle) {

        //============== 设置状态为默认状态 =============//

        //如果当前不是正在刷新就返回，因为这个方法主要针对从正在刷新状态（oldstate）到默认状态
        if (oldState != MJRefreshStateRefreshing) return;

        //刷新完成后，保存刷新完成的时间
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.lastUpdatedTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // 恢复inset和offset
        [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{

            //118 -> 64（剪去了header的高度）
            self.scrollView.mj_insetT += self.insetTDelta;

            // 自动调整透明度
            if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;

        } completion:^(BOOL finished) {

            self.pullingPercent = 0.0;

            if (self.endRefreshingCompletionBlock) {
                //调用刷新完成的block
                self.endRefreshingCompletionBlock();
            }
        }];

    } else if (state == MJRefreshStateRefreshing) {

         //============== 设置状态为正在刷新状态 =============//
         dispatch_async(dispatch_get_main_queue(), ^{

             [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{

                CGFloat top = self.scrollViewOriginalInset.top + self.mj_h;//64 + 54 (都是默认的高度)
                // 重新设置contentInset，top = 118
                self.scrollView.mj_insetT = top;
                // 设置滚动位置
                [self.scrollView setContentOffset:CGPointMake(0, -top) animated:NO];

            } completion:^(BOOL finished) {
                //调用进行刷新的block
                [self executeRefreshingCallback];
            }];
         });
    }
}


```

> 这里需要注意两点：
> 
> 1.  这里状态的切换，主要围绕着两种：默认状态和正在刷新状态。也就是针对**开始刷新**和**结束刷新**这两个切换点。
> 2.  从正在刷新状态状态切换为默认状态时（结束刷新），需要记录刷新结束的时间。因为header里面有一个默认的label是用来显示上次刷新的时间的。

## MJRefreshStateHeader

这个类是`MJRefreshHeader`类的子类，它做了两件事：

### 有哪些职能？

1.  简单布局了`stateLabel`和`lastUpdatedTimeLabel`。
2.  根据控件状态的切换（默认状态，正在刷新状态），实现了这两个label显示的文字的切换。

给一张图，让大家直观感受一下这两个控件：

![两个Label](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1024" height="709"></svg>)

### 职能如何实现？

这个类通过覆盖父类三个方法来实现上述两个实现：

#### 方法1：prepare方法

```
- (void)prepare
{
    [super prepare];

    // 初始化间距
    self.labelLeftInset = MJRefreshLabelLeftInset;

    // 初始化文字
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderIdleText] forState:MJRefreshStateIdle];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderPullingText] forState:MJRefreshStatePulling];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderRefreshingText] forState:MJRefreshStateRefreshing];
}

```

> 在这里，将每一个状态对应的提示文字放入一个字典里面,key是状态的NSNumber形式

```
- (void)setTitle:(NSString *)title forState:(MJRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
}

```

#### 方法2：placeSubviews方法

```
- (void)placeSubviews
{
    [super placeSubviews];

    if (self.stateLabel.hidden) return;

    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;

    if (self.lastUpdatedTimeLabel.hidden) {

        //如果更新时间label是隐藏的，则让状态label撑满整个header
        if (noConstrainsOnStatusLabel) self.stateLabel.frame = self.bounds;

    } else {

        //如果更新时间label不是隐藏的，根据约束设置更新时间label和状态label（高度各占一半）
        CGFloat stateLabelH = self.mj_h * 0.5;

        if (noConstrainsOnStatusLabel) {
            self.stateLabel.mj_x = 0;
            self.stateLabel.mj_y = 0;
            self.stateLabel.mj_w = self.mj_w;
            self.stateLabel.mj_h = stateLabelH;
        }

        // 更新时间label
        if (self.lastUpdatedTimeLabel.constraints.count == 0) {
            self.lastUpdatedTimeLabel.mj_x = 0;
            self.lastUpdatedTimeLabel.mj_y = stateLabelH;
            self.lastUpdatedTimeLabel.mj_w = self.mj_w;
            self.lastUpdatedTimeLabel.mj_h = self.mj_h - self.lastUpdatedTimeLabel.mj_y;
        }
    }
}

```

> 这里主要是对`lastUpdatedTimeLabel`和`stateLabel`进行布局。要注意`lastUpdatedTimeLabel`隐藏的情况。

#### 方法3: setState:方法

```
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState

    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];

    // 重新设置key（重新显示时间）
    self.lastUpdatedTimeKey = self.lastUpdatedTimeKey;
}


```

> 在这里，根据传入的state的不同，在`stateLabel`和`lastUpdatedTimeLabel`里切换相应的文字。
> 
> *   `stateLabel`里的文字直接从`stateTitles`字典里取出即可。
> *   `lastUpdatedTimeLabel`里的文字需要通过一个方法来取出即可：

```
- (void)setLastUpdatedTimeKey:(NSString *)lastUpdatedTimeKey
{
    [super setLastUpdatedTimeKey:lastUpdatedTimeKey];

    // 如果label隐藏了，就不用再处理
    if (self.lastUpdatedTimeLabel.hidden) return;

    //根据key，从NSUserDefaults获取对应的NSData型时间
    NSDate *lastUpdatedTime = [[NSUserDefaults standardUserDefaults] objectForKey:lastUpdatedTimeKey];

    // 如果有block，从block里拿来时间，这应该是用户自定义显示时间格式的渠道
    if (self.lastUpdatedTimeText) {
        self.lastUpdatedTimeLabel.text = self.lastUpdatedTimeText(lastUpdatedTime);
        return;
    }

    //如果没有block，就按照下面的默认方法显示时间格式
    if (lastUpdatedTime) {

        // 获得了上次更新时间
        // 1.获得年月日
        NSCalendar *calendar = [self currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
        NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:lastUpdatedTime];
        NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];

        // 2.格式化日期
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        BOOL isToday = NO;
        if ([cmp1 day] == [cmp2 day]) {
            //今天，省去年月日
            formatter.dateFormat = @" HH:mm";
            isToday = YES;

        } else if ([cmp1 year] == [cmp2 year]) { // 今年
            //今年，省去年，显示月日
            formatter.dateFormat = @"MM-dd HH:mm";
        } else {
            //其他，年月日都显示
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        }
        NSString *time = [formatter stringFromDate:lastUpdatedTime];

        // 3.显示日期
        self.lastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@%@",
                                          [NSBundle mj_localizedStringForKey:MJRefreshHeaderLastTimeText],
                                          isToday ? [NSBundle mj_localizedStringForKey:MJRefreshHeaderDateTodayText] : @"",
                                          time];
    } else {
        // 没有获得上次更新时间（应该是第一次更新或者多次更新，之前的更新都失败了）
        self.lastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@",
                                          [NSBundle mj_localizedStringForKey:MJRefreshHeaderLastTimeText],
                                          [NSBundle mj_localizedStringForKey:MJRefreshHeaderNoneLastDateText]];
    }
}


```

> 在这里注意两点：
> 
> 1.  作者通过使用block来让用户自己定义日期现实的格式，如果用户没有自定义，就使用作者提供的默认格式。
> 2.  在默认格式的设置里，判断了是否是今日，是否是今年的情况。在以后设计显示时间的labe的时候可以借鉴一下。

## MJRefreshNormalHeader

### 有哪些职能？

MJRefreshNormalHeader 继承于 MJRefreshStateHeader，它主要做了两件事：

1.  它在MJRefreshStateHeader上添加了`_arrowView`和`loadingView`。
2.  布局了这两个view并在Refresh控件的状态切换的时候改变这两个view的样式。

还是给一张图来直观感受一下这两个view：

![两个view](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1024" height="663"></svg>)

### 职能如何实现？

同MJRefreshStateHeader一样，也是重写了父类的三个方法：

#### 方法1：prepare

```
- (void)prepare
{
    [super prepare];

    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

```

#### 方法2：placeSubviews

```
- (void)placeSubviews
{
    [super placeSubviews];

    // 首先将箭头的中心点x设为header宽度的一半
    CGFloat arrowCenterX = self.mj_w * 0.5;

    if (!self.stateLabel.hidden) {

        CGFloat stateWidth = self.stateLabel.mj_textWith;
        CGFloat timeWidth = 0.0;
        if (!self.lastUpdatedTimeLabel.hidden) {
            timeWidth = self.lastUpdatedTimeLabel.mj_textWith;
        }

        //在stateLabel里的文字宽度和更新时间里的文字宽度里取较宽的
        CGFloat textWidth = MAX(stateWidth, timeWidth);
        //根据self.labelLeftInset和textWidth向左移动中心点x
        arrowCenterX -= textWidth / 2 + self.labelLeftInset;
    }

    //中心点y永远设置为header的高度的一半
    CGFloat arrowCenterY = self.mj_h * 0.5;

    //获得了最终的center，而这个center同时适用于arrowView和loadingView，因为二者是不共存的。
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);

    // 箭头
    if (self.arrowView.constraints.count == 0) {
        //控件大小等于图片大小
        self.arrowView.mj_size = self.arrowView.image.size;
        self.arrowView.center = arrowCenter;
    }

    // 菊花
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = arrowCenter;
    }

    //arrowView的色调与stateLabel的字体颜色一致
    self.arrowView.tintColor = self.stateLabel.textColor;
}

```

> 在这里注意一点：因为`stateLabel`和`lastUpdatedTimeLabel`是上下并排分布的，而`arrowView`或`loadingView`是在这二者的左边，所以为了避免这两组重合，在计算`arrowView`或`loadingView`的center的时候，需要获取`stateLabel`和`lastUpdatedTimeLabel`两个控件的宽度并比较大小，将较大的一个作为两个label的‘最宽距离’，再计算center，这样一来就不会重合了。 而对于如何计算宽度，作者给出了一个方案，大家可以在以后的实践中使用：

```
- (CGFloat)mj_textWith {
    CGFloat stringWidth = 0;
    CGSize size = CGSizeMake(MAXFLOAT, MAXFLOAT);
    if (self.text.length > 0) {
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        stringWidth =[self.text
                      boundingRectWithSize:size
                      options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{NSFontAttributeName:self.font}
                      context:nil].size.width;
#else

        stringWidth = [self.text sizeWithFont:self.font
                             constrainedToSize:size
                                 lineBreakMode:NSLineBreakByCharWrapping].width;
#endif
    }
    return stringWidth;
}

```

#### 方法3: setState:

```
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState

    // 根据状态更新arrowView和loadingView的显示
    if (state == MJRefreshStateIdle) {

        //1\. 设置为默认状态
        if (oldState == MJRefreshStateRefreshing) {

            //1.1 从正在刷新状态中切换过来
            self.arrowView.transform = CGAffineTransformIdentity;

            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                //隐藏菊花
                self.loadingView.alpha = 0.0;

            } completion:^(BOOL finished) {

                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                //菊花停止旋转
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
                //显示箭头
                self.arrowView.hidden = NO;
            }];

        } else {
            //1.2 从其他状态中切换过来
            [self.loadingView stopAnimating];
            //显示箭头并设置为初始状态
            self.arrowView.hidden = NO;
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }

    } else if (state == MJRefreshStatePulling) {

        //2\. 设置为可以刷新状态
        [self.loadingView stopAnimating];
        self.arrowView.hidden = NO;
        [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            //箭头倒立
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];

    } else if (state == MJRefreshStateRefreshing) {

        //3\. 设置为正在刷新状态
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        //菊花旋转
        [self.loadingView startAnimating];
        //隐藏arrowView
        self.arrowView.hidden = YES;
    }
}

```

到此为止，我们已经从`MJRefreshComponent`到`MJRefreshNormalHeader`的实现过程看了一遍。可以看出，作者将`prepare`,`placeSubviews`以及`setState：`方法作为基类的方法，让下面的子类去一层一层实现。

而每一层的子类，根据自身的职责，分别按照自己的方式来实现这三个方法：

*   `MJRefreshHeader`: 负责header的高度和调整header自身在外部的位置。
*   `MJRefreshStateHeader`:负责header内部的`stateLabel`和`lastUpdatedTimeLabel`的布局和不同状态下内部文字的显示。
*   `MJRefreshNormalHeader`:负责header内部的`loadingView`以及`arrowView`的布局和不同状态下的显示。

这样做的好处是，如果想要增加某种类型的header，只要在某一层上做文章即可。例如该框架里的`MJRefreshGifHeader`,它和`MJRefreshNormalHeader`属于同一级，都是继承于`MJRefreshStateHeader`。因为二者都具有相同形式的`stateLabel`和`lastUpdatedTimeLabel`，唯一不同的就是左侧的部分：

*   `MJRefreshNormalHeader`的左侧是箭头。
*   `MJRefreshGifHeader`的左侧则是一个gif动画。

还是提供一张图来直观感受一下：

![normalHeader 与 gifHeader](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1024" height="662"></svg>)

下面我们来看一下的实现：

## MJRefreshGifHeader

它提供了两个接口，是用来设置不同状态下使用的图片数组的：

```
- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(MJRefreshState)state 
{ 
    if (images == nil) return; 

    //设置不同状态下的图片组和持续时间
    self.stateImages[@(state)] = images; 
    self.stateDurations[@(state)] = @(duration); 

    /* 根据图片设置控件的高度 */ 
    UIImage *image = [images firstObject]; 
    if (image.size.height > self.mj_h) { 
        self.mj_h = image.size.height; 
    } 
}

- (void)setImages:(NSArray *)images forState:(MJRefreshState)state 
{ 
   //如果没有传入duration，则根据图片的多少来计算
    [self setImages:images duration:images.count * 0.1 forState:state]; 
}

```

### 有哪些职能？

然后，和`MJRefreshNormalHeader`一样，它也重写了基类提供的三个方法来实现显示gif图片的职能。

### 职能如何实现？

####1\. 初始化和label的间距

```
- (void)prepare
{
    [super prepare];

    // 初始化间距
    self.labelLeftInset = 20;
}

```

####2\. 根据label的宽度和存在与否设置gif的位置

```
- (void)placeSubviews
{
    [super placeSubviews];

    //如果约束存在，就立即返回
    if (self.gifView.constraints.count) return;

    self.gifView.frame = self.bounds;

    if (self.stateLabel.hidden && self.lastUpdatedTimeLabel.hidden) {

        //如果stateLabel和lastUpdatedTimeLabel都在隐藏状态，将gif剧中显示
        self.gifView.contentMode = UIViewContentModeCenter;

    } else {

        //如果stateLabel和lastUpdatedTimeLabel中至少一个存在，则根据label的宽度设置gif的位置
        self.gifView.contentMode = UIViewContentModeRight;

        CGFloat stateWidth = self.stateLabel.mj_textWith;
        CGFloat timeWidth = 0.0;
        if (!self.lastUpdatedTimeLabel.hidden) {
            timeWidth = self.lastUpdatedTimeLabel.mj_textWith;
        }
        CGFloat textWidth = MAX(stateWidth, timeWidth);
        self.gifView.mj_w = self.mj_w * 0.5 - textWidth * 0.5 - self.labelLeftInset;
    }
}

```

#### 3\. 根据传入状态的不同来设置动画

```
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState

    if (state == MJRefreshStatePulling || state == MJRefreshStateRefreshing) {

        //1\. 如果传进来的状态是可以刷新和正在刷新
        NSArray *images = self.stateImages[@(state)];
        if (images.count == 0) return;

        [self.gifView stopAnimating];

        if (images.count == 1) {
            //1.1 单张图片
            self.gifView.image = [images lastObject];
        } else {
            //1.2 多张图片
            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
        }
    } else if (state == MJRefreshStateIdle) {
        //2.如果传进来的状态是默认状态
        [self.gifView stopAnimating];
    }
}

```

* * *

Footer类是用来处理上拉加载的，实现原理和下拉刷新很类似，在这里先不介绍了～

总的来说，该框架设计得非常工整：通过一个基类来定义一些状态和一些需要子类实现的接口。通过一层一层地继承，让每一层的子类各司其职，只完成真正属于自己的任务，提高了框架的可定制性，而且对于功能的扩展和bug的追踪也很有帮助，非常值得我们参考与借鉴。



## 参考

1. [MJRefresh 源码解析 - 掘金](https://juejin.im/post/5a36fe1af265da431876d432)
