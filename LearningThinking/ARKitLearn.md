## ARKit

`Augmented Reality`，创建错觉，虚拟物体放入在物理世界中，将`iphone`等设备作为进入虚拟世界的入口，根据你摄像头所能看到的内容。


* 相机捕捉现实世界图像 —— 由ARKit来实现
* 在图像中显示虚拟3D模型 —— 由SceneKit来实现

![ARKit从入门到精通（2）-ARKit工作原理及流程介绍 - 简书](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041435972369.jpg)

[](http://www.jianshu.com/p/0492c7122d2f)
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

#### World tracking 

获得设备在物理环境中的相对位置

#### Visual inertial odometry

通过相机图像，使用虚拟惯性里程计，并通过来自你设备的动作数据，获取你设备在那个位置和方向的精确视图。 S是通过现实世界的拓扑，

### Scene Understanding

提供你设备周围的环境特性或属性的能力，

#### Pane detection

平面探测，物理环境的表面或者平面

#### Hit-testing
为了摆放你的虚拟你物体，我们提供了碰撞测试功能

#### Light estimation

光线估计，渲染虚拟几何体或者实现正确打光，以匹配现实物理世界。


### Rendering

Easy integration

AR Views

Custom rendering


![](http://oc98nass3.bkt.clouddn.com/2017-08-31-15041307674446.jpg)


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





