## UICollectionView



layout.scrollDirection = UICollectionViewScrollDirectionVertical

![](http://oc98nass3.bkt.clouddn.com/15372728978793.jpg)



### 排序逆序

思路：

* 旋转坐标系，mCollectView坐标旋转180，倒过来
    * mCollectView坐标旋转180
    * 然后，cell坐标旋转180，恢复原来的坐标。
* 数据源数组逆序排列
* 因为我们是旋转了180度，所以滚动到最左边 本质还是最右边。 另外在写滚动的时候，一定要注意判断数据源长度，不要越界。
![](http://oc98nass3.bkt.clouddn.com/15373215615943.jpg)

```
mCollectView.transform = CGAffineTransformMakeRotation(M_PI);
cell.transform = CGAffineTransformMakeRotation(M_PI);
```

## 设置section的背景颜色

Basically, we will have to subclass UICollectionViewLayoutAttributes, UICollectionReusableView and UICollectionViewLayout in order to create a instance UICollectionReusableView as section's background view.

自定义一个UICollectionViewLayoutAttributes

```objc
+ (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                withIndexPath:(NSIndexPath *)indexPath {
    
    ECCollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind
                                                                                              withIndexPath:indexPath];
    if (indexPath.section%2 == 0) {
        layoutAttributes.color = [UIColor redColor];
    } else {
        layoutAttributes.color = [UIColor blueColor];
    }
    return layoutAttributes;
}

```
![](http://oc98nass3.bkt.clouddn.com/15397755573987.jpg)

1. [ios - How to change background color of a whole section in UICollectionView? - Stack Overflow](https://stackoverflow.com/questions/13609204/how-to-change-background-color-of-a-whole-section-in-uicollectionview)



##  NSIndexpath.item vs NSIndexpath.row

在NSIndexPath中，索引存储在一个名为“_indexes”的简单c数组中，该数组定义为NSUInteger *，并且数组的长度存储在定义为NSUInteger的“_length”中。访问者“section”是“_indexes [0]”的别名，“item”和“row”都是“_indexes [1]”的别名。因此，这两者在功能上是相同的。

在编程风格方面 - 也许是定义链 - 你最好在表的上下文中使用“row”，在集合的上下文中使用“item”。

[ios - NSIndexpath.item vs NSIndexpath.row - Stack Overflow](https://stackoverflow.com/questions/14765730/nsindexpath-item-vs-nsindexpath-row)