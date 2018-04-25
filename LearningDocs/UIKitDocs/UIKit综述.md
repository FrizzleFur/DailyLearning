#  UIKit综述


## iOS Rendering Process 概念

iOS Rendering Process 译为 iOS 渲染流程，本文特指 iOS 设备从设置将要显示的图元数据到最终在设备屏幕成像的整个过程。

### 基于平铺的渲染

iOS 设备的屏幕分为 N * N 像素的图块，每个图块都适合于 SoC 缓存，几何体在图块内被大量拆分，只有在所有几何体全部提交之后才可以进行光栅化（Rasterization）。
![](http://oc98nass3.bkt.clouddn.com/15246449976700.jpg)

> Note: 这里的光栅化指将屏幕上面被大量拆分出来的几何体渲染为像素点的过程。

![](http://oc98nass3.bkt.clouddn.com/15246450612857.jpg)

## iOS Rendering 技术框架

![](http://oc98nass3.bkt.clouddn.com/15246449709724.jpg)
    
其实 UIKit Framework 自身并不具备在屏幕成像的能力，它主要负责对用户操作事件的响应，事件响应的传递大体是经过逐层的**视图树**遍历实现的。

> 那么我们日常写的 UIKit 组件为什么可以呈现在 iOS 设备的屏幕上呢？


### Core Animation
Core Animation 其实是一个令人误解的命名。你可能认为它只是用来做动画的，但实际上它是从一个叫做 Layer Kit 这么一个不怎么和动画有关的名字演变而来的，所以做动画仅仅是 Core Animation 特性的冰山一角。

Core Animation 本质上可以理解为是一个复合引擎，旨在尽可能快的组合屏幕上不同的显示内容。这些显示内容被分解成独立的图层，即 CALayer，CALayer 才是你所能在屏幕上看见的一切的基础。

其实很多同学都应该知道 CALayer，UIKit 中需要在屏幕呈现的组件内部都有一个对应的 CALayer，也就是所谓的 Backing Layer。正是因为一一对应，所以 CALayer 也是树形结构的，我们称之为图层树。

视图的职责就是**创建并管理**这个图层，以确保当子视图在层级关系中**添加或者被移除**的时候，**他们关联的图层**也**同样对应在层级关系树当中有相同的操作**。


> 但是为什么 iOS 要基于 UIView 和 CALayer 提供两个平行的层级关系呢？为什么不用一个简单的层级关系来处理所有事情呢？

原因在于要做**职责分离**，这样也能**避免很多重复代码**。在 iOS 和 Mac OS X 两个平台上，事件和用户交互有很多地方的不同，基于多点触控的用户界面和基于鼠标键盘的交互有着本质的区别，这就是为什么 iOS 有 UIKit 和 UIView，而 Mac OS X 有 AppKit 和 NSView 的原因。他们功能上很相似，但是在实现上有着显著的区别。

> Note: 实际上，这里并不是两个层级关系，而是四个，每一个都扮演不同的角色，除了视图树和图层树之外，还存在呈现树和渲染树。


## 参考

1.[深入理解 iOS Rendering Process - 掘金](https://juejin.im/post/5ad3f1cc6fb9a028d9379c5f)

