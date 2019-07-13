# 工具-文本三巨头-Tmux学习


### OnMyZch

![](http://upload-images.jianshu.io/upload_images/225323-9f80c1d60073bd39.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

[`oh-my-Zsh`](<https://github.com/robbyrussell/oh-my-Zsh)

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
编辑配置文件：`vim ~/.zshrc`，增加下面内容：

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


## 主题配置

路径在： `/Users/mac/.oh-my-zsh/`

### powerlevel10k

异步加载，性能好

[themes/powerlevel10k](https://www.bilibili.com/video/av52249480)

配置

[Show Off Your Config · bhilburn/powerlevel9k Wiki](https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config)
haccks's Config
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190616013159.png)

### Spaceship配置

* spaceship感觉是对Git图形比较好看，比较简洁的一个主题
[`spaceship`](https://github.com/denysdovhan/spaceship-zsh-theme)主题

![](http://upload-images.jianshu.io/upload_images/225323-1574a71d992ad02d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- Current Git branch and rich repo status:
  - `?` — untracked changes;
  - `+` — uncommitted changes in the index;
  - `!` — unstaged changes;
  - `»` — renamed files;
  - `✘` — deleted files;
  - `$` — stashed changes;
  - `=` — unmerged changes;
  - `⇡` — ahead of remote branch;
  - `⇣` — behind of remote branch;
  - `⇕` — diverged changes.
- Current Mercurial bookmark/branch and rich repo status:
  - `?` — untracked changes;
  - `+` — uncommitted changes in the index;
  - `!` — unstaged changes;
  - `✘` — deleted files;
- Indicator for jobs in the background (`✦`).
- Current Node.js version, through nvm/nodenv/n (`⬢`).
- Current Ruby version, through rvm/rbenv/chruby/asdf (`💎`).
- Current Elm version (`🌳`)
- Current Elixir version, through kiex/exenv/elixir (`💧`).
- Current Swift version, through swiftenv (`🐦`).
- Current Xcode version, through xenv (`🛠`).
- Current Go version (`🐹`).
- Current PHP version (`🐘`).
- Current Rust version (`𝗥`).
- Current version of Haskell GHC Compiler, defined in stack.yaml file (`λ`).
- Current Julia version (`ஃ`).
- Current Docker version and connected machine (`🐳`).
- Current Amazon Web Services (AWS) profile (`☁️`) ([Using named profiles](http://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html)).
- Current Python virtualenv.
- Current Conda virtualenv (`🅒`).
- Current Python pyenv (`🐍`).
- Current .NET SDK version, through dotnet-cli (`.NET`).
- Current Ember.js version, through ember-cli (`🐹`).
- Current Kubectl context (`☸️`).
- Current Terraform workspace (`🛠`).
- Package version, if there's is a package in current directory (`📦`).
- Current battery level and status:
  - `⇡` - charging;
  - `⇣` - discharging;
  - `•` - fully charged.
- Current Vi-mode mode ([with handy aliases for temporarily enabling](./docs/Options.md#vi-mode-vi_mode)).
- Optional exit-code of last command ([how to enable](./docs/Options.md#exit-code-exit_code)).
- Optional time stamps 12/24hr in format ([how to enable](./docs/Options.md#time-time)).
- Execution time of the last command if it exceeds the set threshold.

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

## `Zsh`插件 Plugins

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15129592017167.jpg)

* [Awesome-Zsh-Plugins](https://github.com/unixorn/awesome-zsh-plugins)插件库
* [程序员内功系列--常用命令行工具 | iTimothy](https://xiaozhou.net/learn-the-command-line-tools-md-2018-10-11.html)

### vim-plug

🌺 Minimalist Vim Plugin Manager

异步下载plug
[junegunn/vim-plug: Minimalist Vim Plugin Manager](https://github.com/junegunn/vim-plug)


### autojump 快速跳转

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713020049.gif)


autojump可以很方便地帮我们切换到指定目录，它的工作原理是维护一个命令行中使用过的目录的数据库。

[命令行福利——切换目录autojump | yuweiguo's blog](https://yuweiguocn.github.io/command-line-autojump/)

mac下安装：
```
brew install autojump
```

autojump 支持 zsh，添加以下内容到 ~/.bash_profile 或 ~/.zshrc 文件中：

```
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
```

记得使用 source 命令使刚才的内容生效：

source ~/.bash_profile
source ~/.zshrc
我们可以使用更简洁的命令 j 来实现目录跳转，j 是对 autojump 命令的包装。在使用 autojump 切换目录前，需要在命令行中使用过该目录。跳转到包含 te 的目录：

我们可以使用更简洁的命令 j 来实现目录跳转，j 是对 autojump 命令的包装。在使用 autojump 切换目录前，需要在命令行中使用过该目录。跳转到包含 te 的目录：
j te
话不多说，来看下效果：


使用文件管理器打开目录：
jo te


autojump 支持自动补全，使用Tab键查看匹配的多个目录：

查看 autojump 存储的目录的状态：

j -s


可以看到每个目录都有对应权重，所以当出现匹配多个目录会跳到权重较大的目录下。
更多选项请查看使用帮助：

1
j -h



### thefuck

thefuck 是一个非常有趣的命令行软件，它能自动帮你纠正敲错的命令。平时在快速输入命令的时候，难免会有一些字母输入错误，这个时候，不用担心，直接再输入一个 fuck，吐槽一下，thefuck 就能自动根据你的输入，猜测出你要输入的命令，并自动帮你纠正，方便得一bi:

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713020336.gif)


### tig
tig 的界面看起来比起 git log 要酷炫不少，而且使用起来也挺方便。此外，tig 的默认按键绑定还跟Vim比较类似，真是Vimer的福音。

tig 在Mac OS下的安装:
```linux
brew install tig
```


### git summary

平时我们在多人合作开发一个项目的时候，想要大致了解一下每个人对这个项目提交的commit数量和大致的贡献度，那么 git summary 这个命令绝对能满足你的要求：
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713021037.png)
```linux
brew install git-extras
```

### skm

SKM，全称SSH Key Manager，是一个在命令行下帮助你方便的管理和切换多个SSH key的工具。想象一下，如果你是运维人员，不同的服务器也许有不同的SSH Key来登录，又或者你是一个开发人员，有自己的SSH Key，用来开发和提交代码到自己的git仓库，或许还有公司的SSH Key，用来开发公司的项目。基于以上的情况，需要经常切换SSH Key。而用上了SKM，就方便多了，使用方法类似于 nvm，方便的创建，管理，切换系统当前默认SSH Key，用起来简直不要太爽！

```linux
brew tap timothyye/tap
brew install timothyye/tap/skm
```
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713021155.png)

## `Zsh` 命令

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15301106716847.jpg)


##  搜索

the_silver_searcher: A code searching tool similar to ack, with a focus on speed.


```
brew install the_silver_searcher
```


## Vim党插件 Vi-mode

让输入命令vim化：

[oh-my-zsh/plugins/vi-mode at master · robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/vi-mode)


## 我的Zsh配置


```
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/mac/.oh-my-zsh"
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH=/Users/mac/Documents/development/FlutterSDK/flutter/bin:$PATH
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=http://dart-pub.byted.org


# ZSH_THEME="robbyrussell"
ZSH_THEME="spaceship"
# ZSH_THEME=powerlevel10k/powerlevel10k

# User configuration

source ~/.bash_profile
source $ZSH/oh-my-zsh.sh


# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vi="vim"
alias nvi="nvim"
alias tnew="tmux new -s"

eval $(thefuck --alias)


# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

## autojump 编译脚本
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh


## 插件

# zplug
# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    source ~/.zplug/init.zsh && zplug update --self
fi

# Essential
source ~/.zplug/init.zsh

# What does this do?
zplug "plugins/vi-mode", from:oh-my-zsh
# zplug romkatv/powerlevel10k, use:powerlevel10k.zsh-theme

# Then, source packages and add commands to $PATH
zplug load --verbose

## 添加插件git
plugins=(git)
## 添加插件autojump
plugins=(git autojump)
## 添加插件vi-mode
plugins=(git vi-mode)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Set Spaceship ZSH as a prompt
  autoload -U promptinit; promptinit
  prompt spaceship
```

## 参考
