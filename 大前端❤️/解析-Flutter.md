# 解析-Flutter


## Why Flutter


Flutter 作为 Google 新一代的跨平台框架，有较多的优点，但跟其他跨平台解决方案相比，最吸引我们的是它的高性能，可以轻松构建更流畅的 UI.


1. 首先，Flutter 自建了一个绘制引擎，底层是由 C++ 编写的引擎，负责渲染，文本处理，Dart VM 等；上层的 Dart Framework 直接调用引擎。避免了以往 JS 解决方案的 JS Bridge、线程跳跃等问题。

2. 第二，引擎基于 Skia 绘制，操作 OpenGL、GPU，不需要依赖原生的组件渲染框架。

3. 第三，Dart 的引入，是 Flutter 团队做了很多思考后的决定，Dart 有 AOT 和 JIT 两种模式，线上使用时以 AOT 的方式编译成机器代码，保证了线上运行时的效率；而在开发期，Dart 代码以 JIT 的方式运行，支持代码的即时生效（HotReload)，提高开发效率。

4. 第四，Flutter 的页面和布局是基于 Widget 树的方式，看似不习惯，但这种树状结构解析简单，布局、绘制都可以单次遍历完成计算，而原生布局往往要往复多次计算，“simple is fast”的设计效果。





## Flutter架构

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221141602.png)



## Dart语言

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221154503.png)



## Flutter vs ReactNative框架对比


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221154647.png)




## Flutter On Native

对纯Flutter工程而言，它主要通过FlutterView中Navigator来管理页面间的跳转;对纯Native工程而言（如：android), 它主要通过系统中ActivityStackSupervisor类对页面切换进行管理，这样当Flutter与Native混合时，就面临浏览一组页面，两套页面管理方式（Flutter管理Flutter页面，Native管理Native页面), 若执行回退操作时，很难保证能回退到期望页面。另外，Flutter工程中界面都是一个继承自SurfaceView的FlutterView（说白了Flutter界面就一个View，不是Activity也不是Fragment）,Flutter和Native组件间相互调用也不可避免。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221154925.png)

### 混合栈管理


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221155144.png)


* 每启动一个Activity就启动一个新的FlutterView（方案4）；
* 抽取单一FlutterView或FlutterNativeView，后续每启动一个Activity都对FlutterView或FlutterNativeView进行复用（方案2或方案3）；



![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221162457.png)


在混合工程中，Native 页面，Flutter 页面之间会以多种可能的顺序混合入栈，出栈。要怎么去做？先看一下 Flutter 内部栈的管理默认下是怎么做的：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221163709.png)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221163739.png)


### Hybrid工程修改点

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221162318.png)


### Flutter页面示例

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221171251.png)


## 参考

* [Flutter · 语雀](https://www.yuque.com/xytech/flutter)
* [Flutter中文网](https://flutterchina.club/)
* [Flutter 社区中文资源](https://flutter-io.cn/)
* [Flutter原理与实践 - 美团官方技术博客](https://tech.meituan.com/waimai_flutter_practice.html)
* [一个 Demo 入门 Flutter - Limboy](https://limboy.me/tech/2018/12/07/flutter-demo.html)
* [Release Flutter的最后一公里 - 掘金](https://juejin.im/post/5b456ebee51d4519277b7761)