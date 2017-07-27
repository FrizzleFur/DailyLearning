## 代码技巧

**1. 一种懒加载写法**

```   
if (!self.statusBar.superview) {
    [self.view addSubview:self.statusBar];
}

- (UIView *)statusBar {
    if (_statusBar == nil) {
        _statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUSBAR_HEIGHT)];
        _statusBar.backgroundColor = [UIColor blackColor];
    }
    return _statusBar;
}
```

**2. tableView的一种删除、添加cell后的刷新方法:**
```
[self.dataArray removeObjectsAtIndexes:indexs];
[self.tableView beginUpdates];
[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
   withRowAnimation:(UITableViewRowAnimationNone)];
[self.tableView endUpdates];
```

**3. 字符串遍历**

```
（1） 通过查找的方式来(这方式适合所有格式的子符串，推荐使用)
   NSString *newStr =@"sdfdfs15dfdfdf15fdfdow们啊as阿达阿达打啊";
   NSString *temp =nil;
   for(int i =0; i < [newStr length]; i++)  
   {   
       temp = [newStr substringWithRange:NSMakeRange(i,1)];
       NSLog(@"第%d个字是:%@",i,temp);
   }  
NSRange hotTopicRange = [dynamicComplex.desc rangeOfString:hotTopicComplex.title];

```

**4. 在解决tableView头部插入view的时候，SectionHeaderView的contentInset问题**

```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY < -bannerHeaderHeight) {
        topicDetailBannerView.top = contentOffsetY;
        topicDetailBannerView.height = -contentOffsetY;
    }
    //解决sectionHeader的问题
    if(contentOffsetY >= 0 ){
        scrollView.contentInset = UIEdgeInsetsZero;
    }else{
        scrollView.contentInset = UIEdgeInsetsMake(MIN(-contentOffsetY, bannerHeaderHeight), 0, 0, 0);
    }
}
```

