# UITableView阅读


> `UITableView`:A view that presents data using rows arranged in a single column.
>An instance of `UITableView` (or simply, a table view) is a means for displaying and editing hierarchical lists of information.



## 介绍

表格视图显示一个列表，在一个单一的物品栏。表格是UIScrollView的子类，它允许用户滚动表，虽然表格只允许纵向滚动。这些细胞包括表的每个项目UITableViewCell对象；UITableView使用这些对象绘制的表行可见。细胞内容标题和图像可以有，右边缘的辅助视图。标准附件意见披露指标或详细信息按钮；前者导致一个新的水平层次数据，后者导致了所选项目的详细视图。辅助视图也可以框架控件，如开关和滑块，也可以是自定义的视图。表格视图可以进入编辑模式，用户可以插入，删除，排序表中的行。

表格视图是由零个或多个部分，每一个都有自己的行。部分确定的表格视图的索引号，和行确定一个段中的索引。任何部分可以选择之前一段标题，也可以跟随一段尾。


### 获取Table中view的坐标

```objc
- (CGRect)rectForSection:(NSInteger)section;                                    // includes header, footer and all rows
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForFooterInSection:(NSInteger)section;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (nullable NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;                         // returns nil if point is outside of any row in the table
- (nullable NSIndexPath *)indexPathForCell:(UITableViewCell *)cell;                      // returns nil if cell is not visible
- (nullable NSArray<NSIndexPath *> *)indexPathsForRowsInRect:(CGRect)rect;                              // returns nil if rect not valid

```

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

## 参考 

[UITableView - UIKit | Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uitableview#//apple_ref/occ/cl/UITableView)


