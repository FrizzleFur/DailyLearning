# UIStackView

`UIStackView`为布局一组控件提供了线性的布局页面，这组控件可以垂直显示，也可以水平显示。当View被加入到`UIStackView`,你不再需要为它设置约束。`UIStackView`会自动管理子控件的布局并为他们添加约束。这也就意味着，子控件可以去适应不同的屏幕尺寸。

简单扩展一下，利用下面的方法，你可以轻松的为添加和删除视图加上动画效果。

```objc
// Animate stack
UIView.Animate(0.25, ()=>{
    // Adjust stack view
    MyUIStackView.LayoutIfNeeded();
});
```


## 布局

1. Fill: 填充满所在的父类stack view

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143051.png)


2. Top: 顶部对齐 所在的父类stack view

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143058.png)


3. Center  中间对齐 所在的父类stack view

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143140.png)


4. Bottom  底部对齐 所在的父类stack view

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143148.png)


5. First Baseline  首行基线对齐 所在的父类stack view

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143155.png)


6. First Baseline  末尾基线对齐 所在的父类stack view

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143210.png)


Distribution：用来设置子视图水平方向的布局，有下面5个属性可选择

1. Fill：水平填充满。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143217.png)


2.  Fill Equally：水平相等 填充满。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143226.png)


3. Equal Spacing:  stack view 子视图之间Spacing 相等，这个spacing 一定大于默认是设置的spacing

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143241.png)


4. Equal Spacing: 每个子视图中心线之间距离相等

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143253.png)


5. Fill Proporttionally: 按照每个子视图等比例填充满。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191113143311.png)


Spacing：每个子视图之间间距。

## 参考

1. [简便的自动布局，对UIStackView的个人理解！ - 爱家人爱老婆的IT男 - 博客园](https://www.cnblogs.com/bokeyuanlibin/p/5693575.html)
2. [UIStackView上手教程 - 简书](https://www.jianshu.com/p/19fbf3ee2840)
