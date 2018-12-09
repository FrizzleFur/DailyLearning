## MVVM解析

> MVVM 衍生于 MVC ，是对 MVC 的一种演进，它促进了 UI 代码与业务逻辑的分离。

![](http://oc98nass3.bkt.clouddn.com/15235264488103.jpg)


> 之前对MVVM的理解太浅，以为只是把VC请求放在了VM中，其实VM可以绑定View,并将Model变化的情况，通过ViewModel更新所绑定的view.

[不再对 MVVM 感到绝望 - 掘金](https://juejin.im/post/5a782d0d5188257a856f1dd7)



## MVC

![](http://oc98nass3.bkt.clouddn.com/15359950245553.jpg)

![](http://oc98nass3.bkt.clouddn.com/15359900306008.jpg)
模型-视图-控制器（MVC模式）是一种非常经典的软件架构模式，在UI框架和UI设计思路中扮演着非常重要的角色。从设计模式的角度来看，MVC模式是一种复合模式，它将多个设计模式在一种解决方案中结合起来，用来解决许多设计问题。MVC模式把用户界面交互分拆到不同的三种角色中，使应用程序被分成三个核心部件：Model（模型）、View（视图）、Control（控制器）。它们各自处理自己的任务：

（1）模型：模型持有所有的数据、状态和程序逻辑。模型独立于视图和控制器。

（2）视图：用来呈现模型。视图通常直接从模型中取得它需要显示的状态与数据。对于相同的信息可以有多个不同的显示形式或视图。

（3）控制器：位于视图和模型中间，负责接受用户的输入，将输入进行解析并反馈给模型，通常一个视图具有一个控制器。

MVC模式将它们分离以提高系统的灵活性和复用性，不使用MVC模式，用户界面设计往往将这些对象混在一起。MVC模式实现了模型和视图的分离，这带来了几个好处。

（1）一个模型提供不同的多个视图表现形式，**也能够为一个模型创建新的视图而无须重写模型。一旦模型的数据发生变化，模型将通知有关的视图，每个视图相应地刷新自己**。

（2）**模型可复用。因为模型是独立于视图的**，所以可以把一个模型独立地移植到新的平台工作。

（3）提高开发效率。在开发界面显示部分时，你仅仅需要考虑的是如何布局一个好的用户界面；开发模型时，你仅仅要考虑的是业务逻辑和数据维护，这样能使开发者专注于某一方面的开发，提高开发效率。

![](http://oc98nass3.bkt.clouddn.com/15359902008210.jpg)


### 观察者模式

MVC模式的关键是实现了视图和模型的分离。这是如何实现的呢？MVC模式通过建立一个“发布/订阅”（publish-subscribe）的机制来分离视图和模型。发布－订阅（publish-subscribe）机制的目标是发布者，它发出通知时并不需知道谁是它的观察者。可以有任意数目的观察者订阅并接收通知。MVC模式最重要的是用到了Observer（观察者模式），正是观察者模式实现了发布－订阅（publish-subscribe）机制，实现了视图和模型的分离。

![](http://oc98nass3.bkt.clouddn.com/15359915104611.jpg)

观察者模式：定义对象间的一种一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都得到通知并被自动更新。

观察者就对应于MVC模式中的View（视图）。视图向模型注册成为观察者，模型（主题）变化时就通知视图（观察者）更新自己，

* 但是还有一个问题，我们如果不引入控制器的话，直接将接受用户输入并解析输入操纵模型的功能放到视图中的话会产生两个问题：

* 第一、会造成视图代码变得复杂，使得视图就有了两个责任，不但要管理用户界面，还要处理如何控制模型的逻辑，有违单一责任的设计原则，

* 一个类应该仅有一个引起它变化的原因，如果一个类承担的责任过多，就等于把这些责任耦合在一起，一个责任的变化可能会削弱或抑制这个类完成其他责任的能力，这种耦合会导致脆弱的设计，当变化同时面临两个或多个方向变化时设计会遭到意想不到的破坏甚至根本没办法处理。

* 第二、会造成模型和视图的紧耦合，如果你想复用此视图来处理其他模型，根本不可能。

* 于是把控制器从视图中分离出来，将视图和模型解耦，通过控制器来保持控制器和视图之间的松耦合，使设计更有弹性和容易扩展，足以容纳以后的改变。

       策略模式：定义了算法族，分别封装起来，让他们之间可以相互替换，此模式让算法的变化独立于使用算法的客户。

       MVC模式视图和控制器实现了经典的策略模式：视图是一个对象，可以被调整使用不同的策略（行为），而控制器提供了策略（行为）。视图想换另一种行为，换控制器就可以了。视图只关心系统中可视的部分，对于任何界面行为，都委托给控制器处理。使用策略模式也可以让视图和模型之间的关系解耦，因为控制器负责和模型交互来传递用户的请求。对于工作是怎么完成的，视图毫不知情。


### Model–view–controller


MVC 是 iOS 开发中使用最普遍的架构模式，同时也是苹果官方推荐的架构模式。MVC 代表的是 Model–view–controller ，它们之间的关系如下：

![](http://oc98nass3.bkt.clouddn.com/15359898232426.jpg)

是的，MVC 看上去棒极了，model 代表数据，view 代表 UI ，而 controller 则负责协调它们两者之间的关系。然而，尽管从技术上看 view 和 controller 是相互独立的，但事实上它们几乎总是结对出现，一个 view 只能与一个 controller 进行匹配，反之亦然。既然如此，那我们为何不将它们看作一个整体呢：

![](http://oc98nass3.bkt.clouddn.com/15359898617148.jpg)


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
![](http://oc98nass3.bkt.clouddn.com/15359952531157.jpg)

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


下面，我们直接上代码，一起来看一个 `MVC` 模式转换成 `MVVM` 模式的示例。首先是 `model` 层的代码 `Person` ：



```
@interface Person : NSObject

- (instancetype)initwithSalutation:(NSString *)salutation firstName:(NSString *)firstName lastName:(NSString *)lastName birthdate:(NSDate *)birthdate;

@property (nonatomic, copy, readonly) NSString *salutation;
@property (nonatomic, copy, readonly) NSString *firstName;
@property (nonatomic, copy, readonly) NSString *lastName;
@property (nonatomic, copy, readonly) NSDate *birthdate;

@end

```


然后是 `view` 层的代码 `PersonViewController` ，在 `viewDidLoad` 方法中，我们将 `Person` 中的属性进行一定的转换后，赋值给相应的 `view` 进行展示：


```
- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.model.salutation.length > 0) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.model.salutation, self.model.firstName, self.model.lastName];
    } else {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.model.firstName, self.model.lastName];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE MMMM d, yyyy"];
    self.birthdateLabel.text = [dateFormatter stringFromDate:model.birthdate];
}

```


接下来，我们引入一个 `viewModel` ，将 `PersonViewController` 中的展示逻辑抽取到这个 `PersonViewModel` 中：


```
@interface PersonViewModel : NSObject

- (instancetype)initWithPerson:(Person *)person;

@property (nonatomic, strong, readonly) Person *person;
@property (nonatomic, copy, readonly) NSString *nameText;
@property (nonatomic, copy, readonly) NSString *birthdateText;

@end

@implementation PersonViewModel

- (instancetype)initWithPerson:(Person *)person {
    self = [super init];
    if (self) {
       _person = person;

      if (person.salutation.length > 0) {
          _nameText = [NSString stringWithFormat:@"%@ %@ %@", self.person.salutation, self.person.firstName, self.person.lastName];
      } else {
          _nameText = [NSString stringWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
      }

      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"EEEE MMMM d, yyyy"];
      _birthdateText = [dateFormatter stringFromDate:person.birthdate];
    }
    return self;
}

@end

```



最终，`PersonViewController` 将会变得非常轻量级：

```
- (void)viewDidLoad {
    [super viewDidLoad];

    self.nameLabel.text = self.viewModel.nameText;
    self.birthdateLabel.text = self.viewModel.birthdateText;
}

```



怎么样？其实 `MVVM` 并没有想像中的那么难吧，而且更重要的是它也没有破坏 `MVC` 的现有结构，只不过是移动了一些代码，仅此而已。好了，说了这么多，那 `MVVM` 相比 `MVC` 到底有哪些好处呢？我想，主要可以归纳为以下三点：

*   由于展示逻辑被抽取到了 `viewModel` 中，所以 `view` 中的代码将会变得非常轻量级；
*   由于 `viewModel` 中的代码是与 `UI` 无关的，所以它具有良好的可测试性；
*   对于一个封装了大量业务逻辑的 `model` 来说，改变它可能会比较困难，并且存在一定的风险。在这种场景下，`viewModel` 可以作为 `model` 的适配器使用，从而避免对 `model` 进行较大的改动。


首先我们明确一个点，在一个MVC结构中，即便抛开视图后，模型和控制器处理的大部分业务逻辑，都是为视图服务的。我们常说的“重VC”，很大一部分重在视图相关的逻辑或是为之服务的逻辑。

所以，当我们抽象一些视图的基础模型，并通过VM将视图本身的（不需要与外界交互的）状态变迁逻辑封装在一个MVVM组的内部，对外（对VC）只暴露必要的数据更新和消息回调接口。繁琐的视图逻辑就可以被限制在一个MVVM当中（它确实也应当在那里）。这时留在VC中的逻辑，一般情况下就很少了。如果此刻的VC还让你感到“重”的话，我们大可再对其抽象一个VC-Logic，将复杂的逻辑进行封装。

各个模块所负责的主要工作可以参考下图
![](http://oc98nass3.bkt.clouddn.com/15359930200792.jpg)


1）什么是“处理视图状态”？
视图可能根据不同的状态有不同的展示内容，甚至展示效果。我们常见的“cur”（current)前缀就适用于说明这种场景。“当前选择的模块”，“某个按钮当前的选择状态”，这些表示视图状态的操作变量的定义应当在VM当中，相关的逻辑交互也应当在VM当中。如果说View提供了视图的所有展示元素；那么VM则可以确定某个视图模块某一时刻某一个状态下的呈现内容。

2）什么是“处理视图协作”？
一个VM不一定只和一个View存在关联，它可能同时协调多个视图。
我们以同程旅行的一个筛选界面作为参考场景进行说明：

![](http://oc98nass3.bkt.clouddn.com/15359931414076.jpg)

当我们将“4.5分以上”后面的对号勾上的时候，上面的“4.5分以上”会被同步勾取，同时，“评分”后面会多出个小绿点，这表示评分这页的筛选条件选择的不是默认的“不限”。很显然，关键词模块、筛选分类模块、筛选详情模块正常人都会分成3部分视图绘制。这三个视图间显然是有交互关系的（即“筛选详情模块”的勾选触发了“关键词模块”的高亮和“筛选分类模块”的加点），而VM即是处理这种交互关系理想场所。

3）什么是“数据绑定”？
这边特指将一个模型数据和视图中的一个展示内容进行关联绑定；
单向绑定一般指模型数据变化触发对应的视图数据变化
双向绑定指模型数据，视图数据任意一方变化，都会触发另一方的同步变化。

4）什么是“数据转换”？
我们不能企望所有的模型数据都能直接被视图使用，比如模型中是一个BOOL（0/1）值，而对应的视图展示期望为“是”/“否”，类似这样的数据转化工作，交给VM吧！



## 参考

* [MVVM With ReactiveCocoa - 雷纯锋的技术博客](http://blog.leichunfeng.com/blog/2016/02/27/mvvm-with-reactivecocoa/)
* [不再对 MVVM 感到绝望 - 掘金](https://juejin.im/post/5a782d0d5188257a856f1dd7)

* [How not to get desperate with MVVM implementation – Flawless App Stories – Medium](https://medium.com/flawless-app-stories/how-to-use-a-model-view-viewmodel-architecture-for-ios-46963c67be1b)
* [leichunfeng/MVVMReactiveCocoa: GitBucket iOS App](https://github.com/leichunfeng/MVVMReactiveCocoa)
* [对于MVVM，多一些思考总是没差的 - 简书](https://www.jianshu.com/p/fbfbdfba117f)
* [ObjC 中国 - MVVM 介绍](https://objccn.io/issue-13-1/)


