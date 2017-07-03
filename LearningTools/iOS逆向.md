
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


## 参考

1. [iOS 逆向手把手教程之一：砸壳与class-dump · Swiftyper](http://www.swiftyper.com/2016/05/02/iOS-reverse-step-by-step-part-1-class-dump/)
2. [iOS 逆向实战 - 钉钉签到远程“打卡”](https://www.instapaper.com/read/923533156)
3. [iOS逆向工程-----class-dump - 简书](http://www.jianshu.com/p/2add936e8bdd)


