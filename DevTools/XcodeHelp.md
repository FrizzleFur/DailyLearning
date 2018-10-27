
# XcodeHelp


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

#### 参考

[https://blog.csdn.net/lee727n/article/details/79808003](https://blog.csdn.net/lee727n/article/details/79808003)

[https://stackoverflow.com/questions/40743713/command-line-tool-error-xcrun-error-unable-to-find-utility-xcodebuild-n](https://stackoverflow.com/questions/40743713/command-line-tool-error-xcrun-error-unable-to-find-utility-xcodebuild-n)

[https://www.jianshu.com/p/97ff0728362b](https://www.jianshu.com/p/97ff0728362b)


## 参考

1. [XCode9 安装 alcatraz - 简书](https://www.jianshu.com/p/ccc609651a03)
