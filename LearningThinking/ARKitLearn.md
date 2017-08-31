## ARKit

`Augmented Reality`，创建错觉，虚拟物体放入在物理世界中，将`iphone`等设备作为进入虚拟世界的入口，根据你摄像头所能看到的内容。


* 相机捕捉现实世界图像 —— 由ARKit来实现
* 在图像中显示虚拟3D模型 —— 由SceneKit来实现

![ARKit从入门到精通（2）-ARKit工作原理及流程介绍 - 简书](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041435972369.jpg)

2.下图是一个<ARKit>与<SceneKit>框架关系图，通过下图可以看出

继承：子类拥有父类所有的属性及方法

1.<ARKit>框架中中显示3D虚拟增强现实的视图ARSCNView继承于<SceneKit>框架中的SCNView,而SCNView又继承于<UIKit>框架中的UIView

UIView的作用是将视图显示在iOS设备的window中，SCNView的作用是显示一个3D场景，ARScnView的作用也是显示一个3D场景，只不过这个3D场景是由摄像头捕捉到的现实世界图像构成的
2.ARSCNView只是一个视图容器，它的作用是管理一个ARSession,笔者称之为AR会话。
ARSession的作用及原理将在本篇下一小节介绍
3.在一个完整的虚拟增强现实体验中，<ARKit>框架只负责将真实世界画面转变为一个3D场景，这一个转变的过程主要分为两个环节：由ARCamera负责捕捉摄像头画面，由ARSession负责搭建3D场景。
4.在一个完整的虚拟增强现实体验中，将虚拟物体现实在3D场景中是由<SceneKit>框架来完成中：每一个虚拟的物体都是一个节点SCNNode,每一个节点构成了一个场景SCNScene,无数个场景构成了3D世界
5.综上所述，ARKit捕捉3D现实世界使用的是自身的功能，这个功能是在iOS11新增的。而ARKit在3D现实场景中添加虚拟物体使用的是父类SCNView的功能，这个功能早在iOS8时就已经添加（SceneKit是iOS8新增）
今后在介绍使用ARSCNView时将不再累述这一关系，可以简单的理解为：ARSCNView所有跟场景和虚拟物体相关的属性及方法都是自己父类SCNView的

###  Tracking 
Tracking in real time.实时追踪设备在现实物理世界的位置(position)和方向（orientation）
![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041317564881.jpg)


上图中划出曲线的运动的点代表设备，可以看到以设备为中心有一个坐标系也在移动和旋转，这代表着设备在不断的移动和旋转。这个信息是通过设备的运动传感器获取的。
动图中右侧的黄色点是 3D 特征点。3D 特征点就是处理捕捉到的图像得到的，能代表物体特征的点。例如地板的纹理、物体的边边角角都可以成为特征点。上图中我们看到当设备移动时，ARKit 在不断的追踪捕捉到的画面中的特征点。
ARKit 将上面两个信息进行结合，最终得到了高精度的设备位置和偏转信息。

#### 追踪状态

世界追踪有三种状态，我们可以通过 camera.trackingState 获取当前的追踪状态。

![TrackingState.png](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041586656266.png)

从上图我们看到有三种追踪状态：

Not Available：世界追踪正在初始化，还未开始工作。
Normal： 正常工作状态。
Limited：限制状态，当追踪质量受到影响时，追踪状态可能会变为 Limited 状态。
与 TrackingState 关联的一个信息是 ARCamera.TrackingState.Reason，这是一个枚举类型：

case excessiveMotion：设备移动过快，无法正常追踪。
case initializing：正在初始化。
case insufficientFeatures：特征过少，无法正常追踪。
case none：正常工作。

#### World tracking 

获得设备在物理环境中的相对位置

#### Visual inertial odometry

通过相机图像，使用虚拟惯性里程计，并通过来自你设备的动作数据，获取你设备在那个位置和方向的精确视图。 S是通过现实世界的拓扑，

### Scene Understanding

提供你设备周围的环境特性或属性的能力，

#### Pane detection

平面探测，物理环境的表面或者平面
ARKit 的平面检测用于检测出现实世界的水平面。
![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041589355506.png)

平面检测是一个动态的过程，当摄像机不断移动时，检测到的平面也会不断的变化。下图中可以看到当移动摄像机时，已经检测到的平面的坐标原点以及平面范围都在不断的变化。
![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041589712505.gif)

此外，随着平面的动态检测，不同平面也可能会合并为一个新的平面。下图中可以看到已经检测到的平面随着摄像机移动合并为了一个平面。

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041590104949.gif)


```
// Create a world tracking session configuration.
let configuration = ARWorldTrackingSessionConfiguration()
configuration.planeDetection = .horizontal
// Create a session.
let session = ARSession()
// Run.
session.run(configuration)
```

##### 平面的表示方式

当 ARKit 检测到一个平面时，ARKit 会为该平面自动添加一个 ARPlaneAnchor，这个 ARPlaneAnchor 就表示了一个平面。

ARPlaneAnchor 主要有以下属性：

alignment: 表示该平面的方向，目前只有 horizontal 一个可能值，表示这个平面是水平面。ARKit 目前无法检测出垂直平面。

```
var alignment: ARPlaneAnchor.Alignment
```

#### Hit-testing 场景交互

为了摆放你的虚拟物体，我们提供了碰撞测试功能

`Hit-testing` 是为了获取当前捕捉到的图像中某点击位置有关的信息(包括平面、特征点、`ARAnchor` 等)。

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041607787333.png)

当点击屏幕时，`ARKit` 会发射一个射线，假设屏幕平面是三维坐标系中的 xy 平面，那么该射线会沿着 z 轴方向射向屏幕里面，这就是一次 Hit-testing 过程。此次过程会将射线遇到的所有有用信息返回，返回结果以离屏幕距离进行排序，离屏幕最近的排在最前面。

ResultType

ARFrame 提供了 Hit-testing 的接口：


```
func hitTest(_ point: CGPoint, types: ARHitTestResult.ResultType) -> [ARHitTestResult]

```

上述接口中有一个 types 参数，该参数表示此次 Hit-testing 过程需要获取的信息类型。ResultType 有以下四种：

featurePoint
表示此次 Hit-testing 过程希望返回当前图像中 Hit-testing 射线经过的 3D 特征点。如下图：

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041609876390.gif)

estimatedHorizontalPlane
表示此次 Hit-testing 过程希望返回当前图像中 Hit-testing 射线经过的预估平面。预估平面表示 ARKit 当前检测到一个可能是平面的信息，但当前尚未确定是平面，所以 ARKit 还没有为此预估平面添加 ARPlaneAnchor。如下图：

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041609963757.gif)

existingPlaneUsingExtent
表示此次 Hit-testing 过程希望返回当前图像中 Hit-testing 射线经过的有大小范围的平面。

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041610041553.gif)

上图中，如果 Hit-testing 射线经过了有大小范围的绿色平面，则会返回此平面，如果射线落在了绿色平面的外面，则不会返回此平面。

existingPlane
表示此次 Hit-testing 过程希望返回当前图像中 Hit-testing 射线经过的无限大小的平面。

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041610136927.gif)

上图中，平面大小是绿色平面所展示的大小，但 exsitingPlane 选项表示即使 Hit-testing 射线落在了绿色平面外面，也会将此平面返回。换句话说，将所有平面无限延展，只要 Hit-testing 射线经过了无限延展后的平面，就会返回该平面。


```
// Adding an ARAnchor based on hit-test
let point = CGPoint(x: 0.5, y: 0.5)  // Image center

// Perform hit-test on frame.
let results = frame. hitTest(point, types: [.featurePoint, .estimatedHorizontalPlane])

// Use the first result.
if let closestResult = results.first {
    // Create an anchor for it.
    anchor = (transform: closestResult.worldTransform)
    // Add it to the session.
    session.add(anchor: anchor)
}

```

#### Light estimation

光线估计，渲染虚拟几何体或者实现正确打光，以匹配现实物理世界。

ARKit 的光照估计默认是开启的，当然也可以通过下述方式手动配置：

```
configuration.isLightEstimationEnabled = true
```
获取光照估计的光照强度也很简单，只需要拿到当前的 ARFrame，通过以下代码即可获取估计的光照强度：



```
let intensity = frame.lightEstimate?.ambientIntensity
```

### Rendering

Easy integration
AR Views
Custom rendering

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041307674446.jpg)

* 将摄像机捕捉到的真实世界的视频作为背景。
* 将世界追踪到的相机状态信息实时更新到 AR world 中的相机。
* 处理光照估计的光照强度。
* 实时渲染虚拟世界物体在屏幕中的位置。

### ARSession
ARSession 
ARSession  run, the Configuration

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041308520213.jpg)

使用自己作为代理，接受`ARFrame`的变化

##### `ARSessionConfiguration`

提供3个维度的跟踪。

ARWorldTrackingSessionConfiguration

提供6个维度的跟踪，含有场景理解功能，确认相机在现实世界的位置，

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041310261817.jpg)

####  Mange AR Processing

##### Pause

#### Reset tracking

#### Scence Information 
##### ARAnchor

### 4x4 矩阵？

物体在三维空间中的运动通常分类两类：平移和旋转，那么表达一个物体的变化就应该能够包含两类运动变化。

平移

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041587172800.png)

首先看上图，假设有一个长方体(黄色虚线)沿 x 轴平移Δx、沿 y 轴平移Δy、沿 z 轴平移Δz 到了另一个位置(紫色虚线)。长方体的顶点 P(x1, y1, z1)则平移到了 P'(x2, y2, z2)，使用公式表示如下：


![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041587246589.png)

旋转

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041587331148.png)

在旋转之前，上图中包含以下信息：

黄色虚线的长方体
P(x1, y1, z1)是长方体的一个顶点
P 点在 xy 平面的投影点 Q(x1, y1, 0)
Q 与坐标原点的距离为 L
Q 与坐标原点连线与 y 轴的夹角是α
那么在旋转之前，P 点坐标可以表示为：


``` 
    x1 = L * sinα
    y1 = L * cosα
    z1 = z1
```
下面我们让长方体绕着 z 轴逆时针旋转β角度，那么看图可以得到以下信息：

P 点会绕着 z 轴逆时针旋转β角度到达 P'(x2, y2, z2)
P' 在 xy 平面投影点 Q'(x2, y2, 0)
Q' 与 Q 在以 xy 平面原点为圆心，半径为 L 的圆上
Q' 与原点连线与 Q 与原点连线之间的夹角为 β
Q'与原点连线与 y 轴的角度是 α-β。
那么在旋转之后，P' 点的坐标可以表示为：

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041587467633.png)


使用矩阵来表示：

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041588616456.png)


从上面的分析可以看出，为了表达旋转信息，我们需要一个 3x3 的矩阵，在表达了旋转信息的 3x3 矩阵中，我们无法表达平移信息，为了同时表达平移和旋转信息，在 3D 计算机图形学中引入了齐次坐标系，在齐次坐标系中，使用四维矩阵表示一个点或向量：

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041588701017.png)


加入一个变化是先绕着 z 轴旋转 β 角度，再沿 x 轴平移Δx、沿 y 轴平移Δy、沿 z 轴平移Δz，我们可以用以下矩阵变化表示：

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041588765098.png)


最后，还有一种变化是缩放，在齐次坐标系中只需要在前三列矩阵中某个位置添加一个系数即可，比较简单，这里不在展示矩阵变换。从上面可以看出，为了完整的表达一个物体在 3D 空间的变化，需要一个 4x4 矩阵。



### 总结

ARKit提供两种虚拟增强现实视图，他们分别是3D效果的ARSCNView和2D效果的ARSKView（关于3D效果和2D效果区别以及在上一小节介绍），无论是使用哪一个视图都是用了相机图像作为背景视图（这里可以参考iOS自定义相机中的预览图层），而这一个相机的图像就是由<ARKit>框架中的相机类ARCamera来捕捉的。

2.ARSCNView与ARCamera两者之间并没有直接的关系，它们之间是通过AR会话，也就是ARKit框架中非常重量级的一个类ARSession来搭建沟通桥梁的

3.要想运行一个ARSession会话，你必须要指定一个称之为会话追踪配置的对象:ARSessionConfiguration,ARSessionConfiguration的主要目的就是负责追踪相机在3D世界中的位置以及一些特征场景的捕捉（例如平面捕捉），这个类本身比较简单却作用巨大

ARSessionConfiguration是一个父类，为了更好的看到增强现实的效果，苹果官方建议我们使用它的子类ARWorldTrackingSessionConfiguration，该类只支持A9芯片之后的机型，也就是iPhone6s之后的机型

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041442539645.jpg)

1.3.2-ARWorldTrackingSessionConfiguration与ARFrame

1.ARSession搭建沟通桥梁的参与者主要有两个ARWorldTrackingSessionConfiguration与ARFrame

2.ARWorldTrackingSessionConfiguration（会话追踪配置）的作用是跟踪设备的方向和位置,以及检测设备摄像头看到的现实世界的表面。它的内部实现了一系列非常庞大的算法计算以及调用了你的iPhone必要的传感器来检测手机的移动及旋转甚至是翻滚

我们无需关心内部实现，ARKit框架帮助我们封装的非常完美，只需调用一两个属性即可
3.当ARWorldTrackingSessionConfiguration计算出相机在3D世界中的位置时，它本身并不持有这个位置数据，而是将其计算出的位置数据交给ARSession去管理（与前面说的session管理内存相呼应），而相机的位置数据对应的类就是ARFrame

ARSession类一个属性叫做currentFrame，维护的就是ARFrame这个对象
4.ARCamera只负责捕捉图像，不参与数据的处理。它属于3D场景中的一个环节，每一个3D Scene都会有一个Camera，它决定了我们看物体的视野

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041452604938.jpg)

#### 1.4-ARKit工作完整流程

ARKit框架工作流程可以参考下图:
1.ARSCNView加载场景SCNScene
2.SCNScene启动相机ARCamera开始捕捉场景
3.捕捉场景后ARSCNView开始将场景数据交给Session
4.Session通过管理ARSessionConfiguration实现场景的追踪并且返回一个ARFrame
5.给ARSCNView的scene添加一个子节点（3D物体模型）
ARSessionConfiguration捕捉相机3D位置的意义就在于能够在添加3D物体模型的时候计算出3D物体模型相对于相机的真实的矩阵位置
在3D坐标系统中，有一个世界坐标系和一个本地坐标系。类似于UIView的Frame和Bounds的区别，这种坐标之间的转换可以说是ARKit中最难的部分

![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041482797633.jpg)


#### ARKitArchitecture


椅子是计算机程序创建的虚拟世界的物体，而背景则是摄像机捕捉到的真实世界，AR 系统将两者结合在一起。我们从上图可以窥探出 AR 系统由以下几个基础部分组成：

捕捉真实世界：上图中的背景就是真实世界，一般由摄像机完成。
虚拟世界：例如上图中的椅子就是虚拟世界中的一个物体模型。当然，可以有很多物体模型，从而组成一个复杂的虚拟世界。
虚拟世界与现实世界相结合：将虚拟世界渲染到捕捉到的真实世界中。
世界追踪：当真实世界变化时(如上图中移动摄像机)，要能追踪到当前摄像机相对于初始时的位置、角度变化信息，以便实时渲染出虚拟世界相对于现实世界的位置和角度。
场景解析：例如上图中可以看出椅子是放在地面上的，这个地面其实是 AR 系统检测出来的。
与虚拟世界互动：例如上图中缩放、拖动椅子。(其实也属于场景解析的范畴)

ARKitSystem
![ARKitSystem](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041485645877.png)

ARKitArchitecture
![ARKitArchitecture](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041484664569.png)

对于上图，ARSession 是核心整个ARKit系统的核心，ARSession 实现了世界追踪、场景解析等重要功能。而 ARFrame 中包含有 ARSession 输出的所有信息，是渲染的关键数据来源。虽然 ARKit 提供的 API 较为简单，但看到上面整个框架后，对于初识整个体系的开发者来说，还是会觉着有些庞大。没关系，后面几节会对每个模块进行单独的介绍，当读完最后时，再回头来看这个架构图，或许会更加明了一些。



### 追踪什么？

在这个 AR-World 坐标系中，ARKit 会追踪以下几个信息：

追踪设备的位置以及旋转，这里的两个信息均是相对于设备起始时的信息。
追踪物理距离(以“米”为单位)，例如 ARKit 检测到一个平面，我们希望知道这个平面有多大。
追踪我们手动添加的希望追踪的点，例如我们手动添加的一个虚拟物体。

#### 世界追踪如何工作？

苹果文档中对世界追踪过程是这么解释的：ARKit 使用视觉惯性测距技术，对摄像头采集到的图像序列进行计算机视觉分析，并且与设备的运动传感器信息相结合。ARKit 会识别出每一帧图像中的特征点，并且根据特征点在连续的图像帧之间的位置变化，然后与运动传感器提供的信息进行比较，最终得到高精度的设备位置和偏转信息。


## 资源

[苹果官方 demo ARKit Demo App: Placing Objects in Augmented Reality](https://developer.apple.com/sample-code/wwdc/2017/PlacingObjects.zip)

[WWDC ARKit 初体验 - 简书](http://www.jianshu.com/p/5b1d322f22c9)

## 参考

1. [直击苹果 ARKit 技术 - 简书](http://www.jianshu.com/p/7faa4a3af589)
2. [ARKit从入门到精通（2）-ARKit工作原理及流程介绍 - 简书](http://www.jianshu.com/p/0492c7122d2f)
3. [ARKit从入门到精通（3）-ARKit自定义实现](http://www.jianshu.com/p/e67d519d2cf7)




