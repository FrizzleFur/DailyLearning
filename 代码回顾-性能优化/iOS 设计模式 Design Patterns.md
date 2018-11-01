# iOS 设计模式 Design Patterns

## 常见设计模式

> App开发过程中，随着业务的不断发展，代码和逻辑不断增加，有时候不得不重构以前的代码，好的架构，利于代码的拓展和重构，下面就简单探讨一下`iOS`中常见的设计模式吧。

![设计模式](http://upload-images.jianshu.io/upload_images/225323-084955b97a69fd9d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### MVC

> 一个简单的举例

![](https://i.loli.net/2018/10/21/5bcc88930ebf8.jpg)

通信方式

![](https://i.loli.net/2018/10/21/5bcc88ba9690b.jpg)


* 初期：依据`MVC`模式，把项目进行`Model`、`View`、`Controller`简单分类：

![](http://upload-images.jianshu.io/upload_images/225323-538dc5ac5e0c8a35.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 中期：业务模块增加了，`Model`、`View`、`Controller`越来越多，于是，根据业务模块的分类，在每个模块内使用`MVC`模式：

![](http://upload-images.jianshu.io/upload_images/225323-61a4cca94b1f01db.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 后期：`MVC`模式还是没有干净、很好地分割模块，在`用户点击`、`网络请求`和`JSON解析数据`这些方面，会有交叉重叠的地方：

![](http://upload-images.jianshu.io/upload_images/225323-ee8cdb09cd5ca3db.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](http://upload-images.jianshu.io/upload_images/225323-cc86545bb5394e2c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



###  MVC-N

把项目分为四类：`Model`、`View`、`Controller`、`Networking`：

![MVC-N](http://upload-images.jianshu.io/upload_images/225323-3f6e8b026875bc98.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### MVVM

上面`MVC-N`新建了一个模块，来管理网络请求，然而，获取数据后的数据解析，还是放在了`Controller`中，如何让`Controller`专注于用户交互呢？而`MVVM`模式，添加了`ViewModel`来管理数据解析和网络请求等，解决了这个问题。

在`MVVM`中，`Controller`依然存在，但是不再直接持有`Model`，`Controller`持有`ViewModel`，`Model`被交给`ViewModel`管理。

![MVVM](http://upload-images.jianshu.io/upload_images/225323-7cfd7fb099155bb1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


###  Multicast Closure DelegateNEW


代理模式大家应该最熟悉了，`UIKit`中很多，经典的`UITableViewDelegate`、`UIAlertViewDelegate`. 基本原理是定一个协议`Protocol`，列出需要实现的方法协议，然后交给指定的代理实现，可以有多个代理，为了避免循环引用，代理`delegate`的属性设为`weak`,

####  多播委托（MulticastDelegate）

        多播委托（MulticastDelegate）继承自 `Delegate` ，表示多路广播委托；即，其调用列表中可以拥有多个元素的委托。实际上，我们自定义的委托的基类就是 `MulticastDelegate`。

![多播委托](http://upload-images.jianshu.io/upload_images/225323-d2526c31853c0bae.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

假如现在有一个需求，我们以图片下载为例。这里先忽略哪些`SDWebimage`等已经封装好的第三方类库。对于图片下载一般的过程如下：

1. 先判断该图片`url`是否已经下载完毕。如果已经下载完毕那么直接回调显示图片。如果没有下载那么进入下载过程。
2. 使用合适的图片下载器下载图片。
3. 图片下载完毕后回调显示图片。并且把该图片存到缓存中。

这里的难点是回调。如果一个页面中有多个地方需要显示同一张图片，那么势必会发生这样一种情况，就是同时有多个请求下载同意url的图片，并且下载完成后需要同时在多个地方显示图片。要是实现这样的需求，用现有的方案貌似很难解决。有的同学会想到通知中心，但是通知中心其实是一个广播服务，只要注册了接受该通知那么所有的注册者都能收到通知，但事实上我只需要在我需要下载的那个url的图片下载完后给出通知，而不需要所有的下载完毕事件都通知。这时候我们就需要多播委托了。

普通的`delegate`只能是一对一的回调，无法做到一对多的回调。而多播委托正式对`delegate`的一种扩展和延伸，多了一个注册和取消注册的过程，任何需要回调的对象都必须先注册。比较经典的就是`XMPPframework `这个框架，用了很多多播委托模式（`GCDMulticastDelegate`）。


####  多播闭包委托

多播闭包委托 （Multicast Closure Delegate）继承自多播委托。

![多播闭包委托](http://upload-images.jianshu.io/upload_images/225323-095d1ffe6698fbcc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## [附]设计原则

* [设计模式六大原则（1）：单一职责原则](http://www.uml.org.cn/sjms/201211023.asp#1)

* [设计模式六大原则（2）：里氏替换原则](http://www.uml.org.cn/sjms/201211023.asp#2)

* [设计模式六大原则（3）：依赖倒置原则](http://www.uml.org.cn/sjms/201211023.asp#3)

* [设计模式六大原则（4）：接口隔离原则](http://www.uml.org.cn/sjms/201211023.asp#4)

* [设计模式六大原则（5）：迪米特法则](http://www.uml.org.cn/sjms/201211023.asp#5)

* [设计模式六大原则（6）：开闭原则](http://www.uml.org.cn/sjms/201211023.asp#6)

## 总结

个人觉得，一种设计模式代表的是一种思想。平时开发的过程中，**尽量根据业务需求和已有的代码结构，参考成熟的设计模式，选取最适合当前的需求的模式**，而这些优秀的模式也是建立在不断的`Code Review`和对对代码的`Deep Thinking`的基础上，不断优化的成果，值得借鉴。

## 参考

1. [iOS Design Patterns - Part 2: Project Setup | Ray Wenderlich](https://videos.raywenderlich.com/courses/72-ios-design-patterns/lessons/2)

2. [设计模式六大原则](http://www.uml.org.cn/sjms/201211023.asp)
3. [前端你别闹](https://mp.weixin.qq.com/s?__biz=MzI5ODM3MjcxNQ==&mid=2247483943&idx=1&sn=d2b019ae41d8bd63d42f5abd0df64173&chksm=eca79923dbd01035b4038e8c513075ed5dcf201659cfca291125f45b4491fa96cf8b6f023a50&scene=21#wechat_redirect)

