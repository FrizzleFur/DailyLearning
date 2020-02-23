# 解析-SnapKit


## 1.基本使用

```swift
viewOne.snp.makeConstraints { (make) in
    make.left.top.equalToSuperview()
    make.width.height.equalTo(40)
}
//当前视图与 title中心相同 （centerX 和 centerY）
make.center.equalTo(title)
//当前视图宽高大于等于 title
make.size.greaterThanOrEqualTo(title)
//当前视图 的 上下左右(top,left,bottom,right) 等于 title
make.edges.equalTo(title)
//当前视图距离title视图上、左、下、右边距分别是20、20、20、30
make.edges.equalTo(title).inset(UIEdgeInsetsMake(20, 20, 20, 30)) 
//当前视图为title视图的一半
make.size.equalTo(title).multipliedBy(0.5)
```


## 2.属性

```swift
.equalTo：等于
.lessThanOrEqualTo：小于等于
.greaterThanOrEqualTo：大于等于
.edges:：边缘  
.size：尺寸
.center：中心
.inset：内位移修正
.offset：外位移修正
.multipliedBy：倍率修正
.dividedBy：倍率修正
```

* HuggingPriority-抗拉伸
  在布局的过程中，我们往往会遇到两个 View 放在同一行的情况，如果两个 View 不能够填满整个空间，就会被拉伸。
  这时我们设置其中不需要拉伸的 View 的 HuggingPriority 为 high，就可以让其不被拉伸
* CompressionResistancePriority-抗压缩
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200213101909.png)
  这中情况下，我们设置 LeftLabel 抗压缩性 CompressionResistancePriority 为 high，设置 RightLabel 的 CompressionResistancePriority 为 low，那么就会自动拉伸 RightLabel，而 LeftLabel 就会维持原状。



## 3.更新、移除、重设约束

```swift
//保存约束的引用
var constraint:Constraint?
title.snp.makeConstraints { (make) -> Void in
    self.constraint = make.width.height.equalTo(150).constraint
    make.center.equalTo(self.view)
}

//移除约束
self.constraint?.deactivate()
//1.更新修改约束
self.constraint?.update(offset: 60)      
//2.视图约束更新
override func updateViewConstraints() {
    self.title.snp.updateConstraints{ (make) -> Void in
    //视图宽度与屏幕等宽
        make.width.equalTo(self.view)
    }
    super.updateViewConstraints()
}

//重做约束
title.snp.remakeConstraints { (make) -> Void in
    make.width.height.equalTo(100)
}
```
