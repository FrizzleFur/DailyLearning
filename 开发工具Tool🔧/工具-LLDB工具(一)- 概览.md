# 工具-LLDB工具(一)- 概览



## LLDB 是什么？
> “如果调试是删除 bug 的过程，那么编程就是引入 bug 的过程。”（Edsger W. Dijkstra）

LLDB是下一代高性能调试器。它构建为一组可重用的组件，可以高度利用较大的LLVM项目中的现有库，例如Clang表达式解析器和LLVM反汇编程序。
LLDB是Mac OS X上Xcode的默认调试器，支持在桌面和iOS设备和模拟器上调试C，Objective-C和C ++。


## LLDB 命令结构


知道了 LLDB 是什么，还需要了解其命令结构及语法，这样才能告别死记命令，开启压榨 LLDB 之路了。LLDB 通用结构的形式如下：

<command> [<subcommand> [<subcommand>...]] <action> [-options [option-value]] [argument [argument...]]

其中：

command、subcommand：LLDB调试命令的名称。命令和子命令按层级结构来排列：一个命令对象为跟随其的子命令对象创建一个上下文，子命令又为其子命令创建一个上下文，依此类推。

action：命令操作，想在前面的命令序列的上下文中执行的一些操作。

options：命令选项，行为修改器(action modifiers)。通常带有一些值。

argument：命令参数，根据使用的命令的上下文来表示各种不同的东西。

[]：表示命令是可选的，可以有也可以没有。

举个例子：

命令：breakpoint set -n main对应到上面的语法就是：

command：breakpoint 断点命令

action：set 设置断点

option：-n 表根据方法 name 设置断点

arguement：main 表示方法名为 main



## LLDB 常用命令总结
辅助记忆：apropos
当我们并不能完全记得某个命令的时候，使用 apropos通过命令中的某个关键字就可以找到所有相关的命令信息。

比如: 我们想使用stop-hook的命令，但是已经不记得stop-hook命令是啥样了：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190412091420.png)

1. [LLDB to GDB Command Map](https://lldb.llvm.org/lldb-gdb.html)
一.断点设置
关于断点设置，多数人都习惯用图形界面去做，但在调试中有些场景仅仅靠图形界面还是不够的，比如：如何通过断点实现类似 KVO 那样对成员变量变化的监听呢？（别跟我说你要加代码重写set方法…即使这样也不靠谱）。下面一一罗列那些好用的断点命令：

breakpoint list：查看所有断点列表

breakpoint delete：删除所有断点（可跟组号删除指定组）

breakpoint disable/enable：禁用 启用指定断点

breakpoint set -r some：遍历整个项目中包含 some 这个字符的所有方法并设置断点

breakpoint 支持按文件名、函数名、行数、正则等各种条件筛选设置断点，请结合语法并参考官方文档

watchpoint set expression 0x10cc64d50：在内存中为地址为0x10cc64d50的对象设置内存断点

watchpoint set variable xxoo：为当前对象的变量 xxoo 设置内存断点

target stop-hook add -o "frame variable"：添加每次程序 stop 时都希望执行的命令：frame variable（打印当前栈内的所有变量）

target stop-hook、watchpoint 的增删改查命令与 breakpoint 的基本相同

更多变态断点玩法需自定义插件支持，迫不及待的你请快进此文 》》》



## 参考

1. [LLDB to GDB Command Map](https://lldb.llvm.org/lldb-gdb.html)
2. [LLDB 知多少](https://mp.weixin.qq.com/s/VEpClFwTQn66f8INeHRFlQ)
3. [DerekSelander/lldb_fix: RESOLVED IN XCODE 10.2! Fix for LLDB (in Xcode 10) which incorrectly imports the wrong API headers](https://github.com/DerekSelander/lldb_fix)