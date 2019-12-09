# 解析-依赖注入Swinject


# 背景

## 什么是依赖
[IOS架构 — Swinject 依赖注入框架 - 简书](https://www.jianshu.com/p/4bcac6d64382#%E4%BB%80%E4%B9%88%E6%98%AF%E4%BE%9D%E8%B5%96)

依赖是我们代码中两个模块之间的耦合（在面向对象语言中，指的是两个类），通常是其中一个模块使用另外一个提供的功能。

### 依赖有什么不好？

从上层到底层依赖都是危险的，因为我们在某种程度上把两个模块进行耦合，这样当需要修改其中一个模块时，我们必须修改与其耦合的模块的代码。这对于创建一个可测试的app来说是很不利的，因为单元测试要求测试一个模块时，要保证它和app中其他模块是隔离的。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20191209141432.png)

从上面的例子我们知道，通过构造函数传递依赖（注入），从而把创建模块的任务从另一个模块内部抽离出来。对象在其他地方创建，并以构造函数参数的形式传递给另一个对象。

但新问题出现了。如果我们不能在模块内部创建其他的模块，那么必须有个地方对这些模块进行初始化。另外，如果我们需要创建的模块的构造函数包含大量的依赖参数，代码将变得丑陋和难以阅读，app中将存在大量传递的对象。依赖注入正是为解决这类问题而诞生的。

我们需要在app中提供另一个模块，专门负责提供其他模块的实例并注入他们的依赖，这个模块就是依赖注入器，模块的创建集中于app中的一个统一的入口。


* 依赖倒置 
    * 这里我们重点讲下依赖倒置原则：实体必须依靠抽象而不是具体实现。它表示高层次的模块不应该依赖于低层次的模块，它们都应该依赖于抽象。
    * 在传统软件设计中，我们一般都是上层代码依赖下层代码，当下层代码变动时，我们上层代码要跟着变动，维护成本比较高。
    * 这时我们可以上层定义接口，下层来实现这个接口，从而使得下层依赖于上层，降低耦合度。
    * （PC主板和鼠标键盘接口就是一个很好的例子，各数据厂商根据主板上的接口来生产自己的鼠标键盘产品，这样鼠标坏了后我们可以随便换个符合接口要求的鼠标，而不用修改主板上的什么东西）
*  控制反转
    * 上面讲的依赖倒置是一种原则，而控制反转就是实现依赖倒置的一种具体方法。
    * 控制反转核心是把上层（类）所依赖单元的实例化过程交由第三方实现，而类中不允许存在对所依赖单元的实例化语句。

## 定义

> 1. 依赖是另一个对象依赖于实现其业务目的的对象
> 2. 依赖注入是从对象中获取其依赖性的工作

* 一个依赖关系指的是可被利用的一种对象（即服务提供端） 。
* 依赖注入是将所依赖的传递给将使用的从属对象（即客户端）。
* 该服务是将会变成客户端的状态的一部分。 传递服务给客户端，而非允许客户端来建立或寻找服务，是本设计模式的基本要求。


依赖注入，特别是将SimpleCurrencyFormatter类从获取其Locale依赖性的工作中解脱出来，解决了这个问题。考虑以下实现：


### 通俗理解

[浅谈控制反转与依赖注入 - 知乎](https://zhuanlan.zhihu.com/p/33492169)

* a依赖b，但a不控制b的创建和销毁，仅使用b，那么b的控制权交给a之外处理，这叫控制反转（IOC）
* 而a要依赖b，必然要使用b的instance，那么可以通过
    * 通过a的接口，把b传入；
    * 通过a的构造，把b传入；
    * 通过设置a的属性，把b传入；
* 这个过程叫依赖注入（DI）。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721113603.png)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721113639.png)

一个更加实际的例子

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721114620.png)

可以看到相较于左侧，右侧依赖注入的方式可以明显解决传参一层层传递的问题。

## Why should I use it?

* 依赖注入有助于我们在不同的环境中使我们的组件更少耦合和更可重用。总的来说，它是分离关注的一种形式，因为它使用从初始化和配置的依赖性来分离。为实现这一目标，我们可以使用不同的技术将依赖项注入到我们的模块中。
* 如上所述，依赖注入的一个非常重要的方面是它使我们的代码更易于测试。 我们可以为我们想要测试的类/模块的依赖项注入模拟实例。这使我们可以将测试集中在模块中的单元测试代码上，并确保这部分按预期工作，而不会产生导致测试失败不明确的模糊副作用，因为其中一个依赖项不符合预期。这些依赖项应该自行测试，以便更容易地发现真正的错误并加快开发工作流程。


## Swinject

Swinject是Swift 的轻量级依赖注入框架。

依赖注入（DI）是一种软件设计模式，它实现了控制反转（IoC）以解决依赖关系。在模式中，**Swinject可以帮助您将应用程序拆分为松散耦合的组件，可以更轻松地开发，测试和维护**。Swinject由Swift泛型类型系统和第一类函数提供支持，可以简单而流畅地定义应用程序的依赖关系。


### 什么是Dependency Injection Container

The ability to automatically compose an object graph from maps between Abstractions and concrete types by making use of the types’ metadata supplied by the compiler and the Common Language Runtime.
有一个人引用了这本书的这样一句话。我觉得简单来说是可以通过传入一个抽象类型，可以构造出一个实例。我们简单的看一个使用代码

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721115802.png)
这里我们通过register方法，对一个类型进行注册。然后通过resolver方法，去调用构造方法得到这个实例。

## Swinject框架解析

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721121220.png)

* 核心是 Container类。它提供了两类方法，register 和 resolve。

* 为了找到在 resolve 时，能够找到对应的方法，内部维护了一个叫做services 的字典。key 是根据 serviceType、name、argumentsType 确定的。
* 在 register 时，会字典里加入一个条目。在 resolve 时，会根据字典，找到对应的 ServiceEntryProtocol，然后调用其方法生成一个 component。
* container.register(Animal.self) { _ in Cat() }
    .inObjectScope(.container)
* 例子如上，每次 register 方法，都会返回 ServiceEntry 实例，然后调用其 inObjectScope 方法，会设置其 objectScope。


[Swinject 源码框架(一）：基本原理 - 花老🐯 - 博客园](https://www.cnblogs.com/huahuahu/p/Swinject-yuan-ma-kuang-jia-yi-ji-ben-yuan-li.html)

## 基本用法


假设我们正在编写一款与动物玩的游戏。首先，我们将编写没有依赖注入的程序。这是Cat代表动物的类，


```swift
class Cat {
    let name: String
    
        init(name: String) {
        self.name = name
    }

    func sound() -> String {
        return "Meow!"
    }
}
```

和PetOwner类有一个Cat作为宠物玩的实例。


```swift
class PetOwner {
    let pet = Cat(name: "Mimi")

    func play() -> String {
        return "I'm playing with \(pet.name). \(pet.sound())"
    }
}
```
现在我们可以实例化PetOwner的play方法。
```swift
let petOwner = PetOwner()
print(petOwner.play()) // prints "I'm playing with Mimi. Meow!"
```


### 使用依赖注入解耦

如果每个人都是养猫的人，那就太棒了，但实际上有些人是养狗的人。**因为a的实例化Cat是硬编码的**，所以PetOwner类依赖于Cat类。必须将依赖关系解耦为支持Dog或其他类。


```swift
// AnimalType协议以摆脱依赖。
protocolAnimal {
 var name:String? { get }your
}
// Cat 修改类以符合协议，
class Cat: Animal {
 let name:String?init(name: String?) {
 self.name= name
 }
}
```

并且PetOwner修改了类以AnimalType通过其初始化程序注入。

```swift
class PetOwner {
    let pet: AnimalType

    init(pet: AnimalType) {
        self.pet = pet
    }

    func play() -> String {
        return "I'm playing with \(pet.name). \(pet.sound())"
    }
}
```

现在，我们可以在创建实例AnimalType时将依赖项注入协议PetOwner。

```swift
let catOwner = PetOwner(pet: Cat(name: "Mimi"))
print(catOwner.play()) // prints "I'm playing with Mimi. Meow!"
```

如果我们可以和Dog一起玩(Dog实现AnimalType协议)

```swift
class Dog: AnimalType {
    let name: String

    init(name: String) {
        self.name = name
    }

    func sound() -> String {
            return "Bow wow!"
    }
}
```
那么我们也可以和狗一起玩。
```swift
let dogOwner = PetOwner(pet: Dog(name: "Hachi"))
print(dogOwner.play()) // prints "I'm playing with Hachi. Bow wow!"
```

到目前为止，我们已经注入了PetOwner自己的依赖关系，但是如果随着应用程序的发展我们获得更多的依赖关系，那么手动维护依赖注入就更难了。让我们在这里介绍Swinject来管理依赖项。

### 使用Swinject

```swift
let container = Container()
container.register(AnimalType.self) { _ in Cat(name: "Mimi") }
container.register(PetOwner.self) { r in
    PetOwner(pet: r.resolve(AnimalType.self)!)
}
```

在上面的代码中，我们告诉`container`将`AnimalType`解析为一个名为“Mimi”的Cat实例，还有一个将`AnimalType`类型作为宠物的`PetOwner`实例。resolve如果容器无法解析实例，则该方法返回nil，但此处我们知道`AnimalType`已经注册并强制解包可选参数。

我们还需要配置的容器`Container`。让我们从container拿出一个PetOwner实例。
```swift
let petOwner = container.resolve(PetOwner.self)!
print(petOwner.play()) // prints "I'm playing with Mimi. Meow!"
```

使用已注入的依赖项（dependencies）的，已解析（resolved）实例来设置和检索Container实例已非常简单。

## 依赖注入应用

如果业务的解析等关系比较紧密，那么可以先解构依赖，将依赖使用注入的方式重构，方便对依赖项进行测试。

1. **一般把一些基础方法进行抽象，抽成协议protocol，让业务类有协议规范。**
2. **让一些业务类实现抽象协议后，需要一个类将业务实现类进行组装，让业务流程跑通。**

比如一个例子：一个应用程序，列出某些位置的当前天气，如下面的屏幕截图。将通过API从服务器接收天气信息，并且数据用于呈现在表格视图中。当然你会写单元测试

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721083442.png)

这里的问题是网络访问和数据处理的各个部分是耦合的。换句话说，数据处理取决于网络访问。如果依赖项是硬编码的，则很难围绕依赖项编写单元测试。
解耦前的`WeatherFetcher.swift`，依赖网络请求库`Alamofire`
```swift
import Foundation
import Alamofire
import SwiftyJSON

struct WeatherFetcher {
    static func fetch(response: [City]? -> ()) {
        Alamofire.request(.GET, OpenWeatherMap.url, parameters: OpenWeatherMap.parameters)
            .response { _, _, data, _ in
                let cities = data.map { decode($0) }
                                response(cities)
            }
    }

    private static func decode(data: NSData) -> [City] {
        let json = JSON(data: data)
        var cities = [City]()
        for (_, j) in json["list"] {
            if let id = j["id"].int {
                let city = City(
                    id: id,
                    name: j["name"].string ?? "",
                    weather: j["weather"][0]["main"].string ?? "")
                cities.append(city)
            }
        }
        return cities
    }
}
```

对Network抽出其依赖协议，剥离请求的实现


```swift
// Networking.swift
import Foundation

protocol Networking {
    func request(response: NSData? -> ())
}

struct Network : Networking {
    func request(response: NSData? -> ()) {
        Alamofire.request(.GET, OpenWeatherMap.url, parameters: OpenWeatherMap.parameters)
            .response { _, _, data, _ in
                response(data)
            }
    }
}
```

```swift
// WeatherFetcher.swift
struct WeatherFetcher {
    let networking: Networking

    func fetch(response: [City]? -> ()) {
        networking.request { data in
            let cities = data.map { self.decode($0) }
            response(cities)
        }
    }

    private func decode(data: NSData) -> [City] {
        let json = JSON(data: data)
        var cities = [City]()
        for (_, j) in json["list"] {
            if let id = j["id"].int {
                let city = City(
                    id: id,
                    name: j["name"].string ?? "",
                    weather: j["weather"][0]["main"].string ?? "")
                cities.append(city)
            }
        }
        return cities
    }
    }
```

然后修改WeatherFetcherSpec以测试解耦网络和JSON解析器。

WeatherFetcherSpec.swift

```swift
// WeatherFetcherSpec.swift
import Swinject
class WeatherFetcherSpec: QuickSpec {
    override func spec() {
        var container: Container!
        beforeEach {
            container = Container()

            // Registrations for the network using Alamofire.
            container.register(Networking.self) { _ in Network() }
            container.register(WeatherFetcher.self) { r in
                WeatherFetcher(networking: r.resolve(Networking.self)!)
            }

            // Registration for the stub network.
            container.register(Networking.self, name: "stub") { _ in
                StubNetwork()
            }
            container.register(WeatherFetcher.self, name: "stub") { r in
                WeatherFetcher(
                    networking: r.resolve(Networking.self, name: "stub")!)
            }
        }




```

## DI的小点

### 初始化注入

初始化程序注入是一种模式，用于通过其初始化程序将依赖项传递给依赖实例。如果依赖实例在没有依赖项的情况下无法工作，则初始化程序注入是合适的。

以下代码定义了初始化程序注入依赖于于`Animal`的`PetOwner`：


```swift
let container = Container()
container.register(Animal.self) { _ in Cat() }
container.register(Person.self) { r in
    PetOwner(pet: r.resolve(Animal.self)!)
}
Where the protocols and classes are

protocol Animal {
    func sound() -> String
}

class Cat: Animal {
    init() { }

    func sound() -> String {
        return "Meow"
    }
}

protocol Person { }

class PetOwner: Person {
    let pet: Animal

    init(pet: Animal) {
        self.pet = pet
    }
}
```


请注意，在创建PetOwner，初始化PetOwner实例时，Swinject会自动解析Animal的实际类型, 然后传递给PetOwner实例


### 属性注入

属性注入是一种通过setter属性将依赖项传递给依赖实例的模式。如果依赖项对依赖实例是可选的，则属性注入是合适的。

以下代码将属性注入定义为PetOwner2：


```swift
let container = Container()
container.register(Animal.self) { _ in Cat() }
container.register(Person.self) { r in
    let owner = PetOwner2()
    owner.pet = r.resolve(Animal.self)
    return owner
}
```

或者，您可以使用initCompleted回调而不是在注册闭包中定义注入：

```swift
let container = Container()
container.register(Animal.self) { _ in Cat() }
container.register(Person.self) { _ in PetOwner2() }
    .initCompleted { r, p in
        let owner = p as! PetOwner2
        owner.pet = r.resolve(Animal.self)
    }
```

### 方法注入

方法注入与属性注入类似，但它使用一种方法将依赖项传递给依赖实例。
以下代码将Method Injection定义为PetOwner3：

```swift
let container = Container()
container.register(Animal.self) { _ in Cat() }
container.register(Person.self) { r in
    let owner = PetOwner3()
    owner.setPet(r.resolve(Animal.self)!)
    return owner
}

class PetOwner3: Person {
    var pet: Animal?

    init() { }

    func setPet(pet: Animal) {
        self.pet = pet
    }
}
// Or, you can use initCompleted callback instead of defining the injection in the registration closure:

let container = Container()
container.register(Animal.self) { _ in Cat() }
container.register(Person.self) { _ in PetOwner3() }
    .initCompleted { r, p in
        let owner = p as! PetOwner3
                owner.setPet(r.resolve(Animal.self)!)
    }
```



### 在DI容器中命名注册

如果要为服务类型注册两个或更多组件，可以将注册命名为区分。


在DI容器中注册参数

```swift
// 传递给register方法的工厂闭包可以接受在解析服务时传递的参数。注册服务时，可以在参数后指定Resolver参数。

container.register(Animal.self) { _, name in
    Horse(name: name)
}
container.register(Animal.self) { _, name, running in
    Horse(name: name, running: running)
}

// 然后在调用resolve方法时传递运行时参数。如果只传递1个参数，请使用resolve(_:argument:)。

let animal1 = container.resolve(Animal.self, argument: "Spirit")!

print(animal1.name) // prints "Spirit"
print((animal1 as! Horse).running) // prints "false"

// If you pass 2 arguments or more, use resolve(_:arguments:,_:).

let animal2 = container.resolve(Animal.self, arguments: "Lucky", true)!

print(animal2.name) // prints "Lucky"
print((animal2 as! Horse).running) // prints "true"

// Where the Horse class is:
class Horse: Animal {
    let name: String
    let running: Bool

    convenience init(name: String) {
        self.init(name: name, running: false)
    }

    init(name: String, running: Bool) {
        self.name = name
        self.running = running
    }
}
```

### Registration Keys

对给定服务的组件注册存储在具有内部创建的密钥的容器中。在尝试解析服务依赖项时，容器使用密钥。
* 服务的类型
* 注册名称
* 参数的数量和类型

例如，以下注册可以在容器中共存，因为服务类型不同：
以下注册可以在容器中共存，因为注册名称不同：
以下注册可以在容器中共存，因为参数的数量不同。第一次注册没有参数，第二次注册有一个参数：
以下注册可以在容器中共存，因为参数的类型不同。第一次注册有String和Bool类型。所述第二注册具有Bool和String顺序类型：
```swift
container.register(Animal.self) { _, name, running in
    Horse(name: name, running: running)
}
container.register(Animal.self) { _, running, name in
    Horse(name: name, running: running)
}
```

注册时的参数类型是确定的，不是可选类型。
```swift
// Registers with name argument as String.
// The argument is inferred as String because Cat initializer takes an argument as String.
// The Registration Key is (Animal, (String) -> Animal)
container.register(Animal.self) { _, name in Cat(name: name) }

// This is the correct Registration Key (Animal, (String) -> Animal)
let name1: String = "Mimi"
let mimi1 = container.resolve(Animal.self, argument: name1) // Returns a Cat instance.

// Cannot resolve since the container has no Registration Key matching (Animal, (NSString) -> Animal)
let name2: NSString = "Mimi"
let mimi2 = container.resolve(Animal.self, argument: name2) // Returns nil.

// Cannot resolve since the container has no Registration Key matching (Animal, (Optional<String>) -> Animal)
let name3: String? = "Mimi"
let mimi3 = container.resolve(Animal.self, argument: name3) // Returns nil.

// Cannot resolve since the container has no Registration Key matching (Animal, (ImplicitlyUnwrappedOptional<String>) -> Animal)
let name4: String! = "Mimi"
let mimi4 = container.resolve(Animal.self, argument: name4) // Returns nil.
```


### 对象范围


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721115906.png)

对象范围是一种配置选项，用于确定如何在系统中共享DI容器提供的实例。它在Swinject中的`ObjectScope`枚举表示。

inObjectScope注册一对服务类型和组件工厂时，使用方法指定对象范围。例如

```swift
container.register(Animal.self) { _ in Cat() }
    .inObjectScope(.container)
```

#### Transient


#### 图表（默认scope）
每次手动调用 resolve，都会生成新的实例。
但是在其 factory 方法中生成的实例，是共享的，即如果已经生成过了，就不会重新生成了。
用于解决循环依赖

使用ObjectScope.graph时ObjectScope.transient，如果直接调用resolve容器的方法，则始终创建实例，但在根实例的解析期间共享在工厂闭包中解析的实例以构造对象图。

#### 容器Container

被这个 Container 及其子 Container 共享。可以理解为单例。

在ObjectScope.container，容器提供的实例在容器及其子容器内共享（请参阅容器层次结构）。换句话说，当您第一次解析类型时，它是由容器通过调用工厂闭包创建的。容器在该类型的任何后续解析中返回相同的实例。

此范围在其他DI框架中也称为Singleton。

#### 弱Weak

和 Container 类似，但是Container 并不持有它。如果没有其他引用，这个实例会被销毁，下次重新生成。

在ObjectScope.weak容器提供的实例中，只要存在其他强引用，就在容器及其子容器内共享。一旦对实例的所有强引用都不再存在，它将不再被共享，并且将在该类型的下一个分辨率期间创建新实例。

以上表示引用类型 - 在此对象范围中不共享值类型。

#### 自定义范围

```swift
extension ObjectScope {
    static let custom = ObjectScope(storageFactory: PermamentStorage.init)
}
```
.custom范围中的实例将以与范围相同的方式共享，.container但可以根据需要丢弃：

```swift
container.resetObjectScope(.custom)
```

重置范围后，容器将在第一次解析类型时创建新实例，并将在该类型的任何后续解决方案中共享此实例。

可以通过提供不同的storageFactory或编写ObjectScopeProtocol协议的自定义实现来另外修改自定义范围的行为。

## 模块化服务注册

`Assembly`是一个提供`Container`注册**服务定义**的协议，。Container将包含从每个注册到的所有服务定义 。我们来看一个例子：AssemblyAssembler


```swift
class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FooServiceProtocol.self) { r in
           return FooService()
        }
        container.register(BarServiceProtocol.self) { r in
           return BarService()
        }
    }
}

class ManagerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FooManagerProtocol.self) { r in
           return FooManager(service: r.resolve(FooServiceProtocol.self)!)
        }
        container.register(BarManagerProtocol.self) { r in
           return BarManager(service: r.resolve(BarServiceProtocol.self)!)
        }
    }
}
```


## 业务示例


```swift
// FeedAssembly.swift
import Foundation
import Business
import RxSwift
import RxCocoa
import Swinject

// 集成Feed组件
// 该文件负责控制Feed组件对外提供的服务
// 以及使用其它组件的外部接口和服务, 为Feed组件注入依赖
//
// 通过注入具体集成依赖, 才算一个功能完整的模块, 可以独立运行.
// 具体依赖仅属于APP层的胶水配置代码知道. 调用方不用关心

// NOTE: 适配模型类, 保持命名一致, 简化胶水代码
extension Document: FeedItem {}

class FeedAssembly: Assembly {
    // 负责集成绑定FeedViewController的输出事件
    typealias FeedViewControllerEventBinder = (FeedViewController) -> Void

    func assemble(container: Container) {
        // NOTE: 隔离实例化一创建. 每个实例化有且仅有一处地方管理创建, 并注入依赖

        // FeedAssembly作为一个完整Feed模块的集成提供方, 注册的服务对象就是其对外的接口, 应该尽量隐藏实现,
        // 让外部最小化依赖, 真的需要时再逐步放开或者添加新接口.
        // 这里外部只需要一个UIViewController, 不需要关心内部实现, 所以用UIViewController. 并提供name排重
        container.register(UIViewController.self, name: "Feed") { (r) in
            // 即使是内部固定的依赖, 使用容器也可以获得动态替换, 或者子环境替换的优势
            let vc = DemoFeedViewController(
                source: r.resolve(FeedDataSource.self)!
            )
            if let binder = r.resolve(FeedViewControllerEventBinder.self, name: "eventBinder") {
                binder(vc)
            }
            return vc
        }

        // 对内FeedAssembly需要选择使用哪些外部服务, 这些算FeedAssembly组装的内部依赖. 方便FeedAssembly替换组装实现.
        // 也使用容器是获取动态化功能, 让个别外部拥有者有机会替换实现. 比如Test Mock
        container.register(FeedDataSource.self) { (r) in
            return FeedAssembly.documentSource(manager: r.documentManager)
        }

        // 对应Feed发出的外部事件处理和绑定, 单独注册定义使其可以被动态替换. 也使依赖功能明确
        // 但实际使用中, eventBinder和dataSource都是负责FeedViewController的交互, 是需要搭配使用的.
        container.register(FeedViewControllerEventBinder.self, name: "eventBinder") { r in
            // 注册代码仅应该创建和传入依赖, 不应该有具体逻辑, 保持轻量化, 配置化.
            return FeedAssembly.eventBinder(manager: r.documentManager, navigation: r.navigation, trace: r.traceService)
        }
    }

    class DemoFeedViewController: FeedViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? true
        }
    }

    // 相应的胶水都应该单独提出来, 有需要时也可以放在其它地方单独管理, 这样提取后实际Assembly
    // register的地方仅有创建对象和配置注入相应的依赖, 无具体逻辑. 很轻量级, 可以自动生成
    static func documentSource(manager: BaseDocumentManager) -> FeedDataSource {
        return manager.documentsChanged
                      .startWith(ArrayChangeEvent(value: manager.documents, type: NSKeyValueChange.setting))
                      .map({ ArrayChangeEvent($0)! })
    }

    // Feed事件输出依赖. 粘合其它模块, 并明确输入依赖.
    static func eventBinder(manager: BaseDocumentManager, navigation: NavigationService, trace: TraceService) -> FeedViewControllerEventBinder {
        return { vc in
            // 使用细粒度的信号绑定, 绑定的粒度更细, 可直接绑定到实现类. 而不需要Delegate对象中转.
            // 且支持多个事件监听者.
            vc.itemCreated.map {_ in manager.create(title: "No Title").0}
                          .bind(onNext: navigation.showEditor(doc:))
                          .disposed(by: vc.disposeBag)

            vc.itemDeleted.bind { (item, _) in
                // NOTE: 胶水知道具体实现, 传回的数据是传入的, 所以强转.
                if let m = item as? Document {
                    manager.delete(document: m)
                } else {
                    // 分支完整性, 防止内部实现改出异常情况
                    assertionFailure("应该是胶水传入的模型")
                }
            }.disposed(by: vc.disposeBag)

            vc.itemClicked.map({$0.item as! Document})
                          .bind(onNext: navigation.showEditor(doc:))
                          .disposed(by: vc.disposeBag)

            // TODO: Demo现在不需要远程加载数据
            // f.feedReloaded
            FeedAssembly.bind(trace: trace, to: vc)
        }
    }

    // 统计事件集中管理, 不干扰正常业务逻辑
    static func bind(trace: TraceService, to: FeedViewController) {
        // trace有默认参数, rx不能直接绑定?
        let log = { (s: String) in
            trace.trace(s)
        }
        to.itemCreated.map {_ in "create new document"}
                      .bind(onNext: log)
                      .disposed(by: to.disposeBag)

        to.itemDeleted.map { "delete document \($0.item.title.value) at \($0.at)"}
                      .bind(onNext: log)
                      .disposed(by: to.disposeBag)
    }
}
```

## 注意

1. 循环依赖
_Circular dependencies_ are dependencies of instances that depend on each other. To define circular dependencies in Swinject, one of the dependencies must be injected through a property.

```swift
protocol ParentProtocol: AnyObject { }
protocol ChildProtocol: AnyObject { }

class Parent: ParentProtocol {
    let child: ChildProtocol?

    init(child: ChildProtocol?) {
        self.child = child
    }
}

class Child: ChildProtocol {
    weak var parent: ParentProtocol?
}
```
循环依赖关系定义如下：
```swift
let container = Container()
container.register(ParentProtocol.self) { r in
    Parent(child: r.resolve(ChildProtocol.self)!)
}
container.register(ChildProtocol.self) { _ in Child() }
    .initCompleted { r, c in
            let child = c as! Child
        child.parent = r.resolve(ParentProtocol.self)
    }
```
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721121916.png)

**这里必须在回调中对parent属性的注入指定为initCompleted，以避免父子依赖无限递归。**
1. Property Dependencies


```swift
protocol ParentProtocol: AnyObject { }
protocol ChildProtocol: AnyObject { }

class Parent: ParentProtocol {
    var child: ChildProtocol?
}

class Child: ChildProtocol {
    weak var parent: ParentProtocol?
}

let container = Container()
container.register(ParentProtocol.self) { r in
    let parent = Parent()
    parent.child = r.resolve(ChildProtocol.self)!
    return parent
}
container.register(ChildProtocol.self) { _ in Child() }
    .initCompleted { r, c in
        let child = c as! Child
        child.parent = r.resolve(ParentProtocol.self)
    }
```
3. Initializer Dependencies
不支持。这种依赖性会导致无限递归。

解析循环依赖关系时，可能会调用其中一个工厂方法（一个包含循环依赖关系的解析）。在最终的对象图中只会使用一个结果实例，但在某些情况下，这可能会有问题 - 特别是当出现工厂调用的副作用时，例如

耗时的操作
与已解析的依赖项的交互
您可以通过解析initCompleted闭包内的依赖循环的两个部分来避免重复调用，例如重构
```swift
container.register(ParentProtocol.self) { r in
    let parent = Parent()
    parent.child = r.resolve(ChildProtocol.self)!
    return parent
}
to

container.register(ParentProtocol.self) { _ in Parent() } 
    .initCompleted { r, p in
        let parent = p as! Parent
        parent.child = r.resolve(ChildProtocol.self)!
    }
```


2. 自我注册（自我约束）
[主人的Swinject / Misc.md·Swinject / Swinject](https://github.com/Swinject/Swinject/blob/master/Documentation/Misc.md)
在Swinject或其他DI框架中，服务类型不仅可以是协议，还可以是具体或抽象类。一种特殊情况是服务类型和组件类型相同。这种情况称为自我注册或自我约束。以下是使用Swinject进行自我绑定的示例：

```swift
let container = Container()
container.register(Animal.self) { _ in Cat(name: "Mimi") }
container.register(PetOwner.self) { r in
    PetOwner(name: "Selfie", pet: r.resolve(Animal.self)!)
}

// Then a PetOwner service is resolved as itself:

let owner = container.resolve(PetOwner.self)!
print(owner.name) // prints "Selfie"
print(owner.pet.name) // prints "Mimi"

// 协议和类:

protocol Animal {
    var name: String { get set }
}

class Cat: Animal {
    var name: String

    init(name: String) {
        self.name = name
    }
}

class PetOwner {
    let name: String
    let pet: Animal

    init(name: String, pet: Animal) {
        self.name = name
        self.pet = pet
    }
}
```

## 技巧

* [Swift中依赖注入的解耦策略 - 掘金](https://juejin.im/post/5cceaa3e6fb9a032143772fa)

## 缺点

觉得是有的，可以看到右侧，我们要构造一个车，需要传入一系列的依赖进入。如果模块变大的话，这注定是十分臃肿的。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190721114620.png)

## 参考

* [Swinject/SwinjectMVVMExample: An example to use Swinject in MVVM architecture with ReactiveCococa](https://github.com/Swinject/SwinjectMVVMExample)
* [使用ReactiveCocoa进行MVVM架构中的依赖注入第1部分：简介](https://yoichitgy.github.io/post/dependency-injection-in-mvvm-architecture-with-reactivecocoa-part-1-introduction/)
* [Dependency Injection in Practice · Race Condition](https://www.racecondition.software/blog/dependency-injection/)
* [Swift的依赖注入框架 - 使用Swinject第1部分的简单天气应用示例 快速注射](https://yoichitgy.github.io/post/dependency-injection-framework-for-swift-simple-weather-app-example-with-swinject-part-1/)
* [Swift的依赖注入框架 - 使用Swinject的简单天气应用程序示例第2部分| 快速注射](https://yoichitgy.github.io/post/dependency-injection-framework-for-swift-simple-weather-app-example-with-swinject-part-2/)