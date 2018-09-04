目前iOS开发中大多数页面都已经开始使用Interface Builder的方式进行UI开发了，但是在一些变化比较复杂的页面，还是需要通过代码来进行UI开发的。而且有很多比较老的项目，本身就还在采用纯代码的方式进行开发。

而现在iPhone和iPad屏幕尺寸越来越多，虽然开发者只需要根据屏幕点进行开发，而不需要基于像素点进行UI开发。但如果在项目中根据不同屏幕尺寸进行各种判断，写死坐标的话，这样开发起来是很吃力的。

所以一般用纯代码开发UI的话，一般都是配合一些自动化布局的框架进行屏幕适配。苹果为我们提供的适配框架有：VFL、UIViewAutoresizing、Auto Layout、Size Classes等。

其中Auto Layout是使用频率最高的布局框架，但是其也有弊端。就是在使用NSLayoutConstraint的时候，会发现代码量很多，而且大多都是重复性的代码，以至于好多人都不想用这个框架。

后来Github上的出现了基于NSLayoutConstraint封装的第三方布局框架Masonry，Masonry使用起来非常方便，本篇文章就详细讲一下Masonry的使用。



在使用Masonry添加约束之前，需要在addSubview之后才能使用，否则会导致崩溃。
在添加约束时初学者经常会出现一些错误，约束出现问题的原因一般就是两种：约束冲突和缺少约束。对于这两种问题，可以通过调试和log排查。
之前使用Interface Builder添加约束，如果约束有错误直接就可以看出来，并且会以红色或者黄色警告体现出来。而Masonry则不会直观的体现出来，而是以运行过程中崩溃或者打印异常log体现，所以这也是手写代码进行AutoLayout的一个缺点。
这个问题只能通过多敲代码，积攒纯代码进行AutoLayout的经验，慢慢就用起来越来越得心应手了。


### Masonry介绍

这篇文章只是简单介绍`Masonry`，以及`Masonry`的使用，并且会举一些例子出来。但并不会涉及到`Masonry`的内部实现，以后会专门写篇文章来介绍其内部实现原理，包括顺便讲一下链式语法。

#### 什么是Masonry

`Masonry`是一个对系统`NSLayoutConstraint`进行封装的第三方自动布局框架，采用链式编程的方式提供给开发者`API`。系统`AutoLayout`支持的操作，`Masonry`都支持，相比系统`API`功能来说，`Masonry`是有过之而无不及。

`Masonry`采取了链式编程的方式，代码理解起来非常清晰易懂，而且写完之后代码量看起来非常少。之前用`NSLayoutConstraint`写很多代码才能实现的布局，用`Masonry`最少一行代码就可以搞定。下面看到`Masonry`的代码就会发现，太简单易懂了。

`Masonry`是同时支持`Mac`和`iOS`两个平台的，在这两个平台上都可以使用`Masonry`进行自动布局。我们可以从`MASUtilities.h`文件中，看到下面的定义，这就是`Masonry`通过宏定义的方式，区分两个平台独有的一些关键字。

```
#if TARGET_OS_IPHONE    
    #import <UIKit/UIKit.h>
    #define MAS_VIEW UIView
    #define MASEdgeInsets UIEdgeInsets
#elif TARGET_OS_MAC
    #import <AppKit/AppKit.h>
    #define MAS_VIEW NSView
    #define MASEdgeInsets NSEdgeInsets
#endif

```

**Github地址：**
[https://github.com/SnapKit/Masonry](https://github.com/SnapKit/Masonry)

#### 集成方式

`Masonry`支持`CocoaPods`，可以直接通过`podfile`文件进行集成，需要在`CocoaPods`中添加下面代码：

```
pod 'Masonry'

```

#### Masonry学习建议

在`UI`开发中，纯代码和`Interface Builder`我都是用过的，在开发过程中也积累了一些经验。对于初学者学习纯代码`AutoLayout`，我建议还是先学会`Interface Builder`方式的`AutoLayout`，领悟苹果对自动布局的规则和思想，然后再把这套思想嵌套在纯代码上。这样学习起来更好入手，也可以避免踩好多坑。

在项目中设置的`AutoLayout`约束，起到对视图布局的标记作用。设置好约束之后，程序运行过程中创建视图时，会根据设置好的约束计算`frame`，并渲染到视图上。

所以在纯代码情况下，视图设置的约束是否正确，要以运行之后显示的结果和打印的`log`为准。

#### Masonry中的坑

在使用`Masonry`进行约束时，有一些是需要注意的。

1.  在使用`Masonry`添加约束之前，需要在`addSubview`之后才能使用，否则会导致崩溃。
2.  在添加约束时初学者经常会出现一些错误，约束出现问题的原因一般就是两种：约束冲突和缺少约束。对于这两种问题，可以通过调试和`log`排查。
3.  之前使用`Interface Builder`添加约束，如果约束有错误直接就可以看出来，并且会以红色或者黄色警告体现出来。而`Masonry`则不会直观的体现出来，而是以运行过程中崩溃或者打印异常`log`体现，所以这也是手写代码进行`AutoLayout`的一个缺点。
    这个问题只能通过多敲代码，积攒纯代码进行`AutoLayout`的经验，慢慢就用起来越来越得心应手了。

### Masonry基础使用

#### Masonry基础API

```
mas_makeConstraints()    添加约束
mas_remakeConstraints()  移除之前的约束，重新添加新的约束
mas_updateConstraints()  更新约束，写哪条更新哪条，其他约束不变

equalTo()       参数是对象类型，一般是视图对象或者mas_width这样的坐标系对象
mas_equalTo()   和上面功能相同，参数可以传递基础数据类型对象，可以理解为比上面的API更强大

width()         用来表示宽度，例如代表view的宽度
mas_width()     用来获取宽度的值。和上面的区别在于，一个代表某个坐标系对象，一个用来获取坐标系对象的值

```

#### Auto Boxing

上面例如`equalTo`或者`width`这样的，有时候需要涉及到使用`mas_`前缀，这在开发中需要注意作区分。
如果在当前类引入`#import "Masonry.h"`之前，用下面两种宏定义声明一下，就不需要区分`mas_`前缀。

```
// 定义这个常量，就可以不用在开发过程中使用"mas_"前缀。
#define MAS_SHORTHAND
// 定义这个常量，就可以让Masonry帮我们自动把基础数据类型的数据，自动装箱为对象类型。
#define MAS_SHORTHAND_GLOBALS

```

#### 修饰语句

`Masonry`为了让代码使用和阅读更容易理解，所以直接通过点语法就可以调用，还添加了`and`和`with`两个方法。这两个方法内部实际上什么都没干，只是在内部将`self`直接返回，功能就是为了更加方便阅读，对代码执行没有实际作用。
例如下面的例子：

```
make.top.and.bottom.equalTo(self.containerView).with.offset(padding);

```

其内部代码实现，实际上就是直接将`self`返回。

```
- (MASConstraint *)with {
    return self;
}

```

#### 更新约束和布局

关于更新约束布局相关的`API`，主要用以下四个`API`：

```
- (void)updateConstraintsIfNeeded  调用此方法，如果有标记为需要重新布局的约束，则立即进行重新布局，内部会调用updateConstraints方法
- (void)updateConstraints          重写此方法，内部实现自定义布局过程
- (BOOL)needsUpdateConstraints     当前是否需要重新布局，内部会判断当前有没有被标记的约束
- (void)setNeedsUpdateConstraints  标记需要进行重新布局

```

关于`UIView`重新布局相关的`API`，主要用以下三个`API`：

```
- (void)setNeedsLayout  标记为需要重新布局
- (void)layoutIfNeeded  查看当前视图是否被标记需要重新布局，有则在内部调用layoutSubviews方法进行重新布局
- (void)layoutSubviews  重写当前方法，在内部完成重新布局操作

```

### Masonry示例代码

```
Masonry本质上就是对系统AutoLayout进行的封装，包括里面很多的API，都是对系统API进行了一次二次包装。
typedef NS_OPTIONS(NSInteger, MASAttribute) {
    MASAttributeLeft = 1 << NSLayoutAttributeLeft,
    MASAttributeRight = 1 << NSLayoutAttributeRight,
    MASAttributeTop = 1 << NSLayoutAttributeTop,
    MASAttributeBottom = 1 << NSLayoutAttributeBottom,
    MASAttributeLeading = 1 << NSLayoutAttributeLeading,
    MASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    MASAttributeWidth = 1 << NSLayoutAttributeWidth,
    MASAttributeHeight = 1 << NSLayoutAttributeHeight,
    MASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    MASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    MASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
};

```

#### 常用方法

###### 设置内边距

```
/** 
 设置yellow视图和self.view等大，并且有10的内边距。
 注意根据UIView的坐标系，下面right和bottom进行了取反。所以不能写成下面这样，否则right、bottom这两个方向会出现问题。
 make.edges.equalTo(self.view).with.offset(10);

 除了下面例子中的offset()方法，还有针对不同坐标系的centerOffset()、sizeOffset()、valueOffset()之类的方法。
 */
[self.yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).with.offset(10);
    make.top.equalTo(self.view).with.offset(10);
    make.right.equalTo(self.view).with.offset(-10);
    make.bottom.equalTo(self.view).with.offset(-10);
}];

```

###### 通过insets简化设置内边距的方式

```
// 下面的方法和上面例子等价，区别在于使用insets()方法。
[self.blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    // 下、右不需要写负号，insets方法中已经为我们做了取反的操作了。
    make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
}];

```

###### 更新约束

```
// 设置greenView的center和size，这样就可以达到简单进行约束的目的
[self.greenView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    // 这里通过mas_equalTo给size设置了基础数据类型的参数，参数为CGSize的结构体
    make.size.mas_equalTo(CGSizeMake(300, 300));
}];

// 为了更清楚的看出约束变化的效果，在显示两秒后更新约束。
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 指定更新size，其他约束不变。
    [self.greenView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
});

```

###### 大于等于和小于等于某个值的约束

```
[self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    // 设置宽度小于等于200
    make.width.lessThanOrEqualTo(@200);
    // 设置高度大于等于10
    make.height.greaterThanOrEqualTo(@(10));
}];

self.textLabel.text = @"这是测试的字符串。能看到1、2、3个步骤，第一步当然是上传照片了，要上传正面近照哦。上传后，网站会自动识别你的面部，如果觉得识别的不准，你还可以手动修改一下。左边可以看到16项修改参数，最上面是整体修改，你也可以根据自己的意愿单独修改某项，将鼠标放到选项上面，右边的预览图会显示相应的位置。";

```

`textLabel`只需要设置一个属性即可

```
self.textLabel.numberOfLines = 0;

```

###### 使用基础数据类型当做参数

```
/** 
 如果想使用基础数据类型当做参数，Masonry为我们提供了"mas_xx"格式的宏定义。
 这些宏定义会将传入的基础数据类型转换为NSNumber类型，这个过程叫做封箱(Auto Boxing)。

 "mas_xx"开头的宏定义，内部都是通过MASBoxValue()函数实现的。
 这样的宏定义主要有四个，分别是mas_equalTo()、mas_offset()和大于等于、小于等于四个。
 */
[self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    make.width.mas_equalTo(100);
    make.height.mas_equalTo(100);
}];

```

###### 设置约束优先级

```
/** 
 Masonry为我们提供了三个默认的方法，priorityLow()、priorityMedium()、priorityHigh()，这三个方法内部对应着不同的默认优先级。
 除了这三个方法，我们也可以自己设置优先级的值，可以通过priority()方法来设置。
 */
[self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    make.width.equalTo(self.view).priorityLow();
    make.width.mas_equalTo(20).priorityHigh();
    make.height.equalTo(self.view).priority(200);
    make.height.mas_equalTo(100).priority(1000);
}];

```

```
Masonry也帮我们定义好了一些默认的优先级常量，分别对应着不同的数值，优先级最大数值是1000。
static const MASLayoutPriority MASLayoutPriorityRequired = UILayoutPriorityRequired;
static const MASLayoutPriority MASLayoutPriorityDefaultHigh = UILayoutPriorityDefaultHigh;
static const MASLayoutPriority MASLayoutPriorityDefaultMedium = 500;
static const MASLayoutPriority MASLayoutPriorityDefaultLow = UILayoutPriorityDefaultLow;
static const MASLayoutPriority MASLayoutPriorityFittingSizeLevel = UILayoutPriorityFittingSizeLevel;

```

###### 设置约束比例

```
// 设置当前约束值乘以多少，例如这个例子是redView的宽度是self.view宽度的0.2倍。
[self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    make.height.mas_equalTo(30);
    make.width.equalTo(self.view).multipliedBy(0.2);
}];

```

#### 小练习

###### 子视图等高练习

```
/** 
 下面的例子是通过给equalTo()方法传入一个数组，设置数组中子视图及当前make对应的视图之间等高。

 需要注意的是，下面block中设置边距的时候，应该用insets来设置，而不是用offset。
 因为用offset设置right和bottom的边距时，这两个值应该是负数，所以如果通过offset来统一设置值会有问题。
 */
CGFloat padding = LXZViewPadding;
[self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.equalTo(self.view).insets(UIEdgeInsetsMake(padding, padding, 0, padding));
    make.bottom.equalTo(self.blueView.mas_top).offset(-padding);
}];

[self.blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, padding, 0, padding));
    make.bottom.equalTo(self.yellowView.mas_top).offset(-padding);
}];

/** 
 下面设置make.height的数组是关键，通过这个数组可以设置这三个视图高度相等。其他例如宽度之类的，也是类似的方式。
 */
[self.yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view).insets(UIEdgeInsetsMake(0, padding, padding, padding));
    make.height.equalTo(@[self.blueView, self.redView]);
}];

```

###### 子视图垂直居中练习

```
/** 
 要求：(这个例子是在其他人博客里看到的，然后按照要求自己写了下面这段代码)
 两个视图相对于父视图垂直居中，并且两个视图以及父视图之间的边距均为10，高度为150，两个视图宽度相等。
 */
CGFloat padding = 10.f;
[self.blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.view);
    make.left.equalTo(self.view).mas_offset(padding);
    make.right.equalTo(self.redView.mas_left).mas_offset(-padding);
    make.width.equalTo(self.redView);
    make.height.mas_equalTo(150);
}];

[self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.view);
    make.right.equalTo(self.view).mas_offset(-padding);
    make.width.equalTo(self.blueView);
    make.height.mas_equalTo(150);
}];

```

### UITableView动态Cell高度

在`iOS` `UI`开发过程中，`UITableView`的动态`Cell`高度一直都是个问题。实现这样的需求，实现方式有很多种，只是实现起来复杂程度和性能的区别。

在不考虑性能的情况下，`tableView`动态`Cell`高度，可以采取估算高度的方式。如果通过估算高度的方式实现的话，无论是纯代码还是`Interface Builder`，都只需要两行代码就可以完成`Cell`自动高度适配。

**实现方式：**
需要设置`tableView`的`rowHeight`属性，这里设置为自动高度，告诉系统`Cell`的高度是不固定的，需要系统帮我们进行计算。然后设置`tableView`的`estimatedRowHeight`属性，设置一个估计的高度。(我这里用的代理方法，实际上都一样)

**原理：**
这样的话，在`tableView`被创建之后，系统会根据`estimatedRowHeight`属性设置的值，为`tableView`设置一个估计的值。然后在`Cell`显示的时候再获取`Cell`的高度，并刷新`tableView`的`contentSize`。

**实现代码：**
UITableView部分

```
- (void)tableViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (MasonryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MasonryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LXZTableViewCellIdentifier];
    [cell reloadViewWithText:self.dataList[indexPath.row]];
    return cell;
}

// 需要注意的是，这个代理方法和直接返回当前Cell高度的代理方法并不一样。
// 这个代理方法会将当前所有Cell的高度都预估出来，而不是只计算显示的Cell，所以这种方式对性能消耗还是很大的。
// 所以通过设置estimatedRowHeight属性的方式，和这种代理方法的方式，最后性能消耗都是一样的。
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        // 设置tableView自动高度
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerClass:[MasonryTableViewCell class] forCellReuseIdentifier:LXZTableViewCellIdentifier];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

```

UITableViewCell部分

```
// 自定义了一个UIImageView和UILabel控件，并且通过Masonry进行约束。
[self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.size.mas_equalTo(CGSizeMake(40, 40));
      make.top.left.equalTo(self.contentView).mas_offset(CellPadding);
}];

[self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.avatarImageView.mas_right).mas_offset(CellPadding);
      make.top.equalTo(self.contentView).mas_offset(CellPadding);
      make.right.bottom.equalTo(self.contentView).mas_offset(-CellPadding);
      make.height.greaterThanOrEqualTo(@30);
}];

```

### UIScrollView自动布局

之前听很多人说过`UIScrollView`很麻烦，然而我并没有感觉到有多麻烦(并非装逼)。我感觉说麻烦的人可能根本就没试过吧，只是觉得很麻烦而已。
我这里就讲一下两种进行`UIScrollView`自动布局的方案，并且会讲一下自动布局的技巧，只要掌握技巧，布局其实很简单。

> 布局小技巧：
> 给`UIScrollView`添加的约束是定义其`frame`，设置`contentSize`是定义其内部大小。`UIScrollView`进行`addSubview`操作，都是将其子视图添加到`contentView`上。
> 所以，添加到`UIScrollView`上的子视图，对`UIScrollView`添加的约束都是作用于`contentView`上的。只需要按照这样的思路给`UIScrollView`设置约束，就可以掌握设置约束的技巧了。

#### 提前设置contentSize

```
// 提前设置好UIScrollView的contentSize，并设置UIScrollView自身的约束
self.scrollView.contentSize = CGSizeMake(1000, 1000);
[self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
}];

// 虽然redView的get方法内部已经执行过addSubview操作，但是UIView始终以最后一次添加的父视图为准，也就是redView始终是在最后一次添加的父视图上。
[self.scrollView addSubview:self.redView];
[self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(self.scrollView);
    make.width.height.mas_equalTo(200);
}];

[self.scrollView addSubview:self.blueView];
[self.blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.redView.mas_right);
    make.top.equalTo(self.scrollView);
    make.width.height.equalTo(self.redView);
}];

[self.scrollView addSubview:self.greenView];
[self.greenView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.scrollView);
    make.top.equalTo(self.redView.mas_bottom);
    make.width.height.equalTo(self.redView);
}];

```

#### 自动contentSize

上面的例子是提前设置好`UIScrollView`的`contentSize`的内部`size`，然后直接向里面`addSubview`。但是这有个要求就是，需要提前知道`contentSize`的大小，不然没法设置。
这个例子中将会展示动态改变`contentSize`的大小，内部视图有多少`contentSize`就自动扩充到多大。

这种方式的实现，主要是依赖于创建一个`containerView`内容视图，并添加到`UIScrollView`上作为子视图。`UIScrollView`原来的子视图都添加到`containerView`上，并且和这个视图设置约束。
因为对`UIScrollView`进行`addSubview`操作的时候，本质上是往其`contentView`上添加。也就是`containerView`的父视图是`contentView`，通过`containerView`撑起`contentView`视图的大小，以此来实现动态改变`contentSize`。

```
// 在进行约束的时候，要对containerView的上下左右都添加和子视图的约束，以便确认containerView的边界区域。
[self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
}];

CGFloat padding = LXZViewPadding;
[self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.scrollView).insets(UIEdgeInsetsMake(padding, padding, padding, padding));
}];

[self.containerView addSubview:self.greenView];
[self.greenView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.equalTo(self.containerView).offset(padding);
    make.size.mas_equalTo(CGSizeMake(250, 250));
}];

[self.containerView addSubview:self.redView];
[self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.containerView).offset(padding);
    make.left.equalTo(self.greenView.mas_right).offset(padding);
    make.size.equalTo(self.greenView);
    make.right.equalTo(self.containerView).offset(-padding);
}];

[self.containerView addSubview:self.yellowView];
[self.yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.containerView).offset(padding);
    make.top.equalTo(self.greenView.mas_bottom).offset(padding);
    make.size.equalTo(self.greenView);
    make.bottom.equalTo(self.containerView).offset(-padding);
}];

```



## 参考

1. [iOS自动布局框架 - Masonry详解 - 简书](https://www.jianshu.com/p/ea74b230c70d)