## MVVM解析

> MVVM 衍生于 MVC ，是对 MVC 的一种演进，它促进了 UI 代码与业务逻辑的分离。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15235264488103.jpg)

> 之前对MVVM模式的理解太浅，以为只是把VC请求放在了VM中，其实VM可以绑定View,并将Model变化的情况，通过ViewModel更新所绑定的view.

[不再对 MVVM 感到绝望 - 掘金](https://juejin.im/post/5a782d0d5188257a856f1dd7)

对于 MVVM 来说，**我们可以把 view 看作是 viewModel 的可视化形式，viewModel 提供了 view 所需的数据和命令。因此，viewModel 的可测试性可以帮助我们极大地提高应用的质量**。

[MVVM With ReactiveCocoa - 雷纯锋的技术博客](http://blog.leichunfeng.com/blog/2016/02/27/mvvm-with-reactivecocoa/)


## 从MVC谈起

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359950245553.jpg)

模型-视图-控制器（MVC模式）是一种非常经典的软件架构模式，在UI框架和UI设计思路中扮演着非常重要的角色。从设计模式的角度来看，MVC模式是一种复合模式，它将多个设计模式在一种解决方案中结合起来，用来解决许多设计问题。MVC模式把用户界面交互分拆到不同的三种角色中，使应用程序被分成三个核心部件：Model（模型）、View（视图）、Control（控制器）。它们各自处理自己的任务：

（1）模型：模型持有所有的数据、状态和程序逻辑。模型独立于视图和控制器。

（2）视图：用来呈现模型。视图通常直接从模型中取得它需要显示的状态与数据。对于相同的信息可以有多个不同的显示形式或视图。

（3）控制器：位于视图和模型中间，负责接受用户的输入，将输入进行解析并反馈给模型，通常一个视图具有一个控制器。

MVC模式将它们分离以提高系统的灵活性和复用性，不使用MVC模式，用户界面设计往往将这些对象混在一起。MVC模式实现了模型和视图的分离，这带来了几个好处。

（1）一个模型提供不同的多个视图表现形式，**也能够为一个模型创建新的视图而无须重写模型。一旦模型的数据发生变化，模型将通知有关的视图，每个视图相应地刷新自己**。

（2）**模型可复用。因为模型是独立于视图的**，所以可以把一个模型独立地移植到新的平台工作。

（3）提高开发效率。在开发界面显示部分时，你仅仅需要考虑的是如何布局一个好的用户界面；开发模型时，你仅仅要考虑的是业务逻辑和数据维护，这样能使开发者专注于某一方面的开发，提高开发效率。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359902008210.jpg)

### 如果没有Controller

MVC 是 iOS 开发中使用最普遍的架构模式，同时也是苹果官方推荐的架构模式。MVC 代表的是 Model–view–controller ，它们之间的关系如下：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359898232426.jpg)

是的，MVC 看上去棒极了，model 代表数据，view 代表 UI ，而 controller 则负责协调它们两者之间的关系。然而，尽管从技术上看 view 和 controller 是相互独立的，但事实上它们几乎总是结对出现，一个 view 只能与一个 controller 进行匹配，反之亦然。既然如此，那我们为何不将它们看作一个整体呢：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359898617148.jpg)


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

那么上面的代码有什么问题呢？在photolistviewcontroller，我们可以找到表象逻辑如转换日期字符串和何时启动/停止的活动指标。我们也有视图代码，如显示/隐藏表视图的实现。此外，视图控制器中还有另一个依赖项API服务。如果你打算为PhotoListViewController写的测试，你会发现你停留因为它太复杂了。我们嘲笑apiservice，假表的视图和模拟电池测试整个photolistviewcontroller。

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

### MVC的设计模式

MVC模式中应用到了那些设计模式？

答： 众所周知MVC不是设计模式，是一个比设计模式更大一点的模式，称作设计模式不合理，应该说MVC它是一种软件开发架构模式，它包含了很多的设计模式，最为密切是以下三种：Observer (观察者模式), Composite（组合模式）和Strategy（策略模式）。所以说MVC模式又称复合模式。MVC(Model-View-Controller) 模式的基本思想是数据，显示和处理相分离。模型(Model)负责数据管理，视图(View)负责数据显示，控制器(Controller)负责业务逻辑和响应策略。由观察者模式确定的模型视图关系是其中最为重要的。

[用组合模式、策略模式、观察者模式结合来实现一个MVC - wty814022051的专栏 - CSDN博客](https://blog.csdn.net/wty814022051/article/details/5582995)

#### MVC的观察者模式

MVC模式的关键是实现了视图和模型的分离。这是如何实现的呢？MVC模式通过建立一个“发布/订阅”（publish-subscribe）的机制来分离视图和模型。发布－订阅（publish-subscribe）机制的目标是发布者，它发出通知时并不需知道谁是它的观察者。可以有任意数目的观察者订阅并接收通知。**MVC模式最重要的是用到了Observer（观察者模式），正是观察者模式实现了发布－订阅（publish-subscribe）机制，实现了视图和模型的分离**。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359915104611.jpg)

> 观察者模式：定义对象间的一种一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都得到通知并被自动更新。

观察者就对应于MVC模式中的View（视图）。视图向模型注册成为观察者，模型（主题）变化时就通知视图（观察者）更新自己，

* 但是还有一个问题，我们如果不引入控制器的话，直接将接受用户输入并解析输入操纵模型的功能放到视图中的话会产生两个问题：

* 第一、会造成视图代码变得复杂，**使得视图就有了两个责任，不但要管理用户界面，还要处理如何控制模型的逻辑**，有违单一责任的设计原则，

* **一个类应该仅有一个引起它变化的原因，如果一个类承担的责任过多，就等于把这些责任耦合在一起，一个责任的变化可能会削弱或抑制这个类完成其他责任的能力**，这种耦合会导致脆弱的设计，当变化同时面临两个或多个方向变化时设计会遭到意想不到的破坏甚至根本没办法处理。

* 第二、会造成模型和视图的紧耦合，如果你想复用此视图来处理其他模型，根本不可能。

* 于是把控制器从视图中分离出来，将视图和模型解耦，通过控制器来保持控制器和视图之间的松耦合，使设计更有弹性和容易扩展，足以容纳以后的改变。

#### MVC的策略模式

> 策略模式：定义了算法族，分别封装起来，让他们之间可以相互替换，此模式让算法的变化独立于使用算法的客户。

* 完成一项任务，往往可以有多种不同的方式，每一种方式称为一个策略，我们可以根据环境或者条件的不同选择不同的策略来完成该项任务。
* 在软件系统中，有许多算法可以实现某一功能，如查找、排序等，一种常用的方法是硬编码(Hard Coding)在一个类中，如需要提供多种查找算法，可以将这些算法写到一个类中，在该类中提供多个方法，每一个方法对应一个具体的查找算法；当然也可以将这些查找算法封装在一个统一的方法中，通过if…else…等条件判断语句来进行选择。这两种实现方法我们都可以称之为硬编码，如果需要增加一种新的查找算法，需要修改封装算法类的源代码；更换查找算法，也需要修改客户端调用代码。在这个算法类中封装了大量查找算法，该类代码将较复杂，维护较为困难。


* MVC模式视图和控制器实现了经典的策略模式：视图是一个对象，可以被调整使用不同的策略（行为），而控制器提供了策略（行为）。视图想换另一种行为，换控制器就可以了。视图只关心系统中可视的部分，对于任何界面行为，都委托给控制器处理。使用策略模式也可以让视图和模型之间的关系解耦，因为控制器负责和模型交互来传递用户的请求。对于工作是怎么完成的，视图毫不知情。

### MVC的形成

* 从MVC的形成过程来看，最初只有模型和视图两个元素。模型封装了数据并提供操作接口，视图用来表现数据和接收用户请求。模型是独立的，而视图依赖 于模型：从模型获取数据进行显示；向模型发送用户请求，并根据返回结果刷新自己。

* 需要用多个视图表现同一模型时，情况发生了变化：一个视图修改数据以后，不但本身要刷新，其他所有视图也要刷新。如果由该视图通知其他视图，它就需 要知道其 他所有视图，由于每个视图都可能发出修改，每个视图都要知道其他所有视图，这种关联过于复杂，不但难以维护，而且不便于增加新的视图。如果让模型通知所有 视图更新，可能会影响模型的独立性。**用观察者(Observer)模式 可以解决上述矛盾， 从而实现：由模型通知视图，而模型不依赖于具体的视图，具体视图之间相互独立**。

* 视图是用户请求的接收者，但不宜作为请求的处理者。因为界面是易变的，如果业务代码和界面代码放在一起，**频繁的界面修改可能会破坏比较稳定的业务代码**。_将业务逻辑分离出来，由一个控制器负责，就是为了避免这种干扰_。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190219151816.png)


模型在状态变化的时候，直接通知所有视图，视图向模型查询状态数据，然后刷新自身。当用户发出操作时，视图把消息发给控制器，控制器按照业务逻辑进行处理，需要查询或更新数据时，控制器会调用模型。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359900306008.jpg)

* _MVC架构把数据处理，程序输入输出控制及数据显示分离开来，并且描述了不同部件的对象间的通信方式_。使得软件可维护性，可扩展性，灵活性以及封装性大大提高；
* MVC(Model-View-Controller)把系统的组成分解为M（模型）、 V（视图）、C（控制器）三种部件。
* 视图表示数据在屏幕上的显示。
* 控制器提供处理过程控制，它在模型和视图之间起连接作用。
* 控制器本身不输出任何信息和做任何处理，它只负责把用户的请求转成针对Model的操作，和调用相应的视图来显示Model处理后的数据。
* 同样的数据，可以有不同的显示和进行各种处理。显示仅仅是表现数据，而处理是根据用户请求改变数据的过程，不但包含业务逻辑，也要提供响应策略。
* 响应策略由控制器负责，视图可以使用不同的控制器提供不同的响应方式，这是策略(Strategy)模式的应用。 

### MVC的优缺点

#### 优点

（1） 有利于团队开发分工协作和质量控制，降低开发成本。

（2） 可以为一个模型在运行时同时建立和使用多个视图。变化-传播机制可以确保所有相关的视图及时得到模型数据变化，从而使所有关联的视图和控制器做到行为同步。

（3） **视图与控制器的可接插性，允许更换视图和控制器对象**，而且可以根据需求动态的打开或关闭、甚至在运行期间进行对象替换。

（4） **模型的可移植性**。因为模型是独立于视图的，所以可以把一个模型独立地移植到新的平台工作。需要做的只是在新平台上对视图和控制器进行新的修 改。

（5） 潜在的框架结构。可以基于此模型建立应用程序框架，不仅仅是用在设计界面的设计中。

#### 缺点

（1）增加了系统结构和实现的复杂性。对于简单的界面，严格遵循MVC，使模型、视图与控制器分离，会增加结构的复杂性，并可能产生过多的更新操作，降低运行效率。

（2）视图对模型数据的访问效率低。视图可能需要多次调用Model才能获得足够的显示数据。

（3）完全理解MVC并不是很容易。使用MVC需要精心的计划，由于它的内部原理比较复杂，所以需要花费一些时间去思考。 同时由于模型和视图要严格的分离，这样也给调试应用程序到来了一定的困难。 

—— 其实我觉得这个MVC算是很基础的工程架构，不算很复杂，所以应用很广泛。

## MVVM模式

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190805141346.png)

MVVM（Model-View-ViewModel）是一种体系结构或模式，它使组件的依赖性变得简单，因为View依赖于ViewModel，而ViewModel依赖于模型线性。它的事件流是线性的，相反，从Model到ViewModel和ViewModel到View。

![MVVM](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721093701.png)

另一方面，在MVC（模型 - 视图 - 控制器）架构或模式中，Controller依赖于模型和视图，其事件流程从模型到控制器和视图到控制器。

![MVC](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721093724.png)


MVC的问题在于，随着项目的发展，Controller往往会变得庞大而复杂，因为它必须同时处理模型和视图(几乎覆盖所有)。实际上，MVC是Web应用程序中的一个很好的模式，支持[Ruby on Rails](http://rubyonrails.org/)或[ASP.NET MVC等框架](http://www.asp.net/mvc)，但在iOS应用程序中，MVC通常会生成单片且难以维护的代码。

对于MVC的缺点，MVVM越来越受欢迎来开发移动应用程序或桌面应用程序。在iOS应用程序中，MVVM的“视图”由“View”（UIView）和“ViewController”（UIViewController）组成。视图逻辑（例如，值`1000`应显示为`"1,000"`）在ViewModel中实现。View只使用ViewModel提供的值来显示。Model负责业务逻辑。**由于责任分离，MVVM架构中的iOS应用程序更容易测试**。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721093906.png)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359952531157.jpg)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190304081524.png)

为了解决这个问题，我们的首要任务是清理视图控制器的视图控制器，分为两部分：视图和视图模型。具体地说，我们要：

* 设计一组绑定接口。
* 将显示逻辑和控制逻辑移到`ViewModel`上。

因此，我们可以将UI组件抽象为一组规范表示：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15235279133274.jpg)

### ViewModel

MVVM 中的 viewModel 的主要职责就是从 model 层获取 view 所需的数据，并且将这些数据转换成 view 能够展示的形式。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721132712.png)


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

### 绑定 ViewModel 

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



```objc
@interface Person : NSObject

- (instancetype)initwithSalutation:(NSString *)salutation firstName:(NSString *)firstName lastName:(NSString *)lastName birthdate:(NSDate *)birthdate;

@property (nonatomic, copy, readonly) NSString *salutation;
@property (nonatomic, copy, readonly) NSString *firstName;
@property (nonatomic, copy, readonly) NSString *lastName;
@property (nonatomic, copy, readonly) NSDate *birthdate;

@end

```


然后是 `view` 层的代码 `PersonViewController` ，在 `viewDidLoad` 方法中，我们将 `Person` 中的属性进行一定的转换后，赋值给相应的 `view` 进行展示：


```objc
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


```objc
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

```objc
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


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359930200792.jpg)


1）什么是“处理视图状态”？
视图可能根据不同的状态有不同的展示内容，甚至展示效果。我们常见的“cur”（current)前缀就适用于说明这种场景。“当前选择的模块”，“某个按钮当前的选择状态”，这些表示视图状态的操作变量的定义应当在VM当中，相关的逻辑交互也应当在VM当中。如果说View提供了视图的所有展示元素；那么VM则可以确定某个视图模块某一时刻某一个状态下的呈现内容。

2）什么是“处理视图协作”？
一个VM不一定只和一个View存在关联，它可能同时协调多个视图。
我们以同程旅行的一个筛选界面作为参考场景进行说明：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359931414076.jpg)

当我们将“4.5分以上”后面的对号勾上的时候，上面的“4.5分以上”会被同步勾取，同时，“评分”后面会多出个小绿点，这表示评分这页的筛选条件选择的不是默认的“不限”。很显然，关键词模块、筛选分类模块、筛选详情模块正常人都会分成3部分视图绘制。这三个视图间显然是有交互关系的（即“筛选详情模块”的勾选触发了“关键词模块”的高亮和“筛选分类模块”的加点），而VM即是处理这种交互关系理想场所。

3）什么是“数据绑定”？
这边特指将一个模型数据和视图中的一个展示内容进行关联绑定；
单向绑定一般指模型数据变化触发对应的视图数据变化
双向绑定指模型数据，视图数据任意一方变化，都会触发另一方的同步变化。

4）什么是“数据转换”？
我们不能企望所有的模型数据都能直接被视图使用，比如模型中是一个BOOL（0/1）值，而对应的视图展示期望为“是”/“否”，类似这样的数据转化工作，交给VM吧！

### 数据绑定方式

1. 单向数据绑定

2. 双向数据绑定

3. 集合的数据绑定

4. 执行过程绑定

5. 错误处理

基本着五种绑定能够覆盖业务中的大部分的场景


## 模块职责

* Model模型对应的管理类, 负责添加, 删除, 通知, 保存等功能, 仅提供能力, 无主动行为,Models are the application's dynamic data structure, independent of the user interface. They directly manage the data and business logic of the application.
* View: Views are responsible for rendering content and handling user interaction with that content.
* View Model：A view model is a view's model. It has the data needed to populate a particular kind of view and the presentation logic needed to transform that data into properties that can be rendered.
* Controller: Controllers are responsible for controlling the flow of the application execution.
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190805173404.png)


## 依赖

我们在MVVM架构中了解了依赖于ViewModel和ViewModel的View。当我们编写代表模型，视图或ViewModel的协议，类或结构时，**我们如何强制依赖的方向**？如果将所有类型放在目录中，甚至放在应用程序目标中，则很容易混乱。

iOS 8引入了动态框架包含Model，View和ViewModel框架的iOS应用程序的体系结构（如下图所示）确保依赖关系的方向是从View到ViewModel和ViewModel到Model，应用程序注入了依赖关系。例如，如果在ViewModel框架中创建一个类型，它可以在Model框架中引用类型，但不能在View框架中引用那些类型。

该体系结构保持了依赖关系方向的一致性，使应用程序易于开发，测试和维护。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721094213.png)

## 参考

* [使用ReactiveCocoa进行MVVM架构中的依赖注入第1部分：简介](https://yoichitgy.github.io/post/dependency-injection-in-mvvm-architecture-with-reactivecocoa-part-1-introduction/)
* [MVVM With ReactiveCocoa - 雷纯锋的技术博客](http://blog.leichunfeng.com/blog/2016/02/27/mvvm-with-reactivecocoa/)
* [不再对 MVVM 感到绝望 - 掘金](https://juejin.im/post/5a782d0d5188257a856f1dd7)
* [swift-best-practices/CombinedDocument.md at master · Lickability/swift-best-practices](https://github.com/Lickability/swift-best-practices/blob/master/CombinedDocument.md)

* [How not to get desperate with MVVM implementation – Flawless App Stories – Medium](https://medium.com/flawless-app-stories/how-to-use-a-model-view-viewmodel-architecture-for-ios-46963c67be1b)
* [leichunfeng/MVVMReactiveCocoa: GitBucket iOS App](https://github.com/leichunfeng/MVVMReactiveCocoa)
* [对于MVVM，多一些思考总是没差的 - 简书](https://www.jianshu.com/p/fbfbdfba117f)
* [ObjC 中国 - MVVM 介绍](https://objccn.io/issue-13-1/)


