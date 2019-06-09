# 项目心得


## CI注入


L项目在组件化得过程中，将业务模块不断的进行解耦，后续使用了CI依赖注入，方便切换功能模块，使得耦合性进一步降低。


依赖注入依赖于称为控制反转的原则。**主要思想是需要一些依赖关系的代码片段不会为自己创建它们，而是提供这些依赖关系的控制被推迟到一些更高的抽象**。这些依赖项通常会**传递到对象的初始化程序中**。对于典型的对象创建级联，这是相反的方法 - 倒置方法：对象A创建对象B，创建对象C，等等。

从实际角度来看，**控制反转的主要好处是代码更改仍然是孤立的**。甲依赖注入容器支持控制反转通过提供一个知道一个对象主要如何为一个对象提供的依赖关系。您需要做的****就是向容器询问您需要的物体，然后瞧......它已经准备好了！


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190401131830.png)


[iOS 依赖注入工具 Swinject - 简书](https://www.jianshu.com/p/62f534b152c8)



### 对依赖进行解耦

**首先将宠物抽象为一个接口(协议), 这样做的价值在于能够将依赖解耦, 使用者的代码依赖于这个接口, 而非具体的实现, 因而在替换依赖时就很方便了.**

```swift

protocol AnimalType {
    var name: String { get }
    func sound() -> String
}
```

让 Cat 类实现这个协议:

```swift
class Cat: AnimalType {
    let name: String

    init(name: String) {
        self.name = name
    }

    func sound() -> String {
        return "Meow!"
    }
}
```


将 PetOwner 类修改为依赖于 AnimalType 接口, 而非 Cat 实现, 并且使用构造注入(构造注入的概念详见开篇给出的链接):

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

则使用的时候:
let catOwner = PetOwner(pet: Cat(name: "Mimi"))
print(catOwner.play()) // 输出 "I'm playing with Mimi. Meow!"

如果是要给宠物主人一条狗来溜溜:

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


则使用的时候:

```swift
let dogOwner = PetOwner(pet: Dog(name: "Hachi"))
print(dogOwner.play()) // 输出 "I'm playing with Hachi. Bow wow!"

```




### 控制反转原则

控制反转（Inversion of Control，缩写为IoC），是面向对象编程中的一种设计原则，可以用来减低计算机代码之间的耦合度。其中最常见的方式叫做依赖注入（Dependency Injection，简称DI），还有一种方式叫“依赖查找”（Dependency Lookup）。通过控制反转，对象在被创建的时候，由一个调控系统内所有对象的外界实体将其所依赖的对象的引用传递给它。也可以说，依赖被注入到对象中。




## 模块划分

### 模块：

一致而互相有紧密关连的软件组织。模块按功能划分，高内聚。
* 模块的构成：功能定义、功能实现。
* 功能定义用对外接口和对外暴露的实体来描述* 功能实现是对模块对外接口的具体实现
* 定义和实现可以分开，分别用一个gradlemodule实现
* 模块的生命周期：声明依赖、配置、运行、卸载
* 模块容器负责管理模块的实例，从模块容器拿到实现。

### 原则：

* 粒度合理：粒度要足够小，粒度太大造成职责太多，依赖关系复杂

* 依赖明确：明确声明自己的依赖

* 代码内聚：实现同一功能的代码放到一个模块

* 边界清晰：不该暴露的不暴露

### 模块间的通信


•模块间通信的方式：router、eventbus(全局事件)、接口调用。
•Router：各模块依赖Router模块，模块中定义路由，通过路由启动其他模块。
    •优点：做到一定程度的接口，模块不再依赖其他模块的Activity。
    •缺点：不能做到完全的解耦，有时模块仍然需要依赖其他模块的实体和类；依赖关系不够明确。
•Eventbus。
    •优点：一定程度的解耦。
    •缺点：事件往往难以放到模块内部，容易下沉到下层模块，违背按功能划分的原则；事件通信使模块间的依赖关系不明确。•接口调用：依赖清晰，可追溯，推荐使用。


## 依赖注入


* Swinject
    * assemble： Provide hook for Assembler to load Services into the provided container




### 类之间强耦合的情况


首先来看如果没有依赖注入的时候的情况, 一般编程时都会容易将两个类直接耦合在一起, 并且依赖的是实现, 而不是抽象. 而这也的做法在实践中是不可取的:


### 对依赖进行解耦

* [dependency-injection-framework-for-swift-introduction-to-swinject](https://yoichitgy.github.io/post/dependency-injection-framework-for-swift-introduction-to-swinject/)
* [iOS 依赖注入工具 Swinject](https://www.jianshu.com/p/62f534b152c8)

这里就相当于每次都在 container 中去手动获取想要的对象. 而对象的依赖是事先配置好的, 创建对象的时候就会进行依赖注入.

如果每个人都是猫人，那就太棒了，但实际上有些人是狗人。因为a的实例化Cat是硬编码的，所以PetOwner类依赖于Cat类。必须将依赖关系解耦为支持Dog或其他类。

使用依赖注入
现在是开始利用依赖注入的时候了。在这里，我们将介绍AnimalType协议以摆脱依赖。

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

## CI集成


* Jenkins - pipLine
    * pipLine script
        * 包上传
* fastLane - Lane 
    * Gym打包
    * Lane 执行脚本流



