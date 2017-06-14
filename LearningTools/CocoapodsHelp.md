
# CocoaPods



## Podfile


### use_frameworks!

[podfile中 use_frameworks! 和 #use_frameworks!区别 - 简书](http://www.jianshu.com/p/ac629a1cb8f5)

静态库：（静态链接库）（.a）在编译时会将库copy一份到目标程序中，编译完成之后，目标程序不依赖外部的库，也可以运行
       缺点是会使应用程序变大
动态库：（.dylib）编译时只存储了指向动态库的引用。
       可以多个程序指向这个库，在运行时才加载，不会使体积变大，
       但是运行时加载会损耗部分性能，并且依赖外部的环境，如果库不存在或者版本不正确则无法运行
Framework：实际上是一种打包方式，将库的二进制文件，头文件和有关的资源文件打包到一起，方便管理和分发。

对于是否使用Framework，CocoaPods 通过use_frameworks来控制

不使用use_frameworks! -> static libraries 方式 -> 生成.a文件
在Podfile中如不加use_frameworks!，cocoapods会生成相应的 .a文件（静态链接库），
Link Binary With Libraries: libPods-**.a 包含了其他用pod导入有第三库的.a文件
2.use_frameworks! -> dynamic frameworks 方式 -> 生成.framework文件

使用了use_frameworks!，cocoapods会生成对应的frameworks文件（包含了头文件，二进制文件，资源文件等等）
Link Binary With Libraries：Pods_xxx.framework包含了其它用pod导入的第三方框架的.framework文件


iOS8 / Xcode 6 之前是无法使用静态库，出现了AppExtension之后可以使用

对于是否使用Framework，CocoaPods 通过use_frameworks来控制

不使用use_frameworks! -> static libraries 方式 -> 生成.a文件
在Podfile中如不加use_frameworks!，cocoapods会生成相应的 .a文件（静态链接库），
Link Binary With Libraries: libPods-**.a 包含了其他用pod导入有第三库的.a文件
2.use_frameworks! -> dynamic frameworks 方式 -> 生成.framework文件

使用了use_frameworks!，cocoapods会生成对应的frameworks文件（包含了头文件，二进制文件，资源文件等等）
Link Binary With Libraries：Pods_xxx.framework包含了其它用pod导入的第三方框架的.framework文件
1.纯oc项目中 通过pod导入纯oc项目, 一般都不使用frameworks

2.swift 项目中通过pod导入swift项目，必须要使用use_frameworks！，在需要使用的到地方 import AFNetworking

3.swift 项目中通过pod导入OC项目

 1） 使用use_frameworks，在桥接文件里加上#import "AFNetworking/AFNetworking.h"
 2）不使用frameworks，桥接文件加上 #import "AFNetworking.h"


[Podfile中的 use_frameworks! - 林天海云 - SegmentFault](https://segmentfault.com/a/1190000007076865)

A、用cocoapods 导入swift 框架 到 swift项目和OC项目都必须要 use_frameworks!
B、使用 dynamic frameworks，必须要在Podfile文件中添加 use_frameworks!

(1)如果在Podfile文件里不使用 use_frameworks! 则是会生成相应的 .a文件（静态链接库），通过 static libraries 这个方式来管理pod的代码。   

(2)Linked:libPods-xxx.a包含了其它用pod导入的第三方框架的.a文件。

(3)如果使用了use_frameworks! 则cocoapods 会生成相应的 .frameworks文件（动态链接库：实际内容为 Header + 动态链接库 + 资源文件），使用 dynamic frameworks 来取代 static libraries 方式。   

(4)Linked:Pods_xxx.framework包含了其它用pod导入的第三方框架的.framework文件。
use_frameworks! -> dynamic frameworks 方式 -> .framework
#use_frameworks! -> static libraries 方式 -> .a

关于Library 和 Framework 可以参考：
http://blog.lanvige.com/2015/...



Library vs Framework in iOS


CocoaPods 终于支持了Swift，同时也发现Github团队的又一力作Carthage。它们都将包统一编译为Framework，但不同的是，Carthage 仅支持 iOS 8 & Xcode 6 Dynamic Framework 这一新特性。

Update 201504 CocoaPods 0.36 后也仅支持 Dynamic Framework，放弃了之前的 Static Framework 形式。

那这个编译结果有什么区别？

Static Library
Dynamic Library
Static Framework
Dynamic Framework
Static Library & Dynamic Library

这两者属于标准的编译器知识，所以讲的会比较多。

简单的说，静态链接库是指模块被编译合并到应用中，应用程序本身比较大，但不再需要依赖第三方库。运行多个含有该库的应用时，就会有多个该库的Copy在内存中，冗余。

动态库可以分开发布，在运行时查找并载入到内存，如果有通用的库，可以共用，节省空间和内存。同时库也可以直接单独升级，或作为插件发布。

Library & Framework

在iOS中，Library 仅能包含编译后的代码，即 .a 文件。

但一般来说，一个完整的模块不仅有代码，还可能包含.h 头文修的、.nib 视图文件、图片资源文件、说明文档。（像 UMeng 提供的那些库，集成时，要把一堆的文件拖到Xcode中，配置起来真不是省心的事。）

Framework 作为 Cocoa/Cocoa Touch 中使用的一种资源打包方式，可以上述文件等集中打包在一起，方便开发者使用（就像Bundle），。

我们每天都要跟各种各样的Framework打交道。如Foundation.framework / UIKit.framework等，这些都是Cocoa Touch开发框架本身提供的，而且这些 Framework 都是动态库。

但Apple对待第三方开发者使用动态库的态度却是极端的否定，所以在iOS 7之前如果使用动态库是肯定会被reject的，reason。但在2014年Xcode6和iOS 8发布时却开放了这个禁地，应该主要是为了App Extension。

Framework 包含什么？

到底Framework中有什么，这里来看Alamofire编译后的结果：


```
Alamofire.framework
├── Alamofire
├── Headers
│   ├── Alamofire-Swift.h
│   └── Alamofire.h
├── Info.plist
├── Modules
│   ├── Alamofire.swiftmodule
│   │   ├── arm.swiftdoc
│   │   ├── arm.swiftmodule
│   │   ├── arm64.swiftdoc
│   │   ├── arm64.swiftmodule
│   │   ├── i386.swiftdoc
│   │   ├── i386.swiftmodule
│   │   ├── x86_64.swiftdoc
│   │   └── x86_64.swiftmodule
│   └── module.modulemap
└── _CodeSignature
    └── CodeResources
    ```


Framework 包括了二进制文件（可动态链接并且为每种处理器架构专属生成），这点和静态库并无区别，但不同的是，它包含其它资源：

头文件 - 也包含Swift symbols所生成的头文件，如 `Alamofire-Swift.h`
所有资源文件的签名 - Framework被嵌入应用前都会被重新签名。
资源文件 - 像图片等文件。
Dynamic Frameworks and Libraries - 参见Umbrella Frameworks
Clang Module Map 和 Swift modules - 对应处理器架构所编译出的Module文件
Info.plist - 该文件中说明了作者，版本等信息。
Cocoa Touch Framework (实际内容为 Header + 动态链接库 + 资源文件)

Static Framework & Dynamic Framework

刚才也说明了Apple所创建的标准 Cocoa Touch Framework 里面包含的是动态链接库。而Dynamic Framework 为 Xcode 6中引入的新特性，仅支持 iOS 8，因为Carthage使用的是该特性，所以仅支持iOS 8，说明上有提。

但新版CocoaPods中使用Framework是能够支持iOS 7的，这说明它不是Dynamic Framework。推断它仅是将Static Library封装入了Framework。还是静态库，伪Framework。（v 0.36 正式版开始，仅提供 Dynamic Framework 的方式，不再支持 iOS7）。

关于Static Framework，见：

伪Framework 是指使用Xcode的Bundle来实现的。在使用时和Cocoa Touch Framework没有区别。但通过Framework，可以或者其中包含的资源文件（Image, Plist, Nib）。

#### Xcode 6 and iOS Static Frameworks
iOS Universal Framework Mk 8 中文
iOS-Framework
Swift 与 Framework 的关系
在Xcode 6.0 Beta 4的 Release Notes 中，可以找到这句话：

```
Xcode does not support building static libraries that include Swift code. (17181019)
在静态库中使用Swift语言开发，在build时会得到：
```
```

error: /Applications/Xcode.app/Contents/Developer/Toolchains/
XcodeDefault.xctoolchain/usr/bin/libtool:
unknown option character `X' in: -Xlinker
```

CocoaPods 将第三方都编译为Static Library。这导致Pod不支持Swift语言。所以新版Pod已将Static Library改为Framework。

Pods 0.36.0.beta.1 虽然已经支持Swift，但在编译时仍会给出下面警告：

1
ld: warning: embedded dylibs/frameworks only run on iOS 8 or later
CocoaPods 0.36 rc 开始对Swift正式放弃旧的打包方式，使用Dynamic Framework，也就意味着不再支持 iOS 7。更多见：SO

其它扩展阅读：

How to distribute Swift Library without exposing the source code?
Pod Authors Guide to CocoaPods Frameworks
Dynamic Framework

使用Dynamic 的优势：

模块化，相对于Static Library，Framework可以将模块中的函数代码外的资源文件打包在一起。
共享可执行文件 iOS 有沙箱机制，不能跨App间共享共态库，但Apple开放了App Extension，可以在App和Extension间共间动态库（这也许是Apple开放动态链接库的唯一原因了）。
iOS 8 Support only:

如果使用了动态链接库，在尝试编译到iOS 7设备上时，会出现在下错误：

1
2
3
ld: warning: directory not found for option '-F/Volumes/Mactop BD/repos/SwiftWeather/Carthage.build/iOS'
ld: embedded dylibs/frameworks are only supported on iOS 8.0 and later (@rpath/Alamofire.framework/Alamofire) for architecture armv7
clang: error: linker command failed with exit code 1 (use -v to see invocation)
REF::

WWDC2014 Building Modern Frameworks
Dynamic Linking
How to Create a Framework for iOS
Library? Static? Dynamic? Or Framework? - SO
Dynamic Frameworks on iOS 7
CocoaPods Swift Support PR
Apple - Framework Programming Guide
Module System of Swift (简析 Swift 的模块系统)
深入浅出Cocoa之Framework
linux中静态库和动态库的区别和汇总
IOS开发～Cocoa Touch Static Library（静态库）
说说iOS中静态库的开发


[Library vs Framework in iOS | Lanvige's Zen Garden](http://blog.lanvige.com/2015/01/04/library-vs-framework-in-ios/?utm_source=tuicool&utm_medium=referral)

