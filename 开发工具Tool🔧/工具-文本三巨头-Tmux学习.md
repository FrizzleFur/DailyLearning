# 工具-文本三巨头-Tmux学习

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713023841.png)

### 会话

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190713023810.png)

#### 新建会话

新建一个tmux session非常简单，语法为`tmux new -s session-name`，也可以简写为`tmux`，为了方便管理，建议指定会话名称，如下。

```linux
tmux # 新建一个无名称的会话
tmux new -s demo # 新建一个名称为demo的会话
```

#### 断开当前会话

会话中操作了一段时间，我希望断开会话同时下次还能接着用，怎么做？此时可以使用detach命令。

```linux
tmux detach # 断开当前会话，会话在后台运行
```

也许你觉得这个太麻烦了，是的，tmux的会话中，我们已经可以使用tmux快捷键了。使用快捷键组合`Ctrl+b` + `d`，三次按键就可以断开当前会话。

#### 进入之前的会话

断开会话后，想要接着上次留下的现场继续工作，就要使用到tmux的attach命令了，语法为`tmux attach-session -t session-name`，可简写为`tmux a -t session-name` 或 `tmux a`。通常我们使用如下两种方式之一即可：

```linux
tmux a # 默认进入第一个会话
tmux a -t demo # 进入到名称为demo的会话
```

#### 关闭会话

会话的使命完成后，一定是要关闭的。我们可以使用tmux的kill命令，kill命令有`kill-pane`、`kill-server`、`kill-session` 和 `kill-window`共四种，其中`kill-session`的语法为`tmux kill-session -t session-name`。如下：

```linux
tmux kill-session -t demo # 关闭demo会话
tmux kill-server # 关闭服务器，所有的会话都将关闭
```

#### 查看所有的会话

管理会话的第一步就是要查看所有的会话，我们可以使用如下命令：

```linux
tmux list-session # 查看所有会话
tmux ls # 查看所有会话，提倡使用简写形式
```

## Tmux快捷键

表一：系统指令。

| 前缀 | 指令 | 描述 |
| --- | --- | --- |
| `Ctrl+b` | `?` | 显示快捷键帮助文档 |
| `Ctrl+b` | `d` | 断开当前会话 |
| `Ctrl+b` | `D` | 选择要断开的会话 |
| `Ctrl+b` | `Ctrl+z` | 挂起当前会话 |
| `Ctrl+b` | `r` | 强制重载当前会话 |
| `Ctrl+b` | `s` | 显示会话列表用于选择并切换 |
| `Ctrl+b` | `:` | 进入命令行模式，此时可直接输入`ls`等命令 |
| `Ctrl+b` | `[` | 进入复制模式，按`q`退出 |
| `Ctrl+b` | `]` | 粘贴复制模式中复制的文本 |
| `Ctrl+b` | `~` | 列出提示信息缓存 |

表二：窗口（window）指令。

| 前缀 | 指令 | 描述 |
| --- | --- | --- |
| `Ctrl+b` | `c` | 新建窗口 |
| `Ctrl+b` | `&` | 关闭当前窗口（关闭前需输入`y` or `n`确认） |
| `Ctrl+b` | `0~9` | 切换到指定窗口 |
| `Ctrl+b` | `p` | 切换到上一窗口 |
| `Ctrl+b` | `n` | 切换到下一窗口 |
| `Ctrl+b` | `w` | 打开窗口列表，用于且切换窗口 |
| `Ctrl+b` | `,` | 重命名当前窗口 |
| `Ctrl+b` | `.` | 修改当前窗口编号（适用于窗口重新排序） |
| `Ctrl+b` | `f` | 快速定位到窗口（输入关键字匹配窗口名称） |

表三：面板（pane）指令。

| 前缀 | 指令 | 描述 |
| --- | --- | --- |
| `Ctrl+b` | `"` | 当前面板上下一分为二，下侧新建面板 |
| `Ctrl+b` | `%` | 当前面板左右一分为二，右侧新建面板 |
| `Ctrl+b` | `x` | 关闭当前面板（关闭前需输入`y` or `n`确认） |
| `Ctrl+b` | `z` | 最大化当前面板，再重复一次按键后恢复正常（v1.8版本新增） |
| `Ctrl+b` | `!` | 将当前面板移动到新的窗口打开（原窗口中存在两个及以上面板有效） |
| `Ctrl+b` | `;` | 切换到最后一次使用的面板 |
| `Ctrl+b` | `q` | 显示面板编号，在编号消失前输入对应的数字可切换到相应的面板 |
| `Ctrl+b` | `{` | 向前置换当前面板 |
| `Ctrl+b` | `}` | 向后置换当前面板 |
| `Ctrl+b` | `Ctrl+o` | 顺时针旋转当前窗口中的所有面板 |
| `Ctrl+b` | `方向键` | 移动光标切换面板 |
| `Ctrl+b` | `o` | 选择下一面板 |
| `Ctrl+b` | `空格键` | 在自带的面板布局中循环切换 |
| `Ctrl+b` | `Alt+方向键` | 以5个单元格为单位调整当前面板边缘 |
| `Ctrl+b` | `Ctrl+方向键` | 以1个单元格为单位调整当前面板边缘（Mac下被系统快捷键覆盖） |
| `Ctrl+b` | `t` | 显示时钟 |


#### **Buffer缓存**

tmux复制操作的内容默认会存进`buffer`里，`buffer`是一个粘贴缓存区，新的缓存总是位于栈顶，它的操作命令如下：

```linux
tmux list-buffers # 展示所有的 buffers
tmux show-buffer [-b buffer-name] # 显示指定的 buffer 内容
tmux choose-buffer # 进入 buffer 选择页面(支持jk上下移动选择，回车选中并粘贴 buffer 内容到面板上)
tmux set-buffer # 设置buffer内容
tmux load-buffer [-b buffer-name] file-path # 从文件中加载文本到buffer缓存
tmux save-buffer [-a] [-b buffer-name] path # 保存tmux的buffer缓存到本地
tmux paste-buffer # 粘贴buffer内容到会话中
tmux delete-buffer [-b buffer-name] # 删除指定名称的buffer
```

### 保存Tmux会话

信息时代，数据尤为重要。tmux保护现场的能力依赖于tmux进程，如果进程退出，则意味着会话数据的丢失，因此关机重启后，tmux中的会话将被清空，这不是我们想要见到的。幸运的是，目前有这样两款插件：`Tmux Resurrect` 和 `Tmux Continuum`，可以永久保存tmux会话（它们均适用于tmux v1.9及以上版本）。

#### Tmux Resurrect

Tmux Resurrect无须任何配置，就能够备份tmux会话中的各种细节，包括窗口、面板的顺序、布局、工作目录，运行程序等等数据。因此它能在系统重启后完全地恢复会话。由于其幂等的恢复机制，它不会试图去恢复一个已经存在的窗口或者面板，所以，即使你不小心多恢复了几次会话，它也不会出现问题，这样主动恢复时我们就不必担心手抖多按了一次。另外，如果你是[tmuxinator](https://github.com/tmuxinator/tmuxinator)用户，我也建议你迁移到 tmux-resurrect插件上来，具体请参考[Migrating from `tmuxinator`](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/migrating_from_tmuxinator.md#migrating-from-tmuxinator)。

Tmux Resurrect安装过程如下所示：
```linux
cd ~/.tmux
mkdir plugins
git clone https://github.com/tmux-plugins/tmux-resurrect.git
```

安装后需在`~/.tmux.conf`中增加一行配置：

```linux
run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux
```

至此安装成功，按下`prefix + r`重载tmux配置。

Tmux Resurrec提供如下两个操作：

*   **保存**，快捷指令是`prefix` + `Ctrl + s`，tmux状态栏在保存开始，保存后分别提示”Saving…”，”Tmux environment saved !”。
*   **恢复**，快捷指令是`prefix` + `Ctrl + r`，tmux状态栏在恢复开始，恢复后分别提示”Restoring…”，”Tmux restore complete !”。

保存时，tmux会话的详细信息会以文本文件的格式保存到`~/.tmux/resurrect`目录，恢复时则从此处读取，由于数据文件是明文的，因此你完全可以自由管理或者编辑这些会话状态文件（如果备份频繁，记得定期清除历史备份）。


## 插件

Install using [tpm](https://github.com/tmux-plugins/tpm)

If you are a tpm user, you can install the theme and keep up to date by adding the following to your .tmux.conf file:

set -g @plugin 'dracula/tmux'
Add any configuration options below this line in your tmux config.


## 主题

1. [OhMyTmux](https://github.com/gpakosz/.tmux).
2. [draculatheme](https://draculatheme.com/tmux).

![image](https://github.com/FrizzleFur/DailyLearning/assets/16328879/570f8c53-c84d-4612-a491-f489968a72ce)


## 参考

* [Tmux使用手册 | louis blog](http://louiszhai.github.io/2017/09/30/tmux/#Buffer%E7%BC%93%E5%AD%98)
* [程序员内功系列--Tmux篇 | iTimothy](https://xiaozhou.net/learn-the-command-line-tmux-2018-04-27.html)
* [tmux美化](https://github.com/gpakosz/.tmux)
* [Tmux 入门介绍 - 文章 - 伯乐在线](http://blog.jobbole.com/87278/)
* [我的tmux配置及说明【k-tmux】](http://www.wklken.me/posts/2015/08/06/linux-tmux.html)
* [Tmux - Linux从业者必备利器 • cenalulu's Tech Blog](http://cenalulu.github.io/linux/tmux/)
* [linux下的终端利器----tmux - CSDN博客](http://blog.csdn.net/gatieme/article/details/49301037)
* [Linux终极shell-Z Shell-用强大的zsh & oh-my-zsh把Bash换掉](http://www.linuxdiyf.com/linux/24777.html)
* [Tmux 入门介绍 - 文章 - 伯乐在线](http://blog.jobbole.com/87278/)
* [Tmux使用手册 | louis blog](http://louiszhai.github.io/2017/09/30/tmux/#Buffer%E7%BC%93%E5%AD%98)
* [我的tmux配置及说明【k-tmux】](http://www.wklken.me/posts/2015/08/06/linux-tmux.html)
* [Tmux - Linux从业者必备利器 • cenalulu's Tech Blog](http://cenalulu.github.io/linux/tmux/)
* [tmux美化](https://github.com/gpakosz/.tmux)
