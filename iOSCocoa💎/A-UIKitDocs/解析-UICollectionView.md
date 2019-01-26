## 解析-UICollectionView

参考 ：[浅析collectionView的item间距 - 简书](https://www.jianshu.com/p/1e12a2b8f53c)

[定制自己的瀑布流 - sindrilin的小巢](http://sindrilin.com/tips/2015/09/18/%E5%AE%9A%E5%88%B6%E8%87%AA%E5%B7%B1%E7%9A%84%E7%80%91%E5%B8%83%E6%B5%81.html)


### 一、创建collectionView（collectionView控制器）
(collectionView)
```objc
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout 

(collectionView控制器)
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout ;

```
初始化类似tableView，设置delegate 和 datasource；

不同于tablView初始化设置UITableViewStyle，而collctionView初始化设置UICollectionViewLayout（一般用它的子类UICollectionViewFlowLayout）。

此处的UICollectionViewLayout是用于存储collectionView的一些布局属性：

```objc
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection; 
@property (nonatomic) UIEdgeInsets sectionInset;

```
cell间距的设置需要用到以上这些关键性属性。


### 二、布局协议

UICollectionViewDelegateFlowLayout

协议中有以下这几个和布局相关的方法
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

这几个方法的功能和UICollectionViewLayout的4个属性基本相对应：
1.属性用于统一设置
2.对象方法既可以统一设置，也可以区别设置
这几个方法名的区别在后半部分

* xxxxx sizeForItemAtIndexPath:(NSIndexPath *)indexPath
* 等同于属性 itemSize；
* xxxxx insetForSectionAtIndex:(NSInteger)section
* 等同于属性 sectionInset；
* xxxxx minimumLineSpacingForSectionAtIndex:(NSInteger)section
* 等同于属性 minimumLineSpacing；
* xxxxx minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
* 等同于属性 minimumInteritemSpacing；

### 三、图文解析对应属性（针对不同滚动方向）


![collectionView布局.gif](https://i.loli.net/2018/12/04/5c05f5b479375.jpg)

gif中每个不同颜色代表不同的section


![水平方向滚动.png](https://i.loli.net/2018/12/04/5c05f5bec831f.jpg)


水平方向滚动的collectionView，竖直方向的间距是固定的：minimumInteritemSpacing指的是同一个section 内部item的竖直方向间隙；
minimumLineSpacing指的是同一个section 内部 item的水平方向间隙；

![竖直方向滚动.png](https://i.loli.net/2018/12/04/5c05f5c29275d.jpg)

竖直方向滚动的collectionView，水平方向的间距是固定的：minimumInteritemSpacing指的是同一个section 内部item的水平方向间隙；
minimumLineSpacing指的是同一个section 内部 item的竖直方向间隙；
总结：
minimumInteritemSpacing表示 同一个section内部间item的 和滚动方向垂直方向的间距；
minimumLineSpacing指的是同一个section 内部 item 的滚动方向的间距；
sectionInset指的是每个section内缩进；属性设置的每个section的内错进是相同的，都是正数。如果需要实现不同的setion的不同的内缩进，可以使用对象方法
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;来实现。
注意：
在写demo的过程中，发现collectionView的contentInsetAdjustmentBehavior（等同于控制器的automaticallyAdjustsScrollViewInsets属性）默认为UIScrollViewContentInsetAdjustmentAutomatic枚举值，会自适应控制器的边距，避开导航栏和状态栏，而使得collectionView的真实高度 和设置的高度不一致（相差状态栏和导航栏的高度和）。




### 其他


```objc
layout.scrollDirection = UICollectionViewScrollDirectionVertical

```
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


### API

_- (void)prepareLayout_

系统在准备对`item`进行布局前会调用这个方法，我们重写这个方法之后可以在方法里面预先设置好需要用到的变量属性等。比如在瀑布流开始布局前，我们可以对存储瀑布流高度的数组进行初始化。有时我们还需要将布局属性对象进行存储，比如卡片动画式的定制，也可以在这个方法里面进行初始化数组。切记要调用`[super prepareLayout];`

_- (CGSize)collectionViewContentSize_

由于`collectionView`将`item`的布局任务委托给`layout`对象，那么滚动区域的大小对于它而言是不可知的。自定义的布局对象必须在这个方法里面计算出显示内容的大小，包括`supplementaryView`和`decorationView`在内。

_- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect_

个人觉得完成定制布局最核心的方法，没有之一。`collectionView`调用这个方法并将自身坐标系统中的矩形传过来，这个矩形代表着当前`collectionView`可视的范围。我们需要在这个方法里面返回一个包括`UICollectionViewLayoutAttributes`对象的数组，这个布局属性对象决定了当前显示的`item`的大小、层次、可视属性在内的布局属性。同时，这个方法还可以设置`supplementaryView`和`decorationView`的布局属性。合理使用这个方法的前提是不要随便返回所有的属性，除非这个`view`处在当前`collectionView`的可视范围内，又或者大量额外的计算造成的用户体验下降——你加班的原因。

_- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath_

相当重要的方法。`collectionView`可能会为了某些特殊的`item`请求特殊的布局属性，我们可以在这个方法中创建并且返回特别定制的布局属性。根据传入的indexPath调用`[UICollectionViewLayoutAttributes layoutAttributesWithIndexPath: ]`方法来创建属性对象，然后设置创建好的属性，包括定制形变、位移等动画效果在内

_- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds_

当`collectionView`的`bounds`改变的时候，我们需要告诉`collectionView`是否需要重新计算布局属性，通过这个方法返回是否需要重新计算的结果。简单的返回`YES`会导致我们的布局在每一秒都在进行不断的重绘布局，造成额外的计算任务。