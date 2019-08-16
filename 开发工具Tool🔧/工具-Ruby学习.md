# 工具-Ruby学习

 时间 |  备注
 --- | --- 
`2019-07-13` | start

> 记录小白学习`Ruby`的过程。




## Gem源

由于团队协同开发，如果每个人的ruby版本或者pod版本不一致时，会导致每个人的Podfile.lock 文件不一致，就需要重新执行 pod install ，重新编译项目，比较麻烦。故将版本进行了一次统一。
在升级的过程中，主要发现了两个问题：


由于国内网络原因（你懂的），导致 rubygems.org 存放在 Amazon S3 上面的资源文件间歇性连接失败。所以你会与遇到 gem install rack 或 bundle install的时候半天没有响应，具体可以用 gem install rails -V 来查看执行过程。

Gem源地址的域名由 .org 变成了 .com
安装ruby遇到请求失败的问题



### 详细步骤

```linux
升级Gem（可以跳过）

# 更新Gem版本（这里需要翻墙）
$ gem update --system
# 检查版本
$ gem -v
2.7.7

更换Gem源

# 移除旧的源
$ gem sources --remove https://gems.ruby-china.org/
# 添加新的源
$ gem sources -a https://gems.ruby-china.com/
# 查看当前源
$ gem sources -l
*** CURRENT SOURCES ***

https://gems.ruby-china.com
# 确保只有 gems.ruby-china.com

安装或升级rvm（已经安装可以跳过）

# 如果未安装rvm
$ curl -sSL https://get.rvm.io | bash -s stable
# 然后，载入 RVM 环境
$ source ~/.rvm/scripts/rvm
# 检查版本
$ rvm -v
rvm 1.29.4 (latest) by Michal Papis, Piotr Kuczynski, Wayne E. Seguin [https://rvm.io]

# 如果已经安装rvm，想更新
$ rvm get stable

安装ruby

# 安装指定版本ruby，这个过程会比较慢
$ rvm install 2.5.1 
# 检查版本
$ ruby -v
ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-darwin18
```


## 问题

### Ruby的路径读取


原因： Mac自带Ruby环境是ruby 2.3.0.和目前工程EEScaffold设置的pod编译要求的的ruby版本V2.5.1不匹配，路径需要在.zshrc中重新指定，或者RVM的配置不对。
使用`rvm list`检查当前的ruby和现在是否对齐，注意ruby的默认和当前需要一致，不然读取的路径path不一致导致出错。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713171906.png)


the thing is that RVM only sets the environemnt, ther is no involvment of RVM when executing anything else, when you run ruby or gem there is no RVM involvment already - so it can not be checked if the environment is "properly configured"

事情是RVM只设置environemnt，在执行任何其他操作时不是RVM的参与，当你运行ruby或gem时，已经没有RVM参与 - 所以无法检查环境是否“正确配置”
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713172119.png)

[Feature request: rvm get head could check all $PATH items vs rvm default · Issue #3212 · rvm/rvm](https://github.com/rvm/rvm/issues/3212)

#### 解决方案

安装了Zsh后也有很多同学的path设置错了，导致Ruby安装出错。
[Received Warning message "Path set to RVM" after updating ruby version using rvm - Stack Overflow](https://stackoverflow.com/questions/27784961/received-warning-message-path-set-to-rvm-after-updating-ruby-version-using-rvm)

我发现最高票的答案是

```linux
I had same issue with oh-my-zsh While installing rvm with option --rails, there was this warning:

This solution works for me: Open .zshrc file, and find PATH line

change

export PATH=/path/to/something

into

export PATH="$PATH:/path/to/something"

save it and do source ~/.zshrc, Then it worked.

```

另一个篇也提到，需要将路径修改好

[ruby - RVM警告！ PATH未正确设置 - Stack Overflow](https://stackoverflow.com/questions/22650731/rvm-warning-path-is-not-properly-set-up)

```linux
In my case, Heroku had added the following to my .bashrc:

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
Notice how it's prepending itself to the path. All I had to do was switch it around to:

### Added by the Heroku Toolbelt
export PATH="$PATH:/usr/local/heroku/bin"
And my problem was solved!
```


既然是Path出了问题，我看下zsh中ruby有没有path问题，突然发现，配置flutter的路径有问题。需要改成"$PATH"的形式。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713173504.png)

原来的不仔细，太随意的书写✍️造成了很大问题，做事需认真，好习惯收益终生啊。


还有人在.zshrc的top添加下面的路径，解决了报错，不太理解这种方式。
```linux
After adding [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
to the top of ~/.zshrc rather than the bottom I can confirm this has solved the issue for me. Thanks!
```


使用`rvm get head`更新rvm?

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713172232.png)


[Warning! PATH is not properly set up, $GEM_HOME is not set #3682](https://github.com/rvm/rvm/issues/3682)


```linux
Warning! PATH is not properly set up, $GEM_HOME is not set.
         Usually this is caused by shell initialization files. Search for PATH=... entries.
                  You can also re-add RVM to your profile by running: rvm get stable --auto-dotfiles
         To fix it temporarily in this shell session run: rvm use ruby-2.5.1
         To ignore this error add rvm_silence_path_mismatch_check_flag=1 to your ~/.rvmrc file.
Warning, new version of rvm available '1.29.9', you are using older version '1.29.8'.
You can disable this warning with:    echo rvm_autoupdate_flag=0 >> ~/.rvmrc
You can enable  auto-update  with:    echo rvm_autoupdate_flag=2 >> ~/.rvmrc

Warning! PATH is not properly set up, :/Users/mac/.rvm/bin/bin is not available.
```


### Path is not at first place

```linux
Warning! PATH is not properly set up, /Users/mac/.rvm/gems/ruby-2.5.1@global/bin is not at first place.
         Usually this is caused by shell initialization files. Search for PATH=... entries.
         You can also re-add RVM to your profile by running: rvm get stable --auto-dotfiles
         To fix it temporarily in this shell session run: rvm use ruby-2.5.1@global
         To ignore this error add rvm_silence_path_mismatch_check_flag=1 to your ~/.rvmrc file.
Downloading https://get.rvm.io
No GPG software exists to validate rvm-installer, skipping.
```

#### 解决方案

[Warning! PATH is not properly set up · Issue #4306 · rvm/rvm](https://github.com/rvm/rvm/issues/4306)

我先使用了建议的命令
```linux
rvm get stable --auto-dotfiles
```

发现not work,后面我尝试

```linux
rvm reset
```
切换到System的V2.3.0版本，但是这样工程就对不上了。所以我最后用

```linux
rvm use ruby-2.5.1
```
指定ruby为当前的路径，不知道这是不是临时的方案。目前看来，worked.


### NoMethodError - undefined method `size' for nil:NilClass

```linux
Looking for related issues on cocoapods/cocoapods...
 - NoMethodError - undefined method `size' for nil:NilClass
   https://github.com/CocoaPods/CocoaPods/issues/8377 [closed] [2 comments]
```

仍然在查找中。。。。


## 参考

* [Pod、Ruby环境升级记录 - 简书](https://www.jianshu.com/p/5d489106fe6c)
* [RubyChina：](https://gems.ruby-china.com/)
* [Ruby官网：](https://www.ruby-lang.org/zh_cn/)
* [CocoaPods官网：](https://cocoapods.org/)