
## IOS AutoLayout 详解

看到以上视图咱们可以看出它分为两个而且这两种除了名字不一样，选项是一摸一样的额。Selected Views 这个说的就是你要处理的约束问题是当前你选中的View，而All Views in View Controller，则是说明要解决的约束问题是这个ViewController所有的VIew的(这个可得慎重的)。


Update Frames 修改Frame，当你的约束设置正确但是Frame不对的时候使用者选项可以讲View的Frame展示成为约束所描述的样子

Update Constaints 而这个选项，说实话我没用过。他的意思咱们也可以知道他是通过Frame 去修改 约束……

Add Missing Constraints 添加缺失的约束，这个选项我也没使用过，因为这个方法添加的缺失的约束不一定就是正确的约束，在实际运行中肯定会出现问题所以尽量自己把缺失的约束自己添加了。

Reset to Suggested Constaints 重新设置建议的约束？没使用过，不知道什么意思

Clear Constraints 清除约束，会删除选中的视图的所有的约束。在All Views in View Controller 你要是做这个选项的时候可得慎重，使用了就说明你要删除当前VC所有的约束。当然你可以 ctrl-z


## Aspect Ratio

1. Aspect Ratio:
设置视图的宽高比

2. 使用场景:
视图宽度随着屏幕宽度变化拉伸时,让其高度自动进行等比例拉伸.保持该视图宽高比不变.

1.新建工程,在视图控制器中添加一个 imageView,并为其设置一张宽高比为16:9的图片.

2.对imageView添加如下约束.

1.竖向居中
2.增加宽度约束为320
3.设置Aspect Ratio宽高比为16:9
4.增加顶部约束

![](https://i.loli.net/2018/12/08/5c0bca00c1a28.jpg)

由于设置了imgView宽高比为16:9,所以宽度动态变化时,其高度也会根据设置的宽高比做相应变化.



## 参考

5. [IOS AutoLayout 详解 - 简书](https://www.jianshu.com/p/4ef0277e9c5e)