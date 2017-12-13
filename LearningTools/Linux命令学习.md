# Linux  Commands Learning

记录小白学习`Linux`的过程，如有错误，万望指正，感激不尽。
![zsh配合iterm2效果.png](http://upload-images.jianshu.io/upload_images/225323-5d4602aff38a4cf4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

start :`2017-05-01`
update : `2017-12-11`

>Linux 命令

### 常用命令

#### man命令
>常用工具命令 man命令是Linux下的帮助指令，通过man指令可以查看Linux中的指令帮助、配置文件帮助和编程帮助等信息。
> 语法 man(选项)(参数) 
  -a：在所有的man帮助手册中搜索；
  -f：等价于whatis指令，显示给定关键字的简短描述信息； 
  -P：指定内容时使用分页程序；
  -M：指定man手册搜索的路径。 
来自: [](http://man.linuxde.net/man)


* 不区分大小写智能提示。我是不喜欢大小写区分的那种人，所以用了 `zsh` 之后，经常按 `Tab` 进行提示。
此外按下 `tab` 键显示出所有待选项后，再按一次 `tab` 键，即进入选择模式，进入选择模式后，按 tab 切向下一个选项，按 `shift + tab` 键切向上一个选项，`ctrl+f/b/n/p` 可以向前后左右切换。
![](http://upload-images.jianshu.io/upload_images/225323-11c6c703424c4b1f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

`kill + 空格键 + Tab`键，列出运行的进程，要啥哪个进程不需要再知道 PID 了，当然了 `zsh`，提供了让你知道 PID 的方法：
比如输入：`kill vim`，再按下 `tab`，会变成：`kill 5643`

* `ls **/*`，分层级地列出当前目录下所有文件及目录，并递归目录
* `ls *.png` 查找当前目录下所有 png 文件
* `ls **/*.png` 递归查找

`zsh` 的目录跳转很智能，你无需输入 `cd` 就可直接输入路径即可。比如：`..` 表示后退一级目录，`../../ `表示后退两级，依次类推。
在命令窗口中输入：`d`，将列出当前 session 访问过的所有目录，再按提示的数字即可进入相应目录。

### Mac 常用命令(Unix)

#### 在Finder标题栏显示完整路径

在“终端”中输入下面的命令：
```
$ defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
$ killall Finder
```
#### killall process杀进程
`$ killall ProcessName`
* 杀进程神器，一些重要进程不建议用这个命令

#### 寻找文件`mdfind`命令

许多Linux用户都发现Linux下查找文件的方法在OS X上不好用。当然经典的Unix  `find` 命令总是可以，但既然OS X有杀手级搜索工具Spotlight，为什么不在命令行上也使用一下呢？ 

这就是  `mdfind` 命令了。Spotlight能做的查找，  `mdfind` 也能做。包括搜索文件的内容和元数据（metadata）。 

`mdfind` 还提供更多的搜索选项。例如  `-onlyin` 选项可以约束搜索范围为一个目录： 
`$ mdfind -onlyin ~/Documents essay`

#### `Unix`登录登出
Mac底层是Unix内核，可以登入登出Unix。
可以先用`who`命令查看当前登录的账户
1. `Logout `
2. `Login UserName`
如果有密码，会提示输入密码

### `Zsh` 命令

#### `ls` 命令

* `ls` 显示当前下面的文件及文件夹
* `ls -a` 显示当前目录下的所有文件及文件夹包括隐藏的.和..等
* `ls -al` 显示当前目录下的所有文件及文件夹包括隐藏的.和..等并显示详细信息，详细信息包括大小，属组，创建时间

#### 历史命令
1. 查找历史命令，今天发现很好用有木有：
`Ctr + R`,不用一个去查找了.（2017-05-19）╮(✪ω✪)╭
2. `histroy`命令
`histroy`会展示所有命令历史，可以`histroy n`展示n条历史命令。
3. 执行历史命令
* `!!`      显示上一条历史命令
* `!n`      显示第n条历史命令
* `!n:p`    打印第n条历史命令

#### 历史路径

`Zsh`中输入`$ d`加回车就可以查看历史文件路径，然后输入对应路径的编号就可以到对应路径中了，很方便有木有ヾ(o◕∀◕)ﾉ
![](http://upload-images.jianshu.io/upload_images/225323-3a8fb29f9a7740ae.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


####  取消命令 `q`
在`Zsh`中，如果输入错误想取消，或者取消当前的任务进程，比如下载等，可以输入`q`来实现取消。

#### `echo` 命令

创建一个txt，并写入内容
`$ echo "Text Content" >> fileName`
`$ echo "Hello." >> welcome.txt`

#### `vim` 命令

`$ vim filename`
然后点`i`进入编辑, 编辑完成按`Esc`退出编辑，然后点击`:`回到底部，输入`wq`+`Enter`保存退出

### 文件操作
参考[Unix常用命令](http://www.cnblogs.com/hjzhang/archive/2009/12/04/2043586.html)

#### 移动,拷贝
1. 文件移动
`$ mv filename path`
mv + 文件名 + 路径
2. 文件拷贝
`$ cp filename path`文件拷贝到path
如果要复制目录，需要加参数-r或-R
例如：`$cp /home/a.tar /home/demo`
`$cp –r /home/aaa /home/bbb` 其中aaa 、bbb均为目录。

#### 拷贝详解
[复制文件或目录命令：cp](http://www.kwx.gd/LinuxBase/Linux-cp.html)
【语法】cp[选项][参数]
【详解】cp命令用于将单个或多个源文件或文件目录，复制到目标文件或文件夹目录中。
【参数】

选项 | 相应功能
--- | ---
-a	| 功能等于同时使用-d -p -r。
-b	| 在复制文件或目录时，为每个已经存在的目标文件或目录创建备份。
-d	| 当复制带符号链接的对象时，不复制符号连接所指向的目标文件或目录。
-f	| 强制复制文件或目录，不提示任何信息。
-i	| 复制文件时，遇到同名文件或文件夹时提示确认
-l	| 不复制文件，建立源文件的快捷方式
-p	| 保留源文件或目录的所有者、所属组信息和权限属性。
-P	| 功能同等于-d
-r	| 复制目录及目录内的所有文件或子目录
-s	| 创建符号链接
-S	| 指定备份文件的扩展名
-u	| 在更新源文件或目标文件不存在的情况下才复制文件
-v	| 显示命令的执行详细过程
-x| 当源文件或目录所在的文件系统（如ext3），与目标文件或目录所在的文件系统相同的情况下才进行复制。
 --help	| 显示命令帮助信息。
--version	| 显示cp命令版本信息。

【说明】

关键词  | 介绍
 ----- | ----- 
源文件或目录	|被复制的文件或目录
目标文件或目录 |	被复制的文件或目录，所要到达的位置。

#### `rm` 删除
删除文件
`$ rm filename`
一、rmdir：删除一个空的目录
rm命令
用于删除文件或文件夹。具体语法为：rm + 路径 +文件名 。例如，要删除/home/long/manual.tar文件，用下面命令：$rm /home/long/manual.tar
如果要删除目录，用rm –r +路径+目录名 。例如：要删除/home/manual目录，用$rm –r /home/manual
注意：要删除一个文件或文件夹，首先要具有对这个文件夹的写权限。

1. `-v`选项：提示

```
 mkdir -v directoryName
```
   结果： 操作成功后都会有提示信息。
![](http://oc98nass3.bkt.clouddn.com/15130866514954.jpg)
   
2. 一次删除两个目录，用空格分开： 空目录1、空目录2

```
   rmdir directory1  directory2
```
   结果：一次删除了空目录1、2

3. `-p`选项：级联删除

eg1：   目录1122/1

```
   rmdir -p -v 1122/1
```
   结果：先删除1122/1，再删除1122。


eg2：   目录1122/1  1122/2

```
    rmdir -p -v 1122/1
```
    结果：删除1122/1,再删除1122时错误，因为此时1122不是空文件夹。


二、`rm` 删除文件或者目录

1. `-f`选项：不管目录下的文件存在不存在，都不给予提示（force强制）

    目录1122/1/a，1122/1为目录，a为文件

```
     rm -f 1122/1
```

     结果：提示1122/1为目录，不能删除


```
     rm 1122/1/a
```

     结果：成功，但是没有任何提示

```
     rm 1122/1/b
```

     结果：没有任何提示 
   
2. `-r`：删除此目录下的所有文件，但是此目录不删除

    目录：1122/1 1122/2

```
     rm -r -v 1122
```

     结果：删除1122/1  1122/22
 
3.组合删除:删除该目录以及该目录下的所有文件

   目录1122/1/a  1122/2

```
   rm -rf -v 1122
```

   结果：


## Bash 命令

[让你提升命令行效率的 Bash 快捷键](<https://linuxtoy.org/archives/bash-shortcuts.html>)

[Mac 命令行下编辑常用的快捷键](<http://notes.11ten.net/mac-command-line-editing-commonly-used-shortcut-keys.html>)

#### Mac 命令行操作命令

命令  | 介绍
--- | ---
# !!  | 上一条命令
# !-n  | 倒数第N条历史命令
# !-n:p  |  打印上一条命令（不执行）
# !?string？ |  最新一条含有“string”的命令
# !-n:gs/str1/str2/  | 将倒数第N条命令的str1替换为str2，并执行（若不加g,则仅替换第一个）
history  | 显示命令历史列表
Ctrl+l  | 清屏
Ctrl+w  | 剪切光标所在处之前的一个词（以空格、标点等为分隔符）
Ctrl+k  | 剪切命令行中光标所在处之后的所有字符（包括自身）
Ctrl+u  |  剪切命令行中光标所在处之前的所有字符（不包括自身）
Ctrl+h  | 删除光标所在处前一个字符
Ctrl+y  |  粘贴刚才所删除的字符
[Tab] = |  命令行自动补全
↑(Ctrl+p)  |  显示上一条命令
↓(Ctrl+n)  |  显示下一条命令
Ctrl+a  |  移动到当前行的开头
Ctrl+e |   移动到当前行的结尾

## Tool

### iTerm2

[iTerm2](<https://www.iterm2.com/)
[Mac item2常用快捷键是什么？iterm2 快捷键大全](<https://my.oschina.net/repine/blog/737641)
[iTerm 拯救你的Terminal(终端)](<http://www.jianshu.com/p/deb5c35ff141)

### 标签
 介绍 | 命令
--- | ---
新建标签： | command + t
关闭标签： | command + w
切换标签： | command + 数字 command + 左右方向键
切换全屏： | command + enter
查找： | command + f

### 分屏
 介绍 | 命令
--- | ---
查看历史命令： | command + ;
查看剪贴板历史： | command + shift + h
垂直分屏： | command + d
水平分屏： | command + shift + d
切换屏幕： | command + option + 方向键 command + [ 或 command + ]

### 其他
 介绍 | 命令
--- | ---
清除当前行： | ctrl + u
到行首： | ctrl + a
到行尾： | ctrl + e
前进后退： | ctrl + f/b (相当于左右方向键)
上一条命令： | ctrl + p
搜索命令历史： | ctrl + r
删除当前光标的字符： | ctrl + d
删除光标之前的字符： | ctrl + h
删除光标之前的单词： | ctrl + w
删除到文本末尾： | ctrl + k
交换光标处文本： | ctrl + t
清屏1： | command + r
清屏2： | ctrl + l

### 自带有哪些很实用的功能/快捷键

 命令 | 介绍
--- | ---
⌘ +  | 数字在各 tab 标签直接来回切换
选择即复制 + 鼠标中键 | 粘贴，这个很实用
⌘ + f  | 所查找的内容会被自动复制
⌘ + d  | 横着分屏 / ⌘ + shift + d 竖着分屏
⌘ + r = clear， | 而且只是换到新一屏，不会想 clear 一样创建一个空屏
ctrl + u  | 清空当前行，无论光标在什么位置
输入开头命令后 按 ⌘ + ;  | 会自动列出输入过的命令
⌘ + shift + h  | 会列出剪切板历史

#### 补充

可以在 `Preferences > keys` 设置全局快捷键调出 iterm，这个也可以用过 Alfred 实现

我常用的一些快捷键
⌘ + 1 / 2 左右 tab 之间来回切换，这个在 前面 已经介绍过了

⌘← / ⌘→ 到一行命令最左边/最右边 ，这个功能同 C+a / C+e

⌥← / ⌥→ 按单词前移/后移，相当与 C+f / C+b，其实这个功能在Iterm中已经预定义好了，⌥f / ⌥b，看个人习惯了

当然除了这些可以自定义的也不能忘了 linux 下那些好用的组合
 命令 | 介绍
--- | ---
C+a / C+e  | 这个几乎在哪都可以使用
C+p / !!  | 上一条命令
C+k  | 从光标处删至命令行尾 (本来 C+u 是删至命令行首，但iterm中是删掉整行)
C+w A+d  | 从光标处删至字首/尾
C+h C+d  | 删掉光标前后的自负
C+y  | 粘贴至光标后
C+r  | 搜索命令历史，这个较常用

### iTerm2 常用快捷键
#### 快捷键介绍

命令  | 介绍
--- | ---
输入的命令开头字符 + Command + ; | 	根据输入的前缀历史记录自动补全
Command + ;	 |  根据历史记录自动补全
Command + [ 或 command + ]	 | 切换屏幕
Command + enter	 | 进入全屏模式，再按一次返回
Command + 鼠标单击 | 	可以打开文件，文件夹和链接（iTerm2 是可以对显示的内容进行点击的哦）
Command + n	 |  新建新的 Window 窗口
Command + t      | 	新建标签页
Command + w	 | 关闭当前标签或是窗口
Command + d	 | 竖直分屏
Command + r	     | 清屏
Command + /	     | 按完之后，整个屏幕变成白茫茫的，而光标位置是一个小圆圈清除显示出来
Command + 方向键	 | 切换标签页
Command + 数字 | 	切换到指定数字标签页
Command + f	 | 查找，所查找的内容会被自动复制 ,输入查找的部分字符，找到匹配的值按 tab，即可复制，带有补全功能
Command + option + e | 	全屏并排展示所有已经打开的标签页，带有可以搜索。
Command + Option + b | 历史回放，i类似视频录像的东西，有记录你最近时间内的操作。有一个类似播放器的进度条可以拖动查看你做了什么。存放内容设置（Preferences -> Genernal -> Instant Replay）。
Command + Option + 数字	 | 切换 Window 窗口
Command + shift + d	 | 水平分屏
Command + shift + h | 	查看剪贴板历史，在光标位置下方会出现一列你输入过的历史记录
Command + Shift + m	 | 可以保存当前位置，之后可以按Command + Shift + j跳回这个位置。
Command + shift + alt + w	 | 关闭所有窗口
Control + u	 | 清空当前行，无论光标在什么位置
Control + a	 | 移动到行首
Control + e	 | 移动到行尾
Control + f	 | 向前移动，相当于方向键右
Control + b	 | 向后移动，相当于方向键左
Control + p	 | 上一条命令，相当于方向键上
Control + n	 | 下一条命令，相当于方向键下
Control + r	 | 搜索历史命令
Control + y	 | 召回最近用命令删除的文字
Control + h	 | 删除光标之前的字符
Control + d	 | 删除光标所在位置的字符
Control + w	 | 删除光标之前的单词
Control + k	 | 删除从光标到行尾的内容
Control + c	 | 结束当前状态，另起一行
Control + t	 | 交换光标和之前的字符

## OnMyZch

![](http://upload-images.jianshu.io/upload_images/225323-9f80c1d60073bd39.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

[`oh-my-Zsh`](<https://github.com/robbyrussell/`oh-my-Zsh`)

### zsh切换bash bash切换zsh
1. `zsh`切换`bash`
`chsh -s /bin/bash`
2. `bash`切换`zsh`
`chsh -s /bin/zsh`

### 安装 `Zsh` + `oh-my-Zsh`

`Zsh` 官网：<https://www.`Zsh`.org/>
`oh-my-Zsh` 官网：<http://ohmyz.sh/>
先说下：`Zsh` 和 `oh-my-Zsh` 的关系
`Zsh` 是 Shell 中的一种，什么 Shell 你可以再搜索下，简单粗暴讲就是一个：命令解释器，你输入什么命令，它就执行什么，这个东西再 Unix 世界还有其他几个。
由于 `Zsh` 配置门槛有点高，或者说需要专门花时间去了解 `Zsh` 才能配置好一个好用的 `Zsh`，也因为这样，用户也就相对少了。
直到有一天 `oh-my-Zsh` 的作者诞生，他想要整理出一个配置框架出来，让大家直接使用他的这个公认最好的 `Zsh` 配置，省去繁琐的配置过程。所以，`oh-my-Zsh` 就诞生了，它只是会了让你减少 `Zsh` 的配置，然后又可以好好享受 `Zsh` 这个 Shell。
Mac 和一般 Linux 默认的 shell 是 bash，一般人都觉得不好用，我作为一般人，也喜欢 `Zsh`，所以这里就用 `Zsh`。
为了简化配置 `Zsh` 过程，我们这里选择 `oh-my-Zsh` 这个配置库，这是目前大家公认好用的配置。
打开终端，先安装 git（已经安装的跳过该步骤），输入命令：`brew install git`
打开终端，安装 wget 工具，输入命令：`brew install wget`
打开终端，安装 `Zsh`：`brew install Zsh`
打开终端，安装 `oh-my-Zsh`：`sh -c "$(wget <https://raw.githubusercontent.com/robbyrussell/oh-my-Zsh/master/tools/install.sh -O -)"`
下载完后，会提示你输入当前登录系统的用户密码，输入完成之后就会从 bash 切换到 `Zsh`，如果你没有输入密码直接跳过了，可以运行该命令进行手动切换：`chsh -s /bin/Zsh` 你当前系统用户名
切换完成之后，关掉终端，重新打开终端即可
如果你需要修改 `oh-my-Zsh` 的主题，和安装 `Zsh` 插件，具体可以看我过去整理的这篇文章：`Zsh` 

#### `Zsh` 软件特色

不区分大小写智能提示。我是不喜欢大小写区分的那种人，所以用了 `Zsh` 之后，经常按 `Tab` 进行提示。
此外按下 tab 键显示出所有待选项后，再按一次 `tab` 键，即进入选择模式，进入选择模式后，按 `tab` 切向下一个选项，按 `shift + tab` 键切向上一个选项，`ctrl+f/b/n/p` 可以向前后左右切换。
`kill` + 空格键 + `Tab`键，列出运行的进程，要啥哪个进程不需要再知道 PID 了，当然了 `Zsh`，提供了让你知道`PID` 的方法：
比如输入：`kill vim`，再按下 `tab`，会变成：`kill 5643`
`ls **/*`，分层级地列出当前目录下所有文件及目录，并递归目录
`ls *.png` 查找当前目录下所有 png 文件
`ls **/*.png` 递归查找
`Zsh` 的目录跳转很智能，你无需输入 cd 就可直接输入路径即可。比如：.. 表示后退一级目录，../../ 表示后退两级，依次类推。
在命令窗口中输入：d，将列出当前 `session` 访问过的所有目录，再按提示的数字即可进入相应目录。
给 man 命令增加结果高亮显示：
编辑配置文件：`vim ~/.Zshrc`，增加下面内容：

```
# man context highlight
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
```

刷新配置文件：source ~/.zshrc，重新查看 man 的命令就可以有高亮了。

### 2.7.更新oh-my-zsh
[Linux终极shell-Z Shell-用强大的zsh & oh-my-zsh把Bash换掉](http://www.linuxdiyf.com/linux/24777.html)
默认情况下, 您将被提示检查每几周的升级. 如果你想我ZSH自动升级本身没有提示你, 修改`~/.zshrc
disable_update_prompt = true
禁用自动升级, 修改~/.zshrc
disable_auto_update = true
当然你也可以选择手动更新
如果你想在任何时间点升级（也许有人刚刚发布了一个新的插件，你不想等待一个星期？)你只需要运行：
upgrade_oh_my_zsh
 
2.8.卸载oh-my-zsh
如果你想卸载oh-my-zsh, 只需要执行uninstall_oh_my_zsh zsh， 从命令行运行. 这将删除本身和恢复你以前的bash或者zsh配置.
uninstall_oh_my_zsh zsh
 
3.更多任性的功能, 速度来感受吧
1]兼容 bash，原来使用 bash 的兄弟切换过来毫无压力，该咋用咋用。
2]强大的历史纪录功能，输入 grep 然后用上下箭头可以翻阅你执行的所有 grep 命令。
3]智能拼写纠正，输入gtep mactalk * -R，系统会提示：zsh: correct ‘gtep’ to ‘grep’ [nyae]? 比妹纸贴心吧，她们向来都是让你猜的……
4]各种补全：路径补全、命令补全，命令参数补全，插件内容补全等等。触发补全只需要按一下或两下 tab 键，补全项可以使用 ctrl+n/p/f/b上下左右切换。比如你想杀掉 java 的进程，只需要输入 kill java + tab键，如果只有一个 java 进程，zsh 会自动替换为进程的 pid，如果有多个则会出现选择项供你选择。ssh + 空格 + 两个tab键，zsh会列出所有访问过的主机和用户名进行补全
5]智能跳转，安装了autojump之后，zsh 会自动记录你访问过的目录，通过 j + 目录名 可以直接进行目录跳转，而且目录名支持模糊匹配和自动补全，例如你访问过hadoop-1.0.0目录，输入j hado 即可正确跳转。j –stat 可以看你的历史路径库。
6]目录浏览和跳转：输入 d，即可列出你在这个会话里访问的目录列表，输入列表前的序号，即可直接跳转。
7]在当前目录下输入 .. 或 … ，或直接输入当前目录名都可以跳转，你甚至不再需要输入 cd 命令了。
8]通配符搜索：ls -l */.sh，可以递归显示当前目录下的 shell 文件，文件少时可以代替 find，文件太多就歇菜了。
9]更强的别名
10]插件支持

### 配置pure(refined)主题

1. 首先，显示隐藏文件，进入`oh-my-zsh`文件的自定义目录，`$ .oh-my-zsh/custom/`，创建一个`theme`文件夹，存放你自定义的`theme`.
![](http://upload-images.jianshu.io/upload_images/225323-e790e5e27a651523.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
（`pure`已经在默认主题中，只需要引用）

2. `pure`的改名警告⚠️
![](http://upload-images.jianshu.io/upload_images/225323-0df914ed283fcaa2.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
`pure`的作者把名字改成了“refined”，把`.zshrc`文件的`ZSH_THEME`改成“refined”.就可以了
![](http://upload-images.jianshu.io/upload_images/225323-2c47cfe2952ada19.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](http://upload-images.jianshu.io/upload_images/225323-a91c6f360ab8f311.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 配置[`spaceship`](https://github.com/denysdovhan/spaceship-zsh-theme)主题

![](http://upload-images.jianshu.io/upload_images/225323-1574a71d992ad02d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### `.zshrc`文件的引号问题
报错：`/Users/xxx/.oh-my-zsh/oh-my-zsh.sh:source:110: no such file or directory: /Users/xxx/.oh-my-zsh/themes/”refined”.zsh-theme`
其实是因为" 变成-> “了， 自己打上去会被改成“，修改为"。
![](http://upload-images.jianshu.io/upload_images/225323-82841e69f8ea0fe6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


#### iterm2-snazzy
Elegant iTerm2 theme with bright colors
[iterm2-snazzy](https://github.com/sindresorhus/iterm2-snazzy)
![](http://upload-images.jianshu.io/upload_images/225323-1f9449cf9e766fbc.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
>To get the exact same look as in the screenshot, you need to use the `[Pure prompt](https://github.com/sindresorhus/pure)`, `Menlo font`, and the `[zsh-syntax-highlighting plugin](https://github.com/zsh-users/zsh-syntax-highlighting)` to have commands highlighted.
记得在`iterm2`的颜色切换成`snazzy`
![](http://upload-images.jianshu.io/upload_images/225323-d88bdb6295e3729c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### `zsh-syntax-highlighting`问题

1.首先cd 到 `Users/USERNAME/.oh-my-zsh/custom/plugins`
执行`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git`
![](http://upload-images.jianshu.io/upload_images/225323-1af638c46306d582.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 配置`.zshrc`文件
`plugins=(zsh-syntax-highlighting)`
`source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`
![](http://upload-images.jianshu.io/upload_images/225323-ebe8e87deba7fcfe.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3. 最后执行配置
执行 `source ~/.zshrc`

### Resource其他资源

#### `Zsh`插件 Plugins
![](http://oc98nass3.bkt.clouddn.com/15129592017167.jpg)
[Awesome-Zsh-Plugins](https://github.com/unixorn/awesome-zsh-plugins)插件库

####  IDE
![](http://oc98nass3.bkt.clouddn.com/15129591787875.jpg)
[Hyper](https://hyper.is/)一个轻量简洁的终端

### 参考资料

1. [一个Java程序员眼中的Mac OS（系列六：终端方案iTerm2 + Zsh）](http://www.jianshu.com/p/e7af448d01b0)
2. [Mac 终端命令大全](<http://www.jianshu.com/p/3291de46f3ff)
3. [iTerm2 - Mac 开发配置手册 - 极客学院Wiki](http://wiki.jikexueyuan.com/project/mac-dev-setup/iterm.html)
4. [你应该知道的 iTerm2 使用方法--MAC终端工具](http://wulfric.me/2015/08/iterm2/)
5. [iTerm - 让你的命令行也能丰富多彩 - SwiftCafe 享受代码的乐趣](http://swiftcafe.io/2015/07/25/iterm/)
6.  [Terminal 代理方案 - 杨辉的个人博客](http://yanghui.name/blog/2015/07/19/make-all-command-through-proxy/)
7. [Mac下iTerm2＋Tmux配置 - Karrdy - SegmentFault](https://segmentfault.com/a/1190000003001555)
8. [我的tmux配置及说明【k-tmux】](http://www.wklken.me/posts/2015/08/06/linux-tmux.html)
9.  [Mac 下配置终端环境 iTerm2 + Zsh + Oh My Zsh + tmux | 明无梦](http://www.dreamxu.com/mac-terminal/)
10. [Tmux - Linux从业者必备利器 • cenalulu's Tech Blog](http://cenalulu.github.io/linux/tmux/)
11. [linux下的终端利器----tmux - CSDN博客](http://blog.csdn.net/gatieme/article/details/49301037)
12. [Tmux 入门介绍 - 文章 - 伯乐在线](http://blog.jobbole.com/87278/)
13. [Linux终极shell-Z Shell-用强大的zsh & oh-my-zsh把Bash换掉](http://www.linuxdiyf.com/linux/24777.html)

