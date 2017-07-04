
# iOS逆向


### 学习资源

[学习资料资源入口整理（一起整理啦）](http://www.iosre.com/t/topic/4680)
[iPhone Development Wiki](http://iphonedevwiki.net/index.php/Main_Page)

[iOS%20Hacking%20Guide](chrome-extension://gfbliohnnapiefjpjlpjnehglfpaknnc/pages/pdf_viewer.html?r=https://web.securityinnovation.com/hubfs/iOS%20Hacking%20Guide.pdf)



###  砸壳

为了砸壳，我们需要使用到`dumpdecrypted`，这个工具已经开源并且托管在了`GitHub` 上面，我们需要进行手动编译。步骤如下：

1. 从`GitHub` 上 `clone`源码：

```
$ cd ~/iOSReverse
$ git clone git://github.com/stefanesser/dumpdecrypted/
```

2. 编译 dumpdecrypted.dylib：

```
$ cd dumpdecrypted/
$ make
```

执行完 make 命令之后，在当前目录下就会生成一个 dumpdecrypted.dylib，这个就是我们等下要使用到的砸壳工具。



### class-dump


### 使用 `Xcode` 调试第三方应用


#### get-task-allow

1. 提取`.mobileprovision`文件的`entitlements.plist`

![](http://oc98nass3.bkt.clouddn.com/2017-07-03-14990792796143.jpg)

拷贝内容，新建一个`.plist`文件
![](http://oc98nass3.bkt.clouddn.com/2017-07-03-14990793865052.jpg)

拷贝到`wechat.app`文件夹中


![](http://oc98nass3.bkt.clouddn.com/2017-07-03-14990796280206.jpg)


#### 解决问题

这里会有一个问题，如果app中包含了扩展之类的东西就需要注意了，每个插件包里都会有一个info.plist文件，里面的Bundle identifier也需要做相应的修改，不然后导致安装失败。

另外即使改了所有相关的Bundle identifier，还需要对扩展插件进行砸壳才行。所以为了方便，我就把所有插件相关的东西都删了！

![](http://oc98nass3.bkt.clouddn.com/2017-07-04-14991380843315.jpg)

#### 整体流程

1. 选好一个`mobileprovision`文件，可以运行真机得到。
2. 查看mobileprovision的内容

```
security cms -D -i    yourMobileprovisionName.mobileprovision
```

3. 从 `mobileprovision` 导出 `plist`文件，命名为`entitlements.plist`

```
/usr/libexec/PlistBuddy -c "Print :Entitlements" mobileprovisionName.plist -x > entitlements.plist
```

4. 删除旧的资源签名
```
defaults delete CFBundleResourceSpe Info.plist
```
如果提示说 `Info.plist `中没有`CFBundleREsourceSpecification` 是正常的。

5. 查找证书
```
security find-identity -v -p codesigning
```

6. 重新签名
```
codesign -vvv -fs “YourCertifierName” --entitlements=AppName.app/entitlements.plist --no-strict AppName.app
```

6. 打包`ipa`文件
```
zip -ry AppName.ipa Payload
```
## 参考

1. [iOS 逆向手把手教程之一：砸壳与class-dump · Swiftyper](http://www.swiftyper.com/2016/05/02/iOS-reverse-step-by-step-part-1-class-dump/)
2. [iOS 逆向实战 - 钉钉签到远程“打卡”](https://www.instapaper.com/read/923533156)
3. [iOS逆向工程-----class-dump - 简书](http://www.jianshu.com/p/2add936e8bdd)

###   使用 `Xcode` 调试第三方应用参考
1. [使用 Xcode 调试第三方应用 · Swiftyper](http://swiftyper.com/2017/07/02/attach-third-app-using-xcode/)
2. [iOS APP重签名 - 简书](http://www.jianshu.com/p/5bc225be6c03)

