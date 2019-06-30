# Xcode进阶

在XCode环境下的一些概念【4】：

* Workspace：简单来说，Workspace就是一个容器，在该容器中可以存放多个你创建的Xcode Project， 以及其他的项目中需要使用到的文件。使用Workspace的好处有，1),扩展项目的可视域，即可以在多个项目之间跳转，重构，一个项目可以使用另一个项目的输出。Workspace会负责各个Project之间提供各种相互依赖的关系;2),多个项目之间共享Build目录。
* Project：指一个项目，该项目会负责管理生成一个或者多个软件产品的全部文件和配置，一个Project可以包含多个Target。
* Target：一个Target是指在一个Project中构建的一个产品，它包含了构建该产品的所有文件，以及如何构建该产品的配置。
* Scheme：一个定义好构建过程的Target成为一个Scheme。可在Scheme中定义的Target的构建过程有：Build/Run/Test/Profile/Analyze/Archive
* BuildSetting：配置产品的Build设置，比方说，使用哪个Architectures？使用哪个版本的SDK？。在Xcode Project中，有Project级别的Build Setting，也有Target级别的Build Setting。Build一个产品时一定是针对某个Target的，因此，XCode中总是优先选择Target的Build Setting，如果Target没有配置，则会使用Project的Build Setting。

## Xcode Project

Xcode Project是一个包含构建一个或多个软件产品所需要的一切文件、资源及信息的仓库。 Project包含构建产品的所有元素,并负责维护各个元素之间的关系。它包含一个或多个target，这些target指定如何构建产品。Project 为其中的target定义了默认的编译设置（每个target也可以覆盖默认的设置，指定自己的构建设置）。
Xcode Project 文件包含下面的一些信息：
* 对源文件的引用：
    * 源代码，包括头文件和实现文件
    * 库和框架，内部和外部的
    * 资源文件
    * 图像文件
    * Interface Builder（NIB）文件
* Groups 导航栏中用于组织文件资源的
* Project级别的构建设置。您可以为一个项目指定多个构建设置；例如，你有debug和release的生成设置。
* Targets，每个Target可定制的内容：
    * Project 构建的一个Product的引用
    * 构建某个产品所用的全部文件的引用
    * 构建某个产品所用的构建设置，包括对其他target或其他设置的依赖关系；如果对应的target没有覆盖原来的Project的设置，则使用原来Project的。
* 可用来调试或测试程序的执行环境，每个执行环境可定制的内容：
    * 当用Xcode运行或调试可执行文件的时候，加载什么东西
    * 传递给可执行文件的命令行参数
    * 程序运行时候的环境变量。
一个Project可以单独存在或包含在一个工作空间中。
You use Xcode schemes to specify which target, build configuration, and executable configuration is active at a given time.
使用Xcode schemes来指定使用哪一个target、构建配置、可执行的配置   320/width = heighta/ view.height


## Xcode Target

一个Target指定一个产品来构建并且包含了从项目或workspace的全部（或部分）文件中构建产品的指令。一个target定义了一个单一的产品。它来组织构建产品的输入文件（包含构建产品必需的所有文件：源文件，预编译这些源文件的指令）。Project 可以包含一个或多个target，每个target产生一个产品。
构建产品的指令有两种形式：构建设置和构建阶段（Build settings 和 Build phases）, 你可以在Xcode的项目editor中检查并编辑它们。target继承了project的构建设置。但是你可以在target层次覆盖任何project的设置。在同一时刻，只有一个target是活跃的。Xcode scheme指定了那个target是活跃的。
 一个target以及由它生成的产品可以与其他的target建立关系。如果构建一个target需要另一个target的输出，我们就说第一个target依赖于第二个target。如果它们两个都在同一个workspace中，xcode可以发现这种依赖关系，那么它就会按照需要的顺序来构建产品。这种关系叫做隐式依赖。你也可以在你的构建设置中设置显式依赖，并且你可以指定某两个xcode可能判定为有隐式依赖的target之间没有依赖关系。例如：你可以构建一个库以及一个链接这个库的在同一个workspace下的应用程序。xcode可以发现这种关系并且自动先构建这个库。当然，如果你确实需要链接到一个与当前workspace下不同版本的库中，你可以在你的构建设置中创建一个显示依赖，这将覆盖原来的隐式依赖。
 
## Xcode Scheme

Xcode scheme 定义了可构建的target的集合、构建时可用的设置以及可执行的测试的集合。
你可以创建任意数目的scheme，但是同一时刻只有一个是活跃的。你可以指定某一个scheme应该是存储在project中还是workspace中——如果是存储在project中，它在所有包含这个project的workspace中都是可用的，若是存储在workspace中，它只能在当前的workspace中可用。当你选择一个活跃的scheme，你也就同时选择了一个运行目的（也就是说，这个产品将要构建在那个硬件结构中）。（就是选择运行到那种设备）
Xcode Workspace

Workspace是一个xcode文档，它将一些项目以及其他的文档组织在一起，以便于你基于它们进行工作。一个Workspace可以包含任意个xcode项目，你也可以往里面加一些你想要的文件。 另外，为了阻止每个项目中的文件，workspace 为包含的项目以及它们的target提供了显式或隐式的关系。
Workspace扩展了你的工作流程的范围

一个项目文件包含了指向项目中所有文件的指针，也包含了便已设置以及其他的一些项目信息。在Xcode3及其以前的版本中，项目文件也就是组和文件结构层次的根节点。尽管一个项目可以包含另一个项目的引用，在xcode3 中基于有关联的不同项目工作还是很麻烦的。大部分工作流程局限于一个单一的项目。Xcode4以后的各个版本中，你可以选择创建一个workspace来掌握一个或多个项目，添加你想包含的文件。
除了提供对于每个xcode项目中文件的访问权以外，workspace扩展了许多重要的xcode工作流程的范围。例如，因为索引是通过整个workspace来进行的，所以代码自动填充，跳转到定义，以及其它所有的内容感知的特性才能在workspace中的所有项目中无缝地工作。因为重构操作对于workspace中的所有内容都是起作用的，你可以只用一次操作就重构一个框架项目中的API以及若干个使用这个框架的应用程序项目。当构建的时候，workspace中的一个项目可以使用同一个workspace中其它项目的产品。
一个Workspace文档包含了只想项目及其它文件的指针，但没有其它数据。一个项目可以属于不止一个workspace。下图展示了一个包含了两个xcode项目(Sketch 和 TextEdit)的workspace，以及一些文档项目（Xcode4TransGuideDocPlan）.

Workspace中的项目共享同一个构建目录

默认情况下，一个workspace中的所有xcode项目都是在同一个目中编译的，此目录也称为workspace的构建目录。每个workspace有他们自己的构建目录。因为一个workspace的所有项目中的所有文件都在同一个构建目录中。所有的这些文件对于其它的项目而言是可见的。因此，如果两个或更多项目使用同一个库，你不用将它分别拷贝到各自项目的独立的文件夹中去。
Xcode检查构建目录中的文件来建立隐式的依赖。例如，如果workspace中的一个项目构建了一个库，而同一个workspace中的 另一个项目也链接到这个库上，Xcode会在构建另一个项目之前自动构建这个库。尽管编译设置没有显式地设置。如果有必要的话，你可以用明确地用一个编译设置来覆盖这个隐式依赖。对于显式的依赖你必须创建项目引用。
Workspace中的每个项目仍然拥有它们的独立身份。要打开workspace中一个不受影响，或者被影响的项目，你可以直接打开这个项目，而不在workspace中打开。或者你可以添加此项目到另一个workspace中。因为一个项目可以属于不同的workspace，你可以建立任意数目的组合来工作，而不用修改任何项目或workspace。
你可以使用workspace 的默认构建目录，你也可以指定一个。注意，如果一个项目指定了构建目录，当你构建这个项目时，这个目录会被包含它的workspace的构建目录覆盖掉。

## Build Settings

一个构建设置是一个变量，这个变量包含了产品构建过程中某一方面应该如何展现的信息。例如：构建设置中的信息可以指定xcode传给编译器的选项。
你可以在project或target上设定构建设置。每个project的构建设置会应用到当前project上所有的target上，除非某一个target的构建设置中显式覆盖了原来的设置。
每个target管理需要构建一个product的资源文件。一个构建设置指定了一个特定的方式来用来构建一个target所对应产品构建环境。例如，对于一个产品，其debug和release的设置可以分开。
xcode的构建环境分为两个部分：设定名称及其定义。构建环境title指明了构建设置，而且可以在其他设置中使用。构建设置是xcode在构建阶段用来决定构建环境值的一个常量或公式。构建设置可能有一个展示的名称，用来在xcode用户界面中展示。
当你从项目模板中创建一个新的项目时，除了有xcode默认的构建设置，你还可以为你的项目或某个特定的target创建用户自定义的构建设置。你还可以指定条件编译设置。一个条件编译设置的值取决于是否有一个或多个前提条件。例如，这种机制允许你指定用来构建一个依赖于 特定架构的产品的sdk。
       
       

## 编译加速

[ccache 让你的编译时间飞起来](https://www.jianshu.com/p/53b2e3d203a9)


```
 brew install ccache
```

```#!/bin/sh
if type -p ccache >/dev/null 2>&1; then
export CCACHE_MAXSIZE=10G
export CCACHE_CPP2=true
export CCACHE_HARDLINK=true
export 
CCACHE_SLOPPINESS=file_macro,time_macros,include_file_mtime,include_file_ctime,file_stat_matches  
exec ccache /usr/bin/clang "$@"
else
exec clang "$@" 
fi
```


就这么多了！下次编译的时候会比正常慢一点，你可以在终端中使用 ccache -s 来查看 ccache 是否正常工作。刚开始时应该有很多缓存没有命中，但是当缓存开始渐渐替代之后的编译时，编译速度将会变得快起来。


### 代码段 Snippet

自己定义的代码块是在以下目录下：

```
~/Library/Developer/Xcode/UserData/CodeSnippets/
```

* My Frame

```objc

frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>);
```
![](https://http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15376704555901.jpg)


* My Lines Remark

```objc

/**
 * <#remark#>
 *
 * @param <#param#>
 */

```

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15376705248064.jpg)

* My Property

```objc
property (nonatomic, <#type#>) <#className#> *propertyName;/**< <#remark#> */

```

****

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15376705349709.jpg)

* My Remark

```
/** <#remark#> */

```

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15376706918514.jpg)


### 快速记录问题

* 使用`#warning `来定义问题，或者todo, fixme等
* 使用`Cmd + 5`切换到issue模板
* `Cmd + Option + J`跳转到fiter过滤，输入`user-defined`就可以查看到

### 快捷键

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15376702477628.jpg)

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15376702826707.jpg)

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15376703183349.jpg)

* 显示注释 `Cmd + Option + /`
* 
#### 1. Open Quickly

相信大家都熟悉 `⌘ + ⌥ + O` ，但是你知道怎么在辅助编辑器中打开吗？按住`Alt + Enter`， enjoy~

#### 2. 交换上下行代码：  `⌘ + ⌥ + [` or `⌘ + ⌥ + ]`

#### 3. To jump to the definition. 光标所在处`⌘ + ⌃ + J`
或者在辅助编辑器中打开

#### 4.切换多个编辑器焦点：

 `⌘ + J`
 
#### 5. 文件切换

* ⌃+1 - Related items menu that shows files related to what you are currently working on
* ⌃+2 - Previous and next buttons to navigate 
between your most recent files
The rest of the jump bar consists of heierarchial navigation with each level given a separate shortcut.
* ⌃+4 - Project level navigation
* ⌃+5 - Switch between header and implementation files
* ⌃+6 - Navigation within a file   

#### 6. 在辅助编辑器中跳转到变量的定义： `⌘ + Alt` + 鼠标点击对应变量名
     
#### 7. 在点击文件名时候，按住`Alt`将让文件在辅助编辑器中打开

#### 8. 在光标位置显示Help: `⌃ + ⌘ + ⇧ + /`

#### 9. Filter in Navigator  
本来热键是`⌘ + ⌥ + J`,发现貌似不起作用，就改成`⌘ + ⌥ + O`


## Xcode插件

### 插件路径


```
 ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/
```

### 常用插件

1. 自动补全 [HHEnumeration-Xcode ](https://github.com/youssman/awesome-xcode-plugins)
[molon/MLAutoReplace: Xcode plugin which help you write code faster.](https://github.com/molon/MLAutoReplace)
2. XAlign


![](https://i.loli.net/2018/10/21/5bcc92d432f92.jpg)

1. [pdcgomes/XCActionBar: "Alfred for Xcode" plugin](https://github.com/pdcgomes/XCActionBar)
2. 
![](https://i.loli.net/2018/10/21/5bcc934e71953.gif)

4. [trawor/XToDo: Xcode plugin to collect and list the `TODO`,`FIXME`,`???`,`!!!!`](https://github.com/trawor/XToDo)



### XCode9 安装 alcatraz

XCode8以后，Apple修改了XCode插件签名规则，要使用alcatraz需要update_xcode_plugins进行一次unsign操作。

步骤如下：

#### alcatraz

1.  删除alcatraz

```
rm -rf ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin
rm -rf ~/Library/Application\ Support/Alcatraz/

```

1.  安装alcatraz

```
curl -fsSL https://raw.github.com/supermarin/Alcatraz/master/Scripts/install.sh | sh

```

#### update_xcode_plugins

```
sudo gem install -n /usr/local/bin update_xcode_plugins

```

```
 update_xcode_plugins

```

```
update_xcode_plugins --unsign

```

遇到y/n，选择y

```
update_xcode_plugins --install-launch-agent

```
提示是否加载plugin，选择load bundles
提示签名，输入系统密码即可。
正常的话，能够看到package manager了


## Xcode 模板

设置添加文件模板

For everything you work on, regardless of project:
`~/Library/Developer/Xcode/UserData/IDETemplateMacros.plist`

```swift
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>FULLUSERNAME</key>
	<string>zhenning</string>
	<key>COPYRIGHT</key>
	<string>Copyright © ___YEAR___ zhenning. All rights reserved.</strsing>
</dict>
</plist>
```


[Customizing the file header comment and other text macros in Xcode 9 – Ole Begemann](https://oleb.net/blog/2017/07/xcode-9-text-macros/)


## Xcode辅助工具


* [youssman/awesome-xcode-plugins: Awesome Xcode plugins to rocket your productivity :)](https://github.com/youssman/awesome-xcode-plugins)
* [List of 8 Best Xcode Developer Tools (2018 Edition)](https://www.flexihub.com/xcode-developer-tools/)

1. XcodeWay
XcodeWay
This Xcode source editor extension offers easy access to a number of places you may need for your project. The tool provides you with an additional menu in Xcode and lets you go to various locations, which is extremely helpful during Xcode app development. For example, you can open Finder to the Project folder, Provisioning Profiles, DeviceSupport, CodeSnippets Folder, Themes, and more. Also, it will help you easily check and open GitHub page for the project repository in your default browser. And if, while working on a file, you find that any destination is missing, you can add it and submit a pull request.

2. FlexiHub
FlexiHub is an efficient software solution designed to redirect iOS devices over the network. This reliable app will become a great addition to Xcode iOS development tools allowing accessing iPhones, iPads, or iPods from any network computer, which makes it possible to test and debug iOS apps remotely. FlexiHub is able to virtualize USB devices and forward them across LAN, Ethernet, WIFi, or the Internet quickly and securely.

FlexiHub	
FlexiHub 
Windows, macOS, Linux, Android 
4.8 Rank based on 78+ users
Sign up for a free FlexiHub account below. Test the app for free for 7 days.

 FlexiHub
3. PlayAlways

PlayAlways is one of Xcode development tools that allows creating iOS or macOS Swift playgrounds. Thanks to this menubar app, you’ll be able to create iOS, macOS or tvOS playgrounds with nothing more than a couple of clicks or keyboard shortcut just after you have specified the path of where you want to save them. The solution also comes with Xcode extension which helps create a playground from Swift code that you've currently selected. This significantly simplifies testing your ideas in Swift before using them in your projects.

4. Import

It’s not uncommon that developers need to add an import module but scrolling up seems to be just a waste of time. In this case, a good idea will be to use Import - a simple Xcode source editor extension. This tool will help you in your Xcode app development by offering you a simple keyboard shortcut and menu item to move any import from a selected line to the required position at your file’s top.

5. Injection
Injection


[iOS 自定义代码段模板（CodeSnippets）和文件模板 (.xctemplate) - 简书 - iOS - 掘金](https://juejin.im/entry/58bed7f3570c3500622f9401#2.%E8%87%AA%E5%AE%9A%E4%B9%89%E6%96%87%E4%BB%B6%E6%A8%A1%E6%9D%BF)



### iOS代码自动化工具

[liubobo/automation: code generator](https://github.com/liubobo/automation)


### 代码片段

`code snippets`坐标位于Xcode整个界面的右下角,也可以通过快捷键`cmd + ctrl + opt + 2`调用.

#### OC

#### Swift

[burczyk/XcodeSwiftSnippets: Swift 4 code snippets for Xcode](https://github.com/burczyk/XcodeSwiftSnippets)

### Vim for xcode

* [记：在 Xcode 10 中安装 XVim2 - 风萧萧](https://note.wuze.me/xvim2)


## Debug调试

Xcode使用attach调试进程

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190614141814.png)

## 问题

## Xcode链接iphone一直闪断

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15326666022413.jpg)
![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15326666332024.jpg)

发现一个Xcode链接iphone一直闪断的问题，提示说软件下载更新才能连接，但是下载失败，还以为是数据线接触不良或者是Xcode版本不支持，后来发现开启省电模式就可以了。
[A software update is required to connect to your iOS device / iPhone - Ask Different](https://apple.stackexchange.com/questions/327310/a-software-update-is-required-to-connect-to-your-ios-device-iphone)

The problem can be fixed by installing XCode beta.
This error occurs when the version of macOS (and iTunes) running on the computer is not compatible with the version of iOS on the device you're trying to connect.

Normally, updating the macOS to its current version will solve the problem. However, this won't work if the iOS device is running a newer beta version, and the Mac is not.

## 版本调试

iOS-DeviceSupport [iGhibli/iOS-DeviceSupport: This repository holds the device support files for the iOS, and I will update it regularly.](https://github.com/iGhibli/iOS-DeviceSupport)

### 高版本Xcode不支持低版本iOS

[iOS 12 not supported by Xcode 9.4 : Could not locate device support files - Stack Overflow](https://stackoverflow.com/questions/51215836/ios-12-not-supported-by-xcode-9-4-could-not-locate-device-support-files)

If you want to use your iPhone 8 with this iOS version (NOT RECOMMENDED) with your Xcode 9.4 you can try to download the last beta of Xcode 10 and after connecting the iPhone to the mac go to this folder:

/Applications/Xcode10.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport

You can see the iOS version folder of the iPhone, copy and past it to the same location in your Xcode 9.4 folder.

After this you should be able to deploy to your iPhone 8.

### 低版本Xcode不支持高版本iOS真机调试

[解决低版本Xcode不支持高版本iOS真机调试的问题 - xiangzhihong8的专栏 - CSDN博客](https://blog.csdn.net/xiangzhihong8/article/details/78360091)
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190630113131.png)

1、复制一份旧的SDK，并重新命名为真机测试需要的SDK版本； 
具体做法是，找到路径: /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk （提示：要在应用程序中找到Xcode，右键点击 -> 显示包内容，以前Xcode版本的iOS SDK有的保存在系统根目录下）。

复制一份iPhoneOS.sdk，并命名为iPhoneOS11.1.sdk。如下图所示： 

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190630113344.png)

2，新增真机调试包及内容 
打开路径： 
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport 。我在CocoaChina上找到了11.1的真机包，链接地址如下： 
http://www.cocoachina.com/bbs/read.php?tid=1726904。然后我们打开DeviceSupport并复制一份。 

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190630113333.png)

3、修改SDKSettings.plist文件中的版本号

按照/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk 的顺序打开SDKSettings.plist 文件，将里面所有跟版本有关的数字都修改为11.1即可。再次运行就好了。 

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190630113327.png)

## 关于使用Clang(LLVM)将OC文件转为C/C++文件报错的问题

> main.m:9:9: fatal error: 'UIKit/UIKit.h' file not found
>  import <UIKit/UIKit.h>

> 1 error generated.

> clang -x objective-c -rewrite-objc -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk xxx.m

> //__weak修饰变量，需要告知编译器使用ARC环境及版本号否则会报错，添加说明
> -fobjc-arc -fobjc-runtime=ios-8.0.0

> xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 main.m


⌘⌥⌃+J.


## xcode 10, Command CodeSign failed with a nonzero exit code

[ios - xcode 10, Command CodeSign failed with a nonzero exit code - Stack Overflow](ios - xcode 10, Command CodeSign failed with a nonzero exit code - Stack Overflow)
```
Open keychain access.
Lock the 'login' keychain.
Unlock it, enter your PC account password.
Clean and Build project

```

## xcode 打开工程就崩溃意外退出

有时候因为个人项目配置问题，打开就崩溃

第一步 找到工程文件

![](https://i.loli.net/2018/11/22/5bf631023dab8.jpg)

第二步，找到project.xcworkspace文件

![](https://i.loli.net/2018/11/22/5bf631062e62b.jpg)

第三步： 删除xcuserdata文件夹中的一些个人配置

![](https://i.loli.net/2018/11/22/5bf631a652170.jpg)

我这边是打开了很多tab崩溃，删除的是`UserInterfaceState.xcuserstate`即可
![](https://i.loli.net/2018/11/22/5bf631f369dc2.jpg)

##  xcode启动模拟器无限等待中

[iOS 11][Xcode 9] launch, install, start hangs Simulator #209

```
Due to quirks (most likely Simulator bugs) in the Simulator launching on both Xcode 8 and 9, there is no common code to have it launch successfully on both Xcodes. Through experimenting, I have found these to be most reliable:

Xcode 9:

killall Simulator
xcrun simctl boot <device_id>
open `xcode-select -p`/Applications/Simulator.app
Xcode 8:

killall Simulator
xcrun simctl shutdown booted
xcrun instruments -w <device_id>

```

[[iOS 11][Xcode 9] launch, install, start hangs Simulator · Issue #209 · ios-control/ios-sim](https://github.com/ios-control/ios-sim/issues/209)


## 多个项目切换快捷键

`Cmd + ~`

##  Xcode 编辑iOS版本支持

1. [iOS-DeviceSupport](https://github.com/iGhibli/iOS-DeviceSupport)
2. [Yatko/iOS-device-support-files: iOS 12 not supported by Xcode 9.4 : Could not locate device support files](https://github.com/Yatko/iOS-device-support-files)

## 参考

1. [Injection：iOS热重载背后的黑魔法 - iOS - 掘金](https://juejin.im/entry/5b1f4c5f5188257d7c35e9d9)
