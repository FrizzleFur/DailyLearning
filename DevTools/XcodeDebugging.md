
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

breakpoint

调试过程中，我们用得最多的可能就是断点了。LLDB中的断点命令也非常强大

breakpoint set

breakpoint set命令用于设置断点，LLDB提供了很多种设置断点的方式：

使用-n根据方法名设置断点：

e.g: 我们想给所有类中的viewWillAppear:设置一个断点:

    (lldb) breakpoint set -n viewWillAppear:
    Breakpoint 13: 33 locations.
使用-f指定文件

e.g: 我们只需要给ViewController.m文件中的viewDidLoad设置断点：

    (lldb) breakpoint set -f ViewController.m -n viewDidLoad
    Breakpoint 22: where = TLLDB`-[ViewController viewDidLoad] + 20 at ViewController.m:22, address = 0x000000010272a6f4
这里需要注意，如果方法未写在文件中（比如写在category文件中，或者父类文件中），指定文件之后，将无法给这个方法设置断点。

使用-l指定文件某一行设置断点

e.g: 我们想给ViewController.m第38行设置断点

(lldb) breakpoint set -f ViewController.m -l 38
Breakpoint 23: where = TLLDB`-[ViewController text:] + 37 at ViewController.m:38, address = 0x000000010272a7d5
使用-c设置条件断点

e.g: text:方法接受一个ret的参数，我们想让ret == YES的时候程序中断：

(lldb) breakpoint set -n text: -c ret == YES
Breakpoint 7: where = TLLDB`-[ViewController text:] + 30 at ViewController.m:37, address = 0x0000000105ef37ce
使用-o设置单次断点

e.g: 如果刚刚那个断点我们只想让他中断一次：

(lldb) breakpoint set -n text: -o
'breakpoint 3': where = TLLDB`-[ViewController text:] + 30 at ViewController.m:37, address = 0x000000010b6f97ce
breakpoint command

有的时候我们可能需要给断点添加一些命令，比如每次走到这个断点的时候，我们都需要打印self对象。我们只需要给断点添加一个po self命令，就不用每次执行断点再自己输入po self了

breakpoint command add

breakpoint command add命令就是给断点添加命令的命令。

e.g: 假设我们需要在ViewController的viewDidLoad中查看self.view的值
我们首先给-[ViewController viewDidLoad]添加一个断点

(lldb) breakpoint set -n "-[ViewController viewDidLoad]"
'breakpoint 3': where = TLLDB`-[ViewController viewDidLoad] + 20 at ViewController.m:23, address = 0x00000001055e6004
可以看到添加成功之后，这个breakpoint的id为3，然后我们给他增加一个命令：po self.view

(lldb) breakpoint command add -o "po self.view" 3
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
breakpoint command list

如果想查看某个断点已有的命令，可以使用breakpoint command list。
e.g: 我们查看一下刚刚的断点3已有的命令

(lldb) breakpoint command list 3
'breakpoint 3':
    Breakpoint commands:
      frame variable
      continue
可以看到一共有2条命令，分别为frame variable和continue

breakpoint command delete

有增加就有删除，breakpoint command delete可以让我们删除某个断点的命令
e.g: 我们将断点3中的命令删除:

(lldb) breakpoint command delete 3
(lldb) breakpoint command list 3
Breakpoint 3 does not have an associated command.
可以看到删除之后，断点3就没有命令了

breakpoint list

如果我们想查看已经设置了哪些断点，可以使用breakpoint list
e.g:

(lldb) breakpoint list
Current breakpoints:
4: name = '-[ViewController viewDidLoad]', locations = 1, resolved = 1, hit count = 0
  4.1: where = TLLDB`-[ViewController viewDidLoad] + 20 at ViewController.m:23, address = 0x00000001055e6004, resolved, hit count = 0
我们可以看到当前只有一个断点，打在-[ViewController viewDidLoad]上，id是4

breakpoint disable/enable

有的时候我们可能暂时不想要某个断点，可以使用breakpoint disable让某个断点暂时失效
e.g: 我们来让刚刚的断点4失效

(lldb) breakpoint disable 4
1 breakpoints disabled.
输入完命令之后，显示断点已经失效

当我们又需要这个断点的时候，可以使用breakpoint enable再次让他生效
e.g: 重新启用断点4

(lldb) breakpoint enable 4
1 breakpoints enabled.
breakpoint delete

如果我们觉得这个断点以后再也用不上了，可以用breakpoint delete直接删除断点.
e.g: 删除断点4

(lldb) breakpoint delete 4
1 breakpoints deleted; 0 breakpoint locations disabled.
如果我们想删除所有断点，只需要不指定breakpoint delete参数即可

(lldb) breakpoint delete 
About to delete all breakpoints, do you want to do that?: [Y/n] y
All breakpoints removed. (1 breakpoint)
删除的时候他会提示你，是不是真的想删除所有断点，需要你再次输入Y确认。如果想直接删除，不需要他的提示，使用-f命令选项即可

(lldb) breakpoint delete -f
All breakpoints removed. (1 breakpoint)
实际平时我们真正使用breakpoint命令反而比较少，因为Xcode已经内置了断点工具。我们可以直接在代码上打断点，可以在断点工具栏里面查看编辑断点，这比使用LLDB命令方便很多。不过了解LLDB相关命令可以让我们对断点理解更深刻。
如果你想了解怎么使用Xcode设置断点，可以阅读这篇文章《Xcode中断点的威力》


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
Watchpoint 

`watchpoint set v (变量名)`
跟踪变量的值的变化，如果变量地址变成`0x0000000000000000`就说明变量被释放，指向了`nil`

![](http://oc98nass3.bkt.clouddn.com/2017-08-15-15027669682910.jpg)


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

>A cheatsheet for commands and ideas on how to use LLDB.### Getting help
`(lldb) help`
List all commands and aliases.


`(lldb) help po`Get help documentation for po (expression) command. 


`(lldb) help break set`Get help documentation for breakpoint set. 


`(lldb) apropos step-in`Search through help documentation containing step-in.

### Finding code

  `(lldb) image lookup -rn UIAlertController`Look up all code containing UIAlertController that's compiled or loaded into an executable.

`  (lldb) image lookup -rn (?i)hosturl`Case insensitive search for any code that contains "hosturl".


`   (lldb) image lookup -rn 'UIViewController\ set\w+:\]'`Look up all setter property methods UIViewController implements or overrides. 


`(lldb) image lookup -rn . Security`
Look up all code located within the Security module. 


`(lldb) image lookup -a 0x10518a720`Look up code based upon address 0x10518a720. 


`(lldb) image lookup -s mmap`Look up code for the symbol named mmap.

### Breakpoints

`  (lldb) b viewDidLoad`Creates a breakpoint on all methods named viewDidLoad for both Swift and Objective-C.
`  (lldb) b setAlpha:`Creates a breakpoint on either the setAlpha: Objective-C method or the setter of the Objective-C alpha property.

`  (lldb) b -[CustomViewControllerSubclass viewDidLoad]`Creates a breakpoint on the Objective-C method [CustomViewControllerSubclass viewDidLoad].

`  (lldb) rbreak CustomViewControllerSubclass.viewDidLoad`Creates a regex breakpoint to match either an Objective-C or Swift class CustomViewControllerSubclass which contains viewDidLoad. Could be Objective-C - [CustomViewControllerSubclass viewDidLoad] or could be Swift ModuleName.CustomViewControllerSubclass.viewDidLoad () -> ().

`  (lldb) breakpoint delete`Deletes all breakpoints.

`  (lldb) breakpoint delete 2`Deletes breakpoint ID 2.

`  (lldb) breakpoint list`List all breakpoints and their IDs.

`  (lldb) rbreak viewDid`Creates a regex breakpoint on .*viewDid.*. 

`(lldb) rbreak viewDid -s SwiftRadio`Creates a breakpoint on .*viewDid.*, but restricts the breakpoint(s) to the SwiftRadio module.

`  (lldb) rbreak viewDid(Appear|Disappear) -s SwiftHN`Creates a breakpoint on viewDidAppear or viewDidDisappear inside the SwiftHN module.

`  (lldb) rb "\-\[UIViewController\ set" -s UIKit`Creates a breakpoint on any Objective-C style breakpoints containing - [UIViewController set within the UIKit module.

`  (lldb) rb . -s SwiftHN -o`Create a breakpoint on every function in the SwiftHN module, but remove all breakpoints once the breakpoint is hit.
`  (lldb) rb . -f ViewController.m`Create a breakpoint on every function found in ViewController.m.

### Expressions

`  (lldb) po "hello, debugger"`Prints "hello, debugger" regardless of the debugging context.

`(lldb) expression -lobjc -O -- [UIApplication sharedApplication]`Print the shared UIApplication instance in an Objective-C context. 

`(lldb) expression -lswift -O -- UIApplication.shared`
Print the shared UIApplication instance in a Swift context.

Creates a breakpoint on getenv, executes the getenv function, and stops at the beginning of the getenv function.          (lldb) b getenv(lldb) expression -i0 -- getenv("HOME") raywenderlich.com 361
 Advanced Apple Debugging & Reverse Engineering Appendix A: LLDB Cheatsheet (lldb) expression -u0 -O -- [UIApplication test]Don't let LLDB unwind the stack if you’re executing a method that will cause the program to crash.Declares a global NSString* called globalString. (lldb) expression -g -O -lobjc -- [NSObject new]Debug the debugger that's parsing the [NSObject new] Objective-C expression.Stepping  (lldb) thread return falseReturn early from code with false.Step in.Step over.Step out of a function.Step in if about to execute a function. Step an assembly instruction otherwise.GDB formatting  (lldb) p/x 128Print value in hexadecimal.  (lldb) expression -p -- NSString *globalString = [NSStringstringWithUTF8String: "Hello, Debugger"];(lldb) po globalStringHello, Debugger   (lldb) thread step-in(lldb) s (lldb) thread step-over(lldb) n (lldb) thread step-out(lldb) finish (lldb) thread step-inst(lldb) ni  raywenderlich.com 362
 Advanced Apple Debugging & Reverse EngineeringAppendix A: LLDB Cheatsheet   (lldb) p/d 128Print value in decimal.  (lldb) p/t 128Print value in binary.  (lldb) p/a 128Print value as address.  (lldb) x/gx 0x000000010fff6c40Get the value pointed at by 0x000000010fff6c40 and display in 8 bytes. (lldb) x/wx 0x000000010fff6c40Get the value pointed at by 0x000000010fff6c40 and display in 4 bytes.Memory  (lldb) memory read 0x000000010fff6c40Read memory at address 0x000000010fff6c40.Grab an instance of a remote file and write it to /tmp/file on your computer.Registers & assembly  (lldb) register read -aDisplay all registers on the system.  (lldb) register read rdi rsiRead the RSI and the RDI register in x64 assembly. (lldb) register write rsi 0x0Set the RSI register to 0x0 in x64 assembly. (lldb) register write rflags `$rflags ^ 64`      (lldb) po id $d = [NSData dataWithContentsOfFile:@"..."](lldb) mem read `(uintptr_t)[$d bytes]` `(uintptr_t)[$d bytes] +(uintptr_t)[$d length]` -r -b -o /tmp/file     raywenderlich.com 363
Advanced Apple Debugging & Reverse Engineering Appendix A: LLDB CheatsheetToggle the zero flag in x64 assembly (augment if condition logic).  (lldb) register write rflags `$rflags | 64`Set the zero flag (set to 1) in x64 assembly (augment if condition logic).  (lldb) register write rflags `$rflags & ~64`Clear the zero flag (set to 0) in x64 assembly (augment if condition logic).  (lldb) register write pc `$pc+4`Increments the program counter by 4.  (lldb) disassembleDisplay assembly for function in which you’re currently stopped.  (lldb) disassemble -pDisassemble around current location; useful if in the middle of a function.  (lldb) disassemble -bDisassemble function while showing opcodes; useful for learning what is responsible for what.  (lldb) disassemble -n '-[UIViewController setTitle:]'Disassemble the Objective-C -[UIViewController setTitle:] method. (lldb) disassemble -a 0x000000010b8d972dDisassemble the function that contains the address 0x000000010b8d972d.Modules  (lldb) image listList all modules loaded into the executable's process space.  (lldb) image list -bGet the names of all the modules loaded into the executable's process space.  (lldb) process load /Path/To/Module.framework/ModuleLoad the module located at path into the executable's process space.



### 我的debug速查表（入门级）My debug cheatsheet

[我的debug速查表（入门级）My debug cheatsheet](http://www.iosre.com/t/debug-my-debug-cheatsheet/3778)

debug cheetsheet
common
查找进程：

```
ps aux | grep /App
ps -e | grep /Applications
查找文件：

grep -r ToBeFind /System/Library/
分离fat binary

lipo -thin armv7 WeChat.decrypted -output WeChat_armv7.decrypted
lipo -thin armv64 xxx.decrypted -output xxx_arm64.decrypted
class dump

class-dump --list-arches AlipayWallet.decrypted

class-dump -S -s -H WeChat_armv7.decrypted -o dumparmv7
class-dump -s -S -H --arch armv7 AlipayWallet.decrypted -o dumpAlipay
lldb
参考 
- https://github.com/iosre/iOSAppReverseEngineering43
- http://objccn.io/issue-19-2/27

帮助

help frame
打印UI结构

po [[[UIWindow keyWindow] rootViewController] _printHierarchy]    (iOS 8)
po [[UIWindow keyWindow] recursiveDescription]
栈信息

bt (backtrace)
bt all (all threads)
objc_msgSend 参数打印

po $r0
p (char*)$r1
p (SEL)$r1
返回地址

p/x $lr
断点

br s -a 0x0023234f 
breakpoint set -F "-[NSArray objectAtIndex:]"

br s -a 0x02107730+0x000ab000 -c '(BOOL)[(NSString *)$r2 isEqualToString:@"snakeninny"]'

b ptrace
列举模块

image -o -f
lldb基础命令

c
n
s
frame info
expr

thread return
breakpoint command add 1
远程调试

debugserver *:1234 -a AlipayWallet
debugserver -x backboard *:1234 /var/mobile/Containers/Bundle/Application/9DB7CE45-3B4C-42A3-9D4D-49A3A5122903/AlipayWallet.app/AlipayWallet
lldb连接远程调试

(lldb) process connect connect://192.168.199.164:1234
lldb expr例子

(lldb) expr char *$str = (char *)malloc(8)
(lldb) expr (void)strcpy($str, "munkeys")
(lldb) expr $str[1] = 'o'
(char) $0 = 'o'
(lldb) p $str
(char *) $str = 0x00007fd04a900040 "monkeys"

(lldb) x/4c $str
(lldb) x/1w `$str + 3`
(lldb) expr (void)free($str)

(lldb) expr id $myView = (id)0x7f82b1d01fd0
(lldb) expr (void)[$myView setBackgroundColor:[UIColor blueColor]]
(lldb) expr (void)[CATransaction flush]

(lldb) po [$myButton allTargets]

(lldb) p (ptrdiff_t)ivar_getOffset((struct Ivar *)class_getInstanceVariable([MyView class], "_layer"))
观察点

(lldb) watchpoint set expression -- (int *)$myView + 8
arm64

param1 $x0
param2 $x1

po $x0
p (char*)$x1
cycript
参考： http://www.cycript.org/manual/17

开始

cycript -p BinaryName
打印UI结构

[[UIWindow keyWindow] recursiveDescription].toString()
[[[UIWindow keyWindow] rootViewController] _printHierarchy].toString()
打印沙盒Documents路径

[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]
基本使用

cy# [#0xb226710 url]
@"ww4fd1rfRDShBo_4K6rqfwAAACMAAQED"

cy# c = #0x1752d8c0
cy#"<FavAudioPlayerController: 0x1752d8c0; frame = (0 0; 290 60); autoresize = W; layer = <CALayer: 0x172dc2b0>>"
cy# c->m_audioInfo
cy#"<FavAudioInfo: 0x172b2a30>"
cy# c->m_audioInfo.m_nsAudioPath
linker
-Wl,-sectcreate,__RESTRICT,__restrict,/dev/null
into Other link flag
Anti
iHex replace RESTRICT , restrict
ldid -S AppName
AppSync
Info.plist
输出bundle id

/var/mobile/Containers/Bundle/Application/9DB7CE45-3B4C-42A3-9D4D-49A3A5122903/AlipayWallet.app root# cat Info.plist | grep com.
    <string>com.alipay.iphoneclient</string>
dumpdecrypted
https://github.com/stefanesser/dumpdecrypted

例子

scp -P 2222 Security/dumpdecrypted-master/dumpdecrypted.dylib root@localhost:/var/mobile/Containers/Data/Application/BA2644DB-450F-4DB0-A71F-A38F65488A48/Documents/

scp ~/sec/dumpdecrypted-master/dumpdecrypted.dylib root@192.168.199.164:/var/mobile/Containers/Data/Application/72AB36DD-2E9B-47C0-9695-099235E40C3C/Documents/
dumpdecrypted.dylib

everettjfs-iPhone:/var/mobile/Containers/Data/Application/72AB36DD-2E9B-47C0-9695-099235E40C3C/Documents root# DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib /var/mobile/Containers/Bundle/Application/2DAD493D-6275-4CED-8242-BDEF27F36740/AlipayWallet.app/AlipayWallet
theos
https://github.com/theos/theos3

开始

everettjf@e WeChatVoiceSaver (master)]$ ~/sec/theos/bin/nic.pl
chisel
参考：https://github.com/facebook/chisel

usbmuxd
https://cgit.sukimashita.com/usbmuxd.git/snapshot/usbmuxd-1.0.8.tar.gz2
https://cgit.sukimashita.com/usbmuxd.git/3
First:

cd python-client 
python tcprelay.py -t 22:2222
Then:

ssh root@localhost -p 2222
```


## 参考

[The Debugging Process](https://classroom.udacity.com/courses/ud774/lessons/4377638660/concepts/43903186280923)

[Advanced Apple Debugging & Reverse Engineering](https://videos.raywenderlich.com/courses/82-rwdevcon-2017-vault-workshops/lessons/1)

[Debugging in Xcode2012](https://developer.apple.com/videos/play/wwdc2012/412/)

[What's New in LLDB 2015](https://developer.apple.com/videos/play/wwdc2015/402/)

#### LLDB

[小笨狼与LLDB的故事](http://www.jianshu.com/p/e89af3e9a8d7)

[lldb.llvm.org](https://lldb.llvm.org/tutorial.html)


[Chisel](https://github.com/facebook/chisel) 

