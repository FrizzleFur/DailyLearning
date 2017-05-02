# Linux Learning

记录小白学习`Linux`的过程，如有错误，万望指正，感激不尽。

`2017-05-01`

>Linux 命令
>
### 一些常用`Linux` 命令
#### `ls` 命令
ls 显示当前下面的文件及文件夹
ls -a 显示当前目录下的所有文件及文件夹包括隐藏的.和..等
ls -al 显示当前目录下的所有文件及文件夹包括隐藏的.和..等并显示详细信息，详细信息包括大小，属组，创建时间

#### `echo` 命令

创建一个txt，并写入内容
`$ echo "Text Content" >> fileName`
`$ echo "Hello." >> welcome.txt`

#### `vim` 命令

`$ vim filename`
然后点`i`进入编辑, 编辑完成按`Esc`退出编辑，然后点击`:`回到底部，输入`wq`+`Enter`保存退出

#### `rm` 删除命令
删除文件
`$ rm filename`


## Bash 命令

[让你提升命令行效率的 Bash 快捷键](https://linuxtoy.org/archives/bash-shortcuts.html)

[Mac 命令行下编辑常用的快捷键](http://notes.11ten.net/mac-command-line-editing-commonly-used-shortcut-keys.html)
Mac 命令行编辑快捷键的方法，对Mac的应用有所帮助。

Mac 命令行命令
history 显示命令历史列表
[Tab] =命令行自动补全
↑(Ctrl+p) 显示上一条命令
↓(Ctrl+n) 显示下一条命令
clear 清除 shell 提示屏幕
exit 注销
history 显示命令历史
reset 刷新 shell 提示屏幕
Mac 命令行编辑快捷键
↑(Ctrl+p) 显示上一条命令
↓(Ctrl+n) 显示下一条命令
!num 执行命令历史列表的第num条命令
!! 执行上一条命令
!?string? 执行含有string字符串的最新命令
Ctrl+r 然后输入若干字符，开始向上搜索包含该字符的命令，继续按Ctrl+r，搜索上一条匹配的命令
Ctrl+s 与Ctrl+r类似,只是正向检索
Ctrl+f 光标向前移动一个字符,相当与->
Ctrl+b 光标向后移动一个字符,相当与<-
opt+<\- 光标向前移动一个单词
opt+-> 光标向后移动一个单词
ls !$ 执行命令ls，并以上一条命令的参数为其参数
Ctrl+a 移动到当前行的开头
Ctrl+e 移动到当前行的结尾
Esc+b 移动到当前单词的开头
Esc+f 移动到当前单词的结尾
Ctrl+l 清屏
Ctrl+u 剪切命令行中光标所在处之前的所有字符（不包括自身）
Ctrl+k 剪切命令行中光标所在处之后的所有字符（包括自身）
Ctrl+d 删除光标所在处字符
Ctrl+h 删除光标所在处前一个字符
Ctrl+y 粘贴刚才所删除的字符
Ctrl+w 剪切光标所在处之前的一个词（以空格、标点等为分隔符）
Ctrl+t 颠倒光标所在处及其之前的字符位置，并将光标移动到下一个字符
Ctrl+v 插入特殊字符,如Ctrl+v+Tab加入Tab字符键
Esc+t 颠倒光标所在处及其相邻单词的位置
Ctrl+c 删除整行
Ctrl+(x u) 按住Ctrl的同时再先后按x和u，撤销刚才的操作
Ctrl+s 挂起当前shell
Ctrl+q 重新启用挂起的shell
下面的应用可能稍稍高级一点点

```
# !! - 上一条命令
# !-n - 倒数第N条历史命令
# !-n:p - 打印上一条命令（不执行）
# !?string？- 最新一条含有“string”的命令
# !-n:gs/str1/str2/ - 将倒数第N条命令的str1替换为str2，并执行（若不加g,则仅替换第一个）
```




## Tool

### iTerm2

[iTerm2](https://www.iterm2.com/)

[Mac item2常用快捷键是什么？iterm2 快捷键大全](https://my.oschina.net/repine/blog/737641)

[iTerm 拯救你的Terminal(终端)](http://www.jianshu.com/p/deb5c35ff141)

标签

新建标签：command + t

关闭标签：command + w

切换标签：command + 数字 command + 左右方向键

切换全屏：command + enter

查找：command + f

分屏

垂直分屏：command + d

水平分屏：command + shift + d

切换屏幕：command + option + 方向键 command + [ 或 command + ]

查看历史命令：command + ;

查看剪贴板历史：command + shift + h

其他

清除当前行：ctrl + u

到行首：ctrl + a

到行尾：ctrl + e

前进后退：ctrl + f/b (相当于左右方向键)

上一条命令：ctrl + p

搜索命令历史：ctrl + r

删除当前光标的字符：ctrl + d

删除光标之前的字符：ctrl + h

删除光标之前的单词：ctrl + w

删除到文本末尾：ctrl + k

交换光标处文本：ctrl + t

清屏1：command + r

清屏2：ctrl + l

自带有哪些很实用的功能/快捷键

⌘ + 数字在各 tab 标签直接来回切换

选择即复制 + 鼠标中键粘贴，这个很实用

⌘ + f 所查找的内容会被自动复制

⌘ + d 横着分屏 / ⌘ + shift + d 竖着分屏

⌘ + r = clear，而且只是换到新一屏，不会想 clear 一样创建一个空屏

ctrl + u 清空当前行，无论光标在什么位置

输入开头命令后 按 ⌘ + ; 会自动列出输入过的命令

⌘ + shift + h 会列出剪切板历史

可以在 Preferences > keys 设置全局快捷键调出 iterm，这个也可以用过 Alfred 实现

我常用的一些快捷键

⌘ + 1 / 2 左右 tab 之间来回切换，这个在 前面 已经介绍过了

⌘← / ⌘→ 到一行命令最左边/最右边 ，这个功能同 C+a / C+e

⌥← / ⌥→ 按单词前移/后移，相当与 C+f / C+b，其实这个功能在Iterm中已经预定义好了，⌥f / ⌥b，看个人习惯了

好像就这几个。。囧

设置方法如下

当然除了这些可以自定义的也不能忘了 linux 下那些好用的组合

C+a / C+e 这个几乎在哪都可以使用

C+p / !! 上一条命令

C+k 从光标处删至命令行尾 (本来 C+u 是删至命令行首，但iterm中是删掉整行)

C+w A+d 从光标处删至字首/尾

C+h C+d 删掉光标前后的自负

C+y 粘贴至光标后

C+r 搜索命令历史，这个较常用

选择喜欢的配色方案。

在Preferences->Profiles->Colors的load presets可以选择某个配色方案，大家自己选择吧


## OnMyZch
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

