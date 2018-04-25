# iOSReveal

##  classdump

参考网址：[http://blog.csdn.net/majiakun1/article/details/52064435](https://link.jianshu.com?t=http://blog.csdn.net/majiakun1/article/details/52064435)
根据上面网址所说整理一下：
跟着下面的步骤走
1、打开`Terminal`，输入`mkdir ~/bin`，在当前用户根目录下创建一个bin目录；
2、把class-dump给拷贝到这个目录里，并赋予其可执行权限：

```
sudo chmod 777 /usr/local/bin/class-dump
```
再执行
mv class-dump ~/bin; chmod +x ~/bin/class-dump;
3、打开~/.bash_profile文件：vi ~/.bash_profile，在文件最上方加一行：
export PATH=$HOME/bin/:$PATH，
然后保存并退出（在英文输入法中依次按下esc和:（shift + ;，即冒号），然后输入wq，回车即可）;
4、在Terminal中执行source ~/.bash_profile;
5、上面的操作把~/bin路径给加入了环境变量，我们测试一下好不好用；

测试的结果：

```
localhost:bin zy$ class-dump
class-dump 3.5 (64 bit)
Usage: class-dump [options] <mach-o-file>

  where options are:
        -a             show instance variable offsets
        -A             show implementation addresses
        --arch <arch>  choose a specific architecture from a universal binary (ppc, ppc64, i386, x86_64, armv6, armv7, armv7s, arm64)
        -C <regex>     only display classes matching regular expression
        -f <str>       find string in method name
        -H             generate header files in current directory, or directory specified with -o
        -I             sort classes, categories, and protocols by inheritance (overrides -s)
        -o <dir>       output directory used for -H
        -r             recursively expand frameworks and fixed VM shared libraries
        -s             sort classes and categories by name
        -S             sort methods by name
        -t             suppress header in output, for testing
        --list-arches  list the arches in the file, then exit
        --sdk-ios      specify iOS SDK version (will look in /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS<version>.sdk
        --sdk-mac      specify Mac OS X version (will look in /Developer/SDKs/MacOSX<version>.sdk
        --sdk-root     specify the full SDK root path (or use --sdk-ios/--sdk-mac for a shortcut)

```

有啥错误希望各路大神指点，会尽快修改。



## 参考

* [iOS应用逆向工程资料汇总 - everettjf - 安全爱好者;面向性能编程;](https://everettjf.github.io/2018/01/15/ios-app-reverse-engineering-stuff/)
* [iOS 逆向工程资料整理](https://niyaoyao.github.io/2017/05/09/Learning-Reverse-From-Today-D4/)
* [逆向工程之当/usr/bin安装不了class-dump怎么办](https://www.jianshu.com/p/eeebb43a68b7)



