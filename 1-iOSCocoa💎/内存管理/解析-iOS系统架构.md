# 解析-iOS系统架构

> 虽然iOS系统内核使用极简的微内核架构，但内容依然十分庞大，所以会分
系统架构、进程调度、内存管理和文件系统四个部分进行阐述。


## iOS的架构


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216141730.png)

* UI层： 主要有SpringBoard、Spotlight等UI交互界面
* 应用框架层：主要有 Cocoa Touch
* 核心框架层：主要有 OpenGL、Quartz等图形、多媒体组件
* Darwin：操作系统核心，包括XNU内核和UNIX shell

### Mach

Mach 是 XNU的原子核，是一个微内核轻量级操作系统，仅处理最核心的任务

* 进程和线程抽象
* 任务调度
* 进程间通讯和消息传递
* 虚拟内存管理

### iOS 进化史

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216141657.png)

### iOS 使用的技术


#### bundle

平时开发中，我们经常会听到bundle这个词，在阿里大多数情况下bundle表示一个模块或者一个pod 库。实际上，bundle的概念来源于OS X，最先由NeXTSTEP使用。苹果的给出的定义是：** 一个标准化的有层次的结构，保存了可执行的代码以及该代码所需要的资源。**
bundle是framework、plugin、widgets、内核扩展的根基。


#### FSEvents
提供有关文件系统通知的API，通过这个API，用户应用程序可以简单快速地响应文件添加、修改和删除时间，OC中CoreServices框架（Carbon）提供的FSEventStreamCreate及其它相关API是对FSEvents的封装。


####  通知


分布式IPC的一种形式，进程可以通过这种机制广播或监听事件。


####  GCD
这个不说大家也都知道


#### iOS 的安全机制

* 代码签名：使用SSL验证身份，通过发布者的私钥对公钥进行签名，来验证应用程序的来源以及在传输过程中是否被篡改
* 隔离机制（沙盒化）：不受信任的应用程序必须在一个独立的隔间中运行，隔间实际上就是一个隔离的环境，在这个环境所有的操作都会受到限制，采用“黑名单”风格方法来阻止已知的危险操作，只有在列表具有足够的限制性时才有效果
* Entitlement：更为严格的沙盒，采用“白名单”的方式，只允许那些已知是安全的操作，其他所有操作都不允许，替换当前沙盒机制中采用的“黑名单”方式

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216141912.png)


## 系统架构


## 进程调度


## 内存管理


## 文件系统






## 参考

1. [iOS OSX Mach Darwin XNU - 简书](https://www.jianshu.com/p/d8d79912dd97)
2. [深入浅出iOS系统内核（1）— 系统架构 - 简书](https://www.jianshu.com/p/029cc1b039d6#1%20iOS%20%E8%BF%9B%E5%8C%96%E5%8F%B2)
3. [深入浅出iOS系统内核（2）— 进程调度 - 简书](https://www.jianshu.com/p/e56c3d28e77d)

