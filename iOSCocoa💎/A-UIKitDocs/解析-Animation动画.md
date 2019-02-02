# 解析-Animation动画

核心动画
核心动画基本概念
基本动画
关键帧动画
动画组
转场动画
Core Animation简介
Core Animation，中文翻译为核心动画，它是一组非常强大的动画处理API，使用它能做出非常炫丽的动画效果，而且往往是事半功倍。也就是说，使用少量的代码就可以实现非常强大的功能。
 Core Animation可以用在Mac OS X和iOS平台。
 Core Animation的动画执行过程都是在后台操作的，不会阻塞主线程。
 要注意的是，Core Animation是直接作用在CALayer上的，并非UIView。
乔帮主在2007年的WWDC大会上亲自为你演示Core Animation的强大：点击查看视频
 
核心动画
如果是xcode5之前的版本，使用它需要先添加QuartzCore.framework和引入对应的框架<QuartzCore/QuartzCore.h>
开发步骤:
1.使用它需要先添加QuartzCore.framework框架和引入主头文件<QuartzCore/QuartzCore.h>
2.初始化一个CAAnimation对象，并设置一些动画相关属性
3.通过调用CALayer的addAnimation:forKey:方法增加CAAnimation对象到CALayer中，这样就能开始执行动画了
4.通过调用CALayer的removeAnimationForKey:方法可以停止CALayer中的动画

## CAAnimation继承结构

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190202140330.png)



CAAnimation——简介
是所有动画对象的父类，负责控制动画的持续时间和速度，是个抽象类，不能直接使用，应该使用它具体的子类
属性说明：(红色代表来自CAMediaTiming协议的属性)
duration：动画的持续时间
repeatCount：重复次数，无限循环可以设置HUGE_VALF或者MAXFLOAT
repeatDuration：重复时间
removedOnCompletion：默认为YES，代表动画执行完毕后就从图层上移除，图形会恢复到动画执行前的状态。如果想让图层保持显示动画执行后的状态，那就设置为NO，不过还要设置fillMode为kCAFillModeForwards
fillMode：决定当前对象在非active时间段的行为。比如动画开始之前或者动画结束之后
beginTime：可以用来设置动画延迟执行时间，若想延迟2s，就设置为CACurrentMediaTime()+2，CACurrentMediaTime()为图层的当前时间
timingFunction：速度控制函数，控制动画运行的节奏
delegate：动画代理
 
CAAnimation——动画填充模式
fillMode属性值（要想fillMode有效，最好设置removedOnCompletion = NO）
 
kCAFillModeRemoved 这个是默认值，也就是说当动画开始前和动画结束后，动画对layer都没有影响，动画结束后，layer会恢复到之前的状态
 
kCAFillModeForwards 当动画结束后，layer会一直保持着动画最后的状态 
 
kCAFillModeBackwards 在动画开始前，只需要将动画加入了一个layer，layer便立即进入动画的初始状态并等待动画开始。
 
kCAFillModeBoth 这个其实就是上面两个的合成.动画加入后开始之前，layer便处于动画初始状态，动画结束后layer保持动画最后的状态
 
CAAnimation——速度控制函数
速度控制函数(CAMediaTimingFunction) 
kCAMediaTimingFunctionLinear（线性）：匀速，给你一个相对静态的感觉
kCAMediaTimingFunctionEaseIn（渐进）：动画缓慢进入，然后加速离开
kCAMediaTimingFunctionEaseOut（渐出）：动画全速进入，然后减速的到达目的地
kCAMediaTimingFunctionEaseInEaseOut（渐进渐出）：动画缓慢的进入，中间加速，然后减速的到达目的地。这个是默认的动画行为。
 
设置动画的执行节奏
anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
 
CAAnimation——动画代理方法
CAAnimation在分类中定义了代理方法,是给NSObject添加的分类,所以任何对象,成为CAAnimation的代理都可以
@interface NSObject (CAAnimationDelegate)
 
/* Called when the animation begins its active duration. */
动画开始的时候调用
- (void)animationDidStart:(CAAnimation *)anim;
动画停止的时候调用
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
 
@end
 
CALayer上动画的暂停和恢复
#pragma mark 暂停CALayer的动画
-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    让CALayer的时间停止走动
    layer.speed = 0.0;
    让CALayer的时间停留在pausedTime这个时刻
    layer.timeOffset = pausedTime;
}
 
CALayer上动画的恢复
#pragma mark 恢复CALayer的动画
 
-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = layer.timeOffset;
    1. 让CALayer的时间继续行走
    layer.speed = 1.0;
    2. 取消上次记录的停留时刻
    layer.timeOffset = 0.0;
    3. 取消上次设置的时间
    layer.beginTime = 0.0;
    4. 计算暂停的时间(这里也可以用CACurrentMediaTime()-pausedTime)
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    5. 设置相对于父坐标系的开始时间(往后退timeSincePause)
    layer.beginTime = timeSincePause;
}
 
CAPropertyAnimation
是CAAnimation的子类，也是个抽象类，要想创建动画对象，应该使用它的两个子类：
CABasicAnimation
CAKeyframeAnimation
 
属性说明：
keyPath：通过指定CALayer的一个属性名称为keyPath（NSString类型），并且对CALayer的这个属性的值进行修改，达到相应的动画效果。比如，指定@“position”为keyPath，就修改CALayer的position属性的值，以达到平移的动画效果
 
CABasicAnimation——基本动画
基本动画，是CAPropertyAnimation的子类
 
属性说明:
keyPath:要改变的属性名称(传字符串)
 
fromValue：keyPath相应属性的初始值
 
toValue：keyPath相应属性的结束值
 
动画过程说明：
随着动画的进行，在长度为duration的持续时间内，keyPath相应属性的值从fromValue渐渐地变为toValue
 
keyPath内容是CALayer的可动画Animatable属性
 
如果fillMode=kCAFillModeForwards同时removedOnComletion=NO，那么在动画执行完毕后，图层会保持显示动画执行后的状态。但在实质上，图层的属性值还是动画执行前的初始值，并没有真正被改变。
    创建动画
    CABasicAnimation *anim = [CABasicAnimation animation];;
    设置动画对象
    keyPath决定了执行怎样的动画,调用layer的哪个属性来执行动画
          position:平移
    anim.keyPath = @"position";
    包装成对象
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];;
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(200, 300)];
    anim.duration = 2.0;
    
    让图层保持动画执行完毕后的状态
    执行完毕以后不要删除动画
    anim.removedOnCompletion = NO;
    保持最新的状态
    anim.fillMode = kCAFillModeForwards;
    
    添加动画
    [self.layer addAnimation:anim forKey:nil];
 
CAKeyframeAnimation——关键帧动画
关键帧动画，也是CAPropertyAnimation的子类，与CABasicAnimation的区别是：
CABasicAnimation只能从一个数值（fromValue）变到另一个数值（toValue），而CAKeyframeAnimation会使用一个NSArray保存这些数值
 
属性说明：
values：上述的NSArray对象。里面的元素称为“关键帧”(keyframe)。动画对象会在指定的时间（duration）内，依次显示values数组中的每一个关键帧
 
path：代表路径可以设置一个CGPathRef、CGMutablePathRef，让图层按照路径轨迹移动。path只对CALayer的
 
anchorPoint和position起作用。如果设置了path，那么values将被忽略
 
keyTimes：可以为对应的关键帧指定对应的时间点，其取值范围为0到1.0，keyTimes中的每一个时间值都对应values中的每一帧。如果没有设置keyTimes，各个关键帧的时间是平分的
 
CABasicAnimation可看做是只有2个关键帧的CAKeyframeAnimation
 
    创建动画
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];;
    设置动画对象
    keyPath决定了执行怎样的动画,调整哪个属性来执行动画
    anim.keyPath = @"position";
    NSValue *v1 = [NSValue valueWithCGPoint:CGPointMake(100, 0)];
    NSValue *v2 = [NSValue valueWithCGPoint:CGPointMake(200, 0)];
    NSValue *v3 = [NSValue valueWithCGPoint:CGPointMake(300, 0)];
    NSValue *v4 = [NSValue valueWithCGPoint:CGPointMake(400, 0)];
    
    anim.values = @[v1,v2,v3,v4];
    anim.duration = 2.0;
    让图层保持动画执行完毕后的状态
    状态执行完毕后不要删除动画
    anim.removedOnCompletion = NO;
    保持最新的状态
    anim.fillMode = kCAFillModeForwards;
    
    添加动画
    [self.layer addAnimation:anim forKey:nil];
 
 
 
 
根据路径创建动画
    创建动画
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];;
 
    anim.keyPath = @"position";
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.duration = 2.0;
    
    创建一个路径
    CGMutablePathRef path = CGPathCreateMutable();
    路径的范围
    CGPathAddEllipseInRect(path, NULL, CGRectMake(100, 100, 200, 200));
    添加路径
    anim.path = path;
    释放路径(带Create的函数创建的对象都需要手动释放,否则会内存泄露)
    CGPathRelease(path);
    添加到View的layer
    [self.redView.layer addAnimation:anim forKey];
 
转场动画——CATransition
CATransition是CAAnimation的子类，用于做转场动画，能够为层提供移出屏幕和移入屏幕的动画效果。iOS比Mac OS X的转场动画效果少一点
UINavigationController就是通过CATransition实现了将控制器的视图推入屏幕的动画效果
动画属性:(有的属性是具备方向的,详情看下图)
type：动画过渡类型
subtype：动画过渡方向
startProgress：动画起点(在整体动画的百分比)
endProgress：动画终点(在整体动画的百分比)
 
## 转场动画过渡效果


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190202140417.png)



```objc
    CATransition *anim = [CATransition animation];     转场类型     anim.type = @"cube";     动画执行时间     anim.duration = 0.5;     动画执行方向     anim.subtype = kCATransitionFromLeft;     添加到View的layer     [self.redView.layer addAnimation:anim forKey];
```


### CAAnimationGroup——动画组


动画组，是CAAnimation的子类，可以保存一组动画对象，将CAAnimationGroup对象加入层后，组中所有动画对象可以同时并发运行
 
属性说明：
animations：用来保存一组动画对象的NSArray
默认情况下，一组动画对象是同时运行的，也可以通过设置动画对象的beginTime属性来更改动画的开始时


```objc
    CAAnimationGroup *group = [CAAnimationGroup animation];
 
    创建旋转动画对象
    CABasicAnimation *retate = [CABasicAnimation animation];
    layer的旋转属性
    retate.keyPath = @"transform.rotation";
    角度
    retate.toValue = @(M_PI);
    
 
    创建缩放动画对象
    CABasicAnimation *scale = [CABasicAnimation animation];
    缩放属性
    scale.keyPath = @"transform.scale";
    缩放比例
    scale.toValue = @(0.0);
    添加到动画组当中
    group.animations = @[retate,scale];
           执行动画时间
    group.duration = 2.0;
    执行完以后不要删除动画
    group.removedOnCompletion = NO;
          保持最新的状态
    group.fillMode = kCAFillModeForwards;
 
    
    [self.view.layer addAnimation:group forKey:nil];
    
```