# UIView 解析

`2017-04-19` `iOS_Docs`

[TOC]

> UIView的`setNeedsLayout`, `layoutIfNeeded` 和` layoutSubviews` 方法之间的关系解释



## UIView属性

1. window
获得当前控件所在的window
```objc
@property(nullable, nonatomic,readonly) UIWindow     *window;
```

## UIView的生命周期


查看UIViewapi，常用的加载时机大概如下：

```objc
- (void)layoutSubviews

// 当视图添加子视图时调用

- (void)didAddSubview:(UIView *)subview;


// 当子视图从本视图移除时调用

- (void)willRemoveSubview:(UIView *)subview;


// 当视图即将加入父视图时 / 当视图即将从父视图移除时调用

- (void)willMoveToSuperview:(nullable UIView *)newSuperview;


// 当试图加入父视图时 / 当视图从父视图移除时调用

- (void)didMoveToSuperview;


// 当视图即将加入父视图时 / 当视图即将从父视图移除时调用

- (void)willMoveToWindow:(nullable UIWindow *)newWindow;


// 当视图加入父视图时 / 当视图从父视图移除时调用

- (void)didMoveToWindow;


- (void)removeFromSuperview
- (void)dealloc

```


### `layoutSubviews`调用总结

1. 自身的frame发生变化， 会重新布局`layoutSubviews`
2. 添加视图，调用`addSubView`的时候
3. 滚动一个UIScrollView会触发
4. 子视图frame发生变化，会调用父视图的`addSubView`

Its own bounds (not frame) changed.
The bounds of one of its direct subviews changed.
A subview is added to the view or removed from the view.
Some relevant details:

[UIView的setNeedsLayout, layoutIfNeeded 和 layoutSubviews 方法之间的关系解释](http://blog.csdn.net/meegomeego/article/details/39890385)

* init does not cause layoutSubviews to be called (duh)
* addSubview causes layoutSubviews to be called on the view being added, the view it’s being added to (target view), and all the subviews of the target view
* setFrame intelligently calls layoutSubviews on the view having it’s frame set only if the size parameter of the frame is different
* scrolling a UIScrollView causes layoutSubviews to be called on the scrollView, and it’s superview
* rotating a device only calls layoutSubview on the parent view (the responding viewControllers primary view)
* removeFromSuperview – layoutSubviews is called on superview only (not show in table)

http://stackoverflow.com/questions/728372/when-is-layoutsubviews-called

* init does not cause layoutSubviews to be called (duh)
* addSubview: causes layoutSubviews to be called on the view being added, the view it’s being added to (target view), and all the subviews of the target
* view setFrame intelligently calls layoutSubviews on the view having its frame set only if the size parameter of the frame is different
* scrolling a UIScrollView causes layoutSubviews to be called on the scrollView, and its superview
* rotating a device only calls layoutSubview on the parent view (the responding viewControllers primary view)
* Resizing a view will call layoutSubviews on its superview
My results - http://blog.logichigh.com/2011/03/16/when-does-layoutsubviews-get-called/


#### ios layout机制相关方法

```
- (CGSize)sizeThatFits:(CGSize)size
- (void)sizeToFit

- (void)layoutSubviews
- (void)layoutIfNeeded
- (void)setNeedsLayout

- (void)setNeedsDisplay
- (void)drawRect
```

#### `layoutSubviews`在以下情况下会被调用：

1、init初始化不会触发layoutSubviews
但是是用initWithFrame 进行初始化时，当rect的值不为CGRectZero时,也会触发——就是改变了frame

2、addSubview会触发layoutSubviews

3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化

4、滚动一个UIScrollView会触发layoutSubviews

5、旋转Screen会触发父UIView上的layoutSubviews事件

6、改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件

[When is layoutSubviews called?](http://stackoverflow.com/questions/728372/when-is-layoutsubviews-called)

init does not cause layoutSubviews to be called (duh)
addSubview: causes layoutSubviews to be called on the view being added, the view it’s being added to (target view), and all the subviews of the target
view setFrame intelligently calls layoutSubviews on the view having its frame set only if the size parameter of the frame is different
scrolling a UIScrollView causes layoutSubviews to be called on the scrollView, and its superview
rotating a device only calls layoutSubview on the parent view (the responding viewControllers primary view)
Resizing a view will call layoutSubviews on its superview


在苹果的官方文档中强调:

      You should override this method only if the autoresizing behaviors of the subviews do not offer the behavior you want.

**layoutSubviews, 当我们在某个类的内部调整子视图位置时，需要调用。**

反过来的意思就是说：如果你想要在外部设置subviews的位置，就不要重写。




## 刷新子对象布局


-layoutSubviews方法：这个方法，默认没有做任何事情，需要子类进行重写
-setNeedsLayout方法： 标记为需要重新布局，异步调用layoutIfNeeded刷新布局，不立即刷新，但layoutSubviews一定会被调用
-layoutIfNeeded方法：如果，有需要刷新的标记，立即调用layoutSubviews进行布局（如果没有标记，不会调用layoutSubviews）

如果要立即刷新，要先调用[view setNeedsLayout]，把标记设为需要布局，然后马上调用[view layoutIfNeeded]，实现布局

在视图第一次显示之前，标记总是“需要刷新”的，可以直接调用[view layoutIfNeeded]

### 重绘

-drawRect:(CGRect)rect方法：重写此方法，执行重绘任务
-setNeedsDisplay方法：标记为需要重绘，异步调用drawRect
-setNeedsDisplayInRect:(CGRect)invalidRect方法：标记为需要局部重绘

sizeToFit会自动调用sizeThatFits方法；

sizeToFit不应该在子类中被重写，应该重写sizeThatFits

sizeThatFits传入的参数是receiver当前的size，返回一个适合的size

sizeToFit可以被手动直接调用

sizeToFit和sizeThatFits方法都没有递归，对subviews也不负责，只负责自己

———————————-

layoutSubviews对subviews重新布局

layoutSubviews方法调用先于drawRect

setNeedsLayout在receiver标上一个需要被重新布局的标记，在系统runloop的下一个周期自动调用layoutSubviews

layoutIfNeeded方法如其名，UIKit会判断该receiver是否需要layout.根据Apple官方文档,layoutIfNeeded方法应该是这样的

layoutIfNeeded遍历的不是superview链，应该是subviews链

drawRect是对receiver的重绘，能获得context

setNeedDisplay在receiver标上一个需要被重新绘图的标记，在下一个draw周期自动重绘，iphone device的刷新频率是60hz，也就是1/60秒后重绘 

http://www.jianshu.com/p/eb2c4bb4e3f1
谈谈UIView的几个layout方法-layoutSubviews、layoutIfNeeded、setNeedsLayout...

字数1167 阅读3102 评论5 喜欢46
最近在学习swift做动画，用到constraint的动画，用到layoutIfNeeded就去研究了下UIView的这几个布局的方法。

下面是做得一个动画，下载地址：https://github.com/smalldu/IOS-Animations  
中的AnimationDemo3

动画
下面列举下iOS layout的相关方法:

* layoutSubviews
* layoutIfNeeded
* setNeedsLayout
* setNeedsDisplay
* drawRect
* sizeThatFits
* sizeToFit
大概常用的上面几个 ， 具体的应该还有别的。

layoutSubviews

这个方法，默认没有做任何事情，需要子类进行重写 。 系统在很多时候会去调用这个方法：

1.初始化不会触发layoutSubviews，但是如果设置了不为CGRectZero的frame的时候就会触发。
2.addSubview会触发layoutSubviews
3.设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化
4.滚动一个UIScrollView会触发layoutSubviews
5.旋转Screen会触发父UIView上的layoutSubviews事件
6.改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件
在苹果的官方文档中强调: You should override this method only if the autoresizing behaviors of the subviews do not offer the behavior you want.layoutSubviews, 当我们在某个类的内部调整子视图位置时，需要调用。反过来的意思就是说：如果你想要在外部设置subviews的位置，就不要重写。

### setNeedsLayout

标记为需要重新布局，不立即刷新，但layoutSubviews一定会被调用
配合layoutIfNeeded立即更新
### layoutIfNeeded

如果，有需要刷新的标记，立即调用layoutSubviews进行布局

这个动画中有用到 举个栗子。

如图 ， 上面有个label ，中间有个按钮 ， label已经被自动布局到左上角 。 然后我们那个left的constraint
  @IBOutlet weak var leftContrain:NSLayoutConstraint!
在viewDidLoad中声明好，然后在Main.storyboard中进行连线。点击按钮的时候 ，我们把左边的距离改成100 。

在按钮的点击事件里加上这句。

leftContrain.constant = 100
然后我们想要一个动画的效果。
如果这么做
   UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                self.leftContrain.constant = 100
            }, completion: nil)
你会发现然并卵 。其实这句话self.leftContrain.constant = 100只是执行了setNeedsLayout 标记了需要重新布局，但是没有立即执行。所以我们需要在动画中调用这个方法layoutIfNeeded
所以代码应该这么写
leftContrain.constant = 100
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                self.view.layoutIfNeeded() //立即实现布局
            }, completion: nil)
所以上面不管写多少约束的改变，只需要在动画里动用 一次self.view.layoutIfNeeded(),所有的都会已动画的方式 。如果一些变化不想动画 。在动画前执行self.view.layoutIfNeeded()

### drawRect

这个方法是用来重绘的。

drawRect在以下情况下会被调用：
1、如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect调用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的.所以不用担心在控制器中,这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量值).
2、该方法在调用sizeToFit后被调用，所以可以先调用sizeToFit计算出size。然后系统自动调用drawRect:方法。3、通过设置contentMode属性值为UIViewContentModeRedraw。那么将在每次设置或更改frame的时候自动调用drawRect:。4、直接调用setNeedsDisplay，或者setNeedsDisplayInRect:触发drawRect:，但是有个前提条件是rect不能为0。以上1,2推荐；而3,4不提倡
drawRect方法使用注意点：
1、若使用UIView绘图，只能在drawRect：方法中获取相应的contextRef并绘图。如果在其他方法中获取将获取到一个invalidate的ref并且不能用于画图。drawRect：方法不能手动显示调用，必须通过调用setNeedsDisplay 或者 setNeedsDisplayInRect，让系统自动调该方法。2、若使用calayer绘图，只能在drawInContext: 中（类似于drawRect）绘制，或者在delegate中的相应方法绘制。同样也是调用setNeedDisplay等间接调用以上方法3、若要实时画图，不能使用gestureRecognizer，只能使用touchbegan等方法来掉用setNeedsDisplay实时刷新屏幕
sizeToFit

* sizeToFit会自动调用sizeThatFits方法；
* sizeToFit不应该在子类中被重写，应该重写sizeThatFits
* sizeThatFits传入的参数是receiver当前的size，返回一个适合的size
* sizeToFit可以被手动直接调用sizeToFit和sizeThatFits方法都没有递归，对subviews也不负责，只负责自己
 推荐拓展阅读


### ConvertRect

##### ConvertRect fromView

```objc
CGRect newRect = [self.view convertRect:self.blueView.frame fromView:self.redView];
```

这段代码的意思算出在红色控件里的蓝色控件在控制器view中的位置（其实就是算x和y的值，因为宽高不变）

##### ConvertRect toView

```objc
CGRect newRect = [self.blueView convertRect:CGRectMake(50, 50, 100, 100) toView:self.greenView];
```

* 调用视图 `convertRect`: 调用视图相对于目标视图的frame 
* toview:目标视图
* 目标视图为`nil`的时候指的是Window

## [理解UIView的绘制](http://vizlabxt.github.io/blog/2012/10/22/UIView-Rendering/)

也许要先从Runloop开始说，iOS的mainRunloop是一个60fps的回调，也就是说每16.7ms会绘制一次屏幕，这个时间段内要完成view的缓冲区创建，view内容的绘制（如果重写了drawRect），这些CPU的工作。然后将这个缓冲区交给GPU渲染，这个过程又包括多个view的拼接(compositing)，纹理的渲染（Texture）等，最终显示在屏幕上。因此，如果在16.7ms内完不成这些操作，比如，CPU做了太多的工作，或者view层次过于多，图片过于大，导致GPU压力太大，就会导致“卡”的现象，也就是丢帧。

苹果官方给出的最佳帧率是：60fps，也就是1帧不丢，当然这是理想中的绝佳的体验。

这个60fps改怎么理解呢？一般来说如果帧率达到25+fps，人眼就基本感觉不到停顿了，因此，如果你能让你ios程序稳定的保持在30fps已经很不错了，注意，是“稳定”在30fps，而不是，10fps，40fps，20fps这样的跳动，如果帧频不稳就会有卡的感觉。60fps真的很难达到，尤其在iphone4，4s上。

总的来说，UIView从绘制到Render的过程有如下几步：

* 每一个UIView都有一个layer，每一个layer都有个content，这个content指向的是一块缓存，叫做backing store。

* UIView的绘制和渲染是两个过程，当UIView被绘制时，CPU执行drawRect，通过context将数据写入backing store

* 当backing store写完后，通过render server交给GPU去渲染，将backing store中的bitmap数据显示在屏幕上

上面提到的从CPU到GPU的过程可用下图表示：

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15212684646463.jpg)

下面具体来讨论下这个过程

#### CPU bound：

假设我们创建一个UILabel：

```
UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 300, 14)];
label.backgroundColor = [UIColor whiteColor];
label.font = [UIFont systemFontOfSize:14.0f];
label.text = @"test";
[self.view addSubview:label];
```

这个时候不会发生任何操作，由于UILabel重写了drawRect，因此，这个view会被marked as “dirty”：

类似这个样子：

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15212684345666.jpg)

然后一个新的Runloop到来，上面说道在这个Runloop中需要将界面渲染上去，对于UIKit的渲染，Apple用的是它的Core Animation。

做法是在Runloop开始的时候调用：

```objc
[CATransaction begin];
```

在Runloop结束的时候调用

```objc
[CATransaction commit];
```

在begin和commit之间做的事情是将view增加到view hierarchy中，这个时候也不会发生任何绘制的操作。

* 当[CATransaction commit]执行完后，CPU开始绘制这个view：

* 首先CPU会为layer分配一块内存用来绘制bitmap，叫做backing store

* 创建指向这块bitmap缓冲区的指针，叫做CGContextRef

* 通过Core Graphic的api，也叫Quartz2D，绘制bitmap

* 将layer的content指向生成的bitmap

* 清空dirty flag标记

* 这样CPU的绘制基本上就完成了。

通过time profiler 可以完整的看到个过程：

```
Running Time Self Symbol Name
2.0ms 1.2% 0.0 +[CATransaction flush]
2.0ms 1.2% 0.0 CA::Transaction::commit()
2.0ms 1.2% 0.0 CA::Context::commit_transaction(CA::Transaction*)
1.0ms 0.6% 0.0 CA::Layer::layout_and_display_if_needed(CA::Transaction*)
1.0ms 0.6% 0.0 CA::Layer::display_if_needed(CA::Transaction*)
1.0ms 0.6% 0.0 -[CALayer display]
1.0ms 0.6% 0.0 CA::Layer::display()
1.0ms 0.6% 0.0 -[CALayer _display]
1.0ms 0.6% 0.0 CA::Layer::display_()
1.0ms 0.6% 0.0 CABackingStoreUpdate_
1.0ms 0.6% 0.0 backing_callback(CGContext*, void*)
1.0ms 0.6% 0.0 -[CALayer drawInContext:]
1.0ms 0.6% 0.0 -[UIView(CALayerDelegate) drawLayer:inContext:]
1.0ms 0.6% 0.0 -[UILabel drawRect:]
1.0ms 0.6% 0.0 -[UILabel drawTextInRect:]
```

假如某个时刻修改了label的text：

    label.text = @"hello world";

由于内容变了，layer的content的bitmap的尺寸也要变化，因此这个时候当新的Runloop到来时，CPU要为layer重新创建一个backing store，重新绘制bitmap。

CPU这一块最耗时的地方往往在Core Graphic的绘制上，关于Core Graphic的性能优化是另一个话题了，又会牵扯到很多东西，就不在这里讨论了。

GPU bound：

CPU完成了它的任务：将view变成了bitmap，然后就是GPU的工作了，GPU处理的单位是Texture。

基本上我们控制GPU都是通过OpenGL来完成的，但是从bitmap到Texture之间需要一座桥梁，Core Animation正好充当了这个角色：

Core Animation对OpenGL的api有一层封装，当我们的要渲染的layer已经有了bitmap content的时候，这个content一般来说是一个CGImageRef，CoreAnimation会创建一个OpenGL的Texture并将CGImageRef（bitmap）和这个Texture绑定，通过TextureID来标识。

这个对应关系建立起来之后，剩下的任务就是GPU如何将Texture渲染到屏幕上了。

GPU大致的工作模式如下：


![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15212685103262.jpg)

整个过程也就是一件事：CPU将准备好的bitmap放到RAM里，GPU去搬这快内存到VRAM中处理。

而这个过程GPU所能承受的极限大概在16.7ms完成一帧的处理，所以最开始提到的60fps其实就是GPU能处理的最高频率。

因此，GPU的挑战有两个：

1. 将数据从RAM搬到VRAM中
2. 将Texture渲染到屏幕上

这两个中瓶颈基本在第二点上。渲染Texture基本要处理这么几个问题：

Compositing：

Compositing是指将多个纹理拼到一起的过程，对应UIKit，是指处理多个view合到一起的情况，如

```objc
[self.view addSubview: subview];
```
如果view之间没有叠加，那么GPU只需要做普通渲染即可。 如果多个view之间有叠加部分，GPU需要做blending。

加入两个view大小相同，一个叠加在另一个上面，那么计算公式如下：

```
R = S+D*(1-Sa)
```
R: 为最终的像素值

S: 代表 上面的Texture（Top Texture）

D: 代表下面的Texture(lower Texture)

其中S,D都已经pre-multiplied各自的alpha值。

Sa代表Texture的alpha值。

假如Top Texture（上层view）的alpha值为1，即不透明。那么它会遮住下层的Texture。即,R = S。是合理的。 假如Top Texture（上层view）的alpha值为0.5，S 为 (1,0,0)，乘以alpha后为(0.5,0,0）。D为(0，0，1)。 得到的R为（0.5，0，0.5）。

基本上每个像素点都需要这么计算一次。

因此，view的层级很复杂，或者view都是半透明的（alpha值不为1）都会带来GPU额外的计算工作。

Size

这个问题，主要是处理image带来的，假如内存里有一张400x400的图片，要放到100x100的imageview里，如果不做任何处理，直接丢进去，问题就大了，这意味着，GPU需要对大图进行缩放到小的区域显示，需要做像素点的sampling，这种smapling的代价很高，又需要兼顾pixel alignment。计算量会飙升。

Offscreen Rendering And Mask

如果我们对layer做这样的操作：

```objc
label.layer.cornerRadius = 5.0f;
label.layer.masksToBounds = YES;
```

会产生offscreen rendering,它带来的最大的问题是，当渲染这样的layer的时候，需要额外开辟内存，绘制好radius，mask，然后再将绘制好的bitmap重新赋值给layer。

因此继续性能的考虑，Quartz提供了优化的api：


```objc
label.layer.cornerRadius = 5.0f;
label.layer.masksToBounds = YES;
label.layer.shouldRasterize = YES;
label.layer.rasterizationScale = label.layer.contentsScale;
```


简单的说，这是一种cache机制。

同样GPU的性能也可以通过instrument去衡量：

QQ20131123-6

红色代表GPU需要做额外的工作来渲染View，绿色代表GPU无需做额外的工作来处理bitmap。

That’s all


> UIView可以说是我们日常工作中接触最多的一个对象、是所有视图控件(不包括视图控制器)的基类。
> 主要的功能包括视图样式、层级、约束、自动布局、渲染、手势、动画、坐标转换等等。

其中有些东西(~~比如原生自动布局、而我们平时都用mas/sd~~)并不常用、所以只筛选了一部分平时可能用得到的地方。
由于内容实在太多、所以有些复杂的地方只是简单总结一下并且给出一些参考链接方便查阅

* * *

目录主要分为以下几个样式:
**常用**、会用、_了解_

[iOS文档补完计划--UIView - 简书](https://www.jianshu.com/p/ea3d2970a892)

## UIView属性目录

**创建视图对象**
**配置视图的视觉外观**
    **backgroundColor**
    **hidden**
    **alpha**
    _opaque_
    tintColor
    _tintAdjustmentMode_
    **clipsToBounds**
    _clearsContextBeforeDrawing_
    **maskView**
    layerClass
    layer
**配置与事件相关的行为**
    **userInteractionEnabled**
    multipleTouchEnabled
    exclusiveTouch
**配置边界和框架矩形**
    **frame**
    **bounds**
    center
    **transform**
**管理视图层次结构**
    **superview**
    **subviews**
    _window_
    **addSubview**
    **removeFromSuperview**
    bringSubviewToFront
    sendSubviewToBack
    insertSubview:atIndex:
    insertSubview:aboveSubview:
    insertSubview: belowSubview:
    exchangeSubviewAtIndex:withSubviewAtIndex:
    **isDescendantOfView:**
观察与视图层级的更改
    didAddSubview/willRemoveSubview等六个方法
配置内容边距
    _LayoutMargins相关_
**屏幕的安全区域**
    **safeAreaInsets**
    **safeAreaLayoutGuide**
    safeAreaInsetsDidChange
    insetsLayoutMarginsFromSafeArea
**测量Auto Layout**
    **systemLayoutSizeFittingSize**
    systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority
    **intrinsicContentSize**
    **invalidateIntrinsicContentSize**
    **Compression Resistance priority(抗压缩)**
    **Hugging priority(抗拉伸)**
**触发自动布局**
    needsUpdateConstraints
    **setNeedsUpdateConstraints**
    **updateConstraints**
    **updateConstraintsIfNeeded**
**配置调整大小行为**
    **contentMode**
    **UIViewContentMode**
    **sizeThatFits**
    sizeToFit
    autoresizesSubviews
    autoresizingMask
**布局子视图**
    **layoutSubviews**
    **setNeedsLayout**
    **layoutIfNeeded**
    _requiresConstraintBasedLayout_
    _translatesAutoresizingMaskIntoConstraints_
**绘制和更新视图**
    **drawRect**
    **setNeedsDisplay**
    **setNeedsDisplayInRect**
    _contentScaleFactor_
    tintColorDidChange
**管理手势识别器**
    **添加删除和获取**
    **gestureRecognizerShouldBegin**
_观察焦点_
    _canBecomeFocused_
    _focused_
_运动视觉效果_
    _添加删除和获取_
**后台启动恢复**
捕获视图快照
**识别视图**
    **tag**
    **viewWithTag**
**坐标系转换**
    **convertPoint**
    **convertRect**
    **超出父视图的View可以被点击**
**命中测试(Hit-Testing)**
    **hitTest:withEvent**
    **pointInside:withEvent**
    **为响应链寻找最合适的FirstView**
**结束视图编辑**
    **endEditing:**
Block动画
首尾式动画

* * *

### UIView

> 包含了UIView的基本功能

##### userInteractionEnabled

> 设置用户交互，默认YES允许用户交互

```
@property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

```

##### tag

> 控件标记(父控件可以通过tag找到对应的子控件)，默认为0

```
@property(nonatomic)  NSInteger tag; 

```

##### 观察焦点

##### 管理用户界面方向

**semanticContentAttribute(翻转效果)**

> 是否翻转视图

```
@property (nonatomic) UISemanticContentAttribute semanticContentAttribute NS_AVAILABLE_IOS(9_0);

```

[世上总是有很多奇人异事、比如阿拉伯人的阅读顺序。](https://www.jianshu.com/p/34b5a8d9a77e)
可以让布局自动左右翻转、不过前提是布局时使用Leading以及Trailing两个约束条件而不是Left和Right。

**获取视图方向**

```
/** 获取视图的方向 */
+ (UIUserInterfaceLayoutDirection)userInterfaceLayoutDirectionForSemanticContentAttribute:(UISemanticContentAttribute)attribute NS_AVAILABLE_IOS(9_0);

/** 获取相对于指定视图的界面方向 */
+ (UIUserInterfaceLayoutDirection)userInterfaceLayoutDirectionForSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute relativeToLayoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection NS_AVAILABLE_IOS(10_0);

/** 返回即时内容的布局的方向 */
@property (readonly, nonatomic) UIUserInterfaceLayoutDirection effectiveUserInterfaceLayoutDirection NS_AVAILABLE_IOS(10_0);

```

* * *

### UIViewGeometry(几何分类)

##### multipleTouchEnabled

> 是否允许多点触摸 默认NO

```
@property(nonatomic,getter=isMultipleTouchEnabled) BOOL multipleTouchEnabled;

```

* * *

### 创建视图对象

```
/** 通过Frame初始化UI对象 */
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
/** 用于xib初始化 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

```

* * *

### 配置视图的视觉外观

##### backgroundColor

> 视图背景色

```
@property(nonatomic, copy) UIColor *backgroundColor;

```

默认值nil、也就是透明。

##### hidden

> 是否隐藏视图

```
@property(nonatomic, getter=isHidden) BOOL hidden;

```

父视图的隐藏会导致子视图被隐藏。并且不能被点击、不能成为第一响应者

##### alpha

> 视图透明度

```
@property(nonatomic) CGFloat alpha;

```

父视图的透明度会应用到子视图上。小于0.01则等于被隐藏了。

##### opaque

> 视图是否不透明。主要是用于视图混合

```
@property(nonatomic, getter=isOpaque) BOOL opaque;

```

UIView的默认值是YES、但UIButton等子类的默认值都是NO。
需要注意他并不是我们肉眼层面的透明。

[这和视图合成机制有关](https://blog.csdn.net/wzzvictory/article/details/10076323)
简而言之如果你的视图`alpha=1`、完全可以将`opaque=YES`。让GPU在混合视图时不必考虑下方视图颜色。

##### tintColor

> 色调颜色

```
@property(nonatomic, strong) UIColor *tintColor;

```

1.  `父视图`更改了tintColor为red，那么它所有的一级`子视图`tintColor全部为red。下一级也会根据前一级进行设置。
    除非你主动设置了子视图的tintColor。
2.  `原生控件`基本都有`默认的tintColor`、比如`UIButton为蓝色`。
    当然、也和创建的方式有关。`UIButtonTypeCustom`方式是没有的。
3.  当tintColor被修改、将会调用对象的`tintColorDidChange:`方法。
    个人感觉就这个玩意比较有用、毕竟我们更多的是自定义控件着色。不可能希望全屏幕变成一个颜色。

想进一步了解的话。这里推荐一个博客可以看一看: [《iOS tintColor解析》](https://www.cnblogs.com/wfwenchao/p/4884833.html)

##### tintAdjustmentMode

> 色调(tintColor)模式

```
typedef NS_ENUM(NSInteger, UIViewTintAdjustmentMode) {
    UIViewTintAdjustmentModeAutomatic,//视图的着色调整模式与父视图一致

    UIViewTintAdjustmentModeNormal,//默认值
    UIViewTintAdjustmentModeDimmed,//暗色
} NS_ENUM_AVAILABLE_IOS(7_0);

@property(nonatomic) UIViewTintAdjustmentMode tintAdjustmentMode NS_AVAILABLE_IOS(7_0);

```

改变这个属性、也会调用`tintColorDidChange:`方法。

##### clipsToBounds

> 是否截取掉超过子视图超过自身的部分、默认为NO

```
@property(nonatomic)  BOOL  clipsToBounds; 

```

最大的用处还是切圆角和图片吧。
需要注意的是`layer`有一个方法`maskToBounds`也是一个作用、`clipsToBounds`内部就是调用了`maskToBounds`。
其实效果一样、只不过从语义上来讲分成`View`和`layer`两个方法。

##### clearsContextBeforeDrawing

> 视图重绘前是否先清理以前的内容，默认YES

```
@property(nonatomic)  BOOL   clearsContextBeforeDrawing;

```

如果你把这个属性设为NO、那么你要保证能在 drawRect：方法中正确的绘画。
如果你的代码已经做了大量优化、那么设为NO可以提高性能、尤其是在滚动时可能只需要重新绘画视图的一部分。
所以说、通常用不到。

##### maskView

> 遮罩层

```
@property(nullable, nonatomic,strong) UIView *maskView NS_AVAILABLE_IOS(8_0);

```

1.  虽说是遮罩层、但实际上不会多出一个View。
    只是对颜色的混合有影响。
2.  只会显示出与maskView可见(不透明)部分重叠的部分。
3.  maskView的对应点的alpha会赋值给View对应的point。
4.  与layer.mask基本相同、只是需要8.0的支持。

举一个简单的例子：

```
UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 100, 200, 200)];
view1.backgroundColor = [UIColor blueColor];

UIView * maskView = [[UIView alloc]initWithFrame:view1.bounds];
maskView.backgroundColor = [UIColor clearColor];

UIView * view_1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 200)];
view_1.backgroundColor = [UIColor whiteColor];
[maskView addSubview:view_1];

UIView * view_2 = [[UIView alloc]initWithFrame:CGRectMake(100, 0, 100, 200)];
view_2.backgroundColor = [UIColor whiteColor];
view_2.alpha = 0.5;
[maskView addSubview:view_2];

view1.maskView = maskView;
[self.view addSubview:view1];

```

![](//upload-images.jianshu.io/upload_images/1552225-ad708d8c7eec459b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/450/format/webp)

你还可以通过layer或者图片来设计出很多有趣的效果:[《使用 maskView 设计动画》](https://www.jianshu.com/p/6e360516e3bc)、[《还有一个有趣的动画库》](https://github.com/rounak/RJImageLoader)(layer.mask)

##### layerClass

> 返回当前View所使用的根Layer类型

```
#if UIKIT_DEFINE_AS_PROPERTIES
@property(class, nonatomic, readonly) Class layerClass;                        // default is [CALayer class]. Used when creating the underlying layer for the view.
#else
+ (Class)layerClass;                        // default is [CALayer class]. Used when creating the underlying layer for the view.
#endif

```

layer有很多种、比如`CATextLayer`适合文本、`CAGradientLayer`适合处理渐变、`CAReplicatorLayer`适合处理很多相似的图层。

当然这些我都不太了解~你可以参阅[《[iOS Animation]-CALayer 专用图层》](https://www.cnblogs.com/daxiaxiaohao/p/4272722.html)

##### layer

> layer视图图层(可以用来设置圆角效果/阴影效果)

```
@property(nonatomic,readonly,strong) CALayer  *layer;  

```

* * *

### 配置与事件相关的行为

##### userInteractionEnabled

> 设置用户交互、默认YES允许用户交互。

```
@property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

```

这个属性直接影响到控件能否进入响应链或者成为第一响应者。
[《iOS文档补完计划--UIResponder》](https://www.jianshu.com/p/0af63fe03f76)

##### multipleTouchEnabled

> 是否允许多指触控。默认NO

```
@property(nonatomic,getter=isMultipleTouchEnabled) BOOL multipleTouchEnabled __TVOS_PROHIBITED;

```

##### **exclusiveTouch**

> 是否让View独占Touch事件

```
@property(nonatomic,getter=isExclusiveTouch) BOOL       exclusiveTouch;

```

默认是NO。设置成YES避免在一个界面上同时点击多个button。

* * *

### 配置边界和框架矩形

##### frame

> 位置和尺寸

```
@property(nonatomic) CGRect  frame;

```

以父控坐标系的左上角为坐标原点(0, 0)

##### bounds

> 位置和尺寸

```
@property(nonatomic) CGRect    bounds;

```

以自身标系的左上角为坐标原点(0, 0)

##### center

> 中心点

```
@property(nonatomic) CGPoint   center;

```

以父控件的左上角为坐标原点(0, 0)

##### transform

> 形变

```
@property(nonatomic) CGAffineTransform transform;

```

可以做一些Transform动画、大概就是形变、缩放、位移咯。
**比如你可以给cell做一些小动画**

```
NSArray *cells = tableView.visibleCells;
for (int i = 0; i < cells.count; i++) {
    UITableViewCell *cell = [cells objectAtIndex:i];
    if (i%2 == 0) {
        cell.transform = CGAffineTransformMakeTranslation(-BSScreen_Width,0);
    }else {
        cell.transform = CGAffineTransformMakeTranslation(BSScreen_Width,0);
    }
    [UIView animateWithDuration:duration delay:i*0.03 usingSpringWithDamping:0.75 initialSpringVelocity:1/0.75 options:0 animations:^{
        cell.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {

    }];
}

```

* * *

### 管理视图层次结构

##### superview

> 获取父视图

```
@property(nullable, nonatomic,readonly) UIView *superview;

```

##### subviews

> 获取所有子视图

```
@property(nonatomic,readonly,copy) NSArray<__kindof UIView *> *subviews;

```

数组的顺序等于添加到父视图上的顺序。
你也可以尝试用递归的方式遍历所有子视图嗯。

##### window

> 获取视图所在的Window

```
@property(nullable, nonatomic,readonly) UIWindow  *window;

```

这个我也不太懂干嘛的。只知道如果父视图是UIWindow一定有值、否则(_我测试的都是_)为空。

##### - addSubview:

> 添加子视图

```
- (void)addSubview:(UIView *)view;

```

会被添加在subviews的末尾、视图层级的最上方。

##### - removeFromSuperview

> 从父视图上移除

```
- (void)removeFromSuperview;

```

##### - bringSubviewToFront:

> 移动指定的子视图，使其显示在其所以兄弟节点之上

```
- (void)bringSubviewToFront:(UIView *)view;

```

##### - **sendSubviewToBack**:

> 移动指定的子视图，使其显示在其所有兄弟节点之下

```
- (void)sendSubviewToBack:(UIView *)view;

```

自己试去吧~

```
UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(10, 150, 100, 50)];
view1.backgroundColor = [UIColor blueColor];
[self.view addSubview:view1];

UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(15, 155, 100, 50)];
view2.backgroundColor = [UIColor grayColor];
[self.view addSubview:view2];

UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(20, 160, 100, 50)];
view3.backgroundColor = [UIColor yellowColor];
[self.view addSubview:view3];

//如果将下面两行代码都注释掉   view1 会在下面   view2会在上面
//  下面这行代码能够将view2  调整到父视图的最下面
//    [self.view sendSubviewToBack:view2];
//将view调整到父视图的最上面
[self.view bringSubviewToFront:view1];

```

##### - insertSubview:atIndex:

> 插入子视图(将子视图插入到subviews数组中index这个位置)

```
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index;

```

##### - insertSubview:aboveSubview:

> 插入子视图(将子视图插到siblingSubview之上)

```
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview;

```

##### - insertSubview: belowSubview:

> 插入子视图(将子视图插到siblingSubview之下)

```
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview;

```

##### - exchangeSubviewAtIndex:withSubviewAtIndex:

> 交换两个子视图

```
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2;

```

##### - **isDescendantOfView**:

> 检测一个视图是否属于另一个的子视图

```
- (BOOL)isDescendantOfView:(UIView *)view;

```

举个例子:

```
(lldb) po [self.view isDescendantOfView:view1]
NO
(lldb) po [view1 isDescendantOfView:self.view]
YES

```

需要注意的是、这个判定并不局限于一级结构。

* * *

### **观察与视图层级的更改**

> 包含子视图的成功添加/移除、本视图添加到新父视图的开始/结束。

一下方法默认不做任何操作。需要注意的是在`removeFromSuperview`时、也会调用。只不过`newSuperview`为空。

```
/** 添加自视图完成后调用 */
- (void)didAddSubview:(UIView *)subview;
/** 将要移除自视图时调用 */
- (void)willRemoveSubview:(UIView *)subview;

/** 将要移动到新父视图时调用 */
- (void)willMoveToSuperview:(nullable UIView *)newSuperview;
/** 移动到新父视图完成后调用 */
- (void)didMoveToSuperview;
/** 将要移动到新Window时调用 */
- (void)willMoveToWindow:(nullable UIWindow *)newWindow;
/** 移动到新Window完成后调用 */
- (void)didMoveToWindow;

```

* * *

### 配置内容边距

> [官方文档对Content Margin的解释](https://developer.apple.com/documentation/uikit/uiview/positioning_content_within_layout_margins?language=objc)

##### directionalLayoutMargins

> iOS11 开始引入，可以根据语言的方向进行前后布局，与 layoutMargins 相比，能更好的适配 RTL 语言。

```
@property (nonatomic) NSDirectionalEdgeInsets directionalLayoutMargins API_AVAILABLE(ios(11.0),tvos(11.0));

```

但和我们关系不大、除非某天我们进军中东的某些国家了。

##### layoutMargins

> 自动布局时。用于指定视图和它的子视图之间的边距。

```
@property (nonatomic) UIEdgeInsets layoutMargins NS_AVAILABLE_IOS(8_0);

```

iOS11之后请使用`directionalLayoutMargins`属性进行布局。他将左右的概念替换成了前后。而且这两个属性会互相同步

默认为8个单位。如果视图并不是完全处于安全区域内或者设置了`preservesSuperviewLayoutMargins`则可能更大。

~~不过说实话如果用masonry的话感觉这个属性意义不大~~

##### preservesSuperviewLayoutMargins

> 是否将当前视图的间距和父视图相同。

```
@property (nonatomic) BOOL preservesSuperviewLayoutMargins NS_AVAILABLE_IOS(8_0);

```

设置一个视图的边距（视图边缘与其子视图边缘的距离）、防止其子视图和父视图边缘重合。

##### -layoutMarginsDidChange

> 改变view的layoutMargins这个属性时，会触发这个方法

```
- (void)layoutMarginsDidChange NS_AVAILABLE_IOS(8_0);

```

用原生Layout来布局说实话我没用过。可以看看这篇帖子:[《layoutMargins和preservesSuperviewLayoutMargins》](https://www.jianshu.com/p/4237bd89f521)

* * *

### 屏幕的安全区域

> [官方文档对的《Safe Area》解释](https://developer.apple.com/documentation/uikit/uiview/positioning_content_relative_to_the_safe_area?language=objc)

**iOS11之后、(~~为了帮助适配iPhoneX？~~)苹果给我们引入了一个安全区域的概念。**
**安全区域帮助我们将view放置在整个屏幕的可视的部分。即使把navigationbar设置为透明的，系统也认为安全区域是从navigationbar的bottom开始，保证不被系统的状态栏、或导航栏覆盖。**

##### safeAreaInsets

> 反映了一个view距离该view的安全区域的边距

```
@property (nonatomic,readonly) UIEdgeInsets safeAreaInsets API_AVAILABLE(ios(11.0),tvos(11.0));

```

这个属性会被系统在布局后自动设置。比如你可以在`UIViewController`的`viewSafeAreaInsetsDidChange`方法下检测横屏以及竖屏下的变化。
对于`UIView`也有对应的方法`safeAreaInsetsDidChange`

##### safeAreaLayoutGuide

> safeAreaLayoutGuide是一个相对抽象的概念，为了便于理解，我们可以把safeAreaLayoutGuide看成是一个“view”，这个“view”系统自动帮我们调整它的bounds，让它不会被各种奇奇怪怪的东西挡住，包括iPhone X的刘海区域和底部的一道杠区域，可以认为在这个“view”上一定能完整显示所有内容。

结合Masonry的用法:将四周与安全区域贴合

```
[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
    make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
}];

```

##### - safeAreaInsetsDidChange

> 当View的`safeAreaInsets`发生变化时自动调用

```
- (void)safeAreaInsetsDidChange API_AVAILABLE(ios(11.0),tvos(11.0));

```

##### insetsLayoutMarginsFromSafeArea

> 决定在自动布局时是否考虑`safeAreaInsets`的限制

```
@property (nonatomic) BOOL insetsLayoutMarginsFromSafeArea

```

示例代码:

```
self.view.insetsLayoutMarginsFromSafeArea = NO;
self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
self.tableView.backgroundColor = [UIColor orangeColor];
self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
[self.view addSubview:self.tableView];

NSArray<__kindof NSLayoutConstraint *> *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tableView]-|" options:0 metrics:nil views:@{@"tableView" : self.tableView}];
[self.view addConstraints:constraints];

constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:@{@"tableView" : self.tableView}];
[self.view addConstraints:constraints];

```

关于iOS11安全区域的特性、推荐一篇Bugly的帖子[《iOS 11 安全区域适配总结》](https://mp.weixin.qq.com/s/W1_0VrchCO50owhJNmJnuQ)

* * *

### 测量Auto Layout

##### - **systemLayoutSizeFittingSize**:

> **返回Auto Layout后内容高度**。

```
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize NS_AVAILABLE_IOS(6_0);

```

通常用于包含多层视图的控件计算(比如cell)。这里注意与`sizeThatFits`和`sizeToFits`进行区分。

```
UILabel *label = [[UILabel alloc] init];
label.text = @"SafeAreaS";
label.numberOfLines = 0;
label.textAlignment = NSTextAlignmentCenter;
label.backgroundColor = [UIColor greenColor];
[self.view addSubview:label];

[label mas_makeConstraints:^(MASConstraintMaker *make) {
    if (@available(iOS 11, *)) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
    } else {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.mas_equalTo(0);
    }

}];

[self.view layoutIfNeeded];
CGSize layoutSize =  [label systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
CGSize labelSize = label.frame.size;

//(lldb) po layoutSize
//(width = 79.666666666666671, height = 20.333333333333332)
//
//(lldb) po labelSize
//(width = 79.666666666666671, height = 20.333333333333332)

```

利用这个方法、我们可以对是适应高度的Cell高度进行缓存来适配iOS8以下的情况。需要注意的是要对`cell.contentView`进行计算。

```
model.cellHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

```

##### systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:

> 和上一个方法一样、但是增加了宽高的优先级。使结果更加准确

```
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority NS_AVAILABLE_IOS(8_0);

```

##### intrinsicContentSize

> 返回控件的固有大小

```
#if UIKIT_DEFINE_AS_PROPERTIES
@property(nonatomic, readonly) CGSize intrinsicContentSize NS_AVAILABLE_IOS(6_0);
#else
- (CGSize)intrinsicContentSize NS_AVAILABLE_IOS(6_0);
#endif

```

在自动布局时、有些控件(UILabel/UIButton/UIImageView等)`只需要设置位置而不需要设置大小`、就是利用这个属性。

当内容改变时、调用`invalidateIntrinsicContentSize`通知系统、并且自定义`intrinsicContentSize`的实现、来返回合适的宽高。

举个例子、你可以让你的UITextField能够自适应宽度[《一个随输入文字宽度变化的自定义UITextField》](https://www.jianshu.com/p/a5eaba3c24f7)。

##### - invalidateIntrinsicContentSize

> 废除视图原本内容的`intrinsicContentSize`

```
- (void)invalidateIntrinsicContentSize NS_AVAILABLE_IOS(6_0); 

```

上面已经说过用法了

##### 抗压缩与抗拉伸

##### Compression Resistance priority(抗压缩)

> 有多大的优先级阻止自己变小

```
/* 返回某个方向的抗压缩等级 */
- (UILayoutPriority)contentCompressionResistancePriorityForAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);
/* 设置某个方向的抗压缩等级*/
- (void)setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

```

##### Hugging priority(抗拉伸)

> 有多大的优先级阻止自己变大

```
/* 返回某个方向上的抗拉伸等级 */
- (UILayoutPriority)contentHuggingPriorityForAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);
/* 设置某个方向上的抗拉伸等级*/
- (void)setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

```

通常是给UILabel用的[《HuggingPriority和CompressionResistance 一个例子教你理解》](https://www.jianshu.com/p/5cf559435eb9)

* * *

### 触发自动布局

##### - needsUpdateConstraints

> 通知用户是否有需要更新的约束

```
- (BOOL)needsUpdateConstraints NS_AVAILABLE_IOS(6_0);

```

这个可以作为你判断是否应该在后续代码里主动调用`updateConstraints`的前提。不过通常我们都不太需要、因为布局的修改都是自己写的自然清楚何时调用。
还有就是当View尚未展示时、更新的标记一直会返回YES。

##### - setNeedsUpdateConstraints

> 标记准备更改约束

```
- (void)setNeedsUpdateConstraints NS_AVAILABLE_IOS(6_0);

```

通常是用作批量修改约束时的优化、避免系统多次计算。

##### - updateConstraints

> 当View本体的布局被修改时被自动调用

```
- (void)updateConstraints NS_AVAILABLE_IOS(6_0) NS_REQUIRES_SUPER;

```

你可以在这里自己更新View内部控件的布局、需要调用super实现。
会被调用的情况:

1.  视图被添加到父视图上
2.  主动调用`updateConstraintsIfNeeded`
3.  更新约束时

###### 这里需要注意的是更新约束后自动调用的时机:

1.  如果你使用`NSLayoutConstraint`对约束进行更新
    `updateConstraints`方法会`自动调用`。
2.  如果使用`Masonry`对约束进行更新
    `updateConstraints`方法`不会自动调用`。
    你需要手动`setNeedsUpdateConstraints`然后`updateConstraintsIfNeeded`

##### - updateConstraintsIfNeeded

> 立即触发约束更新，自动更新布局

```
- (void)updateConstraintsIfNeeded NS_AVAILABLE_IOS(6_0);

```

会把之前`setNeedsUpdateConstraints`标记之后的所有约束修改、同时更新。
并且(如果控件已经被`setNeedsUpdateConstraints`标记)自动调用控件的`updateConstraints`方法。

##### 所以、方法调用的顺序为：

视图的布局改变时:`updateConstraints`被执行。
视图布局修改:`setNeedsUpdateConstraints`-->`updateConstraintsIfNeeded`
而当`setNeedsUpdateConstraints`被调用`needsUpdateConstraints`也会返回YES作为标记。

贴一个Masoney动画的例子:[《Masonry自动布局详解二：动画更新约束》](https://blog.csdn.net/woaifen3344/article/details/50114415)
但是这个帖子有些问题

```
// 告诉self.view约束需要更新
[self.view setNeedsUpdateConstraints];
// 调用此方法告诉self.view检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
[self.view updateConstraintsIfNeeded];

```

这两句话并没什么必要、因为我并没有更新self.view的约束。直接修改成这样、是比较好的。

```
- (void)onGrowButtonTaped:(UIButton *)sender {
    self.scacle += 0.5;

    [self.growingButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);

        // 初始宽、高为100，优先级最低
        make.width.height.mas_equalTo(100 * self.scacle);
        // 最大放大到整个view
        make.width.height.lessThanOrEqualTo(self.view);
    }];

    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

```

这也佐证了一个问题。`layoutIfNeeded`执行动画与`setNeedsUpdateConstraints`/`updateConstraintsIfNeeded`并没什么直接关系。

* * *

### 配置调整大小行为

##### contentMode

> 内容显示的模式。默认`UIViewContentModeScaleToFill

```
@property(nonatomic) UIViewContentMode contentMode;  

```

我们平时调整图片显示状态用的就是这个属性

##### UIViewContentMode

> 内容具体的显示模式

```
typedef NS_ENUM(NSInteger, UIViewContentMode) {
    UIViewContentModeScaleToFill,       //!< 缩放内容到合适比例大小.
    UIViewContentModeScaleAspectFit,    //!< 缩放内容到合适的大小，边界多余部分透明.
    UIViewContentModeScaleAspectFill,   //!< 缩放内容填充到指定大小，边界多余的部分省略.
    UIViewContentModeRedraw,            //!< 重绘视图边界 (需调用 -setNeedsDisplay).
    UIViewContentModeCenter,            //!< 视图保持等比缩放.
    UIViewContentModeTop,               //!< 视图顶部对齐.
    UIViewContentModeBottom,            //!< 视图底部对齐.
    UIViewContentModeLeft,              //!< 视图左侧对齐.
    UIViewContentModeRight,             //!< 视图右侧对齐.
    UIViewContentModeTopLeft,           //!< 视图左上角对齐.
    UIViewContentModeTopRight,          //!< 视图右上角对齐.
    UIViewContentModeBottomLeft,        //!< 视图左下角对齐.
    UIViewContentModeBottomRight,       //!< 视图右下角对齐.
};

```

##### - sizeThatFits:

> 计算内容最合适的大小、但并不改变view的size

```
- (CGSize)sizeThatFits:(CGSize)size;

```

通常用于leaf-level views、这里注意与`systemLayoutSizeFittingSize`进行区分。

这里的参数size、类似于UILabel的`preferredMaxLayoutWidth`属性用于限制计算范围。

你可以自己试试

```
UITextView * textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 100, 20, 20)];
[self.view addSubview:textView];
//textView.text = @"asdasdasdasdasdasdasda\nasasdasdasdasdasdasdasda\nasasdasdasdasdasdasdasda\nasasdasdasdasdasdasdasda\nasasdasdasdasdasdasdasda\nasasdasdasdasdasdasdasda\nasasdasdasdasdasdasdasda\nas";

textView.text = @"asdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasdaasdasdasdasdasdasdasda";
textView.backgroundColor = [UIColor orangeColor];

CGSize s = [textView sizeThatFits:CGSizeMake(self.view.bounds.size.width, 999)];
textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, s.width, s.height);

```

如果我们想让UITextField等控件也自适应、重写`intrinsicContentSize`内部用`sizeThatFits:CGSizeMake`计算一下就好了呗。

##### - sizeToFit

> 计算内容最合适的大小、并改变view的size

```
- (void)sizeToFit;

```

会使用控件原有的宽高进行计算、等价于:

```
CGSize s = [textView sizeThatFits:textView.frame.size];
textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, s.width, s.height);

```

注意如果修改了size、会调用`layoutSubviews`

##### autoresizesSubviews

> 当本身大小发生改变时、是否自动布局子视图

```
@property(nonatomic) BOOL  autoresizesSubviews;

```

如果视图的autoresizesSubviews属性声明被设置为YES，则其子视图会根据autoresizingMask属性的值自动进行尺寸调整。

##### autoresizingMask

> 当父视图`autoresizesSubviews`为`YES`并且改变了大小时、该子视图的布局规则。

```
@property(nonatomic) UIViewAutoresizing autoresizingMask;

```

现在基本都是Auto Layout、很少用到这两个东西了。
可以了解一下[《IOS-AutoresizesSubviews》](https://blog.csdn.net/eward9888/article/details/8250556)

* * *

### 布局子视图

##### - layoutSubviews

> 当控件被(系统)赋予了一个新的大小时触发。

```
- (void)layoutSubviews;

```

1.  添加到屏幕时触发
    必须有指定的rect

2.  调用`setNeedsLayout`时触发

3.  size发生改变时触发。
    触发次数需要满足最后两点规则

4.  滑动scrollview时触发

5.  旋转屏幕时触发

6.  **系统赋予大小**
    我们都知道用户所设置的frame/layout并不会直接修改控件frame、而是会在特定的周期由系统进行布局绘制。也就是说、`我们在一个周期内连续设置多次frame/layout、系统也只会在周期结束时布局一次、并触发一次layoutSubviews`。

7.  控件只有被添加到屏幕上、才能触发layoutSubviews。
    通常都会触发两次、因为你还得给他设置frame/layout。
    不过如果先设置frame然后隔了很久才添加到屏幕上、就是一次。

##### - setNeedsLayout

> 为该控件设置标记。等待更新布局

```
- (void)setNeedsLayout;

```

和`setNeedsUpdateConstraints`的机制一样、他允许你对其多个子View进行布局后统一更新。

注意它并不是实时更新、而会在下一次布局周期中进行统一更新。

##### - layoutIfNeeded

> 立即更新该View所有子视图的布局

```
- (void)layoutIfNeeded;

```

它会将所有尚未更新的布局立即进行更新。

通常的用处有两个（欢迎补充）：
1.布局尚未完成、但我们需要获取具体的Frame(当然、根据情况你也可以使用`systemLayoutSizeFittingSize`以节省性能)

```
UIView * view = [UIView new];

[self.view addSubview:view];

[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self.view);
    make.height.mas_equalTo(50);
}];

CGSize s = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
NSLog(@"%lf",s.height);//50.000000

NSLog(@"%lf",view.frame.size.height);//0.000000
[self.view layoutIfNeeded];
NSLog(@"%lf",view.frame.size.height);//50.000000

```

1.  让约束通过动画更新
    贴一个Masoney动画的例子:[《Masonry自动布局详解二：动画更新约束》](https://blog.csdn.net/woaifen3344/article/details/50114415)

##### requiresConstraintBasedLayout

> 标记View是否需要用AutoLayout进行布局

```
#if UIKIT_DEFINE_AS_PROPERTIES
@property(class, nonatomic, readonly) BOOL requiresConstraintBasedLayout NS_AVAILABLE_IOS(6_0);
#else
+ (BOOL)requiresConstraintBasedLayout NS_AVAILABLE_IOS(6_0);
#endif

```

这个说实话不太懂、看文档和网上的意思都是如果不返回YES、有可能不调用`updateConstraints`方法。但是我自己写起来总会调用、希望有大神指正。
至于为什么要调用`updateConstraints`:[《masonry小问题之requiresConstraintBasedLayout》](https://www.jianshu.com/p/b58233a2c640)

##### translatesAutoresizingMaskIntoConstraints

> 是否将`AutoresizingMask`转化成`Constraints`约束。默认为YES

```
@property(nonatomic) BOOL translatesAutoresizingMaskIntoConstraints NS_AVAILABLE_IOS(6_0);

```

名字已经把这个属性的作用说的很明白了、但我们还可以再解释一下:

1.  当我们用代码添加视图时:
    视图的`translatesAutoresizingMaskIntoConstraints`属性默认为`YES`，可是`AutoresizingMask`属性默认会被设置成`None`。也就是说如果我们不去动`AutoresizingMask`，那么`AutoresizingMask`就不会对约束产生影响。
2.  当我们使用`interface builder`添加视图时:
    `AutoresizingMask`虽然会被设置成非`None`，但是`translatesAutoresizingMaskIntoConstraints`默认被设置成了`NO`。所以也不会有冲突。
3.  会出现问题的情况:
    当有一个视图是靠`AutoresizingMask`布局的，而我们修改了`translatesAutoresizingMaskIntoConstraints`后会让视图失去约束，走投无路。例如我自定义转场时就遇到了这样的问题，转场后的视图并不在视图的正中间。

不过这些问题似乎只有用`NSLayoutConstraint`才能体现出问题？

参考[《AutoLayout的那些事儿》](http://www.cocoachina.com/ios/20160530/16522.html)、[《代码添加constraint，设置translatesAutoresizingMaskIntoConstraints为NO的原因》](https://blog.csdn.net/u010140921/article/details/40627983)

* * *

### 绘制和更新视图

##### - drawRect:

> 自定义的绘制内容

```
- (void)drawRect:(CGRect)rect;

```

1.如果是UIView则不需要调用super、UIView子类需要调用super实现。

1.  不要手动调用。
    可以通过`setNeedsDisplay`或者`setNeedsDisplayInRect`让系统自己调用。
2.  UIImageView不允许使用重写draw绘制
    因为他本身也不使用draw绘制、仅仅是使用内部的image view来显示图像
3.  如果自己实现了drawRect、那务必每次都实现它
    `setNeedsDisplay`会将绘制全部清空。系统自动调用时也是。
    `setNeedsDisplayInRect`则会清空指定的rect。

![](//upload-images.jianshu.io/upload_images/1552225-a30d323f8b72db24.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/542/format/webp)

###### 调用的时机:

**1\. 视图第一次被添加到父视图上的时候、由系统自动调用**
需要注意及时`hidden = YES`或者`alpha = 0`也会调用、但`remove`后再`add`并不会。
**2\. 添加到父视图时必须有给定的rect、才会被自动调用**
也就是size必须不为{0,0}
**3\. 修改了rect被调用自动调用**
**4.`setNeedsDisplay`+`setNeedsDisplayInRect`**
当然、必须有rect

###### 具体使用:

在iOS中使用drawRect绘图一般分为以下5个步骤：
1、获取绘图上下文
CGContextRef context = UIGraphicsGetCurrentContext();
2、创建并设置路径
3、将路径添加到上下文
如：线宽、线条颜色、填充颜色等
4、设置上下文状态
5、绘制路径
6、释放路径

具体可以参考:[《drawRect的绘制的使用（绘制文本字符、绘制图片、绘制图形）》](https://blog.csdn.net/potato512/article/details/56845385)

使用DrawRect是会有一定性能问题的:

1.  contents寄宿图
    [《内存恶鬼drawRect》](https://blog.csdn.net/sandyloo/article/details/51063799)
2.  离屏渲染
    [《深刻理解移动端优化之离屏渲染》](http://www.cocoachina.com/ios/20161114/18072.html)

这块我有空准备补一下、先打个卡:
[《iOS绘制和渲染》](https://www.jianshu.com/p/2bbed48dbfd0)

##### - setNeedsDisplay

> 标记全部重绘

```
- (void)setNeedsDisplay;

```

需要注意的是并不会立即重绘、而是等到下一个周期

##### - setNeedsDisplayInRect:

> 标记指定rect重绘

```
- (void)setNeedsDisplayInRect:(CGRect)rect;

```

需要注意的是并不会立即重绘、而是等到下一个周期。

![](//upload-images.jianshu.io/upload_images/1552225-cb6254eb7566b084.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/428/format/webp)

##### contentScaleFactor

> 视图内容的缩放比例

```
@property(nonatomic) CGFloat  contentScaleFactor NS_AVAILABLE_IOS(4_0);

```

修改contentScaleFactor可以让UIView的渲染精度提高，这样即使在CGAffineTransform放大之后仍然能保持锐利

##### - tintColorDidChange

> 当`tintColor`或者`tintAdjustmentMode`被修改时系统调用

```
- (void)tintColorDidChange NS_AVAILABLE_IOS(7_0);

```

你可以把他当成一个监听来使用

```
- (void)tintColorDidChange {
  _tintColorLabel.textColor = self.tintColor;
  _tintColorBlock.backgroundColor = self.tintColor;
}

```

* * *

### 管理手势识别器

##### 添加删除和获取

```
** 当前视图所附加的所有手势识别器 */
@property(nullable, nonatomic,copy) NSArray<__kindof UIGestureRecognizer *> *gestureRecognizers NS_AVAILABLE_IOS(3_2);

/** 添加一个手势识别器 */
- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);
/** 移除一个手势识别器 */
- (void)removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);

```

##### - gestureRecognizerShouldBegin

> 是否继续识别手势。

```
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer NS_AVAILABLE_IOS(6_0);

```

此方法在gesture recognizer视图转出UIGestureRecognizerStatePossible状态时调用，如果返回NO,则转换到UIGestureRecognizerStateFailed;如果返回YES,则继续识别触摸序列.(默认情况下为YES)。

##### 你可以用来在控件指定的位置使用手势识别

```
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [pan translationInView:self.view];
        CGFloat offsetX = self.scrollView.contentOffset.x;
        if (translation.x > 0 && offsetX == 0.0 ) {
               return NO;
        }
    }
    return YES;
}

```

* * *

### 观察焦点

##### canBecomeFocused

> 返回是否可以成为焦点, 默认NO

```
#if UIKIT_DEFINE_AS_PROPERTIES
@property(nonatomic,readonly) BOOL canBecomeFocused NS_AVAILABLE_IOS(9_0); // NO by default
#else
- (BOOL)canBecomeFocused NS_AVAILABLE_IOS(9_0); // NO by default
#endif

```

焦点是给AppleTV用的、用遥控器选择屏幕上的控件。

[在一个以焦点为基础的交互模型中，在屏幕上的单一视图可以得到焦点，并且用户可以通过浏览屏幕上不同的UI选项将焦点移动到其他视图，从而引起焦点更新。得到焦点的视图被用作任何用户操作的目标事件。例如，如果一个屏幕上的按钮被选中，当由遥控器发送按钮选择事件时，目标事件将被触发。](http://www.cocoachina.com/game/20151123/14389.html)

##### focused

> 返回是否已经被聚焦

```
@property (readonly, nonatomic, getter=isFocused) BOOL focused NS_AVAILABLE_IOS(9_0);

```

* * *

### 运动视觉效果

就是王者荣耀那种可以晃手机看背景图的效果吧

##### 添加删除和获取

> 添加、删除、查看、我没用过知道就得了

```

/** 添加运动效果，当倾斜设备时视图稍微改变其位置 */
- (void)addMotionEffect:(UIMotionEffect *)effect NS_AVAILABLE_IOS(7_0);

/** 移除运动效果 */
- (void)removeMotionEffect:(UIMotionEffect *)effect NS_AVAILABLE_IOS(7_0);

/** 所有添加的运动效果 */
@property (copy, nonatomic) NSArray<__kindof UIMotionEffect *> *motionEffects NS_AVAILABLE_IOS(7_0);

```

* * *

### 后台启动恢复

> 你可以让视图在后台恢复时候仍然保持原有的样子

```
/** 标示是否支持保存,恢复视图状态信息 */
@property (nullable, nonatomic, copy) NSString *restorationIdentifier NS_AVAILABLE_IOS(6_0);
/** 保存视图状态相关的信息 */
- (void) encodeRestorableStateWithCoder:(NSCoder *)coder NS_AVAILABLE_IOS(6_0);
/** 恢复和保持视图状态相关信息 */
- (void) decodeRestorableStateWithCoder:(NSCoder *)coder NS_AVAILABLE_IOS(6_0);

```

UIView的例子就不举了、看看UIViewController的挺好[《iOS的App实现状态恢复》](https://www.jianshu.com/p/7f2fe9361f07)

与添加定位或者播放音频等真后台方式不同、这个仅仅是恢复页面。

* * *

### 捕获视图快照

##### - snapshotViewAfterScreenUpdates:

> 对某个视图进行快照

```
- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates;

```

该方法有一个BOOL类型的参数、这个参数表示是否立即生成快照、还是在需要更新视图的时候生成。

```
UIView *showView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];

showView.backgroundColor = [UIColor redColor];

[self.view addSubview:showView];

self.vvvv = showView;

UIView *snap1 = [showView snapshotViewAfterScreenUpdates:NO];

snap1.center = self.view.center;

[self.view addSubview:snap1];

```

设置YES、会等到当前队列的所有方法完成之后、才会生成快照。
在设置NO的情况、延时生成快照、也能达到YES的效果、原理是一样的。

##### - resizableSnapshotViewFromRect:afterScreenUpdates:withCapInsets:

> 比上面的方法多了两个参数、意味着你可以把视图进行分割操作

```
- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect 
                       afterScreenUpdates:(BOOL)afterUpdates 
                            withCapInsets:(UIEdgeInsets)capInsets;

```

##### - drawViewHierarchyInRect:afterScreenUpdates:

> 比之前的多了一个rect参数、其他并没发现什么去区别~

```
- (BOOL)drawViewHierarchyInRect:(CGRect)rect 
             afterScreenUpdates:(BOOL)afterUpdates;

```

关于`afterUpdates`参数：
尽量设置为NO、否则如果视图中途被释放掉会殷勤crash。

* * *

### 识别视图

##### tag

> 识别标识、默认为0

```
@property(nonatomic) NSInteger tag;

```

##### - viewWithTag

> 范围子View中某个tag的View

```
- (__kindof UIView *)viewWithTag:(NSInteger)tag;

```

1.  搜索包括二级子视图
2.  以队列的形式搜索、搜索到一个则返回。

* * *

### 坐标系转换

> 将一个View中的Rect或Point转化到另一个View的坐标系中

```
/** 将point由point所在视图转换到目标视图view中，返回在目标视图view中的point值 */
- (CGPoint)convertPoint:(CGPoint)point toView:(nullable UIView *)view;
/** 将point由point所在视图转换到目标视图view中，返回在目标视图view中的point值 */
- (CGPoint)convertPoint:(CGPoint)point fromView:(nullable UIView *)view;
/** 将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect */
- (CGRect)convertRect:(CGRect)rect toView:(nullable UIView *)view;
/** 将rect从view中转换到当前视图中，返回在当前视图中的rect */
- (CGRect)convertRect:(CGRect)rect fromView:(nullable UIView *)view;

```

每种转换都有两个方法、但实际向作用都一样。
无非是参数位置的区别~
**将view1中的一个视图、转化到view2的坐标系中**

```
[view1 convertRect:view1.childView toView:view2];
[view2 convertRect:view1.childView fromView:view1];

```

需要注意的是`view`参数如果为nil、则会返回基于当前window的坐标。
并且、两个view必须归属于同一个window。

###### 比如让超出父视图的View可以被点击

```
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            //将point从self的坐标系、映射给subView的坐标系
            CGPoint myPoint = [subView convertPoint:point fromView:self];
            //判断point是否在subView上
            if (CGRectContainsPoint(subView.bounds, myPoint)) {
                return subView;
            }
        }
    }
    return view;
}

```

###### 需要注意的是

如果你想让某个控件拦截某个事件、为了保险起见尽量修改父视图的`hitTest`方法、以免被其他原本能够响应的控件捷足先登。

* * *

### 命中测试(Hit-Testing)

##### - hitTest:withEvent:

> 询问事件在当前视图中的响应者，同时又是作为事件传递的桥梁

```
- (UIView *)hitTest:(CGPoint)point 
          withEvent:(UIEvent *)event;

```

上面例子中重载的方法便是这个。

###### 以下几种状态的视图无法响应事件：

1.  不允许交互
    userInteractionEnabled = NO
2.  隐藏
    hidden = YES 如果父视图隐藏，那么子视图也会隐藏，隐藏的视图3\. 无法接收事件
    透明度
    alpha < 0.01 如果设置一个视图的透明度<0.01，会直接影响子视图的透明度。alpha：0.0~0.01为透明。

##### 默认情况下:

1.  若当前视图无法响应事件
    则返回nil
2.  若当前视图可以响应事件
    但无子视图可以响应事件、则返回自身作为当前视图层次中的事件响应者
3.  若当前视图可以响应事件
    同时有子视图可以响应、则返回子视图层次中的事件响应者

###### 其内部实现大致为:

1.  看自身能否响应时间
2.  看点是否在自身上
3.  看子视图是否能够响应

```
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    //3种状态无法响应事件
     if (self.userInteractionEnabled == NO || self.hidden == YES ||  self.alpha <= 0.01) return nil; 
    //触摸点若不在当前视图上则无法响应事件
    if ([self pointInside:point withEvent:event] == NO) return nil; 
    //从后往前遍历子视图数组 
    int count = (int)self.subviews.count; 
    for (int i = count - 1; i >= 0; i--) 
    { 
        // 获取子视图
        UIView *childView = self.subviews[i]; 
        // 坐标系的转换,把触摸点在当前视图上坐标转换为在子视图上的坐标
        CGPoint childP = [self convertPoint:point toView:childView]; 
        //询问子视图层级中的最佳响应视图
        UIView *fitView = [childView hitTest:childP withEvent:event]; 
        if (fitView) 
        {
            //如果子视图中有更合适的就返回
            return fitView; 
        }
    } 
    //没有在子视图中找到更合适的响应视图，那么自身就是最合适的
    return self;
}

```

##### - pointInside:withEvent:

> 判断触摸点是否在自身坐标范围内

```
- (BOOL)pointInside:(CGPoint)point 
          withEvent:(UIEvent *)event;

```

默认实现是若在坐标范围内则返回YES，否则返回NO。

所以之前那个超出范围点击的方法中

```
if (CGRectContainsPoint(subView.bounds, myPoint)) {
    return subView;
}

```

换成

```
if ([subView pointInside:myPoint withEvent:event]) {
    return subView;
}

```

也是一样可行的。

通过修改`pointInside`的判定[《扩大UIButton的点击范围》](https://www.jianshu.com/p/e368d3fea803)

##### 为响应链寻找最合适的FirstView

从事件传递到APP中开始、寻找最合适的View
UIApplication -> UIWindow -> 父View -> 子view

1.  逐级调用`hitTest:withEvent`方法
2.  `hitTest:withEvent`方法内部通过`pointInside:withEvent:`进行判断。
    通过则返回自身

* * *

### 结束视图编辑

##### - endEditing:

> 强制让自身或者子视图上的`UIResponder`放弃第一响应者。

```
- (BOOL)endEditing:(BOOL)force;

```

更多收起键盘的方式可以看看[《iOS开发－关闭/收起键盘方法总结》](https://www.jianshu.com/p/7db20da82c4a)

* * *

### Block动画

> 传统的Block动画

但是苹果文档中更推荐使用[《UIViewPropertyAnimator》](https://developer.apple.com/documentation/uikit/uiviewpropertyanimator?language=objc)来做动画了

```
/** 用于对一个或多个视图的改变的持续时间、延时、选项动画完成时的操作 */
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

/** 用于对一个或多个视图的改变的持续时间、选项动画完成时的操作，默认：delay = 0.0, options = 0 */
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

/** 用于对一个或多个视图的改变的持续时间内动画完成时的操作，默认：delay = 0.0, options = 0, completion = NULL */
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations NS_AVAILABLE_IOS(4_0);

/** 使用与物理弹簧运动相对应的定时曲线执行视图动画 */
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);

/** 为指定的容器视图创建转换动画 */
+ (void)transitionWithView:(UIView *)view duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^ __nullable)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

/** 使用给定的参数在指定视图之间创建转换动画 */
+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(4_0); // toView added to fromView.superview, fromView removed from its superview

/** 在一个或多个视图上执行指定的系统提供的动画，以及定义的可选并行动画 */
+ (void)performSystemAnimation:(UISystemAnimation)animation onViews:(NSArray<__kindof UIView *> *)views options:(UIViewAnimationOptions)options animations:(void (^ __nullable)(void))parallelAnimations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);

```

* * *

### 首尾式动画

> 通过上下文的方式对动画进行配置

但是苹果文档中更推荐使用[《UIViewPropertyAnimator》](https://developer.apple.com/documentation/uikit/uiviewpropertyanimator?language=objc)来做动画了

```
/** 开始动画 */
+ (void)beginAnimations:(nullable NSString *)animationID context:(nullable void *)context;
/** 提交动画 */
+ (void)commitAnimations;

/** 设置动画代理, 默认nil */
+ (void)setAnimationDelegate:(nullable id)delegate;
/** 动画将要开始时执行方法（必须要先设置动画代理）, 默认NULL */
+ (void)setAnimationWillStartSelector:(nullable SEL)selector;
/** 动画已结束时执行方法（必须要先设置动画代理）, 默认NULL */
+ (void)setAnimationDidStopSelector:(nullable SEL)selector;
/** 设置动画时长, 默认0.2秒 */
+ (void)setAnimationDuration:(NSTimeInterval)duration;
/** 动画延迟执行时间, 默认0.0秒 */
+ (void)setAnimationDelay:(NSTimeInterval)delay;
/** 设置在动画块内部动画属性改变的开始时间, 默认now ([NSDate date]) */
+ (void)setAnimationStartDate:(NSDate *)startDate;
/** 设置动画曲线, 默认UIViewAnimationCurveEaseInOut */
+ (void)setAnimationCurve:(UIViewAnimationCurve)curve;
/** 动画的重复播放次数， 默认0 */
+ (void)setAnimationRepeatCount:(float)repeatCount;
/** 设置是否自定翻转当前的动画效果, 默认NO */
+ (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses;
/** 设置动画从当前状态开始播放, 默认NO */
+ (void)setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState;

/** 在动画块中为视图设置过渡动画 */
+ (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache;

/** 设置是否激活动画 */
+ (void)setAnimationsEnabled:(BOOL)enabled;

```

* * *

### 最后

本文主要是自己的学习与总结。如果文内存在纰漏、万望留言斧正。如果愿意补充以及不吝赐教小弟会更加感激。

* * *

### 参考资料

[官方文档--UIView](https://developer.apple.com/documentation/uikit/uiview?language=objc)
[iOS UIView非常用方法及属性详解](https://www.cnblogs.com/snake-hand/p/3190021.html)
[详解UICoordinateSpace和UIScreen在iOS 8上的坐标问题](https://blog.csdn.net/jgh609445029/article/details/41866807)
[[iOS Animation]-CALayer 专用图层](https://www.cnblogs.com/daxiaxiaohao/p/4272722.html)
[iOS冷门知识 －RightToLeft](https://www.jianshu.com/p/34b5a8d9a77e)
[iOS形变之CGAffineTransform](https://www.jianshu.com/p/ca7f9bc62429)
[UIView的alpha、hidden和opaque属性之间的关系和区别](https://blog.csdn.net/wzzvictory/article/details/10076323)
[iOS tintColor解析](https://www.cnblogs.com/wfwenchao/p/4884833.html)
[ios开发 之 UIView详解](https://blog.csdn.net/zeng_zhiming/article/details/73469182)
[使用 maskView 设计动画](https://www.jianshu.com/p/6e360516e3bc)
[layoutMargins和preservesSuperviewLayoutMargins](https://www.jianshu.com/p/4237bd89f521)
[iOS11适配-Safe Area](https://blog.csdn.net/u011656331/article/details/78365326)
[一个随输入文字宽度变化的自定义UITextField](https://www.jianshu.com/p/a5eaba3c24f7)
[HuggingPriority和CompressionResistance 一个例子教你理解](https://www.jianshu.com/p/5cf559435eb9)
[Masonry约束立即生效跟约束更新/绘制/layout](https://blog.csdn.net/zpz5789/article/details/50922469)
[深入理解Auto Layout 第一弹](https://blog.csdn.net/rjh_xiaoxiao/article/details/50547205)
[IOS-AutoresizesSubviews](https://blog.csdn.net/eward9888/article/details/8250556)[AutoLayout的那些事儿](http://www.cocoachina.com/ios/20160530/16522.html)
[代码添加constraint，设置translatesAutoresizingMaskIntoConstraints为NO的原因](https://blog.csdn.net/u010140921/article/details/40627983)
[drawRect的绘制的使用（绘制文本字符、绘制图片、绘制图形）](https://blog.csdn.net/potato512/article/details/56845385)
[内存恶鬼drawRect](https://blog.csdn.net/sandyloo/article/details/51063799)
[深刻理解移动端优化之离屏渲染](http://www.cocoachina.com/ios/20161114/18072.html)
[iOS绘制和渲染](https://www.jianshu.com/p/2bbed48dbfd0)
[iOS的App实现状态恢复](https://www.jianshu.com/p/7f2fe9361f07)




