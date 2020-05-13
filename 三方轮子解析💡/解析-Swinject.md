# 解析-Swinject


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200513113053.png)


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200513113225.png)

Swinject源码解析



笔者最近在开发中常常使用到Swinject这个框架。

什么是Dependency Injection
在软件工程中，依赖注入是种实现控制反转用于解决依赖性设计模式。一个依赖关系指的是可被利用的一种对象 。依赖注入是将所依赖的传递给将使用的从属对象。

以上是根据维基百科的解释，但是其实这么读有点抽象 笔者查阅了网上资料，发现知乎有个回答非常通俗

a依赖b，但a不控制b的创建和销毁，仅使用b，那么b的控制权交给a之外处理，这叫控制反转（IOC），而a要依赖b，必然要使用b的instance，那么可以通过 通过a的接口，把b传入； 通过a的构造，把b传入； 通过设置a的属性，把b传入； 这个过程叫依赖注入（DI）。


我们看一个实际的例子
​ 从你的角度来看，你觉得左侧和右侧那一个方式更好

一个更加实际的例子

图片来自知乎 可以看到相较于左侧，右侧依赖注入的方式可以明显解决传参一层层传递的问题。

那难道依赖注入就没有缺点么？ 笔者觉得是有的，可以看到右侧，我们要构造一个车，需要传入一系列的依赖进入。如果模块变大的话，这注定是十分臃肿的。

什么是Dependency Injection Container
The ability to automatically compose an object graph from maps between Abstractions and concrete types by making use of the types' metadata supplied by the compiler and the Common Language Runtime. — Dependency Injection in .NET, second edition 笔者在stackoverflow上查阅，有一个人引用了这本书的这样一句话。我觉得简单来说是可以通过传入一个抽象类型，可以构造出一个实例。我们简单的看一个使用代码  这里我们通过register方法，对一个类型进行注册。然后通过resolver方法，去调用构造方法得到这个实例。 我们这边先跳过Swinject这个框架，我们自己通过100行代码来手动实现一个container

```swift
class Container {
    var services = [ServiceKey: Any]()
​
    func _resolve<Service, Arguments>(
        invoker: @escaping ((Arguments) -> Service) -> Any
        ) -> Service? {
        var resolvedInstance: Service?
        let key = ServiceKey(serviceType: Service.self)
​
        if let entry = services[key]  {
            resolvedInstance = resolve(entry: entry, invoker: invoker)
        }
​
        return resolvedInstance
    }
    func resolve<Service, Factory>(
        entry: Any,
        invoker: (Factory) -> Any
        ) -> Service? {
        let resolvedInstance = invoker(entry as! Factory)
        return resolvedInstance as? Service
    }
    func _register<Service, Arguments>(
        _ serviceType: Service.Type,
        factory: @escaping (Arguments) -> Service)
    {
        let key = ServiceKey(serviceType: serviceType)
        services[key] = factory
    }
}
​
public protocol Register {
    func register<Service>(
        _ serviceType: Service.Type,
        factory: @escaping (Resolver) -> Service)
​
    func register<Service, Arg1>(
        _ serviceType: Service.Type,
        factory: @escaping (Resolver, Arg1) -> Service)
​
}
​
extension Container: Register {
    public func register<Service>(
        _ serviceType: Service.Type,
        factory: @escaping (Resolver) -> Service) {
        _register(serviceType, factory: factory)
    }
​
    public func register<Service, Arg1>(
        _ serviceType: Service.Type,
        factory: @escaping (Resolver, Arg1) -> Service)
    {
        _register(serviceType, factory: factory)
    }
​
}
public protocol Resolver {
    func resolve<Service>(_ serviceType: Service.Type) -> Service?
​
    func resolve<Service, Arg1>(
        _ serviceType: Service.Type,
        argument: Arg1) -> Service?
​
}
​
extension Container: Resolver {
    public func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return _resolve() { (factory: (Resolver) -> Any) in factory(self) }
    }
​
    public func resolve<Service, Arg1>(_ serviceType: Service.Type, argument: Arg1) -> Service? {
        typealias FactoryType = ((Resolver, Arg1)) -> Service
        return _resolve(){ (factory: FactoryType) -> Any in return factory((self, argument)) }
    }
}
internal struct ServiceKey: Hashable {
    internal let serviceType: Any.Type
​
    static func == (lhs: ServiceKey, rhs: ServiceKey) -> Bool {
        return lhs.serviceType == rhs.serviceType
    }
​
    var hashValue: Int {
        return ObjectIdentifier(serviceType).hashValue
    }
}
```

可以看到以上，这样一个最基础的Container就已经实现了，总的来说，是通过一个字典形式，key是协议的hash值，value是这个构造方法。每次通过协议注册一个构造方法，然后通过一个协议拿到这个构造方法。


Swinject原理其实很简单，核心代码精简以后不到20行：

```swift
protocol Resolver {
    func resolve<Service>() -> Service?
}

class Container: Resolver {
    private var serviceDic: [String: (Resolver) -> Any] = [:]

    init() {}

    func register<Service>(factory: @escaping (Resolver) -> Service) {
        let key = String(describing: Service.self)
        serviceDic[key] = factory
    }

    func resolve<Service>() -> Service? {
        let key = String(describing: Service.self)
        return serviceDic[key]?(self) as? Service
    }
}
```

使用方法：
```swift
let container = Container()
container.register() { _ in "1234" }
let value: String = container.resolve()! // value = "1234"
```

Swinject工作流程如下：
- Container内部持有一个serviceDic数组。
- register的时候根据向serviceDic中插入值，key为注册的Service，value为Service的构造block。
- resolve的时候根据Service生成的Key在serviceDic中查找构造block，执行。

除此之外Swinject做了什么
Thread Safety 线程安全

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200513142923.png)

Container Hierarchy 容器层次结构

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200513142906.png)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200513142835.png)

Object Scopes 对象范围

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200513142812.png)

Circular Dependency Injection 循环依赖注入


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200513142732.png)


## Tips

1. 函数 assemble(container: Container) { } 内部不允许直接调用函数resolver.revole（）, 
2.  revole（）函数应尽量在使用时lazy调用，避免提前调用，如特殊情况，需要在比较早的时间revolve对应的对象，也只能在 loaded(resolver: Resolver)内部调用resolve。
3.  ChatAssembly与MicroAppAssembly的不合理resolve代码需要从assemble(container: Container) { }内移出（优先选择lazy调用，其次选择为放到loaded(resolver: Resolver)内部）


## Ref

* [Swinject源码解析](https://nine.wiki/ios/yuan-ma-jie-xi/swinject-yuan-ma-jie-xi)