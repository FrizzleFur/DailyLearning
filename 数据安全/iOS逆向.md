# 一条命令完成砸壳

发表于 2018-01-30   |   分类于 [逆向 ](http://www.alonemonkey.com/categories/%E9%80%86%E5%90%91/)  |   [3 Comments](http://www.alonemonkey.com/2018/01/30/frida-ios-dump/#comments)

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

| 

1

 | 

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

 |

到此环境就配置好了，接下来就可以一键砸壳了！ (另当前python基于2.x的语法，先切换到python 2.x的环境

### [](http://www.alonemonkey.com/2018/01/30/frida-ios-dump/#%E4%B8%80%E9%94%AE%E7%A0%B8%E5%A3%B3 "一键砸壳")一键砸壳

最简单的方式直接使用./dump + 应用显示的名字即可，如下:

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

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

 | 

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