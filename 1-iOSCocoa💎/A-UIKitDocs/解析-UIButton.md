## UIButton解析


 | 

> **前言**：在移动 APP 的设计中，我们会经常看到同时带有图片和文字的按钮，这些按钮在设计师同学眼中，可能不值一提，但是在 iOS 开发中，由于 Apple 的 SDK 的局限性，实现起来却并不那么愉快😔。

**关键字**：`UIButton`，按钮，图文按钮，图片和文字的位置

**相关源码地址：**[ButtonLayoutDemo](https://github.com/ShannonChenCHN/Playground/tree/master/ButtonLayoutDemo)

## 目录

*   需求
*   现实
*   问题
*   解决方案
*   小结

### 一、需求

根据以往的经验来看，我们常见的图文按钮样式一般是以下几种的组合：

*   图文布局
    *   上图下文
    *   上文下图
    *   左图右文
    *   右图左文
*   对齐方式
    *   居左
    *   居右
    *   居中
    *   居上
    *   居下
*   对图片做圆角处理

![上图下文（图片带圆角）.png](https://camo.githubusercontent.com/774ce3f4b9b792c0a66935c5201f4edee06fc703/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d373061643837383039613938623037662e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)

![上图下文（整体靠底部对齐）.png](https://camo.githubusercontent.com/e02c699845bdb65039f9bb12cd1d0fa0c417fb90/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d643438663764366234366463353761612e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)

![上文下图（整体靠底部对齐）.png](https://camo.githubusercontent.com/f9de712b98ba6482e4149b0c663ded5334c08dfa/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d346465313337393937376262383634632e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)

![系统默认支持的左图右文（整体居中）.png](https://camo.githubusercontent.com/d25e6e93d4e287fa00fe4aae5819d676cb10da91/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d613366313935313633346231343835352e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)


![左文右图.png](https://camo.githubusercontent.com/ab2f61be2d8a83d5fa52fd96b97b44ded7a13ac0/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d313364663261383335636434653038332e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)


### 二、现实

然而，Cocoa Touch 框架中的 `UIButton` 只支持左图右文的布局方式，而且还不能直接设置图文间距。

代码如下：

```
UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 50, 30)];
[button setTitle:@"title" forState:UIControlStateNormal];
[button setImage:icon forState:UIControlStateNormal];
button.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
[self addSubview:button];

```

效果如下：
[![系统默认支持的左图右文（整体居中）.png](https://camo.githubusercontent.com/d25e6e93d4e287fa00fe4aae5819d676cb10da91/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d613366313935313633346231343835352e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)](https://camo.githubusercontent.com/d25e6e93d4e287fa00fe4aae5819d676cb10da91/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d613366313935313633346231343835352e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)

### 三、问题

所以，我们首先要解决的问题是，怎样才能轻松加愉快地实现：

*   图文布局（可设置图文间距）
*   对齐方式

我们所期望的是，只需要简单地设置两个属性就能实现想要的效果：

```

button.interTitleImageSpacing = 4;
button.imagePosition = UIButtonImagePositionRight;

```

### 四、解决方案

我们先来看看 `UIButton` 的 API ，发现跟内容布局相关的有这些：

```
@interface UIButton : UIControl
...
@property(nonatomic)          UIEdgeInsets contentEdgeInsets;  // 用来调整按钮整体内容区域的位置和尺寸
@property(nonatomic)          UIEdgeInsets titleEdgeInsets;  // 用来调整按钮文字区域的位置和尺寸
@property(nonatomic)          UIEdgeInsets imageEdgeInsets; // 用来调整按钮图片区域的位置和尺寸

- (CGRect)contentRectForBounds:(CGRect)bounds;  // 用来计算按钮整体内容区域的大小和位置
- (CGRect)titleRectForContentRect:(CGRect)contentRect;  // 用来计算按钮文字区域的大小和位置
- (CGRect)imageRectForContentRect:(CGRect)contentRect;  // 用来计算按钮图片区域的大小和位置
...
@end

```

`UIButton` 继承于 `UIControl`，再来看看 `UIControl` 中的跟布局相关的 API：

```
@property(nonatomic) UIControlContentVerticalAlignment contentVerticalAlignment;     // 设置内容在竖直方向的对齐方式
@property(nonatomic) UIControlContentHorizontalAlignment contentHorizontalAlignment;  // 设置内容在水平方向的对齐方式

```

`UIControl` 继承于 `UIView`，`UIView` 是所有视图控件的根类，`UIView` 中的跟布局相关的 API 有：

```
// 手动触发 layout 的两个方法，其中 - layoutIfNeeded 会强制 layout
- (void)setNeedsLayout;
- (void)layoutIfNeeded;

- (void)layoutSubviews;   // layout 时该方法会被调用，调用 -layoutIfNeeded 方法会自动触发这个方法

```

找来找去，就是系统提供给我们的就是这些工具了，看菜下饭吧。

#### 方案一：设置 `titleEdgeInsets` 属性和 `imageEdgeInsets` 属性的值

> 如果你想要直接看最终实现的代码，请戳这里👉[UIButton+Layout.m](https://github.com/ShannonChenCHN/Playground/blob/master/ButtonLayoutDemo/ButtonLayoutDemo/UIButton%2BLayout.m)。

`titleEdgeInsets` ：用来调整按钮文字区域的位置和尺寸。
`imageEdgeInsets`：用来调整按钮图片区域的位置和尺寸。

`titleEdgeInsets` 和 `imageEdgeInsets` 这两个属性都是 `UIEdgeInsets `类型，`UIEdgeInsets `类型有四个成员变量 `top`、`left`、`bottom`、`right`，分别表示上左下右四个方向的偏移量，正值代表往内缩进，也就是往按钮中心靠拢，负值代表往外扩张，就是往按钮边缘贴近。

```
typedef struct UIEdgeInsets {
    CGFloat top, left, bottom, right;  // specify amount to inset (positive) for each of the edges. values can be negative to 'outset'
} UIEdgeInsets;

```

具体怎么用呢？
**要点：**

*   系统默认的布局是内容整体居中，图片在左，文字在右，图片和文字间距为 0。
*   不论是 `titleEdgeInsets`，还是 `imageEdgeInsets`，只设置一个方向的偏移量 A 时，实际效果得到的偏移量是 A / 2。比如想通过
    `button.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);` 设置按钮标题往右偏移 2 pt， 实际上得到的效果是按钮文字只往右偏移了 1 pt。

知道以上两个要点之后，我们就可以开始干活了，如果要想通过设置 `titleEdgeInsets`和 `imageEdgeInsets` 来达到我们的要求，该怎么做呢？

**1\. 左图右文**

```
// 目标图文间距
CGFloat interImageTitleSpacing = 5;
// 获取默认的图片文字间距
CGFloat originalSpacing = button.titleLabel.frame.origin.x - (button.imageView.frame.origin.x + button.imageView.frame.size.width);
// 调整文字的位置
button.titleEdgeInsets = UIEdgeInsetsMake(0,
                                        -(originalSpacing - interImageTitleSpacing),
                                        0,
                                        (originalSpacing - interImageTitleSpacing));

```

**2\. 左文右图**

```
    // 目标图文间距
    CGFloat interImageTitleSpacing = 5;
    // 图片右移
    button.imageEdgeInsets = UIEdgeInsetsMake(0,
                                              button.titleLabel.frame.size.width + interImageTitleSpacing,
                                              0,
                                              -(button.titleLabel.frame.size.width + interImageTitleSpacing));
    // 文字左移
    button.titleEdgeInsets = UIEdgeInsetsMake(0,
                                              -(button.titleLabel.frame.origin.x - button.imageView.frame.origin.x),
                                              0,
                                              button.titleLabel.frame.origin.x - button.imageView.frame.origin.x);

```

**3.上图下文**

```
    // 目标图文间距
    CGFloat interImageTitleSpacing = 5;

    // 图片上移，右移
    button.imageEdgeInsets = UIEdgeInsetsMake(0,
                                            0,
                                            button.titleLabel.frame.size.height + interImageTitleSpacing,
                                            -(button.titleLabel.frame.size.width));

    // 文字下移，左移
    button.titleEdgeInsets = UIEdgeInsetsMake(button.imageView.frame.size.height + interImageTitleSpacing,
                                            -(button.imageView.frame.size.width),
                                            0,
                                            0);

```

**4.上文下图**

```
    // 目标图文间距
    CGFloat interImageTitleSpacing = 5;

    // 图片下移，右移
    button.imageEdgeInsets = UIEdgeInsetsMake(button.titleLabel.frame.size.height + interImageTitleSpacing,
                                            0,
                                            0,
                                            -(button.titleLabel.frame.size.width));

    // 文字上移，左移
    button.titleEdgeInsets = UIEdgeInsetsMake(0,
                                            -(button.imageView.frame.size.width),
                                            button.imageView.frame.size.height + interImageTitleSpacing,
                                            0);

```

**注意：** 实际上，直接按照上面这么写是不行的，因为设置 `titleEdgeInsets `和 `imageEdgeInsets `属性时，button 的 `titleLabel` 和 `imageView` 的 frame 还没有真正计算好，所以这个时候获取到的 frame 是不准确的，要想拿到布局好的 `titleLabel` 和 `imageView` 的 frame ，我们需要先调用 `- layoutIfNeeded`方法。

```
[button layoutIfNeeded];
//  然后设置 button 的 titleEdgeInsets 和 imageEdgeInsets 
// ... 

```

**优雅的实现方式：**直接在创建 button 的地方去调用 `layoutIfNeeded `进行布局，再去计算 `titleEdgeInsets `和 `imageEdgeInsets `，并不是一个好的做法，比较推荐的做法是，写一个 category 或者 自定义一个 `UIButton` 的子类，来实现上面的计算，并提供图片文字的布局样式和图文间距的接口。

接口应该长得像这样：

```
typedef NS_ENUM(NSInteger, SCButtonLayoutStyle) {
    SCButtonLayoutStyleImageLeft,  
    SCButtonLayoutStyleImageRight,
    SCButtonLayoutStyleImageTop,
    SCButtonLayoutStyleImageBottom,
};

@interface UIButton (Layout)

- (void)sc_setLayoutStyle:(SCButtonLayoutStyle)style spacing:(CGFloat)spacing;

@end

```

使用起来应该像这样：

```
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;  // 竖直方向整体居上
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;  // 水平方向整体居中
    [button sc_setLayoutStyle:SCButtonLayoutStyleImageBottom spacing:20];  // 图片在底部，图文间距 20 pt

```

具体的代码实现见 [UIButton+Layout.m](https://github.com/ShannonChenCHN/Playground/blob/master/ButtonLayoutDemo/ButtonLayoutDemo/UIButton%2BLayout.m)

#### 方案二：自定义一个 UIButton 的子类，重写以下两个方法：

```
- (CGRect)titleRectForContentRect:(CGRect)contentRect;   // 设置文字区域的位置和大小
- (CGRect)imageRectForContentRect:(CGRect)contentRect;  // 设置图片区域的位置和大小

```

使用这两个方法可以直接指定 `titleLabel` 和 `imageView` 的大小和位置，参数 `contentRect` 是由 `-contentRectForBounds:` 方法返回值决定的，如果该方法没有被重写，`contentRect` 就跟 `bounds` 的值是一样的。

**使用案例：**
例如我们要实现一个上图下文、整体靠顶部对齐、图文间距 20pt 的图案：

[![上图下文（整体靠顶部对齐）.png](https://camo.githubusercontent.com/2c9b5404b88b4154189eb32466d2bede63bf2fce/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d323265633738633030656635623233302e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)](https://camo.githubusercontent.com/2c9b5404b88b4154189eb32466d2bede63bf2fce/687474703a2f2f75706c6f61642d696d616765732e6a69616e7368752e696f2f75706c6f61645f696d616765732f3831343335362d323265633738633030656635623233302e706e673f696d6167654d6f6772322f6175746f2d6f7269656e742f7374726970253743696d61676556696577322f322f772f31323430)

我们先自定义一个 `UIButton` 的子类，实现 `-titleRectForContentRect:` 和 `-imageRectForContentRect:` 方法：

```
@interface CustomButton : UIButton

@property (assign, nonatomic) CGFloat interTitleImageSpacing;  ///< 图片文字间距

@end

@implementation CustomButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect {

    CGSize titleSize = CGSizeMake(contentRect.size.width, 25);

    CGRect imageFrame = [self imageRectForContentRect:contentRect];

    return CGRectMake((contentRect.size.width - titleSize.width) * 0.5,
                      imageFrame.origin.y + imageFrame.size.height + self.interTitleImageSpacing,
                      titleSize.width,
                      titleSize.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {

    CGSize imageSize = CGSizeMake(25, 24);

    return CGRectMake((contentRect.size.width - imageSize.width) * 0.5, 0, imageSize.width, imageSize.height);
}

@end

```

然后再在外面使用定义好的 `CustomButton`，然后就得到上图中的效果了：

```
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 75, 75)];
    [button setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [button setTitle:@"title" forState:UIControlStateNormal];
    button.interTitleImageSpacing = 20;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:button];

```

**注意：**但是，在这两个方法中不能使用 `self.titleLabel` 和 `self. imageView`，否则会出现无限递归，造成死循环。也就是说这里面的尺寸和位置计算，都是基于 `contentRect` 参数的独立逻辑，所以一般只在我们知道图片和文字的具体参数后才会这样做，所以，这种方式使用起来并不灵活。

#### 方案三：自定义一个 UIButton 的子类，重写 layoutSubviews 计算位置

这个方案的启发来源于腾讯 QMUI 团队开源的 [QMUIKit](https://github.com/QMUI/QMUIDemo_iOS/blob/master/QMUI/QMUIKit/UIKitExtensions/QMUIButton.m)，其主要思想是，所有的 view 在布局时都会调用 `-layoutSubviews` 方法，你只要告诉我整体内容对齐方式是如何，图文布局什么样，图文间距多大，我就可以在 `-layoutSubviews` 方法中帮你全部算好。

这种方式的好处在于可控性好，直接对 `titleLabel` 和 `imageView` 的 frame 进行操作，不用担心系统实现会不会改动，其次，由于是直接操作 frame，计算起来就比较直观简单，不用像使用` titleEdgeInsets` 和 `imageEdgeInsets` 那样把 `titleLabel` 和 `imageView` 挪来挪去。唯一不太好的地方在于计算量比较多，光计算布局就写了差不多 150 行代码。

因为 [QMUIKit](https://github.com/QMUI/QMUIDemo_iOS/blob/master/QMUI/QMUIKit/UIKitExtensions/QMUIButton.m) 中的 QMUIButton 太过于庞杂，其中有很多我们并不需要的功能，维护起来也复杂，所以我针对我们自己项目的需求实现了一个更简洁的 [SCCustomButton](https://github.com/ShannonChenCHN/SCKit/blob/master/SCKit/UIComponents/Classes/SCCustomButton.h)，主要支持以下功能：

*   设置图文布局方式
*   设置图文间距
*   设置图片圆角大小
*   设置内容整体对齐方式

这是 SCCustomButton 提供的接口：

```
/// 图片和文字的相对位置
typedef NS_ENUM(NSInteger, SCCustomButtonImagePosition) {
    SCCustomButtonImagePositionTop,     // 图片在文字顶部
    SCCustomButtonImagePositionLeft,    // 图片在文字左侧
    SCCustomButtonImagePositionBottom,  // 图片在文字底部
    SCCustomButtonImagePositionRight    // 图片在文字右侧
};

/**
 自定义按钮，可控制图片文字间距

 使用方法：
 @code
     SCCustomButton *button = [[SCCustomButton alloc] initWithFrame:CGRectMake(50, 50, 50, 30)];
     button.imagePosition = SCCustomButtonImagePositionLeft;  // 图文布局方式
     button.interTitleImageSpacing = 5;                       // 图文间距
     button.imageCornerRadius = 15;                           // 图片圆角半径
     button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;  // 内容对齐方式
     [self addSubview:button];
 @endcode
 */
@interface SCCustomButton : UIButton

@property (assign, nonatomic) CGFloat interTitleImageSpacing;  ///< 图片文字间距
@property (assign, nonatomic) SCCustomButtonImagePosition imagePosition;     ///< 图片和文字的相对位置
@property (assign, nonatomic) CGFloat imageCornerRadius;                     ///< 图片圆角半径

@end

```

使用起来也非常简单，正好符合我们期望的效果：

```
SCCustomButton *button = [[SCCustomButton alloc] initWithFrame:CGRectMake(50, 50, 50, 30)];
     button.imagePosition = SCCustomButtonImagePositionLeft;  // 图文布局方式
     button.interTitleImageSpacing = 5;                       // 图文间距
     button.imageCornerRadius = 15;                           // 图片圆角半径
     button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;  // 内容对齐方式
     [self addSubview:button];

```

#### 另辟蹊径：自定义一个 `UIView` 或者 `UIControl` 的子类，实现所要求的样式

当然也可以不使用 `UIButton`，自己去实现一个继承于 `UIView` 或者 `UIControl` 的子类，这是完全可以满足我们所要求的样式的，但是这样就需要自己添加和管理 imageView 和 label，并实现一些 `UIButton` 的功能（比如点击按钮时的高亮效果），显然是比前面提到的几种方式更复杂，成本也更高。

### 五、小结

以上几种调整 `UIButton` 的文字和图片位置的方法，都有各自的优缺点，综合起来看，方案三的自由度更高，可控性更好，也易于维护。


## 参考

1. [如何调整 UIButton 中的元素（image 和 title）的布局？ · Issue #80 · ShannonChenCHN/iOSDevLevelingUp](https://github.com/ShannonChenCHN/iOSDevLevelingUp/issues/80)
**延伸阅读**：

*   [调整UIButton的title和image详解](http://www.jianshu.com/p/fb20bce230d9)
*   [iOS中如何把UIButton中的图片和文字上下对齐](http://www.jianshu.com/p/8e4d1aa8b31d)
*   [腾讯 QMUI 团队开源的 QMUIKit](https://github.com/QMUI/QMUIDemo_iOS/blob/master/QMUI/QMUIKit/UIKitExtensions/QMUIButton.m)
*   [Aligning text and image on UIButton with imageEdgeInsets and titleEdgeInsets](https://stackoverflow.com/questions/4564621/aligning-text-and-image-on-uibutton-with-imageedgeinsets-and-titleedgeinsets/5358259#5358259)
*   [How do I put the image on the right side of the text in a UIButton?](https://stackoverflow.com/questions/7100976/how-do-i-put-the-image-on-the-right-side-of-the-text-in-a-uibutton/16725685#16725685)