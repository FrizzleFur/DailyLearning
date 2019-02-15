## UIView绘制机制

变更记录

序号 | 录入时间 | 备注
--- | --- | --- | ---
1 | 2018-04-14 | 新建文章
2 | 2018-05-28 | 整理目录，完善标题

> UIView的`setNeedsLayout`, `layoutIfNeeded` 和` layoutSubviews` 方法之间的关系解释

## UIView绘制机制

![](https://i.loli.net/2018/12/09/5c0c787cce502.jpg)

![](https://i.loli.net/2018/12/09/5c0c78c541bbb.jpg)

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

1. init初始化不会触发layoutSubviews
但是是用initWithFrame 进行初始化时，当rect的值不为CGRectZero时,也会触发——就是改变了frame

2. addSubview会触发layoutSubviews

3. 设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化

4. 滚动一个UIScrollView会触发layoutSubviews

5. 旋转Screen会触发父UIView上的layoutSubviews事件

6. 改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件

```
init does not cause layoutSubviews to be called (duh)
addSubview: causes layoutSubviews to be called on the view being added, the view it’s being added to (target view), and all the subviews of the target
view setFrame intelligently calls layoutSubviews on the view having its frame set only if the size parameter of the frame is different
scrolling a UIScrollView causes layoutSubviews to be called on the scrollView, and its superview
rotating a device only calls layoutSubview on the parent view (the responding viewControllers primary view)
Resizing a view will call layoutSubviews on its superview
```

在苹果的官方文档中强调:

```
You should override this method only if the autoresizing behaviors of the subviews do not offer the behavior you want.
```

**layoutSubviews, 当我们在某个类的内部调整子视图位置时，需要调用。**

反过来的意思就是说：如果你想要在外部设置subviews的位置，就不要重写。

## 刷新子对象布局

- layoutSubviews方法：这个方法，默认没有做任何事情，需要子类进行重写
- setNeedsLayout方法： 标记为需要重新布局，异步调用layoutIfNeeded刷新布局，不立即刷新，但layoutSubviews一定会被调用
- layoutIfNeeded方法：如果，有需要刷新的标记，立即调用layoutSubviews进行布局（如果没有标记，不会调用layoutSubviews）

如果要立即刷新，要先调用`[view setNeedsLayout]`，把标记设为需要布局，然后马上调用`[view layoutIfNeeded]`，实现布局

在视图第一次显示之前，标记总是“需要刷新”的，可以直接调用`[view layoutIfNeeded]`.

### 重绘

- drawRect:(CGRect)rect方法：重写此方法，执行重绘任务
- setNeedsDisplay方法：标记为需要重绘，异步调用drawRect
- setNeedsDisplayInRect:(CGRect)invalidRect方法：标记为需要局部重绘

`sizeToFit`会自动调用`sizeThatFits`方法；

`sizeToFit`不应该在子类中被重写，应该重写sizeThatFits

`sizeThatFits`传入的参数是receiver当前的size，返回一个适合的size

`sizeToFit`可以被手动直接调用

`sizeToFit`和`sizeThatFits`方法都没有递归，对subviews也不负责，只负责自己

———————————-

`layoutSubviews`对subviews重新布局

`layoutSubviews`方法调用先于drawRect

`setNeedsLayout`在receiver标上一个需要被重新布局的标记，在系统runloop的下一个周期自动调用`layoutSubviews`

`layoutIfNeeded`方法如其名，UIKit会判断该receiver是否需要layout.根据Apple官方文档,layoutIfNeeded方法应该是这样的

`layoutIfNeeded`遍历的不是superview链，应该是subviews链

drawRect是对receiver的重绘，能获得context

setNeedDisplay在receiver标上一个需要被重新绘图的标记，在下一个draw周期自动重绘，iphone device的刷新频率是60hz，也就是1/60秒后重绘 


-------

最近在学习swift做动画，用到constraint的动画，用到layoutIfNeeded就去研究了下UIView的这几个布局的方法。

下面是做得一个动画，下载地址：[AnimationDemo3](https://github.com/smalldu/IOS-Animations ) 

下面列举下iOS layout的相关方法:

* layoutSubviews
* layoutIfNeeded
* setNeedsLayout
* setNeedsDisplay
* drawRect
* sizeThatFits
* sizeToFit
* setNeedsUpdateConstraints
* updateConstraintsIfNeeded

大概常用的上面几个 ， 具体的应该还有别的。

### layoutSubviews

这个方法，默认没有做任何事情，需要子类进行重写 。 系统在很多时候会去调用这个方法：

1. 初始化不会触发layoutSubviews，但是如果设置了不为CGRectZero的frame的时候就会触发。
2. addSubview会触发layoutSubviews
3. 设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化
4. 滚动一个UIScrollView会触发layoutSubviews
5. 旋转Screen会触发父UIView上的layoutSubviews事件
6. 改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件
7. 
在苹果的官方文档中强调: You should override this method only if the autoresizing behaviors of the subviews do not offer the behavior you want.layoutSubviews, 当我们在某个类的内部调整子视图位置时，需要调用。反过来的意思就是说：如果你想要在外部设置subviews的位置，就不要重写。

### setNeedsLayout

标记为需要重新布局，不立即刷新，但`layoutSubviews`一定会被调用,配合`layoutIfNeeded`立即更新

### layoutIfNeeded

如果，有需要刷新的标记，立即调用`layoutSubviews`进行布局

这个动画中有用到 举个栗子。

如图 ， 上面有个label ，中间有个按钮 ， label已经被自动布局到左上角 。 然后我们那个left的constraint
  @IBOutlet weak var leftContrain:NSLayoutConstraint!
在viewDidLoad中声明好，然后在Main.storyboard中进行连线。点击按钮的时候 ，我们把左边的距离改成100 。

在按钮的点击事件里加上这句。

`leftContrain.constant = 100`

然后我们想要一个动画的效果。
如果这么做

```objc
UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                self.leftContrain.constant = 100
            }, completion: nil)
```

你会发现然并卵 。其实这句话`self.leftContrain.constant = 100`只是执行了`setNeedsLayout` 标记了需要重新布局，但是没有立即执行。所以我们需要在动画中调用这个方法`layoutIfNeeded`
所以代码应该这么写

```objc
leftContrain.constant = 100
UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                self.view.layoutIfNeeded() //立即实现布局
            }, completion: nil)
```

所以上面不管写多少约束的改变，只需要在动画里动用 一次`self.view.layoutIfNeeded()`,所有的都会已动画的方式 。如果一些变化不想动画 。在动画前执行`self.view.layoutIfNeeded()`


### setNeedsUpdateConstraints

Controls whether the view’s constraints need updating.

### updateConstraintsIfNeeded

Updates the constraints from the bottom up for the view hierarchy rooted at the receiver. UIWindow's implementation creates a layout engine if necessary first

setNeedsUpdateConstraints 保证之后肯定会调用 updateConstraintsIfNeeded .

SetNeedsLayout 保证之后肯定会调用 layoutIfNeeded .

AutoLayout 的本质

[ios - Why calling setNeedsUpdateConstraints isn't needed for constraint changes or animations? - Stack Overflow](https://stackoverflow.com/questions/47823639/why-calling-setneedsupdateconstraints-isnt-needed-for-constraint-changes-or-ani)
This is a common misunderstanding among iOS developers.

Here's one of my "golden rules" for Auto Layout:

Don't bother about "updating constraints".
You never need to call any of these methods:

* setNeedsUpdateConstraints()
* updateConstraintsIfNeeded()
* updateConstraints()
* updateViewConstraints()



### drawRect

这个方法是用来重绘的。

drawRect在以下情况下会被调用：

1. 如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect调用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的.所以不用担心在控制器中,这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量值).
2. 该方法在调用`sizeToFit`后被调用，所以可以先调用`sizeToFit`计算出size。然后系统自动调用`drawRect:`方法。
3. 通过设置`contentMode`属性值为`UIViewContentModeRedraw`。那么将在每次设置或更改frame的时候自动调用`drawRect:`。
4. 直接调用`setNeedsDisplay`，或者`setNeedsDisplayInRect:`触发`drawRect:`，但是有个前提条件是rect不能为0。以上1,2推荐；而3,4不提倡

#### drawRect方法使用注意点：

1. 若使用UIView绘图，只能在drawRect：方法中获取相应的contextRef并绘图。如果在其他方法中获取将获取到一个invalidate的ref并且不能用于画图。drawRect：方法不能手动显示调用，必须通过调用`setNeedsDisplay` 或者 `setNeedsDisplayInRect`，让系统自动调该方法。
2. 若使用CALayer绘图，只能在drawInContext: 中（类似于drawRect）绘制，或者在delegate中的相应方法绘制。同样也是调用setNeedDisplay等间接调用以上方法
3. 若要实时画图，不能使用`gestureRecognizer`，只能使用`touchbegan`等方法来掉用`setNeedsDisplay`实时刷新屏幕

### sizeToFit

* sizeToFit会自动调用sizeThatFits方法；
* sizeToFit不应该在子类中被重写，应该重写sizeThatFits
* sizeThatFits传入的参数是receiver当前的size，返回一个适合的size
* sizeToFit可以被手动直接调用sizeToFit和sizeThatFits方法都没有递归，对subviews也不负责，只负责自己
 推荐拓展阅读

### ConvertRect

UIKit提供了一下几种坐标转换的方法：

```objc
- (CGPoint)convertPoint:(CGPoint)point toView:(nullable UIView *)view;
- (CGPoint)convertPoint:(CGPoint)point fromView:(nullable UIView *)view;
- (CGRect)convertRect:(CGRect)rect toView:(nullable UIView *)view;
- (CGRect)convertRect:(CGRect)rect fromView:(nullable UIView *)view;
```

```objc
[fromView convertPoint:point toView:toView];
[toView convertPoint:point fromView:fromView];
```

##### fromView

注意返回值：The point converted to the local coordinate system (bounds) of the receiver. 是返回依据点在给定view的bounds坐标系的坐标

![](https://i.loli.net/2018/12/09/5c0c705689914.jpg)

```objc
  CGRect newRect = [self.view convertRect:self.blueView.frame fromView:self.redView];
这段代码的意思算出在红色控件里的蓝色控件在控制器view中的位置（其实就是算x和y的值，因为宽高不变）
toView

  CGRect newRect = [self.blueView convertRect:CGRectMake(50, 50, 100, 100) toView:self.greenView];
```
##### toView

**调用视图 `convertRect`: 调用视图相对于目标视图的frame toview目标视图**

目标视图为`nil`的时候指的是Window本身。

```objc
- (CGPoint)convertPoint:(CGPoint)point toView:(nullable UIView *)view;
```


### Runloop与UIView的绘制

也许要先从Runloop开始说，iOS的mainRunloop是一个60fps的回调，也就是说每16.7ms会绘制一次屏幕，这个时间段内要完成view的缓冲区创建，view内容的绘制（如果重写了drawRect），这些CPU的工作。然后将这个缓冲区交给GPU渲染，这个过程又包括多个view的拼接(compositing)，纹理的渲染（Texture）等，最终显示在屏幕上。因此，如果在16.7ms内完不成这些操作，比如，CPU做了太多的工作，或者view层次过于多，图片过于大，导致GPU压力太大，就会导致“卡”的现象，也就是丢帧。

苹果官方给出的最佳帧率是：60fps，也就是1帧不丢，当然这是理想中的绝佳的体验。

这个60fps改怎么理解呢？一般来说如果帧率达到25+fps，人眼就基本感觉不到停顿了，因此，如果你能让你ios程序稳定的保持在30fps已经很不错了，注意，是“稳定”在30fps，而不是，10fps，40fps，20fps这样的跳动，如果帧频不稳就会有卡的感觉。60fps真的很难达到，尤其在iphone4，4s上。

总的来说，UIView从绘制到Render的过程有如下几步：

每一个UIView都有一个layer，每一个layer都有个content，这个content指向的是一块缓存，叫做backing store。

UIView的绘制和渲染是两个过程，当UIView被绘制时，CPU执行drawRect，通过context将数据写入backing store

当backing store写完后，通过render server交给GPU去渲染，将backing store中的bitmap数据显示在屏幕上

上面提到的从CPU到GPU的过程可用下图表示：


![](https://i.imgur.com/d90Tsx6.jpg)

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


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190215162007.png)

然后一个新的Runloop到来，上面说道在这个Runloop中需要将界面渲染上去，对于UIKit的渲染，Apple用的是它的Core Animation。

做法是在Runloop开始的时候调用：

```objc
[CATransaction begin]
```
在Runloop结束的时候调用
```objc
[CATransaction commit]
```

在begin和commit之间做的事情是将view增加到view hierarchy中，这个时候也不会发生任何绘制的操作。

当[CATransaction commit]执行完后，CPU开始绘制这个view：

首先CPU会为layer分配一块内存用来绘制bitmap，叫做backing store

创建指向这块bitmap缓冲区的指针，叫做CGContextRef

通过Core Graphic的api，也叫Quartz2D，绘制bitmap

将layer的content指向生成的bitmap

清空dirty flag标记

这样CPU的绘制基本上就完成了。

通过time profiler 可以完整的看到个过程：

```objc
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


```objc
    label.text = @"hello world";
```

由于内容变了，layer的content的bitmap的尺寸也要变化，因此这个时候当新的Runloop到来时，CPU要为layer重新创建一个backing store，重新绘制bitmap。

CPU这一块最耗时的地方往往在Core Graphic的绘制上，关于Core Graphic的性能优化是另一个话题了，又会牵扯到很多东西，就不在这里讨论了。

#### GPU bound：

CPU完成了它的任务：将view变成了bitmap，然后就是GPU的工作了，GPU处理的单位是Texture。

基本上我们控制GPU都是通过OpenGL来完成的，但是从bitmap到Texture之间需要一座桥梁，Core Animation正好充当了这个角色：

Core Animation对OpenGL的api有一层封装，当我们的要渲染的layer已经有了bitmap content的时候，这个content一般来说是一个CGImageRef，CoreAnimation会创建一个OpenGL的Texture并将CGImageRef（bitmap）和这个Texture绑定，通过TextureID来标识。

这个对应关系建立起来之后，剩下的任务就是GPU如何将Texture渲染到屏幕上了。

GPU大致的工作模式如下：
![image](upload-images.jianshu.io/upload_images/225323-aa04d37acb870bf0.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

整个过程也就是一件事：CPU将准备好的bitmap放到RAM里，GPU去搬这快内存到VRAM中处理。


而这个过程GPU所能承受的极限大概在16.7ms完成一帧的处理，所以最开始提到的60fps其实就是GPU能处理的最高频率。

因此，GPU的挑战有两个：

将数据从RAM搬到VRAM中

将Texture渲染到屏幕上

这两个中瓶颈基本在第二点上。渲染Texture基本要处理这么几个问题：

#### Compositing：

Compositing是指将多个纹理拼到一起的过程，对应UIKit，是指处理多个view合到一起的情况，如

[self.view addsubview : subview]。
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

#### Size

这个问题，主要是处理image带来的，假如内存里有一张400x400的图片，要放到100x100的imageview里，如果不做任何处理，直接丢进去，问题就大了，这意味着，GPU需要对大图进行缩放到小的区域显示，需要做像素点的sampling，这种smapling的代价很高，又需要兼顾pixel alignment。计算量会飙升。

#### Offscreen Rendering And Mask

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

红色代表GPU需要做额外的工作来渲染View，绿色代表GPU无需做额外的工作来处理bitmap。

That’s all

## `layoutSubviews`调用总结

1. 自身的frame发生变化， 会重新布局`layoutSubviews`
2. 添加视图，调用`addSubView`的时候
3. 滚动一个UIScrollView会触发
4. 子视图frame发生变化，会调用父视图的`addSubView`

Its own bounds (not frame) changed.
The bounds of one of its direct subviews changed.
A subview is added to the view or removed from the view.

* init does not cause layoutSubviews to be called (duh)
* addSubview causes layoutSubviews to be called on the view being added, the view it’s being added to (target view), and all the subviews of the target view
* setFrame intelligently calls layoutSubviews on the view having it’s frame set only if the size parameter of the frame is different
* scrolling a UIScrollView causes layoutSubviews to be called on the scrollView, and it’s superview
* rotating a device only calls layoutSubview on the parent view (the responding viewControllers primary view)
* removeFromSuperview – layoutSubviews is called on superview only (not show in table)


## CALayer的属性

下面就逐个过下 CALayer 的一些重要属性:
 
1. shadowPath : 设置 CALayer 背景(shodow)的位置
 
2. shadowOffset : shadow 在 X 和 Y 轴 上延伸的方向，即 shadow 的大小
 
3. shadowOpacity : shadow 的透明效果
 
4. shadowRadius : **shadow 的渐变距离，从外围开始，往里渐变 shadowRadius 距离**
 
5. masksToBounds : 很重要的属性，可以用此属性来防止子元素大小溢出父元素，如若防止溢出，请设为 true
 
6. borderWidth 和 boarderColor : 边框颜色和宽度，很常用
 
7. bounds : 对于我来说比较难的一个属性，测了半天也没完全了解，只知道可以用来控制 UIView 的大小，但是不能控制 位置
 
8. opacity : UIView 的透明效果
 
9. cornerRadius : UIView 的圆角


### 1. 简单阴影

我们给layer设置了shadowOpacity后就能得到一个简单的阴影

```
view.layer.shadowOpacity = 1;

```



shadowOpacity设置了阴影的不透明度,取值范围在0~1
这里shadow有一个默认值
shadowOffset = CGSizeMake(0, -3)
shadowRadius = 3.0
注意:如果view没有设置背景色阴影也是不会显示的

### 2. 阴影属性

layer中与阴影相关的属性有以下几个

```
(CGColorRef *) shadowColor//阴影颜色
(float) shadowOpacity//阴影透明度
(CGSize) shadowOffset//阴影偏移量
(CGFloat) shadowRadius//模糊计算的半径
(CGPathRef *) shadowPath//阴影路径

```

### 3. shadowColor

```
- (void)p_setupSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_setupViewWithY:100 shadowColor:[UIColor redColor]];
    [self p_setupViewWithY:170 shadowColor:[UIColor blueColor]];
    [self p_setupViewWithY:240 shadowColor:[UIColor yellowColor]];
}

- (void)p_setupViewWithY:(CGFloat)y shadowColor:(UIColor *)shadowColor {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, y, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.layer.shadowOpacity = 1;
    view.layer.shadowColor = shadowColor.CGColor;
}

```


![](https://i.imgur.com/h4kngLY.jpg)

shadow color

### 4. shadowOpacity

```
- (void)p_setupSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_setupViewWithY:100 shadowOpacity:0.2];
    [self p_setupViewWithY:170 shadowOpacity:0.6];
    [self p_setupViewWithY:240 shadowOpacity:0.9];
}

- (void)p_setupViewWithY:(CGFloat)y shadowOpacity:(float)shadowOpacity {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, y, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.layer.shadowOpacity = shadowOpacity;
}

```


![](https://i.imgur.com/EC7A4uh.jpg)

shadow opacity

### 5. shadowOffset

```
- (void)p_setupSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_setupViewWithY:100 shadowOffset:CGSizeMake(0, 0)];
    [self p_setupViewWithY:170 shadowOffset:CGSizeMake(5, 0)];
    [self p_setupViewWithY:240 shadowOffset:CGSizeMake(-5, 0)];
    [self p_setupViewWithY:310 shadowOffset:CGSizeMake(0, 5)];
    [self p_setupViewWithY:380 shadowOffset:CGSizeMake(0, -5)];
    [self p_setupViewWithY:450 shadowOffset:CGSizeMake(5, 5)];
    [self p_setupViewWithY:520 shadowOffset:CGSizeMake(-5, -5)];
}

- (void)p_setupViewWithY:(CGFloat)y shadowOffset:(CGSize)shadowOffset {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, y, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.layer.shadowOpacity = 1;
    view.layer.shadowOffset = shadowOffset;
}

```

![](https://i.imgur.com/bF13XYv.jpg)

shadow offset

### 6. shadowRadius

shadowRadius其实可以理解为阴影的宽度

```
- (void)p_setupSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_setupViewWithY:100 shadowRadius:0];
    [self p_setupViewWithY:170 shadowRadius:3.0];
    [self p_setupViewWithY:240 shadowRadius:10.0];

}

- (void)p_setupViewWithY:(CGFloat)y shadowRadius:(CGFloat)shadowRadius {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, y, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    view.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:view];
    view.layer.shadowOpacity = 1;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowRadius = shadowRadius;
}

```



![](https://i.imgur.com/eBRpi8K.jpg)

shadow radius

### 7. shadowPath

```
- (void)p_setupSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_setupViewWithY1:100];
    [self p_setupViewWithY2:170];
    [self p_setupViewWithY3:240];//贝塞尔曲线未闭合
}

- (void)p_setupViewWithY1:(CGFloat)y {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, y, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.layer.shadowOpacity = 1;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}

- (void)p_setupViewWithY2:(CGFloat)y {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, y, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.layer.shadowOpacity = 1;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, view.frame.size.height + 10)];
    [path addLineToPoint:CGPointMake(view.frame.size.width, view.frame.size.height + 10)];
    [path addLineToPoint:CGPointMake(view.frame.size.width, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    view.layer.shadowPath = path.CGPath;
}

- (void)p_setupViewWithY3:(CGFloat)y {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, y, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.layer.shadowOpacity = 1;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(-5, 0)];
    [path addLineToPoint:CGPointMake(-5, view.frame.size.height)];
    [path addLineToPoint:CGPointMake(view.frame.size.width, view.frame.size.height)];
    [path addLineToPoint:CGPointMake(view.frame.size.width, 0)];
    view.layer.shadowPath = path.CGPath;
}

```

![](https://i.imgur.com/NS3dK3G.jpg)

shadow path

当用bounds设置path时,看起来的效果与只设置了shadowOpacity一样
但是添加了shadowPath后消除了离屏渲染问题



## 参考

1. [谈谈UIView的几个layout方法-layoutSubviews、layoutIfNeeded、setNeedsLayout...](http://www.jianshu.com/p/eb2c4bb4e3f1)
2. [UIView的setNeedsLayout, layoutIfNeeded 和 layoutSubviews 方法之间的关系解释](http://blog.csdn.net/meegomeego/article/details/39890385)
3. [When is layoutSubviews called?](http://stackoverflow.com/questions/728372/when-is-layoutsubviews-called)
4. [UIView的setNeedsLayout, layoutIfNeeded 和 layoutSubviews 方法之间的关系解释](http://blog.csdn.net/meegomeego/article/details/39890385)
5. [理解UIView的绘制](http://vizlabxt.github.io/blog/2012/10/22/UIView-Rendering/)
6. [iOS 阴影(shadow) - 简书](https://www.jianshu.com/p/9f73bc843d00)



