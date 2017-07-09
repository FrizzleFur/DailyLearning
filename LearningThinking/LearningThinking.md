# LearningThinking

-------
### 2017-07-07


> 今天在`Review Code`的时候，发现自己以前写的一个分析类中的代码有几个地方挺有意思的。

比如，经常需要调用分享，然而，点击的分享按钮没有做短时间内的去重点击，而执行调用动画是需要一点时间的， 所以可能在
点击调起分享视图，调起动画还没完成的时候，又执行几次调起动画，就会出现多个分享视图，而解决这一点，只需要加入一个监听状态`isShareVCShowing`就行了，如果正在展示动画，就忽略调起请求。

定义一个属性

```
BOOL isShareVCShowing;      //分享页是否正在弹出
```

放入到展示的方法中：

```
- (void)showInWindow {
    isShareVCShowing = true;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    shareView.top = self.view.height;
    shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
    } completion:^(BOOL finished) {
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
        isShareVCShowing = false;
    }];
}
```

然而这样做会有一个问题，成员变量`isShareVCShowing`暴露在`.h`文件里，可能其他类拿到分享这个视图会进行修改，这样就不太好。所以，做一下处理：


在外部定义一个方法，把`isShareVCShowing`属性放在`.m`文件中，

```
- (BOOL)isShareVCShowing;/**< ShareViewController是否正在展示动画中 */
```

实现其get方法：


```
- (BOOL)isShareVCShowing {
    return isShareVCShowing;
}
```

这样，在别的`VC`中调起分享的时候，只需要获取`ShareVC`的展示状态，加入判断即可。


```
BOOL isShareVCShowing =  [shareVC isShareVCShowing];
if (isShareVCShowing) return;//避免多次点击
```


### Where To Go From here?

我在想，既然是这个展示状态是`ShareVC`的属性，是否可以在`ShareVC`这个类里自己做好处理？

其实很简单，把判断卸载在每次调用的`showInWindow`方法上：

```
- (void)showInWindow {
    if (isShareVCShowing) {
        NSLog(@"isShareVCShowing = %d", isShareVCShowing);
        return;
    }
    isShareVCShowing = true;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    shareView.top = self.view.height;
    shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
    } completion:^(BOOL finished) {
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
        isShareVCShowing = false;
    }];
}
```


