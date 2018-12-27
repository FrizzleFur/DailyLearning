# UITableView阅读


> `UITableView`:A view that presents data using rows arranged in a single column.
>An instance of `UITableView` (or simply, a table view) is a means for displaying and editing hierarchical lists of information.



## 介绍

表格视图显示一个列表，在一个单一的物品栏。表格是UIScrollView的子类，它允许用户滚动表，虽然表格只允许纵向滚动。这些细胞包括表的每个项目UITableViewCell对象；UITableView使用这些对象绘制的表行可见。细胞内容标题和图像可以有，右边缘的辅助视图。标准附件意见披露指标或详细信息按钮；前者导致一个新的水平层次数据，后者导致了所选项目的详细视图。辅助视图也可以框架控件，如开关和滑块，也可以是自定义的视图。表格视图可以进入编辑模式，用户可以插入，删除，排序表中的行。

表格视图是由零个或多个部分，每一个都有自己的行。部分确定的表格视图的索引号，和行确定一个段中的索引。任何部分可以选择之前一段标题，也可以跟随一段尾。


### UITableViewStyle
当你创建一个表格实例必须指定表的风格，这种风格是无法改变的:

`UITableViewStylePlain`
A plain table view. Any section headers or footers are displayed as inline separators and float when the table view is scrolled.
简朴表格视图。任何部分的页眉或页脚显示为内联分离器和浮在表视图滚动。

`UITableViewStyleGrouped`
A table view whose sections present distinct groups of rows. The section headers and footers do not float.
一个表视图，其节显示不同的行组。本节的页眉和页脚不浮。

### NSIndexPath

Many methods of UITableView take NSIndexPath objects as parameters and return values. UITableView declares a category on NSIndexPath that enables you to get the represented row index (row property) and section index (section property), and to construct an index path from a given row index and section index (indexPathForRow:inSection: method). Especially in table views with multiple sections, you must evaluate the section index before identifying a row by its index number.


### DataSource & Delegate

一个UITableView对象必须有一个对象，作为一个数据源和一个对象作为代表；通常这些对象是应用程序的代理或更频繁，一个自定义UITableViewController对象。数据源必须采用uitableviewdatasource协议和委托必须采用uitableviewdelegate协议。数据源提供的信息，表格需要构建表和管理数据模型时，一个表的行插入，删除或重新排序。委托管理表行配置和选择、行重新排序、突出显示、附件视图和编辑操作。


### 刷新

Changing UITableView section header without tableView:titleForHeaderInSection

```objc
[self.tableView beginUpdates];
[self.tableView endUpdates];
// forces the tableView to ask its delegate/datasource the following:
//   numberOfSectionsInTableView:
//   tableView:titleForHeaderInSection:
//   tableView:titleForFooterInSection:
//   tableView:viewForHeaderInSection:
//   tableView:viewForFooterInSection:
//   tableView:heightForHeaderInSection:
//   tableView:heightForFooterInSection:
//   tableView:numberOfRowsInSection:
```

[iphone - Changing UITableView section header without tableView:titleForHeaderInSection - Stack Overflow](https://stackoverflow.com/questions/1586420/changing-uitableview-section-header-without-tableviewtitleforheaderinsection)


## cell分割线 设置间距

```objc
// 分割线左间距
    cell.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
```

## 隐藏导航的时候露出状态白线

```objc
 // 取消自动调整内容内间距
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
    」
```


## prepareForReuse

The table view's delegate in tableView(_:cellForRowAt:) should always reset all content when reusing a cell.


* prepareForReuse调用时机
* 在重用cell的时候，如果每个cell中都有不同的子视图或者是需要发送不同的网络请求，此时在应用`dequeueReusableCellWithIdentifier:`方法时就会出现视图重叠的情况，针对于此种情况，我们就需要在自定义的cell中重写`prepareForReuse`方法。因为当屏幕滚动导致一个cell消失，另外一个cell显示时，系统就会发出prepareForReuse的通知，此时，我们需要在重载的prepareForReuse方法中，将所有的子视图隐藏，并且将内容置空。这样就不会出现重叠现象。

So basically the following is not suggested:

```objc

override func prepareForReuse() {
    super.prepareForReuse()
    imageView?.image = nil
}
instead the following is recommended:

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

     cell.imageView?.image = image ?? defaultImage // unexpected situation is also handled. 
     // We could also avoid coalescing the `nil` and just let it stay `nil`
     cell.label = yourText
     cell.numberOfLines = yourDesiredNumberOfLines

    return cell
}
```

Additionally default non-content related items as below is recommended:

```objc


override func prepareForReuse() {
    super.prepareForReuse()
    isHidden = false
    isSelected = false
    isHighlighted = false

}

override func prepareForReuse() {
    super.prepareForReuse()

    imageView.cancelImageRequest() // this should send a message to your download handler and have it cancelled.
    imageView.image = nil
}

```


## UITableViewCell高度计算

rowHeight
UITableView是我们再熟悉不过的视图了，它的 delegate 和 data source 回调不知写了多少次，也不免遇到 UITableViewCell 高度计算的事。UITableView 询问 cell 高度有两种方式。
一种是针对所有 Cell 具有固定高度的情况，通过：

self.tableView.rowHeight = 88;
上面的代码指定了一个所有 cell 都是 88 高度的 UITableView，对于定高需求的表格，强烈建议使用这种（而非下面的）方式保证不必要的高度计算和调用。rowHeight属性的默认值是 44，所以一个空的 UITableView 显示成那个样子。

另一种方式就是实现 UITableViewDelegate 中的：

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // return xxx
}
需要注意的是，实现了这个方法后，rowHeight 的设置将无效。所以，这个方法适用于具有多种 cell 高度的 UITableView。



[优化UITableViewCell高度计算的那些事 · sunnyxx的技术博客](http://blog.sunnyxx.com/2015/05/17/cell-height-calculation/)


## 优化TableView

[VVeboTableView 源码解析 - 掘金](https://juejin.im/post/5a38604b5188252bca04f9fb)


1. 减少CPU／GPU计算量
1.1 cell的重用机制
1.2 将cell高度和 cell里的控件的frame缓存在model里
1.3 减少cell内部控件的层级

2. 按需加载cell


## 参考 

[UITableView - UIKit | Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uitableview#//apple_ref/occ/cl/UITableView)


