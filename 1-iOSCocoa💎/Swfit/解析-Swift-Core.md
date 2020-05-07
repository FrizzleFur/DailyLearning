#  面向协议的 MVVM 架构介绍

在 Swift 中用值类型来替代引用类型，比以前在 Objective-C 中要容易许多，这可以让您的代码更简洁，并且更不容易出错。然而，当需要在多个类型当中共享代码的时候，许多人往往会回避使用值类型，而转为使用继承来实现。

通过 Natasha 在 do{iOS} 2015 上对 MVVM 的介绍，您可以学习到如何使用协议来实现这个功能，而不再采用继承的方式！Natasha The Robot 将会引导您跟随她学习和使用面向协议编程的过程，使用 Swift 2.0 的特性来创建漂亮、稳定的代码。

为什么要简化 Swift 中的代码呢？ 
嗨，我是 Natasha。就是 Twitter 上的 @NatashaTheRobot。关于我的个人介绍的话我还想多说一些：我有一个 每日 Swift 周报，还有一个写了许多关于 Swift 文章的博客，自 Swift 第一天推出以来，我就已经在大量地研究 Swift 了。

作为一名 Objective-C 开发者，我基本上是在 Swift 刚刚推出的时候开始学习 Objective-C 代码的——这导致我使用了很多的引用类型。我习惯性将所有东西声明为类，因为我已经习惯了面向对象编程。这也正是 Objective-C 的思想。

我觉得我自己的编程习惯还是很不错的了，因为我有些时候还是会使用枚举的。它们比普通的枚举要复杂得多，这让我觉得很不错。然而，当我开始参加各种活动然后听取演讲之后，尤其是 Andy Matuschak 关于控制 Swift 代码复杂度的演讲之后，我就豁然开朗了。他提到要使用值类型。直到这个时候，我才知道 Swift 当中有结构体，但是作为一名从 Objective-C 转向 Swift 的开发者，对我来说以类来起步是很自然的一件事情。

这次演讲给我留下了很深的印象，我觉得应该要尽可能将所有东西都应用上值类型。事实上，他发现绝大多数 Swift 标准库中的东西都是使用的值类型，并且语言的创造者本身也在使用值类型。我回到我的工作项目当中，然后创建了一个新文件，准备从此开始实验值类型的强大之处。

最初，我有这样一个感觉：“我是一名 Swift 开发者了！我在使用结构体了！”，但是后来有些需求不得不让我转而使用继承，这感觉非常糟糕，但是我不知道该如何解决这个问题，直到……

面向协议编程 (2:28)
在今年的 WWDC 上，有一个难以置信的演讲，讲述了在 Swift 中进行面向协议编程。在这里，他们解释了如何用协议来替代继承。如果您没有看过这个演讲并且打算转向 Swift 进行开发的话，那么我觉得这是自去年的 WWDC 以来，最为重要的一个演讲了。

在这个演讲中， Apple Swift 标准库的技术总监 Dave Abrahams 提到了：

“Swift 是一门面向协议的编程语言。”

在视频当中，他演讲的标题是“醍醐灌顶的讲解 (Professor of Blowing Your Mind)”，他成功做到了这一点，我以及每一名观众都能感受到这一点。

这对我们来说并不是一个全新的概念：我们已经见识过 Apple 使用了大量的协议，比如说 TableView 当中，我们都觉得这是一个很棒的设计模式，因为没有人希望每时每刻都要继承 UITableViewController。相反，您可以使用协议来告诉 Apple 您需要多少个表视图单元格。我们已经知晓了这种设计模式的魅力所在，而现在我们需要把它带到一个全新的高度。

对于我来说，我对此非常兴奋。我已经迫不及待回到电脑面前，更详细地研究这个设计模式，成为一名“面向协议的程序员”。我随后带着兴奋回去处理我的那些工作。在我的工作当中，我已经有了一个正在使用的代码库，它当中带有了已经确定并建立的模式。这很难向其中加入新的东西，也很难理解应该如何使用它。我想要使用面向协议编程，但是我觉得我已经受限于我的既有项目了，我不知道该如何才能更进一步。

MVVM - 将事情留到第二天再考虑 (5:00)
我的脑海里一直在思考着关于协议的相关内容，我在想“我该怎么将协议整合到我的代码当中呢？”这件事情一直停留在我的脑海里，挥之不去，但是我不知道该如何做到这一点。然后，我就去睡了一觉。我非常强烈推崇这种做法，尽管对于程序员来说，他们的声誉往往在于“不达目的不罢休”。对于我来说，睡一觉可以帮助我解决很多问题，很可能是因为我们的大脑在睡眠的时候可以更好地处理信息。

睡了一觉之后，我醒来发现所有的东西都迎刃而解了。我想我至少能够在我的工作代码中应用一个用例，这让我十分兴奋。这个用例就是使用 MVVM。

Receive news and updates from Realm straight to your inbox

输入你的邮箱地址
 
Comments 
对那些不熟悉 MVVM 的人来说，您可以去阅读 Ash Furrow 的这篇博文：Swift 中的 MVVM。同样在 objc.io 上还有一篇叫做 “MVVM 介绍” 的文章。我会使用一个简单的例子来介绍，所以希望大家能够看到 MVVM 是如何工作的。

我曾经在一家银行工作。比如说您有一个模型，里面包含了关于账户余额的一些原始数据。在模型层当中，您想要保留这个值，作为原始的 NSDecimalNumber。

let amount = 6729383.99
当您向用户展示相同数字的时候，您可能想要转换其显示样式，例如说：“您的账户余额为……”，然后在您的视图当中添加 “$” 标识，并且进行格式化：

Your balance is $6,729,383.99
许多人喜欢将这种代码放到视图控制器当中。这往往会导致视图控制器变得臃肿不堪，从而难以测试。此外，您还可能将这种代码放到模型当中，从而让模型也变得非常难看，因为有许多进行格式化的代码挤在其中。

相反，您可以让模型变得清晰，然后仅仅只用于映射您的原始数据。这是您视图模型的初始状态：

```swift
struct AccountViewModel {
    let displayBalance: String

    init(mode: BankAccount) {
        let formattedBalance = model.balance.currencyValue
        displayBalance = "Your balance is \(formattedBalance)"
    }
}
```

您的视图模型实际上会读取您的数据模型，然后将其中的信息进行格式化，从而准备展示到视图当中。这就是视图模型的魅力所在。这很容易进行测试。您可以将带有账户信息的模型放进去，然后测试显示就可以了，而在此之前，如果您想要测试您的视图控制器或者视图，这是非常非常难的，因为输出特别纷繁复杂。

## Zoetrope 模型 (8:29)

注意到我的视图模型是值类型的。那么这个在 Swift 中是如何起作用的呢？

关键在于，您的视图控制器需要维持视图模型的最新版本。值类型是一种数据类型。它不应该成为真实的数据，它只是数据在某个时间点的一份拷贝而已。您的视图控制器需要跟踪这些信息，决定哪个拷贝数据应该展示给用户（也就是最新的拷贝）。

顺便想想，在 Andy Matuschak 的演讲中，那个关于 zoetrope 的例子。（在日本的 Ghibli 博物馆中有这样一个很神奇的西洋镜）。

这里的关键在于，zoetrope 的每一个帧都是静态值。您可以通过改变人物手部抬起的距离，或者人物头部倾斜的角度，来对字符进行编码。每一帧都是静态的，但是当您把它们放到一起，然后一直看向一个中心的话，那么始终都会有新的数据出现，这样您就可以得到一个美丽、生动的动画。

您可以用相同的方式来实现值类型。您的视图控制器将会跟踪 zoetrope 的最后一个帧图像——也就是最新的一块活跃数据，然后将其展示给用户。只要您的模型发生了更新，也就是有了新的数据，这样您就可以通过计算得到一个新的视图模型。现在，您的视图就会根据最新的信息进行更新了。

var viewModel = ViewModel(model: Account)
没有协议之前的丑陋 (9:57)
现在，我们已经得到了令人兴奋的部分了。我现在将会运行一个非常简单的例子。在这个表视图当中，比如说绝大多数应用都会有的设置屏幕，试想我只有一个设置：用一个滑块 (slider) 来将整个应用主色调变为黄色。

这个操作应该是非常简单的，但是它也会变得很复杂。这里有一个问题：在我们的表视图单元格当中，其中的每一个单独组件都需要以某种方式来进行格式化。如果其中有标签 (label) 的话，那么您必须要定义它的字体，字体颜色，字体大小，等等。如果是开关 (switch) 的话，那么当开关打开的时候会发生些什么？初始状态是关闭还是打开？对于这种拥有这两个元素的简单的表视图单元格来说，我已经有 6 种不同的方式来对它进行配置：

```swift
class SwitchWithTextTableViewCell: UITableViewCell {
    func configure(
        title: String,
        titleFont: UIFont,
        titleColor: UIColor,
        switchOn: Bool,
        switchColor: UIColor = .purpleColor(),
        onSwitchToggleHandler: onSwitchTogglerHandlerType? = nil)
    {
        // 在这里配置视图
    }
}
``
您可以想象得到，我们绝大多数人进行配置的表视图单元格比着远复杂得多。在我的代码当中，这种 configure 方法将非常非常累赘。添加一个副标题将会导致多出额外的三个属性需要设置。在 Swift 中您可以用默认值来获得一些辅助，但是使用这种臃肿的 configure 方法不是非常简洁。

在您实际上调用此方法的视图控制器当中，我们持有了所有存放在其中的信息栈。它看���来并不是很好看；这让人感觉很不好，但是我一直没想到有更好的办法，直到协议的出现。

视图模型及协议 (12:05)
对于单元格来说，我们不应该使用这些臃肿的配置方法，而是应该将每个部分单独拿出来，然后将其放大一个 SwiftchWithTextCellProtocol 的协议当中。这让我感觉到非常开心。这样子，我就可以让我的视图模型实现这个协议，然后在这里设置所有的属性。现在，我就不用再去使用臃肿的配置方法了，但是我仍然需要有一种方式来确保每个单独的属性实际上都被设置了。

```swift
protocol SwitchWithTextCellProtocol {
    var title: String { get }
    var titleFont: UIFont { get }
    var titleColor: UIColor { get }

    var switchOn: Bool { get }
    var switchColor: UIColor { get }

    func onSwitchToggleOn(on: Bool)
}
```

通过 Swift 2.0 当中的协议扩展，我就可以通过默认值做一些处理了。如果对于大多数单元格来说，可以确定某一种颜色的话，那么您就可以对其建立扩展，然后设置该颜色即可。所有的实现此协议的视图模型都没必要再去设置这个颜色了。这个做法非常棒：

```swift
extension SwitchWithTextCellProtocol {
    var switchColor: UIColor {
        return .purpleColor()
    }
}
```

现在，我的 configure 方法只需要获取某个实现此协议的值就可以了：

```swift
class SwitchWithTextTableViewCell: UITableViewCell {
    func configure(withDelegate delegate: SwitchWithTextCellProtocol)
    {
        // 在这里配置方法
    }
}
```

这个方法只有一个参数，这对之前的那个六个参数（甚至更多）的方法来说是一个重大的改进。这是我现在的视图模型的一个示例：

```swift
struct MinionModeViewModel: SwitchWithTextCellProtocol {
    var title = "Minion Mode!!!"
    var switchOn = true

    var switchColor: UIColor {
        return .yellowColor()
    }

    func onSwitchToggleOn(on: Bool) {
        if on {
            print("The Minions are here to stay!")
        } else {
            print("The Minions went out to play!")
        }
    }
}
```

它实现了这个协议，然后配置了所有相关的信息。正如您在前面的示例中看到的那样，您可以用您的模型对象来初始化视图模型了。现在，如果您需要诸如外汇收益之类的信息的话，您实际上可以在您视图模型的各个地方使用这个信息，以便能够指明如何对其进行配置，并将视图展示出来。

因此，这个操作将会非常简单。现在，我的 cellForRowAtIndexPath() 也变得非常的简明了：

```swift
// YourViewController.swift
let cell = tableView.dequeueReusableCellWithIdentifier("SwitchWithTextTableViewCell", forIndexPath: indexPath) as! SwitchWithTextTableViewCell

// This is where the magic happens!
cell.configure(withDelegate: MinionModeViewModel())

return cell
```

我将单元格 dequeue 出来，然后调用了我视图模型的 configure 方法。在这个例子当中，我没有对它的 frame 进行任何的配置，它同样也没有包含模型层，但是您同样可以将这个模型放到视图控制器层级，以便对其进行跟踪。您同样可以在视图模型当中传递这些信息，这样您的单元格就可以生成了。当我们重构之后，我们只需要三行代码就可以完成配置了。

进一步的抽象 (14:10)
这个时候，我为自己的做法感到非常开心。因为我把这个臃肿的带有六个参数的 configure 方法，用协议的方式将其进行了重构。我发现使用协议能够让我的代码更优美、更简洁，逻辑更清晰。

通常情况下，我的下一步动作就是通过博客把它发表出来。我喜欢为了总结学习经验而写博客，因此无论我是学到了什么还是发现了什么，我都会在博客中把它写出来。我的博客上已经讲述了这一点，有人发帖评论说：“有没有考虑创建两个协议呢？一个作为实际编码信息的数据源，就比如说单元格的标题之类的东西，也就是实际的数据。”和颜色、字体之类的信息不同，它们应该是相互独立的，因为字体之类的信息更多是关于格式化方面的，而其中并没有包含实际的数据，并且这种模式我们已经可以看到 Apple 用过了，比如说在 UITableViewCells 或者集合视图之类的地方。

我认为这是一个非常绝妙的想法。我将我的逻辑进行了分离，然后再创建了单元格数据存储和单元格委托：

```swift
protocol SwitchWithTextCellDataSource {
    var title: String { get }
    var switchOn: Bool { get }
}

protocol SwitchWithTextCellDelegate {
    func onSwitchToggleOn(on: Bool)

    var switchColor: UIColor { get }
    var textColor: UIColor { get }
    var font: UIFont { get }
}
```

接下来，我让我的 configure 方法同时接收这两个协议。因为委托可以全部在协议扩展中使用默认值进行配置，比如说字体、颜色之类的信息，这样在理论上我可以不用向里面传递任何东西进去；我可以只用创建一个模型就可以了：

```swift
// SwitchWithTextTableViewCell
func configure(withDataSource dataSource: SwitchWithTextCellDataSource, delegate: SwitchWithTextCellDelegate?)
{
    // 在这里配置视图
}
```

现在我可以使用扩展来改进我的视图模型了。我会使用一个实现数据源的代码块，然后给定要传递给视图当中的原始信息：

```swift
struct MinionModeViewModel: SwitchWithTextCellDataSource {
    var title = "Minion Mode!!!"
    var switchOn = true
}
```

接下来，我会在一个单独的视图模型的部分当中使用处理字体、颜色之类的委托，然后在其中进行相关的配置。

```swift
extension MinionModeViewModel: SwitchWithTextCellDelegate {
    var switchColor: UIColor {
        return .yellowColor()
    }

    func onSwitchToggleOn(on: Bool) {
        if on {
            print("The Minions are here to stay!")
        } else {
            print("The Minions went out to play!")
        }
    }
}
```

最终，我的表视图单元格变得非常简单：

```swift
// SettingsViewController

let viewModel = MinionModeViewModel()
cell.configure(withDataSource: viewModel, delegate: viewModel)
return cell
```

我仅仅只用创建了我的视图模型，然后将其传递到配置方法当中，然后返回单元格，就完毕了。

Swift 2.0 中的 Mixin 和 Trait (16:32)
我对这一点还是比较满意的。我创建了协议，简化了我的代码，然后发表了相关的博客，学习到了相关的知识。接着，我又读到了一个非常赞的文章，我觉得大家都应该去读一读：@mhollemans 写的 Swift 2.0 中的 Mixin 和 Trait。Matthijs 讲述的是游戏开发，虽然我对此并不是很熟悉，但是我们仍然可以去理解他提到的基本概念。

在游戏开发当中，通常会有着一个很庞大的层级关系，以及一系列的继承。比如说“怪物”类型当中，可能会有各种各样的“怪物”。继承在这里变得十分有意义。但是，随着层级的扩展，事情变得开始凌乱起来。


对于这种类型的层次结构来说，刚开始的时候还好。不过随着后面的发展，当您遇到要设计一个也能够射击的怪物的时候，事情就变得麻烦起来了，因为城堡同样也可以射击，因为在城堡的顶端拥有大炮，因此您现在就必须要将这个“射击辅助类”提取出来。当您正在创建这些子类的时候，您会觉得这种做法是非常非常奇异的，但是这很快会变得越来越混乱，最终您将会写出一团乱麻般的代码。

Matthijs 重构了这个代码，这样我们不再使用这些继承对象的逻辑，比如说控制能够射击或者控制能够治疗的子类，而是将其提取成为协议，通过协议扩展来实现这个功能。

这使得代码看起来更加简洁，更容易理解。例如：

class ZapMonster: GameObject, GunTrait, RenderTrait, HealthTrait, MovementTrait {
    ...
}
只需要看一看这个对象的类型，我就可以立刻理解这个对象拥有哪些功能，而不是去一个一个查看它的实现。我个人更加喜欢这样的设计模式。

在我们的应用中应用 Mixin (19:47)
虽然刚刚的例子是关于游戏开发的，但是我希望我也能够在我自己的代码中对表视图单元格应用上这个功能。这样就不用让我实际的单元格实现这个协议了，我只需要将其与更宽泛的 TextPresentable 联系在一起就可以了。这样，任何拥有标签的视图，而不仅仅只是单元格，都可以实现这个协议来完成相关的功能。这样我就可以说这个标签当中有什么样的文本，什么样的颜色，以及什么样的字体：

protocol TextPresentable {
    var text: String { get }
    var textColor: UIColor { get }
    var font: UIFont { get }
}

protocol SwitchPresentable {
    var switchOn: Bool { get }
    var switchColor: UIColor { get }

    func onSwitchToggleOn(on: Bool)
}
Switch 拥有自己独有的协议，这样就可以知道它应该如何配置了。您可以想象这个从游戏开发示例当中得来的灵感：现在您需要一个图像了，你只需要实现 ImagePresentable 协议就可以了；现在您需要一个文本框了，只需要实现 TextFieldPresentable 协议就可以了：

protocol ImagePresentable {
    var imageName: String { get }
}

protocol TextFieldPresentable {
    var placeholder: String { get }
    var text: String { get }

    func onTextFieldDidEndEditing(textField: UITextField)
}
通过协议扩展，您可以配置所有的字体和颜色，因此每一个单独实现这个 TextPresentable 协议的视图都会拥有这个标签的默认配置，因为通常情况下，您应用中的标签基本上都是非常相似的：

extension TextPresentable {

    var textColor: UIColor {
        return .blackColor()
    }

    var font: UIFont {
        return .systemFontOfSize(17)
    }

}
您甚至可以更进一步，创建不同类型的标签，比如说标题标签。或许它拥有确定的字体或者颜色，这就意味着您可以一遍又一遍地在您的应用程序中重用这个标签。这样当您的设计师要求将所有的标题颜色变成蓝色的时候，这种做法将会非常快速。您可以前往协议扩展当中，将其改变为蓝色，然后通过这一行代码的变化，每一个拥有这个 HeaderTextPresentable 协议的视图中的标签都会立刻改变。

我十分喜欢这个设计模式。这是我现在单元格的模样：

class SwitchWithTextTableViewCell<T where T: TextPresentable, T: SwitchPresentable>: UITableViewCell {
    private var delegate: T?

    func configure(withDelegate delegate: T) {
        // 在这里配置视图
    }
}
在这种情况下，它没有实现这些协议，但是它会期待某种实现这些协议的东西传递进去，因此我们使用了泛型。这个单元格期待一个实现了 TextPresentableProtocol 以及 SwitchPresentableProtocol 的委托。这个配置方法并不关心传递进去的对象。就我们而言，传递进去的将是一个视图模型，但是它所想要的只要是实现了这些协议的东西就可以了，现在，您就可以基于这些信息在单元格当中配置所有东西了。

extension MinionModeViewModel: TextPresentable {
    var text: String { return "Minion Mode" }
    var textColor: UIColor { return .blackColor() }
    var font: UIFont { return .systemFontOfSize(17.0) }
}
我们的视图模型将拥有一个 TextPresentable 代码块，在其中您可以配置文本、颜色、字体，并且由于所有这些在协议扩展当中都已经有默认值了，您甚至都不用让视图模型去实现这些具体的内容。

对于 SwitchPresentable 也是一样的。这个开关应该开启还是关闭？当开关开启的时候应该发生些什么？这里，您可以看到这个视图的一小部分：

extension MinionModeViewModel: Switch Presentable {
    var switchOn: Bool { return false }
    var switchColor: UIColor { return .yellowColor() }

    func onSwitchToggleOn(on: Bool) {
        if on {
            print("The Minions are here to stay!")
        } else {
            print("The Minions went out to play!")
        }
    }
}
最后，视图控制器当中的代码就变得十分简单：您只需要 dequeue 相应的单元格。然后通过视图模型对其进行配置，然后返回单元格即可。其中一个关键的地方是，因为我们使用的是泛型，因此我们必须要指明 T 是什么东西，在我们的例子当中，T 是视图模型。

Swift: 一个正在发展的语言 (24:02)
在这一点上我是非常兴奋的。我已经经历了三种不同的迭代版本了。然而，Swift 仍然是一门新语言，它只出现了不到两年的时间。在这个过程中它变化了很多，我们作为一个社区必须要决定 Swift 的最佳用例是什么。

我一直在想一件事情，当我在我的代码中发现或者是提出某个新的设计模式的时候，该如何才能够轻松地进行迁移。这使得我切实相信：

世上唯一不变的事就是变化本身。

这句话特别适用于编程界。我通常会花费一个季度的时间来重写我的每个应用，因为最终您可能会需要改变很多东西；您需要添加单元测试，或者需要为了 iOS 7 重新设计。Apple 有时候会推出新的东西，因此您可能需要删除或者添加新的功能；任何东西都在不断的变化。

因此，我总是在认定我的代码即将被改变的这种假设下进行工作的。对于长期的产品开发来说，我必须要考虑到我正在用的这个设计模式是否允许我简单地进行修改，而不是对一个类进行一个细小的变化就得祈祷这个操作不会发生崩溃。对于我来说，这个设计模式是非常赞的，因为它允许快速地进行修改。

假如说我的产品经理过来跟我说：“哎，对于这个单元格，我希望让它能够添加一个图像”。刚开始的时候，我们只有标签和开关，而现在只是多了一个图像而已。因此，我会让这个单元格期待一个还实现了 ImagePresentableProtocol 的东西传递进去，这就是我在单元格层面所做的全部操作。

我同样也必须要更新我的配置方法，以便能够让其能够真正使用上这个图像，但是这只需要使用两行代码就可以了。最后，我只是对我的视图模型进行扩展就可以了。

extension MinionModeViewModel: ImagePresentable {
    var imageName: String { return "minionParty.png" }
}
开心的 Natasha the Robot：总结 (26:26)
这个时候我是非常开心的。这些就是我所要讨论的所有东西了，在 MVVM 架构中使用协议。

使用协议来配置您的视图
使用协议扩展来实现默认值——这就是您设置用在您应用当中的所有字体、颜色以及配置的地方。这里最大的障碍就是处理子类了；这就是人们为什么总是使用继承——因为需要在多个类当中使用相同的功能。
使用视图模型来为协议提供数据。您使用视图模型的目的在于它们易于测试，并且变化带来的耦合度很小。您的视图控制器可以决定在最新版本的代码当中使用哪个版本的视图模型。
重点是我希望在明年的 WWDC 中，他们能够提出一个适用于 Swift 的全新架构，或者有人能够在这个演讲之后在 Tweet 上给我一个更好的主意。对于那些使用 Swift 开发的人来说，我建议大家保持一个开放的心态。想想您该如何让代码变得更好。

听从您的同事、社区的建议。总有可以改善代码的方式的，并且我确信我可以借此来进行代码的改善。在这一点上，我是非常高兴的，不过我下周可能会读到某些文章，这可能会导致我改变主意，或者学到一些新的东西。

关于 Swift 的一个很酷的事情是，我们都有不同的编程经验。您的同事可能是函数式编程语言出身，也有可能是 Ruby 或者 .NET 出身——他们可能有与你不同的想法。由于 Swift 是一个不断发展的语言，因此您需要虚心向别人学习。这能够改善您的设计模式，并且能够帮助您找到最好的设计模式。我认为您总是可以对其进行优化和改进，分享您的发现，然后周而复始。

## 参考

* [面向协议的 MVVM 架构介绍](https://academy.realm.io/cn/posts/doios-natasha-murashev-protocol-oriented-mvvm/)
* [Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/play/wwdc2015/408/)
