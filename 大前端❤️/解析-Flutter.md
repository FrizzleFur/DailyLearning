# 解析-Flutter



## Why Flutter


Flutter 作为 Google 新一代的跨平台框架，有较多的优点，但跟其他跨平台解决方案相比，最吸引我们的是它的高性能，可以轻松构建更流畅的 UI.


1. 首先，Flutter 自建了一个绘制引擎，底层是由 C++ 编写的引擎，负责渲染，文本处理，Dart VM 等；上层的 Dart Framework 直接调用引擎。避免了以往 JS 解决方案的 JS Bridge、线程跳跃等问题。

2. 第二，引擎基于 Skia 绘制，操作 OpenGL、GPU，不需要依赖原生的组件渲染框架。

3. 第三，Dart 的引入，是 Flutter 团队做了很多思考后的决定，Dart 有 AOT 和 JIT 两种模式，线上使用时以 AOT 的方式编译成机器代码，保证了线上运行时的效率；而在开发期，Dart 代码以 JIT 的方式运行，支持代码的即时生效（HotReload)，提高开发效率。

4. 第四，Flutter 的页面和布局是基于 Widget 树的方式，看似不习惯，但这种树状结构解析简单，布局、绘制都可以单次遍历完成计算，而原生布局往往要往复多次计算，“simple is fast”的设计效果。


### 操作系统绘制API的封装


由于最终的图形计算和绘制都是由相应的硬件来完成，而直接操作硬件的指令通常都会有操作系统屏蔽，应用开发者通常不会直接面对硬件，操作系统屏蔽了这些底层硬件操作后会提供一些封装后的API供操作系统之上的应用调用，但是对于应用开发者来说，直接调用这些操作系统提供的API是比较复杂和低效的，因为操作系统提供的API往往比较基础，直接调用需要了解API的很多细节。正是因为这个原因，几乎所有用于开发GUI程序的编程语言都会在操作系统之上再封装一层，将操作系统原生API封装在一个编程框架和模型中，然后定义一种简单的开发规则来开发GUI应用程序，而这一层抽象，正是我们所说的“UI”系统，如Android SDK正是封装了Android操作系统API，提供了一个“UI描述文件XML+Java操作DOM”的UI系统，而iOS的UIKit 对View的抽象也是一样的，他们都将操作系统API抽象成一个基础对象（如用于2D图形绘制的Canvas），然后再定义一套规则来描述UI，如UI树结构，UI操作的单线程原则等。


## Flutter架构

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221141602.png)


## Widget与Element

* Element: Flutter中真正代表屏幕上显示元素的类是Element,Element是通过Widget生成
* Widget: Widget只是描述Element的一个配置
* 一个Widget对象可以对应多个Element对象。这很好理解，根据同一份配置（Widget），可以创建多个实例（Element）。



## Dart语言

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190221154503.png)

* 一切都是对象， Dart里面一切变量都是object、每一个object都是class的实例、。数字、布尔、函数、null 都是以对象的形式存在，所有的对象都继承于 Object 类
* dart虽然是强类型的语言，但是支持类型推断，在定义变量的时候可不写变量的类型。
* 支持泛型
* 函数是“一等公民”,可以作为变量在代码间到处传递，也可以进行函数嵌套。每一个函数都有返回值，默认返回null(这点与JavaScript类似)
* 在class 中以 下划线开头的属性，为私有属性。
* 变量名 只能以字母和下划线开头,后面可以跟这数字、英文字母、下划线。


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


## Flutter配置

使用flutter doctor，解决好问题

```
╰─ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.0.0, on Mac OS X 10.14 18A391, locale
    zh-Hans-CN)
[✓] Android toolchain - develop for Android devices (Android SDK 28.0.3)
[✓] iOS toolchain - develop for iOS devices (Xcode 10.1)
[✓] Android Studio (version 3.3)
[✓] Connected device (2 available)

• No issues found!
```


Mac上配置遇到的问题:


1. android-licenses


```
flutter doctor --android-licenses
```

接受证书

3. [Stuck at “.android/repositories.cfg could not be loaded.”](https://stackoverflow.com/questions/43433542/stuck-at-android-repositories-cfg-could-not-be-loaded)

新建文件

```
touch ~/.android/repositories.cfg

```


## Flutter 路由库 Boost 

[码上用它开始Flutter混合开发——FlutterBoost](https://mp.weixin.qq.com/s?__biz=MzU4MDUxOTI5NA==&mid=2247484367&idx=1&sn=fcbc485f068dae5de9f68d52607ea08f&chksm=fd54d7deca235ec86249a9e3714ec18be8b2d6dc580cae19e4e5113533a6c5b44dfa5813c4c3&scene=0&subscene=131&clicktime=1551942425&ascene=7&devicetype=android-28&version=2700033b&nettype=ctnet&abtest_cookie=BAABAAoACwASABMABAAklx4AVpkeAMSZHgDWmR4AAAA%3D&lang=zh_CN&pass_ticket=1qvHqOsbLBHv3wwAcw577EHhNjg6EKXqTfnOiFbbbaw%3D&wx_header=1)

简单的理解，我们想做到把Flutter容器做成浏览器的感觉。填写一个页面地址，然后由容器去管理页面的绘制。在Native侧我们只需要关心如果初始化容器，然后设置容器对应的页面标志即可。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190630103508.png)


## 参考

* [OpenFlutter/Flutter-Notebook: 日更的FlutterDemo合集，今天你fu了吗](https://github.com/OpenFlutter/Flutter-Notebook)
* [Flutter · 语雀](https://www.yuque.com/xytech/flutter)
* [Flutter中文网](https://flutterchina.club/)
* [Flutter 社区中文资源](https://flutter-io.cn/)
* [Flutter原理与实践 - 美团官方技术博客](https://tech.meituan.com/waimai_flutter_practice.html)
* [一个 Demo 入门 Flutter - Limboy](https://limboy.me/tech/2018/12/07/flutter-demo.html)
* [Release Flutter的最后一公里 - 掘金](https://juejin.im/post/5b456ebee51d4519277b7761)