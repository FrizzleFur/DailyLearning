## MVVM解析


![](http://oc98nass3.bkt.clouddn.com/15235264488103.jpg)



## MVC
比如在一个`ViewController`中：

```swift

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // ....................
    let photo = self.photos[indexPath.row]
    //Wrap the date
    let dateFormateer = DateFormatter()
    dateFormateer.dateFormat = "yyyy-MM-dd"
    cell.dateLabel.text = dateFormateer.string(from: photo.created_at)
    //.....................
}
  
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.photos.count
}

```

那么上面的代码有什么问题呢？在photolistviewcontroller，我们可以找到表象逻辑如转换日期字符串和何时启动/停止的活动指标。我们也有视图代码，如显示/隐藏表视图的实现。此外，视图控制器中还有另一个依赖项API服务。如果你打算为PhotoListViewController写的测试，你会发现你停留因为它太复杂了。我们嘲笑apiservice，假表的视图和模拟电池测试整个photolistviewcontroller。唷！




```swift
func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    let photo = self.photos[indexPath.row]
    if photo.for_sale { // If item is for sale 
        self.selectedIndexPath = indexPath
        return indexPath
    }else { // If item is not for sale 
        let alert = UIAlertController(title: "Not for sale", message: "This item is not for sale", preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return nil
    }
}
```

我们选择在功能上相应的照片（_ TableView对象：willselectrowat TableView UITableView，indexpath：indexpath）-> indexpath？，检查for_sale属性。如果这是真的，保存为一个segue selectedindexpath。如果没有显示错误信息并返回零，预防控制。

参考代码： [PhotoList/PhotoListViewController.swift](https://github.com/koromiko/Tutorial/blob/MVC/MVVMPlayground/MVVMPlayground/Module/PhotoList/PhotoListViewController.swift)


## MVVM

为了解决这个问题，我们的首要任务是清理视图控制器的视图控制器，分为两部分：视图和视图模型。具体地说，我们要：

* 设计一组绑定接口。
* 将显示逻辑和控制逻辑移到`ViewModel`上。

因此，我们可以将UI组件抽象为一组规范表示：

![](http://oc98nass3.bkt.clouddn.com/15235279133274.jpg)

### ViewModel Binding

1. 使用KVO（键值观察）模式。
2. 使用第三方库FRP（Functional Reactive Programming）如Rxswift和ReactiveCocoa。
3. 自己动手(closure 回调 or delegate)

Using the KVO pattern isn’t a bad idea, but it might create a huge delegate method and we have to be careful about the addObserver/removeObserver, which might be a burden to the View. The ideal way for binding is to use the binding solution in FRP. 


```swift 
// When Prop changed, do something in the closure 
viewModel.propChanged = { in
    DispatchQueue.main.async {
        // Do something to update view 
    }
}
```
每一次的属性prop的更新，propchanged将回调。所以我们可以更新视图根据视图的变化。很简单，对吧？

 
### ViewModel 的 Binding接口

 我们创建的接口/性能结合在photolistviewmodel：
 
```swift
private var cellViewModels: [PhotoListCellViewModel] = [PhotoListCellViewModel]() {
    didSet {
        self.reloadTableViewClosure?()
    }
}
var numberOfCells: Int {
    return cellViewModels.count
}
func getCellViewModel( at indexPath: IndexPath ) -> PhotoListCellViewModel

var isLoading: Bool = false {
    didSet {
        self.updateLoadingStatus?()
    }
}
```

### Binding ViewModel 后

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCellIdentifier", for: indexPath) as? PhotoListTableViewCell else { fatalError("Cell not exists in storyboard")}
		
    let cellVM = viewModel.getCellViewModel( at: indexPath )
		
    cell.nameLabel.text = cellVM.titleText
    cell.descriptionLabel.text = cellVM.descText
    cell.mainImageView?.sd_setImage(with: URL( string: cellVM.imageUrl ), completed: nil)
    cell.dateLabel.text = cellVM.dateText
		
    return cell
}
```

## 参考

* [How not to get desperate with MVVM implementation – Flawless App Stories – Medium](https://medium.com/flawless-app-stories/how-to-use-a-model-view-viewmodel-architecture-for-ios-46963c67be1b)


