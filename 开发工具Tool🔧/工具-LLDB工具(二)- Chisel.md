# 工具-LLDB工具(二)- Chisel - Speed your Debugging!

>`Chisel is a collection of LLDB commands to assist debugging iOS apps.`
[`Chisel`](https://github.com/facebook/chisel)是`facebook`团队的工程师用`python`写的`LLDB`的拓展命令集合。里面的一些命令可以让你的调试加速。


## Chisel安装

```
brew update
brew install chisel
```

## Chisel常用命令

### `pviews` 
>打印view层次

也许你想打印某个`UIView`的frame或者内存地址，无需再使用`Capture View Hierarchy`, 直接使用`pviews`命令即刻

```
pviews [--up] [--depth=depth] <aView>
```
`--up/-u`: 以view为起始位置，向上打印，直到打印到window层
`--depth/-d`: 传入int类型，表示打印的层数，0表示没有限制
e.g: 打印一下`self.view`层级:

```objc
(lldb) pviews self.view
<UIView: 0x7fee7ae1fa60; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x7fee7ae1d3c0>>
   | <UIButton: 0x7fee7ae1dd90; frame = (54 244; 46 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x7fee7ae1e300>>
   | <UIView: 0x7fee7ae1f2e0; frame = (35 312; 240 128); autoresize = RM+BM; layer = <CALayer: 0x7fee7ae1f660>>
   | <_UILayoutGuide: 0x7fee7ae1fc20; frame = (0 0; 0 0); hidden = YES; layer = <CALayer: 0x7fee7ae20030>>
   | <_UILayoutGuide: 0x7fee7ae20b30; frame = (0 0; 0 0); hidden = YES; layer = <CALayer: 0x7fee7ae1d100>>
   | <UILabel: 0x7fee7ae1d3f0; frame = (0.4 150; 58.25 20.5); text = 'aaa'; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x7fee7ae1bb30>>
```

`fvc` +  `VC`类名  =   找`ViewController`

`fv`  + UI控件类名  =  找`UIView`

### alamborder

>所有带有`Ambiguous Layouts`
的view立即会被渲染上红色border

```objc 
Syntax: alamborder [--color=color] [--width=width]
--color
/-c
: border的颜色，参数为string类型，比如'red', 'green', 'magenta'等，不设置默认为红色。
--width
/-w
: border的宽度，参数为CGFloat类型，不设置默认宽度为2。
```

e.g: 假设我们写了这么一段代码，可以明显看出，我们没有设置X轴的位置。
```objc
UIView *subview = [UIView new];[self.view addSubview:subview];[subview mas_makeConstraints:^(MASConstraintMaker *make) { make.top.offset(100); make.size.equalTo(@100);}];
```
运行代码之后，在`LLDB`控制台输入`alamborder`
```
(lldb) alamborder
```

![](http://upload-images.jianshu.io/upload_images/225323-fe49b0a9aebb52b6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### pinvocation
>打印方法调用堆栈，仅支持x86

语法：`Syntax: pinvocation [--all]`
`--all/-a`: 表示打印所有堆栈，不设置默认只打印当前堆栈
说明：与bt命令类似，不过信息比bt打印得更详细，遗憾的是只能支持x86

e.g: 打印一下当前堆栈
```objc
(lldb) pinvocation
frame #0: 0x000962aa TMasonry`-[ViewController viewDidLoad](self=0x7bf2d9c0, _cmd="viewDidLoad") + 234 at ViewController.m:28
NSInvocation: 0x7bf433e0
self: 0x7bf2d9c0
```
### pkp

>通过`-valueForKeyPath:`打印`key path`对应的值。

语法： `Syntax: pkp <keypath>`  
<keypath>: 需要打印的路径，如self.view
说明：以前打印属性一般都用po obj.xxx，现在我想用pkp obj.xxx是一个更好的选择了，因为po obj.xxx是调用getter方法，如果没有getter方法就无法打印了。pkp obj.xxx不仅会调用getter方法，没有getter方法还会去查找成员变量

e.g: 打印一下self.view
```objc
(lldb) pkp self.view
<UIView: 0x7fd1da52d5d0; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x7fd1da52d740>>
pivar
```
### presponder
> 打印响应链
语法： Syntax: presponder <startResponder>
<startResponder>: UIResponder对象，响应链开始位置

e.g: 打印一个tableView的响应链
```objc
(lldb) presponder tableView
<UITableView: 0x7fde54810e00; frame = (0 0; 0 0); clipsToBounds = YES; gestureRecognizers = <NSArray: 0x7fde52519ac0>; layer = <CALayer: 0x7fde5253b4c0>; contentOffset: {0, 0}; contentSize: {0, 220}>
   | <UIView: 0x7fde5255c710; frame = (0 0; 600 600); autoresize = W+H; layer = <CALayer: 0x7fde5253b300>>
   |    | <TableViewController: 0x7fde52491310>
```

### taplog
>将点击的`view`打印出来，这个命令对于查找哪个`view`非常有帮助

语法：Syntax: `taplog`
说明：要查看的view必须能接收点击事件，也就是他的`userInteractionEnabled`必须为`YES`才能被找到，`UILabel`和`UIImageView`默认`userInteractionEnabled`为NO。

用法：我们需要先将程序暂停，输入`taplog`，程序会自己运行，这时候点击你需要查看的`view`，控制台上就会显示出你刚刚点击的`view`相关信息

e.g: 我们先将程序暂停，输入`taplog`
```objc
(lldb) taplog
Process 28421 resuming
程序会自己运行，我们再点击一个UIButton：
<UIButton: 0x7fe6785284e0; frame = (54 244; 46 30); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x7fe678528a50>>
```

### vs
>在`view`层级中搜索`view`，并显示出来
语法：Syntax: `vs <view>`
<view> :要查找的`view`

说明：相比fv，vs主要用于显示view在屏幕上的位置，2个命令可以配合使用.

e.g: 假设我们要找屏幕上的一个`view`, 首先用`fv`查找`UIView`类型的`view`

```objc
(lldb) fv UIView 0x7fbcf37228d0 UIView 0x7fbcf3725e90 UIView
```
然后看看这2个`view`到底哪个是我们想要找的`view`
```objc
(lldb) vs 0x7fbcf3725e90
```

Use the following and (q) to quit.
* (w) move to superview
* (s) move to first subview
* (a) move to previous sibling
* (d) move to next sibling
* (p) print the hierarchy

```
<UIView: 0x7fbcf3725e90; frame = (0 100; 100 100); layer = <CALayer: 0x7fbcf3712a40>>
```

输入命令后他会帮我们在屏幕上用粉红色标志出来`vs`
的`view`
![](http://upload-images.jianshu.io/upload_images/225323-8c6f6322d07f5bc3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### 官方参考命令列表

Command | Description	| iOS  | OS X
---   |    ---   |  ---    |  ---   
pviews |	Print the recursive view description for the key window. |		Yes |	Yes
pvc |	Print the recursive view controller description for the key window.	 |	Yes	 |	No
visualize	 |	Open a UIImage, CGImageRef, UIView, CALayer, NSData (of an image), UIColor, CIColor, or CGColorRef in Preview.app on your Mac. |		Yes |		No
fv	 |	Find a view in the hierarchy whose class name matches the provided regex.	 |	Yes	 |	No
fvc	 |	Find a view controller in the hierarchy whose class name matches the provided regex.	 |	Yes	 |	No
show/hide	 |	Show or hide the given view or layer. You don't even have to continue the process to see the changes!	 |	Yes |		Yes
mask/unmask	 |	Overlay a view or layer with a transparent rectangle to visualize where it is.	 |	Yes |		No
border/unborder |		Add a border to a view or layer to visualize where it is. |		Yes |		Yes
caflush |		Flush the render server (equivalent to a "repaint" if no animations are in-flight).	 |	Yes	 |	Yes
bmessage |		Set a symbolic breakpoint on the method of a class or the method of an instance without worrying which class in the hierarchy actually implements the method.	 |	Yes |		Yes
wivar |		Set a watchpoint on an instance variable of an object.	 |	Yes	 |	Yes
presponder |		Print the responder chain starting from the given object. |		Yes |		Yes

## 参考

1. [LLDB to GDB Command Map](https://lldb.llvm.org/lldb-gdb.html)
2. [LLDB 知多少](https://mp.weixin.qq.com/s/VEpClFwTQn66f8INeHRFlQ)