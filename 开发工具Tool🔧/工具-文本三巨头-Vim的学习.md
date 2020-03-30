# 工具-Vim的学习

> 其实，对vim和emacs这样的工具来说，它们最强大之处，在于它们的可定制性。由于它们的可定制性，你完全可以定制出一个符合你自己编辑习惯的编辑器，在这样一个编辑器里，你的工作效率将达到最高。当然，要达到这样的境界，你需要付出非常坚苦的努力！如果你的工作是以文本编辑为主，例如，你是一个程序员，那么付出这种努力是值得的，也是有回报的。如果你没有很多文本编辑工作要做，那么也没有必要耗费这么大的力气，来学习这些工具。

[yangyangwithgnu/use_vim_as_ide: use vim as IDE](https://github.com/yangyangwithgnu/use_vim_as_ide)

## Vim快捷键

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190609123347.png)

## vi/vim 的使用

基本上 vi/vim 共分为三种模式，分别是**命令模式（Command mode）**，**输入模式（Insert mode）**和**底线命令模式（Last line mode）**。 这三种模式的作用分别是：

### 命令模式：

用户刚刚启动 vi/vim，便进入了命令模式。

此状态下敲击键盘动作会被Vim识别为命令，而非输入字符。比如我们此时按下i，并不会输入一个字符，i被当作了一个命令。

以下是常用的几个命令：

*   **i** 切换到输入模式，以输入字符。
*   **x** 删除当前光标所在处的字符。
*   **:** 切换到底线命令模式，以在最底一行输入命令。

若想要编辑文本：启动Vim，进入了命令模式，按下i，切换到输入模式。

命令模式只有一些最基本的命令，因此仍要依靠底线命令模式输入更多命令。

### 输入模式

在命令模式下按下i就进入了输入模式。

在输入模式中，可以使用以下按键：

*   **字符按键以及Shift组合**，输入字符
*   **ENTER**，回车键，换行
*   **BACK SPACE**，退格键，删除光标前一个字符
*   **DEL**，删除键，删除光标后一个字符
*   **方向键**，在文本中移动光标
*   **HOME**/**END**，移动光标到行首/行尾
*   **Page Up**/**Page Down**，上/下翻页
*   **Insert**，切换光标为输入/替换模式，光标将变成竖线/下划线
*   **ESC**，退出输入模式，切换到命令模式

### 底线命令模式

在命令模式下按下:（英文冒号）就进入了底线命令模式。

底线命令模式可以输入单个或多个字符的命令，可用的命令非常多。

在底线命令模式中，基本的命令有（已经省略了冒号）：

*   q 退出程序
*   w 保存文件

按ESC键可随时退出底线命令模式。

简单的说，我们可以将这三个模式想成底下的图标来表示：


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190609123546.png)


* `vimtutor`命令会显示vim的使用文档

## vi/vim 按键说明

除了上面简易范例的 i, Esc, :wq 之外，其实 vim 还有非常多的按键可以使用。

### 第一部份：一般模式可用的光标移动、复制粘贴、搜索替换等

| 移动光标的方法 | |
| ---  | --- |
| h 或 向左箭头键(←) | 光标向左移动一个字符 |
| j 或 向下箭头键(↓) | 光标向下移动一个字符 |
| k 或 向上箭头键(↑) | 光标向上移动一个字符 |
| l 或 向右箭头键(→) | 光标向右移动一个字符 |
| 如果你将右手放在键盘上的话，你会发现 hjkl 是排列在一起的，因此可以使用这四个按钮来移动光标。 如果想要进行多次移动的话，例如向下移动 30 行，可以使用 "30j" 或 "30↓" 的组合按键， 亦即加上想要进行的次数(数字)后，按下动作即可！ |
| [Ctrl] + [f] | 屏幕『向下』移动一页，相当于 [Page Down]按键 (常用) |
| [Ctrl] + [b] | 屏幕『向上』移动一页，相当于 [Page Up] 按键 (常用) |
| [Ctrl] + [d] | 屏幕『向下』移动半页 |
| [Ctrl] + [u] | 屏幕『向上』移动半页 |
| + | 光标移动到非空格符的下一行 |
| - | 光标移动到非空格符的上一行 |
| n<space> | 那个 n 表示『数字』，例如 20 。按下数字后再按空格键，光标会向右移动这一行的 n 个字符。例如 20<space> 则光标会向后面移动 20 个字符距离。 |
| 0 或功能键[Home] | 这是数字『 0 』：移动到这一行的最前面字符处 (常用) |
| $ 或功能键[End] | 移动到这一行的最后面字符处(常用) |
| H | 光标移动到这个屏幕的最上方那一行的第一个字符 |
| M | 光标移动到这个屏幕的中央那一行的第一个字符 |
| L | 光标移动到这个屏幕的最下方那一行的第一个字符 |
| G | 移动到这个档案的最后一行(常用) |
| nG | n 为数字。移动到这个档案的第 n 行。例如 20G 则会移动到这个档案的第 20 行(可配合 :set nu) |
| gg | 移动到这个档案的第一行，相当于 1G 啊！ (常用) |
| n<Enter> | n 为数字。光标向下移动 n 行(常用) |
| 搜索替换 |
| /word | 向光标之下寻找一个名称为 word 的字符串。例如要在档案内搜寻 vbird 这个字符串，就输入 /vbird 即可！ (常用) |
| ?word | 向光标之上寻找一个字符串名称为 word 的字符串。 |
| n | 这个 n 是英文按键。代表重复前一个搜寻的动作。举例来说， 如果刚刚我们执行 /vbird 去向下搜寻 vbird 这个字符串，则按下 n 后，会向下继续搜寻下一个名称为 vbird 的字符串。如果是执行 ?vbird 的话，那么按下 n 则会向上继续搜寻名称为 vbird 的字符串！ |
| N | 这个 N 是英文按键。与 n 刚好相反，为『反向』进行前一个搜寻动作。 例如 /vbird 后，按下 N 则表示『向上』搜寻 vbird 。 |
| 使用 /word 配合 n 及 N 是非常有帮助的！可以让你重复的找到一些你搜寻的关键词！ |
| :n1,n2s/word1/word2/g | n1 与 n2 为数字。在第 n1 与 n2 行之间寻找 word1 这个字符串，并将该字符串取代为 word2 ！举例来说，在 100 到 200 行之间搜寻 vbird 并取代为 VBIRD 则：
『:100,200s/vbird/VBIRD/g』。(常用) |
| :1,$s/word1/word2/g 或 :%s/word1/word2/g | 从第一行到最后一行寻找 word1 字符串，并将该字符串取代为 word2 ！(常用) |
| :1,$s/word1/word2/gc或 :%s/word1/word2/gc | 从第一行到最后一行寻找 word1 字符串，并将该字符串取代为 word2 ！且在取代前显示提示字符给用户确认 (confirm) 是否需要取代！(常用) |
| 删除、复制与黏贴 |
| x, X | 在一行字当中，x 为向后删除一个字符 (相当于 [del] 按键)， X 为向前删除一个字符(相当于 [backspace] 亦即是退格键) (常用) |
| nx | n 为数字，连续向后删除 n 个字符。举例来说，我要连续删除 10 个字符， 『10x』。 |
| dd | 删除游标所在的那一整行(常用) |
| ndd | n 为数字。删除光标所在的向下 n 行，例如 20dd 则是删除 20 行 (常用) |
| d1G | 删除光标所在到第一行的所有数据 |
| dG | 删除光标所在到最后一行的所有数据 |
| d$ | 删除游标所在处，到该行的最后一个字符 |
| d0 | 那个是数字的 0 ，删除游标所在处，到该行的最前面一个字符 |
| yy | 复制游标所在的那一行(常用) |
| nyy | n 为数字。复制光标所在的向下 n 行，例如 20yy 则是复制 20 行(常用) |
| y1G | 复制游标所在行到第一行的所有数据 |
| yG | 复制游标所在行到最后一行的所有数据 |
| y0 | 复制光标所在的那个字符到该行行首的所有数据 |
| y$ | 复制光标所在的那个字符到该行行尾的所有数据 |
| p, P | p 为将已复制的数据在光标下一行贴上，P 则为贴在游标上一行！ 举例来说，我目前光标在第 20 行，且已经复制了 10 行数据。则按下 p 后， 那 10 行数据会贴在原本的 20 行之后，亦即由 21 行开始贴。但如果是按下 P 呢？ 那么原本的第 20 行会被推到变成 30 行。 (常用) |
| J | 将光标所在行与下一行的数据结合成同一行 |
| c | 重复删除多个数据，例如向下删除 10 行，[ 10cj ] |
| u | 复原前一个动作。(常用) |
| [Ctrl]+r | 重做上一个动作。(常用) |
| 这个 u 与 [Ctrl]+r 是很常用的指令！一个是复原，另一个则是重做一次～ 利用这两个功能按键，你的编辑，嘿嘿！很快乐的啦！ |
| . | 不要怀疑！这就是小数点！意思是重复前一个动作的意思。 如果你想要重复删除、重复贴上等等动作，按下小数点『.』就好了！ (常用) |

### 第二部份：一般模式切换到编辑模式的可用的按钮说明

| 进入输入或取代的编辑模式|  |
| ---  | --- |
| i, I | 进入输入模式(Insert mode)：
i 为『从目前光标所在处输入』， I 为『在目前所在行的第一个非空格符处开始输入』。 (常用) |
| a, A | 进入输入模式(Insert mode)：
a 为『从目前光标所在的下一个字符处开始输入』， A 为『从光标所在行的最后一个字符处开始输入』。(常用) |
| o, O | 进入输入模式(Insert mode)：
这是英文字母 o 的大小写。o 为『在目前光标所在的下一行处输入新的一行』； O 为在目前光标所在处的上一行输入新的一行！(常用) |
| r, R | 进入取代模式(Replace mode)：
r 只会取代光标所在的那一个字符一次；R会一直取代光标所在的文字，直到按下 ESC 为止；(常用) |
| 上面这些按键中，在 vi 画面的左下角处会出现『--INSERT--』或『--REPLACE--』的字样。 由名称就知道该动作了吧！！特别注意的是，我们上面也提过了，你想要在档案里面输入字符时， 一定要在左下角处看到 INSERT 或 REPLACE 才能输入喔！ |
| [Esc] | 退出编辑模式，回到一般模式中(常用) |

### 第三部份：一般模式切换到指令行模式的可用的按钮说明

| 指令行的储存、离开等指令 | |
| ---  | --- |
| :w | 将编辑的数据写入硬盘档案中(常用) |
| :w! | 若文件属性为『只读』时，强制写入该档案。不过，到底能不能写入， 还是跟你对该档案的档案权限有关啊！ |
| :q | 离开 vi (常用) |
| :q! | 若曾修改过档案，又不想储存，使用 ! 为强制离开不储存档案。 |
| 注意一下啊，那个惊叹号 (!) 在 vi 当中，常常具有『强制』的意思～ |
| :wq | 储存后离开，若为 :wq! 则为强制储存后离开 (常用) |
| ZZ | 这是大写的 Z 喔！若档案没有更动，则不储存离开，若档案已经被更动过，则储存后离开！ |
| :w [filename] | 将编辑的数据储存成另一个档案（类似另存新档） |
| :r [filename] | 在编辑的数据中，读入另一个档案的数据。亦即将 『filename』 这个档案内容加到游标所在行后面 |
| :n1,n2 w [filename] | 将 n1 到 n2 的内容储存成 filename 这个档案。 |
| :! command | 暂时离开 vi 到指令行模式下执行 command 的显示结果！例如
『:! ls /home』即可在 vi 当中察看 /home 底下以 ls 输出的档案信息！ |
| vim 环境的变更 |
| :set nu | 显示行号，设定之后，会在每一行的前缀显示该行的行号 |
| :set nonu | 与 set nu 相反，为取消行号！ |

特别注意，在 vi/vim 中，数字是很有意义的！数字通常代表重复做几次的意思！ 也有可能是代表去到第几个什么什么的意思。

举例来说，要删除 50 行，则是用 『50dd』 对吧！ 数字加在动作之前，如我要向下移动 20 行呢？那就是『20j』或者是『20↓』即可。

[](https://www.runoob.com/linux/linux-filesystem.html)

### 可视模式：我理解是选择文本模式

* v:  单行选择
* v:  多行选择
* ctrl+v： 整块选择

# Vim进阶

很多软件都具有这样一种功能：在你下一次启动该软件时，它会自动为你恢复到你上次退出的环境，恢复窗口布局、所打开的文件，甚至是上次的设置。

那么，vim有没有这种功能呢？

答案当然是肯定的！这需要使用vim的会话(session)及viminfo的保存和恢复功能。

会话信息中保存了所有窗口的视图，外加全局设置。
viminfo信息中保存了命令行历史(history)、搜索字符串历史(search)、输入行历史、非空的寄存器内容(register)、文件的位置标记(mark)、最近搜索/替换的模式、缓冲区列表、全局变量等信息。



## Vim 配置

## vimrc的存放位置： 

打开你的vi，在命令模式下，输入【:version】，会看到如下图所示的内容：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190615151030.png)


$VIM 预设值: "/usr/share/vim" 
* 系统 vimrc 文件: "$VIM/vimrc" 
* 用户 vimrc 文件: "$HOME/.vimrc" 
* 用户 vimrc 文件: "~/.vim/.vimrc" 
* 用户 exrc 文件: "$HOME/.exrc" 
* 系统 gvimrc 文件: "$VIM/gvimrc" 
* 用户 gvimrc 文件: "$HOME/.gvimrc" 
* 系统菜单文件: "$VIMRUNTIME/menu.vim" 

$VIM 预设值: "/usr/share/vim" 那么将里面的.vimrc拷贝到~/目录下,~/.vim/.vimrc

要查看你当前使用的 vimrc 配置文件是哪一个，请在 vim 命令中输入（在 vim 中按 esc，然后按冒号，接着输入命令）

```
echo $MYVIMRC
// /Users/username/.vimrc
```
如果还是想修改系统级 vimrc 文件的话，需要先将此文件的写入权限开启。终端中输入

```
sudo chmod a+w /usr/share/vim/vimrc
```

再次使用vim打开.vimrc，看看主题效果是否生效，如果没有效果执行:source ./vimrc


### nvim 

nvim默认读取 ~/.config/nvim/init.vim 下的配置
* 可以连接vim的配置
ln -s ~/.vimrc  ~/.config/nvim/init.vim
* 拷贝一份单独的配置
cp  ~/.vimrc  ~/.config/nvim/init.vim

* oni： nvim的GUI


通常，使用Vim的一些插件都需要Python支持，这里给Neovim添加python支持。

```
pip install neovim --upgrade
// 这里说明一下，如果需要python3支持，则使用pip3 install neovim --upgrade
// 然后修改配置文件，~/.config/nvim/init.vim中添加
let g:python_host_prog = '/usr/local/bin/python'
// 这里也一样，如果是python3，则
let g:python3_host_prog = '/usr/local/bin/python3'
```

[SpaceVim Tutorial On Mac - Zeech's Tech Blog](https://zcheng.ren/2018/07/27/spacevimtutorial/#neovim)

### 下载vim-plug 

vim-plug for  Vim
[vim-plug](https://github.com/junegunn/vim-plug)
Download plug.vim and put it in the "autoload" directory.

* Vim
    * curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
* Neovim
    * curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

NeoVim的配置文件路径在：`~/.config/nvim/init.vim`
位置在：`~/.local/share/nvim/site/autoload/`

```linux
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```


在~/.config/nvim/init.vim中最开始的地方添加如下的内容,安装nerdtree插件

```
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
call plug#end()
```

上面的Plug 'scrooloose/nerdtree'表示要安装的插件
打开你的nvim，执行如下命令进行插件安装
:PlugInstall

安装后的插件路径是~/.vim/plugin/

NERDTree插件的官方地址如下，可以从这里获取最新的版本 https://github.com/scrooloose/nerdtree 下载zip安装包 或者使用下面官网源文件安装方法

我的实验环境是centos6.6,其他版本可能有些不同。 安装方法很简单，先把压缩文件下载下来，解压后将plugin目录下的NERD_tree.vim拷贝~/.vim/plugin以及doc目录下的NERD_tree.txt拷贝到~/.vim/doc. ~表示当前用户的目录，我的环境中没有~/.vim ~/.vim/plugin ~/.vim/doc ，待会会创建，如果你的版本有，那就更好了。

```
wget http://www.vim.org/scripts/download_script.php?src_id=17123 -O nerdtree.zip 
unzip nerdtree.zip

mkdir -p ~/.vim/{plugin,doc}

cp plugin/NERD_tree.vim ~/.vim/plugin/
cp doc/NERD_tree.txt ~/.vim/doc/
```

* [vim插件：显示树形目录插件NERDTree安装 和 使用【转】 - 爱做梦的90后--庄泽彬 - 博客园](https://www.cnblogs.com/zzb-Dream-90Time/p/7116406.html)
[neovim安装vim-plug - 简书](https://www.jianshu.com/p/fbd79ca8d9f0)

ctrl + w + h    光标 focus 左侧树形目录
ctrl + w + l    光标 focus 右侧文件显示窗口
ctrl + w + w    光标自动在左右侧窗口切换
ctrl + w + r    移动当前窗口的布局位置
o       在已有窗口中打开文件、目录或书签，并跳到该窗口
go      在已有窗口 中打开文件、目录或书签，但不跳到该窗口
t       在新 Tab 中打开选中文件/书签，并跳到新 Tab
T       在新 Tab 中打开选中文件/书签，但不跳到新 Tab
i       split 一个新窗口打开选中文件，并跳到该窗口
gi      split 一个新窗口打开选中文件，但不跳到该窗口
s       vsplit 一个新窗口打开选中文件，并跳到该窗口
gs      vsplit 一个新 窗口打开选中文件，但不跳到该窗口
!       执行当前文件
O       递归打开选中 结点下的所有目录
x       合拢选中结点的父目录
X       递归 合拢选中结点下的所有目录
e       Edit the current dif
双击    相当于 NERDTree-o
中键    对文件相当于 NERDTree-i，对目录相当于 NERDTree-e
D       删除当前书签
P       跳到根结点
p       跳到父结点
K       跳到当前目录下同级的第一个结点
J       跳到当前目录下同级的最后一个结点
k       跳到当前目录下同级的前一个结点
j       跳到当前目录下同级的后一个结点
C       将选中目录或选中文件的父目录设为根结点
u       将当前根结点的父目录设为根目录，并变成合拢原根结点
U       将当前根结点的父目录设为根目录，但保持展开原根结点
r       递归刷新选中目录
R       递归刷新根结点
m       显示文件系统菜单
cd      将 CWD 设为选中目录
I       切换是否显示隐藏文件
f       切换是否使用文件过滤器
F       切换是否显示文件
B       切换是否显示书签
q       关闭 NerdTree 窗口
?       切换是否显示 Quick Help
切换标签页

:tabnew [++opt选项] ［＋cmd］ 文件      建立对指定文件新的tab
:tabc   关闭当前的 tab
:tabo   关闭所有其他的 tab
:tabs   查看所有打开的 tab
:tabp   前一个 tab
:tabn   后一个 tab


### NERDTree config  自动打开

" NERDTree config  自动打开
" open a NERDTree automatically when vim starts up
autocmd vimenter * NERDTree
"open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"map F2 to open NERDTree
map <F2> :NERDTreeToggle<CR>
"close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

### 在term2中使用vim依旧打开的是低版本的vim工具

$ echo 'alias vi="nvim"' >> ~/.zshrc
$ echo 'alias vim="nvim"' >> ~/.zshrc
$ source ~/.zshrc


call plug#begin('~/.local/share/nvim/plugged')
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' } 
call plug#end()

## Vim 主题

感觉gruvbox的复古风格不错: [morhetz/gruvbox: Retro groove color scheme for Vim](https://github.com/morhetz/gruvbox)

## Vim for xcode

XVim 是 Xcode 中的 Vim 插件，旨在 Xcode 中提供 Vim 式的操作方式。

### 签署 Xcode

1.  关闭 Xcode
2.  打开 **钥匙串访问**

    *   选择 `钥匙串访问` -> `证书助理` -> `创建证书`

        *   名称：XcodeSigner（可随意）
        *   身份类型：自签名根证书
        *   证书类型：代码签名 
3.  重新签署 Xcode

### XcodeSigner 为创建证书时输入的名称

```
sudo codesign -f -s XcodeSigner /Applications/Xcode.app 
```
等待……


### 安装 XVim2

确认 Xcode 指向 /Applications/Xcode.app/Contents/Developer

```
xcode-select -p
```

### 下载 XVim2

```
git clone https://github.com/XVimProject/XVim2.git
```

下载完毕后，进入目录
cd xvim2

安装
make

安装完成后显示 **BUILD SUCCEEDED **即表示安装成功；然后打开 Xcode 提示 `Unexpected code bundle "XXVim2.xcpplugin`，选择 `Load Bundle` 即可。

### 备注

如果加载时不小心选择了 `Skip Bundle`，需要重新安装：
最后的 X.X，需改成当前 Xcode 的具体版本

```
defaults delete  com.apple.dt.Xcode DVTPlugInManagerNonApplePlugIns-Xcode-X.X
```

另：可在 Xcode 中的 `Edit` -> `XVim` 关闭或启用。

* Xcode11 ： [Xcode 11 · Issue #236 · XVimProject/XVim2](https://github.com/XVimProject/XVim2/issues/236)
    * 下载Develop分支

## Vim工具

### SpaceVim

[SpaceVim主页| SpaceVim](https://spacevim.org/)

> SpaceVim是一个社区驱动的模块化 vim/neovim 配置集合，其中包含了多种功能模块，并且针对 neovim 做了功能优化。SpaceVim有多种功能模块可供选择，用户只需要选择所需的模块，就可以配置出一个适合自己的开发环境。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190615111625.png)


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190615111237.png)

(SpaceVim 的默认界包括 tagbar 、vimfiler 、以及 airline 界面，配色主题采用的 gruvbox。)

#### 安装：

```
[1] 安装SpaceVim工具
# 需要先安装git和curl工具
$ brew install git
$ brew install curl
# SpaceVim是基于neovim的IDE工具
$ brew install neovim
# 运行该指令之后会提示安装/卸载相关命令
$ curl -sLf https://spacevim.org/install.sh | bash
or
$ curl -sLf https://spacevim.org/cn/install.sh | bash -s -- -h
# 自动更新(配置文件)
automatic_update = 1

# 手动更新(编辑模式)
:SPUpdate SpaceVim

# 手动更新(通过git)
git pull

```

想要获取更多的自定义的安装方式，请参考：

```
curl -sLf https://spacevim.org/install.sh | bash -s -- -h
```

SpaceVim是一种模块化配置，可以运行在vim或者neovim上，关于vim以及neovim的安装，请参考以下链接：

* [安装neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim)
* [从源码编译vim](https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source)


#### Unite 为主的工作平台

Unite 的快捷键前缀是f，可以通过g:spacevim_unite_leader来设定，快捷键无需记忆，SpaceVim 有很好的快捷键辅助机制，如下是 Unite 的快捷键键图：
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190615111409.png)

### SpaceVim 选项

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190615111545.png)

#### 语言支持

[Use Vim as a C/C++ IDE | SpaceVim](https://spacevim.org/use-vim-as-a-c-cpp-ide/)

### 安装fzf

1.  安装 `fzf`，将`fzf`的目录添加到`Vim`的`&runtimepath`来启用它。

```
" If installed using Homebrew
set rtp+=/usr/local/opt/fzf
" If installed using git
set rtp+=~/.fzf
```

1. 安装插件`fzf.vim`, 配置`fzf`命令。


#### 安装 fzf

1.  使用 [Homebrew](https://link.jianshu.com?t=https%3A%2F%2Fbrew.sh%2F) 安装`fzf`

```
brew install fzf

```

1.  使用`Git`手动安装

```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

```

#### 安装 fzf.vim

使用 [Vim-plug](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2Fjunegunn%2Fvim-plug) 作为插件管理工具。

```
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

```

OR 使用`vim-plug`安装 `fzf`

```
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

```
#### fzf 命令

| Command | List |
| --- | --- |
| `Files [PATH]` | Files (similar to `:FZF`) |
| `GFiles [OPTS]` | Git files (`git ls-files`) |
| `GFiles?` | Git files (`git status`) |
| `Buffers` | Open buffers |
| `Colors` | Color schemes |
| `Ag [PATTERN]` | [ag](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2Fggreer%2Fthe_silver_searcher) search result (`ALT-A` to select all, `ALT-D` to deselect all) |
| `Lines [QUERY]` | Lines in loaded buffers |
| `BLines [QUERY]` | Lines in the current buffer |
| `Tags [QUERY]` | Tags in the project (`ctags -R`) |
| `BTags [QUERY]` | Tags in the current buffer |
| `Marks` | Marks |
| `Windows` | Windows |
| `Locate PATTERN` | `locate` command output |
| `History` | `v:oldfiles` and open buffers |
| `History:` | Command history |
| `History/` | Search history |
| `Snippets` | Snippets ([UltiSnips](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2FSirVer%2Fultisnips)) |
| `Commits` | Git commits (requires [fugitive.vim](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2Ftpope%2Fvim-fugitive)) |
| `BCommits` | Git commits for the current buffer |
| `Commands` | Commands |
| `Maps` | Normal mode mappings |
| `Helptags` | Help tags <sup id="a1">[1](#helptags) |
| `Filetypes` | File types |


# Vim Cheat Sheet

### Global

:help keyword – open help for keyword
:o file – open file
:saveas file – save file as
:close – close current window

### Cursor Movements

h – move cursor left
j – move cursor down
k – move cursor up
l – move cursor right
H – move to top of screen
M – move to middle of screen
L – move to bottom of screen
w – jump forwards to the start of a word
W – jump forwards to the start of a word (words can contain punctuation)
e – jump forwards to the end of a word
E – jump forwards to the end of a word (words can contain punctuation)
b – jump backwards to the start of a word
B – jump backwards to the start of a word (words can contain punctuation)
0 – jump to the start of the line
^ – jump to the first non-blank character of the line
$ – jump to the end of the line
g_ – jump to the last non-blank character of the line
gg – go to the first line of the document
G – go to the last line of the document
5G – go to line 5
fx – jump to next occurrence of character x
tx – jump to before next occurrence of character x
} – jump to next paragraph (or function/block, when editing code)
{ – jump to previous paragraph (or function/block, when editing code)
zz – center cursor on screen
Ctrl + b – move back one full screen
Ctrl + f – move forward one full screen
Ctrl + d – move forward 1/2 a screen
Ctrl + u – move back 1/2 a screen

Tip: Prefix a cursor movement command with a number to repeat it. For example, 4j moves down 4 lines.

### Insert Mode

i – insert before the cursor
I – insert at the beginning of the line
a – insert (append) after the cursor
A – insert (append) at the end of the line
o – append (open) a new line below the current line
O – append (open) a new line above the current line
ea – insert (append) at the end of the word
Esc – exit insert mode

### Editing

r – replace a single character
J – join line below to the current line
cc – change (replace) entire line
cw – change (replace) to the end of the word
c$ – change (replace) to the end of the line
s – delete character and substitute text
S – delete line and substitute text (same as cc)
xp – transpose two letters (delete and paste)
u – undo
Ctrl + r – redo
. – repeat last command

### Marking Text (Visual Mode)

v – start visual mode, mark lines, then perform an operation (such as d-delete)
V – start linewise visual mode
Ctrl + v – start blockwise visual mode
o – move to the other end of marked area
O – move to other corner of block
aw – mark a word
ab – a block with ()
aB – a block with {}
ib – inner block with ()
iB – inner block with {}
Esc – exit visual mode

### Visual Commands

> – shift text right
< – shift text left
y – yank (copy) marked text
d – delete marked text
~ – switch case

### Registers

:reg – show registers content
"xy – yank into register x
"xp – paste contents of register x

Tip: Registers are being stored in ~/.viminfo, and will be loaded again on next restart of vim.

Tip: Register 0 contains always the value of the last yank command.

### Marks

:marks – list of marks
ma – set current position for mark A
`a – jump to position of mark A
y`a – yank text to position of mark A

### Macros

qa – record macro a
q – stop recording macro
@a – run macro a
@@ – rerun last run macro

### Cut and Paste

yy – yank (copy) a line
2yy – yank (copy) 2 lines
yw – yank (copy) the characters of the word from the cursor position to the start of the next word
y$ – yank (copy) to end of line
p – put (paste) the clipboard after cursor
P – put (paste) before cursor
dd – delete (cut) a line
2dd – delete (cut) 2 lines
dw – delete (cut) the characters of the word from the cursor position to the start of the next word
D – delete (cut) to the end of the line
d$ – delete (cut) to the end of the line
x – delete (cut) character

### Exiting

:w – write (save) the file, but don’t exit
:w !sudo tee % – write out the current file using sudo
:wq or :x or ZZ – write (save) and quit
:q – quit (fails if there are unsaved changes)
:q! or ZQ – quit and throw away unsaved changes

### Search and Replace

/pattern – search for pattern
?pattern – search backward for pattern
\vpattern – ‘very magic’ pattern: non-alphanumeric characters are interpreted as special regex symbols (no escaping needed)
n – repeat search in same direction
N – repeat search in opposite direction
:%s/old/new/g – replace all old with new throughout file
:%s/old/new/gc – replace all old with new throughout file with confirmations
:noh – remove highlighting of search matches

### Search in Multiple Files

:vimgrep /pattern/ {file} – search for pattern in multiple files
e.g.
:vimgrep /foo/ **/*
:cn – jump to the next match
:cp – jump to the previous match
:copen – open a window containing the list of matches

### Working With Multiple Files

:e file – edit a file in a new buffer
:bnext or :bn – go to the next buffer
:bprev or :bp – go to the previous buffer
:bd – delete a buffer (close a file)
:ls – list all open buffers
:sp file – open a file in a new buffer and split window
:vsp file – open a file in a new buffer and vertically split window
Ctrl + ws – split window
Ctrl + ww – switch windows
Ctrl + wq – quit a window
Ctrl + wv – split window vertically
Ctrl + wh – move cursor to the left window (vertical split)
Ctrl + wl – move cursor to the right window (vertical split)
Ctrl + wj – move cursor to the window below (horizontal split)
Ctrl + wk – move cursor to the window above (horizontal split)

### Tabs

:tabnew or :tabnew file – open a file in a new tab
Ctrl + wT – move the current split window into its own tab
gt or :tabnext or :tabn – move to the next tab
gT or :tabprev or :tabp – move to the previous tab
 #gt – move to tab number #
:tabmove # – move current tab to the #th position (indexed from 0)
:tabclose or :tabc – close the current tab and all its windows
:tabonly or :tabo – close all tabs except for the current one
:tabdo command – run the command on all tabs (e.g. :tabdo q – closes all opened tabs)


## 个人Vim配置

.vimrc

```
"==========================================  
" vim-plug插件 
"==========================================  

call plug#begin()
Plug 'ctrlpvim/ctrlp.vim'
Plug 'majutsushi/tagbar'
Plug 'Lokaltog/vim-powerline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim'
call plug#end()
colorscheme gruvbox
set background=dark

"==========================================  
" vim-bundles插件 
"==========================================  

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" vundle 环境设置
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
" vundle 管理的插件列表必须位于 vundle#begin() 和 vundle#end() 之间
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tomasr/molokai'
Plugin 'vim-scripts/phd'
Plugin 'Lokaltog/vim-powerline'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'skywind3000/quickmenu'
Plugin 'MattesGroeger/vim-bookmarks'
Plugin 'suan/vim-instant-markdown'
" 插件列表结束
call vundle#end()
filetype plugin indent on

"==========================================  
"General  
"==========================================  
" history存储长度。  
set history=1000         
" 检测文件类型  
filetype on  
" 针对不同的文件类型采用不同的缩进格式    
filetype indent on                 
" 允许插件    
filetype plugin on  
" 启动自动补全  
filetype plugin indent on  
" 兼容vi模式。去掉讨厌的有关vi一致性模式，避免以前版本的一些bug和局限  
set nocompatible        
set autoread          " 文件修改之后自动载入。  
set shortmess=atI       " 启动的时候不显示那个援助索马里儿童的提示  


"==========================================  
" show and format  
"==========================================  
" 显示行号：  
set number  
set nowrap                    " 取消换行。  
" 为方便复制，用<F6>开启/关闭行号显示:  
nnoremap <F6> :set nonumber!<CR>:set foldcolumn=0<CR>  

" 括号配对情况  
set showmatch  
" How many tenths of a second to blink when matching brackets  
set mat=2  
  
" 设置文内智能搜索提示  
" 高亮search命中的文本。  
set hlsearch            
" 搜索时忽略大小写  
set ignorecase  
" 随着键入即时搜索  
set incsearch  
" 有一个或以上大写字母时仍大小写敏感  
set smartcase  
  
" 代码折叠  
set foldenable  
" 折叠方法  
" manual    手工折叠  
" indent    使用缩进表示折叠  
" expr      使用表达式定义折叠  
" syntax    使用语法定义折叠  
" diff      对没有更改的文本进行折叠  
" marker    使用标记进行折叠, 默认标记是 {{{ 和 }}}  
set foldmethod=syntax  
" 在左侧显示折叠的层次  
" set foldcolumn=4  
" 基于缩进或语法进行代码折叠
"set foldmethod=indent
set foldmethod=syntax
" 启动 vim 时关闭折叠代码
set nofoldenable
  

set tabstop=4                " 设置Tab键的宽度        [等同的空格个数]  
set shiftwidth=4  
set expandtab                " 将Tab自动转化成空格    [需要输入真正的Tab键时，使用 Ctrl+V + Tab]  
" 按退格键时可以一次删掉 4 个空格  
set softtabstop=4  
  
set ai "Auto indent  
set si "Smart indent  
  
" 开启语法高亮功能
syntax enable
" 允许用指定语法高亮配色方案替换默认方案
syntax on


" 禁止光标闪烁
set gcr=a:block-blinkon0
" 禁止显示滚动条
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
" 禁止显示菜单和工具条
set guioptions-=m
set guioptions-=T

" 总是显示状态栏
set laststatus=2
" 显示光标当前位置
set ruler
" 开启行号显示
set number
" 高亮显示当前行/列
set cursorline
" 高亮显示搜索结果
set hlsearch
" 禁止折行
set nowrap

" 设置状态栏主题风格
let g:Powerline_colorscheme='solarized256'
" 搜索替换
let g:ackprg = 'ag --nogroup --nocolor --column'


" NERDTree config  自动打开
" open a NERDTree automatically when vim starts up
autocmd vimenter * NERDTree
"open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"map F2 to open NERDTree
map <F2> :NERDTreeToggle<CR>
"close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
```

## 后记

> 罗马三巨头,公元前62年，凯撒 组建了一个包含了他自己， 政治家克拉苏，以及军事领袖庞培三人的政治联盟。 这三个人一起组成了一个秘密政治小组，称为 Triumvirate（三巨头），来统治罗马共和国。 而文本三巨头则是 zsh、vim 和 tmux。 这三个令人尊敬的工具本身已经非常强大，然而它们的组合却更加所向披靡，把其他文本编辑组合甩开了 N 条街。本文旨在向刚接触各类工具的新手们简述如何建立一个既强大又容易配置的文本三巨头。我想把主要的篇幅放在如何将 zsh、vim 和 tmux 整合起来，并主要讲述了我如何解决两个常见的问题——复制/粘贴功能和颜色配置。
> 使用 zsh、vim 和 tmux 的好处就在于免费使用，速度快，可任意定制，在任何操作系统上都能使用，可在远程环境中使用，还在于可以实现远程结对编程，以及互相之间，和与 Unix 之间深度的整合。最终纯文本编辑的效率和组织性将会得到很大提升。该工具链可以完全由 git 管理，并且可以再几秒钟的时间内克隆到一台远程服务器或是一台新的机器上


## 参考

* [VimAwesome](https://vimawesome.com/plugin/spacevim-hands-off)
* [Linux vi/vim | 菜鸟教程](https://www.runoob.com/linux/linux-vim.html)
* [vi/vim使用进阶: 序言 - 易水博客](https://blog.easwy.com/archives/advanced-vim-skills-prologue/)
* [文本三巨头：zsh、tmux 和 vim - 文章 - 伯乐在线](http://blog.jobbole.com/86571/)

### XVim参考

* [记：在 Xcode 10 中安装 XVim2 - 风萧萧](https://note.wuze.me/xvim2)
*   [XVimProject/XVim2: Vim key-bindings for Xcode 9](https://github.com/XVimProject/XVim2)
*   [XVim2/SIGNING_Xcode.md at master · XVimProject/XVim2](https://github.com/XVimProject/XVim2/blob/master/SIGNING_Xcode.md)
