
# XcodeHelp


1. Track build time in Xcode
If you don't know the exact build time of your project, enable the following option in Xcode.

```
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
```
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190314210614.png)


[Best iOS Development Tips and Tricks](https://developerinsider.co/best-ios-development-tips-and-tricks/)



3. Use Simulator in full-screen mode with Xcode



### Xcode黑魔法

Run without building

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200511150422.png)

连接已经跑起来的程序：去除编译等待时间

’command + shift + R’

### Xcode切换窗口快捷键

>今天在开发的过程，发现一个经常用到的切换多个`Xcode`窗口的快捷键的使用


发现要使用`Cmd + “`/~”` 或者`Cmd +Shift + “`/~”`  来回切换tab窗口的使用，需要用
`Cmd + Shift + T`  来让窗口在外面显示才行，这样就不得不多一步调整，那天可以在同一个窗口切换tab，就爽了。`Cmd +  T`

![](http://oc98nass3.bkt.clouddn.com/2017-06-03-14964614431501.jpg)


网上找了一下，发现现在Xcode8是这样的：
`Cmd + {`
`Cmd + }`
注：
1. "{" 其实是 “Shift + [”
其实是 `Cmd + Shift + [`
2. 上面是在同一个Tab里面使用`Cmd + T`新建的tab的切换，如果使用`Cmd + Shift + T` 新建的窗口，可以使用  `Ctr + ~` （tab键上面）来进行切换，搜了一段时间，请慢用~
By the way,使用快捷键是个好习惯~[s:921]

还在[论坛](http://www.cocoachina.com/bbs/read.php?tid=34765)上发帖了~😄

```
网上找了一下，发现现在Xcode8是这样的：
`Cmd + {`
`Cmd + }`
注：
1. "{" 其实是 “Shift + [”
其实是 `Cmd + Shift + [`
2. 上面是在同一个Tab里面使用`Cmd + T`新建的tab的切换，如果使用`Cmd + Shift + T` 新建的窗口，可以使用  `Ctr + ~` （tab键上面）来进行切换，搜了一段时间，请慢用~
By the way,使用快捷键是个好习惯~[s:921]
```

### 切换编辑器焦点
![](http://oc98nass3.bkt.clouddn.com/2017-06-03-14964613515064.jpg)



###  查看编译时间

![](http://oc98nass3.bkt.clouddn.com/2017-06-14-14974004401607.jpg)

`DYLD_PRINT_STATISTICS`

![](http://oc98nass3.bkt.clouddn.com/2017-06-14-14974004600437.jpg)



### Xcode9安装插件

alcatraz是XCode上的一个插件管理工具。提供了插件查找、安装、删除功能。

![](//upload-images.jianshu.io/upload_images/5592145-725cd61014c4c083.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/544/format/webp)

alcatraz

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

#### 启动xcode

提示是否加载plugin，选择load bundles
提示签名，输入系统密码即可。
正常的话，能够看到package manager了

![](//upload-images.jianshu.io/upload_images/5592145-ef4379f88b4d09cb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/411/format/webp)

package manager

#### 遇到的两个坑

1.  [Command Line Tool - Error - xcrun: error: unable to find utility “xcodebuild”, not a developer tool or in PATH](https://stackoverflow.com/questions/40743713/command-line-tool-error-xcrun-error-unable-to-find-utility-xcodebuild-n)

2.  启动xcode闪退
    原因是原来装了一下plugin冲突了。到1~/Library/Application Support/Developer/Shared/Xcode/Plug-ins ,删除除了alcatraz外的其他plugin，启动正常。



### 只会左键断点？是时候试试这样那样断点了

2015-08-05 09:28 编辑： [suiling](http://www.cocoachina.com/ios/20150805/12842.html) 分类：[iOS开发](http://www.cocoachina.com/ios/) 来源：[空之境界投稿](http://supermao.cn/duan-dian-shen-ru-liao-jie/)

0 19199

[断点](http://www.cocoachina.com/cms/tags.php?/%E6%96%AD%E7%82%B9/)[Break Point](http://www.cocoachina.com/cms/tags.php?/Break+Point/)

**招聘信息：**

*   [iOS开发](http://job.cocoachina.com/job/show?id=68754)
*   [iOS开发](http://job.cocoachina.com/job/show?id=68753)
*   [iOS开发](http://job.cocoachina.com/job/show?id=68752)
*   [app开发上架H5技术](http://job.cocoachina.com/job/show?id=68751)
*   [app开发技术](http://job.cocoachina.com/job/show?id=68750)
*   [图像处理及模式识别工程师](http://job.cocoachina.com/job/show?id=68743)
*   [C/C++工程师](http://job.cocoachina.com/job/show?id=68745)
*   [Cocos2d-x游戏客户端开发](http://job.cocoachina.com/job/show?id=68442)
*   [iOS开发工程师](http://job.cocoachina.com/job/show?id=68612)
*   [京东招聘iOS开发工程师](http://job.cocoachina.com/job/show?id=68573)
*   [cocos2d-x主程](http://job.cocoachina.com/job/show?id=68695)

[](javascript:void(0)) [](javascript:void(0))

![65 (2).jpg](http://cc.cocimg.com/api/uploads/20150730/1438225975213567.jpg "1438225975213567.jpg")

文本是投稿文章，作者：空之境界（[博客](http://supermao.cn/duan-dian-shen-ru-liao-jie/)）

* * *

编码不能没调试，调试不能没断点（Break Point）。XCode的断点功能也是越来越强大。

**基本断点**

如下图，这种是最常用的断点，也是最容易设置。左键点击一下就可以设置。 

![duandian1.png](http://cc.cocimg.com/api/uploads/20150730/1438224910359355.png "1438224910359355.png")

**编辑断点**

断点是可以编辑的。

![duandian2.png](http://cc.cocimg.com/api/uploads/20150730/1438224927240670.png "1438224927240670.png")

断点有下面几个属性可以设置：

*   Condition

*   Ignore

*   Action

*   Options

**Condition**

这里可以输入条件表达式，满足条件的时候断点就会生效。例如上面输入a == 50。这个是非常有用的设置，特别在循环体内调试的时候，用着真的是爽。

**Ingore**

在这里可以设置忽略断点次数。

**Action**

Action是这里最复杂的，最强大的功能了。Action有6中类型。如下图

![QQ截图20150730105638.png](http://cc.cocimg.com/api/uploads/20150730/1438225007147421.png "1438225007147421.png")

1.  AppleScript

2.  Capture GPU Frame

3.  Debugger Command

4.  Log Message

5.  Shell Command

6.  Sound

常用的就是Log Message和Debugger Command

**Log Message**

在这里填写的东西可以打印到控制台。例如我做了如下设置：

![duandian3.png](http://cc.cocimg.com/api/uploads/20150730/1438225128874847.png "1438225128874847.png")

%B会打印断点的名字，%H会打印断点的调用次数，@@中间可以输入表达式。 上面的设置在控制台的输出如下：

![55.png](http://cc.cocimg.com/api/uploads/20150730/1438225371364390.png "1438225371364390.png")

**Debugger Command**

这里可以输入调试命令，也就是po（打印对象信息），bt（打印函数栈），expression（表达式）这些调试命令。看图就明白了：

![duandian4.png](http://cc.cocimg.com/api/uploads/20150730/1438225401812904.png "1438225401812904.png")

image 控制台输出如下：

![duandian5.png](http://cc.cocimg.com/api/uploads/20150730/1438225450194964.png "1438225450194964.png")

**Options**

勾选**Automatically continue after evaluating actions**之后程序会在断点产生后继续运行。这个属性是相当有用的，可以输入调试信息至于不暂停程序。

出了上面的基本断点外，XCode还提供了下面四种断点，需要点击断点面板左下角的+号添加。

![duandian6.png](http://cc.cocimg.com/api/uploads/20150730/1438225565768320.png "1438225565768320.png")

*   Exception Breakpoint

*   OpenGL ES Error Breakpoint

*   Symbolic Breakpoint

*   Test Failure Breakpoint

**Exception Breakpoint**

Exception Breakpoint是一个非常有用的断点项。正如名字所示，当程序抛出异常的时候就回产生断点。通常程序崩溃会停在崩溃的地方，但有时候并不能准确停在引起异常的地方。比如数组越界！比如我下图所示，会引起数组越界访问。 

![duandian7.png](http://cc.cocimg.com/api/uploads/20150730/1438225625879689.png "1438225625879689.png")

![duandian8.png](http://cc.cocimg.com/api/uploads/20150730/1438225651155831.png "1438225651155831.png")

程序运行的时候就会崩溃。但是崩溃停在了main函数里面，就算看了栈信息也不能马上定位到到底是那个数组越界访问了。为什么崩溃不能停在数组越界哪里？这是因为数组越界访问不一定会导致程序崩溃的，数组越界访问会导致异常抛出，而抛出的异常没有得到处理才会导致程序崩溃。因此最后会导致崩溃停在CoreFoundation框架里面。这个时候就需要设置Exception Breakpoint产生断点来定位错误了。

![duandian10.png](http://cc.cocimg.com/api/uploads/20150730/1438225734539767.png "1438225734539767.png")

![duandian11.png](http://cc.cocimg.com/api/uploads/20150730/1438225742253959.png "1438225742253959.png")

**OpenGL ES Error Breakpoint**

这个主要是OpenGL ES的断点调试，这个个人没用到过。

**Symbolic Breakpoint**

Symbolic Breakpoint，符号断点，真的是调试神器啊。当程序运行到特定符号的时候就会产生断点。通过这种方式添加断点，就不需要在源文件中添加，也不需要知道断点设置在文件的第几行。如图： 

![duandian12.png](http://cc.cocimg.com/api/uploads/20150730/1438225777399846.png "1438225777399846.png")

比普通断点多了两个属性Symbol和Module。

**Symbol**

Symbol的内容，可以有如下几种： 

1\. 方法名称：会对所有具有此方法名称的类方法生效。例如 initWithFrame: 。 

2\. 特定类的方法：OC类和C++类都适用，例如 ，[UIView initWithFrame:]或者 Shap::draw()。 

3\. 函数名称。例如普通C函数。

通过设置Symbol来调试，好用根本停不下来，想怎么断点就怎么断点。

**Test Failure Breakpoint**

这个类型的断点会在test assertion 失败的时候暂停程序的执行。

#### 参考

[https://blog.csdn.net/lee727n/article/details/79808003](https://blog.csdn.net/lee727n/article/details/79808003)

[https://stackoverflow.com/questions/40743713/command-line-tool-error-xcrun-error-unable-to-find-utility-xcodebuild-n](https://stackoverflow.com/questions/40743713/command-line-tool-error-xcrun-error-unable-to-find-utility-xcodebuild-n)

[https://www.jianshu.com/p/97ff0728362b](https://www.jianshu.com/p/97ff0728362b)



## 三方项目的编译证书问题

之前发现下的三方库，编译的证书问题，后面发现，其实在所有的target中检查证书和`develop Team`是否为自己的，即可。


![](https://i.loli.net/2018/12/31/5c29e8fc312d4.jpg)


## Xcode 搜索结果file folding

发现Xcode 搜索结果的文件默认都是展开的，有时非目标文件太多，想折叠起来。找半天没找到快捷键。

其实是有个小技巧。

按住Cmd，鼠标点击任意一个Folding箭头，就可以实现全部文件折叠展示了。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190413163247.png)


## 参考

1. [XCode9 安装 alcatraz - 简书](https://www.jianshu.com/p/ccc609651a03)
