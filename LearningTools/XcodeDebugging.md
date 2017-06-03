
# Xcode Debugging

> 你的代码，或者任何人的代码中总会有bug存在，**你可以把调试看做是更好地理解代码的一种方式** —— By Advanced_Apple_Debugging_&_Reverse_Engineering_v0.9.5
    
## The Debugging Process

1. Reproduce the problem
> if you cannot reproduce the problem, then you (probably) do not understand it.


2. Gather Debug Information
> Logs, program, state,...
> What is the value of a variable?
> What kind of error?(ex.EXC_BAD_ACCESS)
> What line of code caused the error?
> Which functions or methods led to the error?

3. Form a Hypothesis


4. Try a fix
> Maximize the information gained per fix!


![](http://oc98nass3.bkt.clouddn.com/2017-05-21-14953337356733.jpg)


### Print Debugging

![](http://oc98nass3.bkt.clouddn.com/2017-05-21-14953347612931.jpg)

## TOOL

### LLDB 
> Use commands to debugging, save your time in rebuild and make breakpoints.

#### 常用命令

`po` —— call the description method on an object.
 `p` —— print the value of 数量级 values

#### Print variable frame
` frame variable`
` fr v`

#### Expression命令
expression命令的作用是执行一个表达式，并将表达式返回的结果输出。expression的完整语法是这样的：

Objective-C

expression <cmd-options> -- <expr>
1
expression <cmd-options> -- <expr>

说expression是LLDB里面最重要的命令都不为过。因为他能实现2个功能。

执行某个表达式。 我们在代码运行过程中，可以通过执行某个表达式来动态改变程序运行的轨迹。 假如我们在运行过程中，突然想把self.view颜色改成红色，看看效果。我们不必写下代码，重新run，只需暂停程序，用expression改变颜色，再刷新一下界面，就能看到效果
Objective-C

  // 改变颜色
`  (lldb) expression -- self.view.backgroundColor = [UIColor redColor]`
  // 刷新界面
`  (lldb) expression -- (void)[CATransaction flush]`
将返回值输出。 也就是说我们可以通过expression来打印东西。 假如我们想打印self.view：
Objective-C

    (lldb) expression -- self.view
    (UIView *) $1 = 0x00007fe322c18a10
    
    (lldb) expression -- self.view
    (UIView *) $1 = 0x00007fe322c18a10

`expression` 可以支持多行输入，输入`expression`后回车，会显示行号，每行输入后换行，双击回车代表完成输入，过掉断言即刻看到表达式的效果。


![](http://oc98nass3.bkt.clouddn.com/2017-06-03-14964589170284.jpg)


#### BreakPoint

![](http://oc98nass3.bkt.clouddn.com/2017-05-23-14955445977510.jpg)



##### breakpoint command add给断点添加命令

e.g: 假设我们需要在ViewController的viewDidLoad中查看self.view的值
我们首先给-[ViewController viewDidLoad]添加一个断点
```
(lldb) breakpoint set -n "-[ViewController viewDidLoad]"
'breakpoint 3': where = TLLDB`-[ViewController viewDidLoad] + 20 at ViewController.m:23, address = 0x00000001055e6004
```
可以看到添加成功之后，这个breakpoint的id为3，然后我们给他增加一个命令：`po self.view`
`(lldb) breakpoint command add -o "po self.view" 3`

-o完整写法是--one-liner，表示增加一条命令。3表示对id为3的breakpoint增加命令。
添加完命令之后，每次程序执行到这个断点就可以自动打印出self.view的值了

如果我们一下子想增加多条命令，比如我想在viewDidLoad中打印当前frame的所有变量，但是我们不想让他中断，也就是在打印完成之后，需要继续执行。我们可以这样玩：

(lldb) breakpoint command add 3
Enter your debugger command(s).  Type 'DONE' to end.
> frame variable
> continue
> DONE
输入breakpoint command add 3对断点3增加命令。他会让你输入增加哪些命令，输入'DONE'表示结束。这时候你就可以输入多条命令了

多次对同一个断点添加命令，后面命令会将前面命令覆盖

##### breakpoints添加通过条件

![](http://oc98nass3.bkt.clouddn.com/2017-06-03-14964707712015.jpg)

##### 非重写方法的符号断点
[非重写方法的符号断点](https://objccn.io/issue-19-2/)
假设你想知道 -[MyViewController viewDidAppear:] 什么时候被调用。如果这个方法并没有在MyViewController 中实现，而是在其父类中实现的，该怎么办呢？试着设置一个断点，会出现以下结果：

```
(lldb) b -[MyViewController viewDidAppear:]
Breakpoint 1: no locations (pending).
WARNING:  Unable to resolve breakpoint to any actual locations.
```
因为 LLDB 会查找一个符号，但是实际在这个类上却找不到，所以断点也永远不会触发。你需要做的是为断点设置一个条件 `[self isKindOfClass:[MyViewController class]]`，然后把断点放在 `UIViewController` 上。正常情况下这样设置一个条件可以正常工作。但是这里不会，因为我们没有父类的实现。

`viewDidAppear`: 是苹果实现的方法，因此没有它的符号；在方法内没有 `self` 。如果想在符号断点上使用 `self`，你必须知道它在哪里 (它可能在寄存器上，也可能在栈上；在 x86 上，你可以在 $esp+4 找到它)。但是这是很痛苦的，因为现在你必须至少知道四种体系结构 (x86，x86-64，armv7，armv64)。想象你需要花多少时间去学习命令集以及它们每一个的调用约定，然后正确的写一个在你的超类上设置断点并且条件正确的命令。幸运的是，这个在 facebook的[Chisel](https://github.com/facebook/chisel) 被解决了。这被成为 `bmessage`：
```
(lldb) bmessage -[MyViewController viewDidAppear:]
Setting a breakpoint at -[UIViewController viewDidAppear:] with condition (void*)object_getClass((id)$rdi) == 0x000000010e2f4d28
Breakpoint 1: where = UIKit`-[UIViewController viewDidAppear:], address = 0x000000010e11533c
LLDB 和 Python
```

##### command和expr的组合
建立一个breakPoint.
使用expr表达式
用command添加到br上面。

```
br com add 1
>expr ...
>continue
>DONE
```
#### Thread

`thread until (line number)`
`thread select (thread number)`
`thread return (value)`
`frame variable ` 查看线程相关变量
`bt (thread backtrace)`  backtrace

#### Watchpoint

#### Chisel
[Chisel Tutorial](https://www.raywenderlich.com/72244/video-tutorial-using-lldb-ios-part-7-using-chisel)
[Chisel](https://github.com/facebook/chisel) 

`border` 标记view
`mask` 标记view
`pca` layer tree
`presponder` responder chain
`pclass` class hierachy
`vs` vs view,  change the view hierachy
`caflush` refresh screen
`visualize` previews views

`pviews` Print the recursive view description for the key window.	
`pvc` Print the recursive view controller description for the key window.	
`fv` Find a view in the hierarchy whose class name matches the provided regex.	
`fvc`  Find a view controller in the hierarchy whose class name matches the provided regex.
`bmessage`  Set a symbolic breakpoint on the method of a class or the method of an instance without worrying which class in the hierarchy actually implements the method.
`wivar`	 Set a watchpoint on an instance variable of an object.	

###  Xcode Debugging Hotkeys
>Here is a listing of Xcode hotkeys (related to debugging) we mentioned in this course. Let us know if we missed any!

```
Show Navigator (⌘+0)
Show Debug Navigator (⌘+6)
Show Breakpoint Navigator (⌘+7)
Show Debug Area (⌘+Shift+Y)
Open Documentation (⌘+Shift+0)
Step Over (F6)
Step Into (F7)
Step Out (F8)
Continue (⌘+Ctrl+Y)
Build (⌘+B)
Run (⌘+R)
Activate/Deactivate Breakpoint (⌘+Y)
Quick Search (⌘+Shift+O)
```

[Xcode Debugging Hotkeys](https://classroom.udacity.com/courses/ud774/lessons/4388088536/concepts/44197787450923)



### Icon Injection Plugin for Xcode

[Icon Injection Plugin for Xcode](https://github.com/johnno1962/injectionforxcode#user-content-use-with-appcode)

![Icon Injection Plugin for Xcode](https://github.com/johnno1962/injectionforxcode/blob/master/documentation/images/injected.gif)

> 一个Xcode的插件，让你在改完代码后无需重新运行Xcode就可以看到效果。

将需要调试的代码写到`injected`这个方法中，然后在和这个方法中设置一个断言，使用`Ctr + =`,即会停在这个断言里，每次修改，使用一下`Ctr + =`就会重新注入，释放断言就可以看到效果。

```
- (void)injected
{
    NSLog(@"I've been injected: %@", self);
}
```

>The plugin can be removed either via Alcatraz, or by running:
> `rm -rf ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/InjectionPlugin.xcplugin`


**注意**

```
- (void)injected as an instance method, which gives you the chance to re-update an object with new contexts.
+ (void)injected as a class method, making it possible to update globals with new information
Listening for INJECTION_BUNDLE_NOTIFICATION, allowing other classes to listen out for injection calls, this is useful for providing app level changes.

```
**原理**

它通过解析应用程序的生成日志来确定源文件是如何最后编译的。用这个包将重新编译成一个`bundle`，该`bundle`使用动态加载程序注入应用程序。现在在`bundle`中就有两个版本，原版本和新的修改版本。修改后的版本是“调和”在原版本发生变化。

### LLDB cheatsheet

>A cheatsheet for commands and ideas on how to use LLDB.

List all commands and aliases.


`(lldb) help po`


`(lldb) help break set`


`(lldb) apropos step-in`








`   (lldb) image lookup -rn 'UIViewController\ set\w+:\]'`


`(lldb) image lookup -rn . Security`
Look up all code located within the Security module. 


`(lldb) image lookup -a 0x10518a720`


`(lldb) image lookup -s mmap`


















`(lldb) rbreak viewDid -s SwiftRadio`














`(lldb) expression -lswift -O -- UIApplication.shared`
Print the shared UIApplication instance in a Swift context.


 Advanced Apple Debugging & Reverse Engineering Appendix A: LLDB Cheatsheet (lldb) expression -u0 -O -- [UIApplication test]
 Advanced Apple Debugging & Reverse Engineering
Advanced Apple Debugging & Reverse Engineering Appendix A: LLDB Cheatsheet


## 参考

[The Debugging Process](https://classroom.udacity.com/courses/ud774/lessons/4377638660/concepts/43903186280923)

[Advanced Apple Debugging & Reverse Engineering](https://videos.raywenderlich.com/courses/82-rwdevcon-2017-vault-workshops/lessons/1)

[Debugging in Xcode2012](https://developer.apple.com/videos/play/wwdc2012/412/)

[What's New in LLDB 2015](https://developer.apple.com/videos/play/wwdc2015/402/)

#### LLDB

[小笨狼与LLDB的故事](http://www.jianshu.com/p/e89af3e9a8d7)
[lldb.llvm.org](https://lldb.llvm.org/tutorial.html)
[Chisel](https://github.com/facebook/chisel) 
