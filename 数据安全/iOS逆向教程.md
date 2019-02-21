# iOS逆向


## App脱壳











## Hopper+LLDB调试第三方App



### ipa工具

[DanTheMan827/ios-app-signer: This is an app for OS X that can (re)sign apps and bundle them into ipa files that are ready to be installed on an iOS device.](https://github.com/DanTheMan827/ios-app-signer)


# 一条命令完成砸壳


### [](http://www.alonemonkey.com/2018/01/30/frida-ios-dump/#%E8%83%8C%E6%99%AF "背景")背景

最早的砸壳工具是stefanesser写的[dumpdecrypted](https://github.com/stefanesser/dumpdecrypted)，通过手动注入然后启动应用程序在内存进行dump解密后的内存实现砸壳，这种砸壳只能砸主App可执行文件。

对于应用程序里面存在framework的情况可以使用conradev的[dumpdecrypted](https://github.com/conradev/dumpdecrypted)，通过_dyld_register_func_for_add_image注册回调对每个模块进行dump解密。

但是这种还是需要拷贝dumpdecrypted.dylib，然后找路径什么的，还是挺麻烦的。所以笔者干脆放到[MonkeyDev](https://github.com/AloneMonkey/MonkeyDev)模板变成一个tweak的形式[dumpdecrypted](https://github.com/AloneMonkey/dumpdecrypted)，这样填写目标bundle id然后看日志把文件拷贝出来就可以了。

但是还是很麻烦，需要拷贝文件自己还原ipa，然后有了KJCracks的[Clutch](https://github.com/KJCracks/Clutch)通过posix_spawnp创建进程然后dump直接生成ipa包在设备，可以说是很方便了。这个是工具在使用的时候大部分应用会出报错，此外生成的包还需要自己拷贝。

### [](http://www.alonemonkey.com/2018/01/30/frida-ios-dump/#%E4%B8%80%E9%94%AEdump "一键dump")一键dump

人都是想偷懒的，于是便有了本文将要介绍的[frida-ios-dump](https://github.com/AloneMonkey/frida-ios-dump)，该工具基于frida提供的强大功能通过注入js实现内存dump然后通过python自动拷贝到电脑生成ipa文件，通过以下方式配置完成之后真的就是一条命令砸壳。

### [](http://www.alonemonkey.com/2018/01/30/frida-ios-dump/#%E7%8E%AF%E5%A2%83%E9%85%8D%E7%BD%AE "环境配置")环境配置

首先上面也说了该工具基于frida，所以首先要在手机和mac电脑上面安装frida，安装方式参数官网的文档:[https://www.frida.re/docs/home/](https://www.frida.re/docs/home/)

如果mac端报如下错:


Uninstalling a distutils installed project (six) has been deprecated and will be removed in a future version. This is due to the fact that uninstalling a distutils project will only partially uninstall the project.

 |

使用如下命令安装即可:

| 

1

 | 

sudo pip install frida –upgrade –ignore-installed six

 |

然后将越狱设备通过USB连上电脑进行端口映射:

| 

1

 | 

iproxy 2222 22


到此环境就配置好了，接下来就可以一键砸壳了！ (另当前python基于2.x的语法，先切换到python 2.x的环境

### [](http://www.alonemonkey.com/2018/01/30/frida-ios-dump/#%E4%B8%80%E9%94%AE%E7%A0%B8%E5%A3%B3 "一键砸壳")一键砸壳

最简单的方式直接使用./dump + 应用显示的名字即可，如下:

➜  frida-ios-dump ./dump.py 微信

open target app......

Waiting for the application to open......

start dump target app......

start dump /var/containers/Bundle/Application/6665AA28-68CC-4845-8610-7010E96061C6/WeChat.app/WeChat

WeChat                                        100%   68MB  11.4MB/s   00:05

start dump /private/var/containers/Bundle/Application/6665AA28-68CC-4845-8610-7010E96061C6/WeChat.app/Frameworks/WCDB.framework/WCDB

WCDB                                          100% 2555KB  11.0MB/s   00:00

start dump /private/var/containers/Bundle/Application/6665AA28-68CC-4845-8610-7010E96061C6/WeChat.app/Frameworks/MMCommon.framework/MMCommon

MMCommon                                      100%  979KB  10.6MB/s   00:00

start dump /private/var/containers/Bundle/Application/6665AA28-68CC-4845-8610-7010E96061C6/WeChat.app/Frameworks/MultiMedia.framework/MultiMedia

MultiMedia                                    100% 6801KB  11.1MB/s   00:00

start dump /private/var/containers/Bundle/Application/6665AA28-68CC-4845-8610-7010E96061C6/WeChat.app/Frameworks/mars.framework/mars

mars                                          100% 7462KB  11.1MB/s   00:00

AppIcon60x60@2x.png                           100% 2253   230.9KB/s   00:00

AppIcon60x60@3x.png                           100% 4334   834.8KB/s   00:00

AppIcon76x76@2x~ipad.png                      100% 2659   620.6KB/s   00:00

AppIcon76x76~ipad.png                         100% 1523   358.0KB/s   00:00

AppIcon83.5x83.5@2x~ipad.png                  100% 2725   568.9KB/s   00:00

Assets.car                                    100%   10MB  11.1MB/s   00:00

.......

AppIntentVocabulary.plist                     100%  197    52.9KB/s   00:00

AppIntentVocabulary.plist                     100%  167    43.9KB/s   00:00

AppIntentVocabulary.plist                     100%  187    50.2KB/s   00:00

InfoPlist.strings                             100% 1720   416.4KB/s   00:00

TipsPressTalk@2x.png                          100%   14KB   2.2MB/s   00:00

mm.strings                                    100%  404KB  10.2MB/s   00:00

network_setting.html                          100% 1695   450.4KB/s   00:00

InfoPlist.strings                             100% 1822   454.1KB/s   00:00

mm.strings                                    100%  409KB  10.2MB/s   00:00

network_setting.html                          100% 1819   477.5KB/s   00:00

InfoPlist.strings                             100% 1814   466.8KB/s   00:00

mm.strings                                    100%  409KB  10.3MB/s   00:00

network_setting.html                          100% 1819   404.9KB/s   00:00

 |

如果存在应用名称重复了怎么办呢？没关系首先使用如下命令查看安装的应用的名字和bundle id:

| 

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

 | 

➜  frida-ios-dump git:(master) ✗ ./dump.py -l

  PID  Name                       Identifier

-----  -------------------------  ----------------------------------------

 9661  App Store                  com.apple.AppStore

16977  Moment                     com.kevinholesh.Moment

 1311  Safari                     com.apple.mobilesafari

16586  信息                         com.apple.MobileSMS

 4147  微信                         com.tencent.xin

10048  相机                         com.apple.camera

 7567  设置                         com.apple.Preferences

    -  CrashReporter              crash-reporter

    -  Cydia                      com.saurik.Cydia

    -  通讯录                        com.apple.MobileAddressBook

    -  邮件                         com.apple.mobilemail

    -  音乐                         com.apple.Music

    ......

 |

然后使用如下命令对指定的bundle id应用进行砸壳即可:

| 

1

 | 

➜  frida-ios-dump git:(master) ✗ ./dump.py -b com.tencent.xin

 |

等待自动砸壳传输完成之后便会到当前目录生成一个解密后的ipa文件，这个时候赶紧拖到[MonkeyDev](https://github.com/AloneMonkey/MonkeyDev)开始逆向之旅吧！

 [](http://www.alonemonkey.com/images/wx-qrcode.jpg)






# 非越狱App集成

Alone_Monkey edited this page on 25 Sep · [47 revisions](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90/_history)

**选真机编译运行！**

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E5%87%86%E5%A4%87%E5%A5%BD%E7%A0%B8%E5%A3%B3%E7%9A%84ipa%E6%88%96%E8%80%85app)准备好砸壳的ipa或者app

第一步是准备好砸壳的ipa或者app，可以从某助手下载越狱应用(下载的也有没砸壳的QAQ)。

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E5%88%9B%E5%BB%BAmonkeyapp%E9%A1%B9%E7%9B%AE)创建MonkeyApp项目

点击`File - New - Project...`创建iOS项目，选择`MonkeyApp`。

![image](https://camo.githubusercontent.com/c54a3aa7cdbe65c4fd7020d90917a44f050af9b4/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313532303935313534333338362e706e67)

然后填写Product Name，对于非越狱设备可以不用管Target App，如果是越狱设备的话可以在Target App填写目标App的名字或者bundle id，工具将会自动使用[frida-ios-dump](https://github.com/AloneMonkey/frida-ios-dump)提取ipa文件(注意:要先按frida-ios-dump repo的README配置好环境！)，如下所示:

![image](https://camo.githubusercontent.com/93b95c8404b3fe718cfd9001b4e802bc801288c8/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313532303935313636383334372e706e67)

另外`/opt/MonkeyDev/bin/dump.py`里面可以指定ip、port以及password。

创建完成之后，你会得到一个这样的工程:

![image](https://camo.githubusercontent.com/e083a8c5bbe81fea9d9e456ff627772c1ca0aa57/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f6d6f6e6b657961707030322e706e67)

这里我创建的项目名字就是`MonkeyApp`，所以下面对应的都是`MonkeyApp`，你自己创建的由你的项目名字而定!

`MonkeyAppDylib`这个是将被注入目标App的动态库，你自己要hook的代码可以在`MonkeyAppDylib.m`文件里面写，我在里面写了一些Demo代码，支持OC runtime的HOOK，C函数的fishhook。还支持theos logtweak的写法！ 直接写在`MonkeyAppDylib.xm`文件文件即可。

`Config` 这个是cycript的一些脚本下载以及methodtrace配置代码。

`LLDBTools` 这个是用于LLDB调试的代码，比如`po pviews()`。

`AntiAntiDebug` 这个里面是反反调试的代码。

`fishhook` 这个是自动集成的fishhook模块。

创建的项目已经自动集成了`RevealServer.framework`和`libcycript.dylib`，如果选择Release编译的话是不会集成的。

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E6%8B%96%E5%85%A5%E7%BC%96%E8%AF%91)拖入编译

我准备了一个砸壳了的ipa文件，然后我右键项目里面的TargetApp文件夹Show in Finder，把ipa文件拖入下面的位置(当然app文件夹也可以的):

![](https://camo.githubusercontent.com/0c62d21f01859f19271f4992241e9762029c74b2/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7075746970612e706e67)

或者支持直接将文件拖到Xcode项目TargetApp下面。

Xcode 8需要另外指定一下依赖，选择`Build Phases`，点击`Target Dependencies`增加需要注入的动态库即可。如下:

![](https://camo.githubusercontent.com/25505e89001073f33ed73cade8ccd651c527aca2/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f575832303137303732362d3134323931302e706e67)

然后编译运行，打开电脑的`Reveal`，就可以看到界面了:

![](https://camo.githubusercontent.com/38c635d07dadcd62d273f666865232e16376cfd4/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313439393837343134303136352e706e67)

从[Cycript](http://www.cycript.org/)下载SDK，然后进去SDK目录运行如下命令，`Cycript`查看界面也没有问题:

![](https://camo.githubusercontent.com/1c8323e2f306ca431318ea7874c9f014038bafdf/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313439393837343335343136392e706e67)

这里Cycript默认端口是`6666`。

# [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E6%9B%B4%E5%A4%9A%E5%8A%9F%E8%83%BD)更多功能

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E5%8A%A8%E6%80%81%E5%BA%93%E8%B0%83%E8%AF%95)动态库调试

在`MonkeyAppDylib.m`文件中写了自己的代码之后就可以直接下断点调试，效果如下:

![](https://camo.githubusercontent.com/b86782affbaeaaf3ff47d4ec27b5d4796acc0f84/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313439393837363632323835342e706e67)

`MonkeyAppDylib.xm`文件也支持动态调试，在文件左侧点击下断点即可，第一次由于后缀Xcode不识别，下的断点不会显示出来，但是断点是生效的！在右侧将文件类型改成Object C++ 重新打开文件或重启Xcode，效果如下:

![](https://camo.githubusercontent.com/1df4f95d6ae1af27c338454b822c9e36f926bc55/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f575832303137303831312d3136333430332e706e67)

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#demo-app)Demo App

`MonkeyApp`不拖入App或者ipa的情况下，会有一个默认的App，以供读者自己测试，样子大概是这个样子····

![image](https://camo.githubusercontent.com/89bdfe806fb493fd61337b259ebe78f8d8cc68c3/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313532303935323133333736362e706e67)

你可以自己修改`MonkeyAppDylib.m`里面的代码，这个是笔者针对`Demo`写的例子啦，另外注意的是MonkeyApp里面都是ARC，所以网上很多MRC的写法是有问题的，多多参考笔者的例子: [https://github.com/AloneMonkey/WeChatPod](https://github.com/AloneMonkey/WeChatPod)

```
CHDeclareClass(CustomViewController)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

//add new method
CHDeclareMethod1(void, CustomViewController, newMethod, NSString*, output){
    NSLog(@"This is a new method : %@", output);
}

#pragma clang diagnostic pop

CHOptimizedMethod0(self, NSString*, CustomViewController,getMyName){
    //get origin value
    NSString* originName = CHSuper(0, CustomViewController, getMyName);

    NSLog(@"origin name is:%@",originName);

    //get property
    NSString* password = CHIvar(self,_password,__strong NSString*);

    NSLog(@"password is %@",password);

    [self newMethod:@"output"];

    //set new property
    self.newProperty = @"newProperty";

    NSLog(@"newProperty : %@", self.newProperty);

    //change the value
    return @"AloneMonkey";

}

//add new property
CHPropertyRetainNonatomic(CustomViewController, NSString*, newProperty, setNewProperty);

CHConstructor{
    CHLoadLateClass(CustomViewController);
    CHClassHook0(CustomViewController, getMyName);

    CHHook0(CustomViewController, newProperty);
    CHHook1(CustomViewController, setNewProperty);
}

```

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#class-dump)class-dump

工程已集成class-dump导出可执行文件OC头文件的功能，可在build settings最下面开启该功能。

![image](https://camo.githubusercontent.com/7d59b9244f9cb0df6549a0fe9b5a00be264116f7/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313530313333383638323834372e706e67)

开启后build会自动进行class-dump的操作，然后会在项目的目录下生成一个头文件的文件夹:

![image](https://camo.githubusercontent.com/d6382c6d61d992ea9c75c79eadb9376321a1238b/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313530313333383835303438352e706e67)

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#restore-symbol)restore-symbol

一般应用发布后调试堆栈是没有符号信息的，由于OC语言的特性，需要保存类名和方法名，所以可以根据具体方法的地址填写到符号表中还原符号表。 具体可以阅读文章 [iOS符号表恢复&逆向支付宝](http://blog.imjun.net/posts/restore-symbol-of-iOS-app/)

开启该功能的方式和class-dump一样。

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E6%96%B9%E6%B3%95%E8%B7%9F%E8%B8%AA%E6%97%A5%E5%BF%97)方法跟踪日志

增加对方法跟踪的日志打印，代替烦人的logify.pl，只需配置一下即可，在新建项目中找到MD

*   ENABLE: 设置为YES开启方法跟踪，默认为NO。
*   CLASS_LIST: 设置需要跟踪的类或指定的方法，如果是对整个类进行跟踪只用写类名，对类里面特定的方法需要在加一个Array数组加上方法名，参考默认的写法。

![](https://camo.githubusercontent.com/f788d6657c30d2df66ca2e374e669c6299707961/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f6d6574686f647472616365636f6e6669672e706e67)

主要代码来自qhd的[ANYMethodLog](https://github.com/qhd/ANYMethodLog)。

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E9%BB%98%E8%AE%A4%E9%9B%86%E6%88%90%E7%9A%84%E5%BA%93)默认集成的库

本工具会默认集成`RevealServer.framework`和`libcycript.dylib`,em…..

集成的`RevealServer.framework`是最新版本的，所以你可能需要最新的`Reveal`，否则使用自己的`RevealServer.framework`替换掉`/opt/MonkeyDev/frameworks`下面的`RevealServer.framework`。

使用Release编译生成将不会集成reveal和cycript。

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E5%A2%9E%E5%8A%A0%E8%87%AA%E5%B7%B1%E7%9A%84%E5%BA%93)增加自己的库

首先将需要注入的dylib或者framework按下面的方式拷贝到frameworks目录下:

![](https://camo.githubusercontent.com/d28fbce26d877dd39a95c499a07e697b3a688e69/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f575832303138303332382d3135353334362e706e67)

然后在下图的位置add进去，emmm。。。。就可以了。

![](https://camo.githubusercontent.com/eaac8c48a8ee615580cdcdcc0a15a6ec4f9065d8/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313439393837343837303437342e706e67)

静态库的话，直接增加到上面，指定`search path`就可以了，和正常开发没啥区别。。。

注意动态库本身的install_path，可以通过`install_name_tool -id`修改其为`@executable_path/Frameworks/xxxxx`

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E9%9B%86%E6%88%90%E7%BD%91%E7%BB%9Ccy%E8%84%9A%E6%9C%AC)集成网络cy脚本

通过配置CycriptConfig.plist可以导入从网络下载的cy脚本，比如通过如下的配置:

![image](https://camo.githubusercontent.com/4322bf51ab5994b882d795e633d9ccdc81412e75/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f6d64636f6e66696730322e706e67)

`LoadAtLaunch`表示是否在启动的时候的时候默认加载脚本，默认加载的脚本就不用再@import xxx导入，可以直接使用。如果不是默认加载的脚本就需要@import xxx导入，xxx就是图中的key，比如@import md。

`priority`表示加载的优先级，数字越小优先级越高，比如某些脚本需要依赖其它脚本就需要调整优先级，让被依赖的脚本先加载。

`content`和`url` 脚本可以直接写到`content`里面也可以是网络的`url`，会自动下载下来。

```
➜  cycript_0.9.594 ./cycript -r 192.168.2.248:6666
cy# APPID
@"com.alonemonkey.TestCycript"
cy# pviews()
`<UIWindow: 0x105313b60; frame = (0 0; 375 667); autoresize = W+H; gestureRecognizers = <NSArray: 0x1c425bae0>; layer = <UIWindowLayer: 0x1c40394e0>>
   | <UIView: 0x1053205d0; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x1c403bd80>>
   |    | <UILabel: 0x10531e7d0; frame = (102.5 45; 170 40); text = 'AloneMonkey'; opaque = NO; autoresize = RM+BM; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x1c408c0d0>>
   |    | <UILabel: 0x1053207b0; frame = (97.5 110; 180 40); text = 'You are the best!!!'; opaque = NO; autoresize = RM+BM; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x1c408e150>>
   |    | <UITextView: 0x105836000; frame = (26 230; 343 427); text = '/opt/MonkeyDev/bin/md

- ...'; clipsToBounds = YES; autoresize = RM+BM; gestureRecognizers = <NSArray: 0x1c0058fc0>; layer = <CALayer: 0x1c002f1a0>; contentOffset: {0, 0}; contentSize: {343, 317}; adjustedContentInset: {0, 0, 0, 0}>
   |    |    | <<_UITextContainerView: 0x105318060; frame = (0 0; 343 317); layer = <__UITextTiledLayer: 0x1c40c42f0>> minSize = {0, 0}, maxSize = {1.7976931348623157e+308, 1.7976931348623157e+308}, textContainer = <NSTextContainer: 0x1c0105fa0 size = (343.000000,inf); widthTracksTextView = YES; heightTracksTextView = NO>; exclusionPaths = 0x1c40025e0; lineBreakMode = 0>
   |    |    |    | <__UITileLayer: 0x1c0240780> (layer)
   |    |    |    | <__UITileLayer: 0x1c0240720> (layer)
   |    |    |    | <__UITileLayer: 0x1c0240a20> (layer)
   |    |    | <UIImageView: 0x105322260; frame = (3 421.5; 337 2.5); alpha = 0; opaque = NO; autoresize = TM; userInteractionEnabled = NO; layer = <CALayer: 0x1c403c620>>
   |    |    | <UIImageView: 0x105322490; frame = (337.5 380; 2.5 44); alpha = 0; opaque = NO; autoresize = LM; userInteractionEnabled = NO; layer = <CALayer: 0x1c403c6e0>>
   |    | <UIButton: 0x1053163b0; frame = (127.5 175; 120 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x1c4039aa0>>
   |    |    | <UIButtonLabel: 0x10540fcf0; frame = (2 6; 116.5 18); text = 'ShowChangeLog'; opaque = NO; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x1c0087b70>>
   |    | <_UILayoutGuide: 0x105320fa0; frame = (0 0; 0 20); hidden = YES; layer = <CALayer: 0x1c403bfe0>>
   |    | <_UILayoutGuide: 0x1053213a0; frame = (0 667; 0 0); hidden = YES; layer = <CALayer: 0x1c403bee0>>`
cy# pvcs()
"<CustomViewController 0x1053133f0>, state: appeared, view: <UIView 0x1053205d0>"
cy# pactions(#0x1053163b0)
"<CustomViewController: 0x1053133f0> showChangeLog:"
cy# rp(#0x1053163b0)
`<UIButton: 0x1053163b0; frame = (127.5 175; 120 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x1c4039aa0>>
<UIView: 0x1053205d0; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x1c403bd80>>
<CustomViewController: 0x1053133f0>
<UIWindow: 0x105313b60; frame = (0 0; 375 667); autoresize = W+H; gestureRecognizers = <NSArray: 0x1c425bae0>; layer = <UIWindowLayer: 0x1c40394e0>>
<UIApplication: 0x105406120>
<AppDelegate: 0x1c002b1a0>`
cy# ?exit

```

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E9%9B%86%E6%88%90frida)集成Frida

如果自己集成第三方现成SDK的库也是一样的步骤，不过需要注意修改`install path`:

```
install_name_tool -id @executable_path/Frameworks/xxxx.dylib xxxx.dylib

```

由于Frida的动态库太大了就没有默认集成在MonkeyDev，但是自己集成起来也是非常简单的就两步:

1.  从[FridaGadget.dylib](https://build.frida.re/frida/ios/lib/FridaGadget.dylib)下载动态库增加到App最后的Copy Files里面:

![image](https://camo.githubusercontent.com/b0b30b58e2e396bed1a766bf1768abf657b55fad/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313530353932343538343136392e706e67)

1.  将FridaGadget.dylib链接到MonkeyDev注入动态库的依赖里面:

![image](https://camo.githubusercontent.com/ebe2e03cb6acc3c6e67d65c7b8c9fc2bf3a1ee90/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313530353932343636313037392e706e67)

启动日志有: `Frida: Listening on 127.0.0.1 TCP port 27042` 就是集成成功。

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E5%A2%9E%E5%8A%A0%E8%B5%84%E6%BA%90)增加资源

把你需要嵌入的Bundle资源和storyboard拷贝到这个目录就可以了哦~

![](https://camo.githubusercontent.com/8260dad17fd0f85a3340340bfcbdb2d226164bc6/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f575832303137303731372d3136333134322e706e67)

upadte: 更新增加资源方式，直接往MonkeyApp里面增加资源即可，比如新建test.plist文件选择MonkeyApp的Target，保证要增加的资源在如下列表中:

![](https://camo.githubusercontent.com/e77a5ef9b2cbb1a5fb535a90044a962235d9d1b7/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f575832303137303930362d3134303834322e706e67)

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E6%9B%B4%E6%94%B9%E5%90%8D%E5%AD%97%E5%92%8Cbundleid)更改名字和bundleid

如果需要更改重签应用的显示名字和bundle id可以在Xcode设置即可，想使用原来的bundle id进行重签，设置build settings里面的MONKEYDEV_DEFAULT_BUNDLEID为YES。

![image](https://camo.githubusercontent.com/e886bd849d50e95b2c5d9fc61a61e5e5f69e7ed9/687474703a2f2f377874646c342e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7363726970745f313531363130323939373736362e706e67)

## [](https://github.com/AloneMonkey/MonkeyDev/wiki/%E9%9D%9E%E8%B6%8A%E7%8B%B1App%E9%9B%86%E6%88%90#%E7%94%9F%E6%88%90ipa)生成IPA

运行之后在源代码的LatestBuild目录双击createIPA.command即可生成IPA文件。

微博:

*   [Alone_Monkey](http://weibo.com/xiaoqing28)

博客:

*   [blogfshare](http://www.blogfshare.com/)
*   [alonemonkey](http://www.alonemonkey.com/)





## 参考


1. [iOS逆向工程之App脱壳 - 青玉伏案 - 博客园](http://www.cnblogs.com/ludashi/p/5725743.html)
2. [iOS逆向工程之Hopper+LLDB调试第三方App - 青玉伏案 - 博客园](https://www.cnblogs.com/ludashi/p/5730338.html)

### App


3. [sunweiliang/NeteaseMusicCrack: iOS网易云音乐 免VIP下载、去广告、去更新 无需越狱...](https://github.com/sunweiliang/NeteaseMusicCrack)
4. [iOS逆向-微信helloWorld | TKkk Notes](http://tkkk.fun/2017/03/19/%E9%80%86%E5%90%91-%E5%BE%AE%E4%BF%A1helloWorld/)
5. [Tyilo/insert_dylib: Command line utility for inserting a dylib load command into a Mach-O binary](https://github.com/Tyilo/insert_dylib)
