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

