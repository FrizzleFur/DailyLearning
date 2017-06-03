
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


#### LLDB


##### Print variable frame
` frame variable`
` fr v`

##### Expression命令
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



##### BreakPoint

![](http://oc98nass3.bkt.clouddn.com/2017-05-23-14955445977510.jpg)


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


## TOOL

### Icon Injection Plugin for Xcode

[Icon Injection Plugin for Xcode](https://github.com/johnno1962/injectionforxcode#user-content-use-with-appcode)

![Icon Injection Plugin for Xcode ](http://oc98nass3.bkt.clouddn.com/2017-06-03-Icon Injection Plugin for Xcode .gif)

> 一个Xcode的插件，让你在改完代码后无需重新运行Xcode就可以看到效果。

将需要调试的代码写到`injected`这个方法中，然后在和这个方法中设置一个断言，使用`Ctr + =`,即会停在这个断言里，每次修改，使用一下`Ctr + =`就会重新注入，释放断言就可以看到效果。

```
- (void)injected
{
    NSLog(@"I've been injected: %@", self);
}
```
**注意**

```
- (void)injected as an instance method, which gives you the chance to re-update an object with new contexts.
+ (void)injected as a class method, making it possible to update globals with new information
Listening for INJECTION_BUNDLE_NOTIFICATION, allowing other classes to listen out for injection calls, this is useful for providing app level changes.

```
**原理**

它通过解析应用程序的生成日志来确定源文件是如何最后编译的。用这个包将重新编译成一个`bundle`，该`bundle`使用动态加载程序注入应用程序。现在在`bundle`中就有两个版本，原版本和新的修改版本。修改后的版本是“调和”在原版本发生变化。

## LLDB

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


## 参考

[The Debugging Process](https://classroom.udacity.com/courses/ud774/lessons/4377638660/concepts/43903186280923)

[Advanced Apple Debugging & Reverse Engineering](https://videos.raywenderlich.com/courses/82-rwdevcon-2017-vault-workshops/lessons/1)

[Debugging in Xcode2012](https://developer.apple.com/videos/play/wwdc2012/412/)

[What's New in LLDB 2015](https://developer.apple.com/videos/play/wwdc2015/402/)

#### LLDB

[小笨狼与LLDB的故事](http://www.jianshu.com/p/e89af3e9a8d7)

