# 解析-SwiftUI笔记01



```swift
struct ContentView : View {
    var body: some View {
        Text("Hello World")
    }
}
```

**SwiftUI 的 View 是对于 UI 应该是如何展示的一个数据描述**，并非真正用于显示的 View。现在的 iOS，底层会用 UIKit 实现，最终从数据描述的 View 生成真正的 UIView。

SwiftUI 的 View 实现成协议，使用 associatedtype 关联了一个 Body 类型。根据 Swift 的语法，带有 associatedtype 的协议不能直接返回，只能作为类型约束。

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol View {

    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required `body` property.
    associatedtype Body : View

    /// The content and behavior of the view.
    @ViewBuilder var body: Self.Body { get }
}
```


### Attribute

编译 Swift 源代码时，在解析阶段（Prase）, 会生成一个抽象语法树（AST，Abstract Syntax Tree)。语法树生成时，所有的 Attribute 统一处理，生成 Attribute 节点。之后在语义分析阶段(semantic analysis)，会有可能触发 Attribute 节点，使其对语法树本身产生影响。

```swift
@dynamicCallable
@dynamicMemberLookup
@available
@objc
```



## Xcode Library

在编写真实项目中，一个公司的 APP UI 包含成百上千种风格的 View 组件，对于 UI 组件丰富的产品，如果一个新需求可以由现有的组件组合，那么需求交付的时间也会大大缩短。

在 Xcode 12 中提供了更强大的工具，一个自定义组件，只需要遵守一个 LiberyContentProvider 协议就可被Xcode识别，可以像系统控件一样直接从 Xcode 里面识别并预览。对于一个大型团队来说，此功能可以大大提高找寻组件和查看组件样式的效率。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200819183553.png)

## SwiftUI View & Modifier

在传统的命令式编程布局系统中，我们对一些 UI 系统结构是通常是通过继承实现的，再编写代码时通过对属性的调用来修改视图的外观，如颜色透明度等。 但这会带来导致类继承结构比较复杂，如果设计不够好会造成 OOP 的通病类爆炸，并且通过继承来的数据结构，子类会集成父类的存储属性，会导致子类实例在内存占据比较庞大，即便很多属性都是默认值并不使用。 如图：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200820092733.png)


在 SwiftUI 中奖视图的修饰期抽象为 Modifier， Modifier通常只含有 1-2 个存储属性，通过原始控件的 Extension 可以在视图定义中添加各种 Modifier，它们在运行时的实现通常是一个闭包，在运行时 SwiftUI 构建出真实的视图。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200820092748.png)

## Data Flow

在使用传统命令式编程编写 UI 代码时，开发者需要手动处理 UIView 和 数据之间的依赖关系，每当一个 UIView 使用了外部的数据源，就表明了 UIView 对外部的数据产生了依赖，当一个数据产生变化时，如果意外的没有同步UIView的状态，那么 Bug 就产生了。

处理简单的依赖关系是可控的，但是在真实项目中，视图之间的依赖关系是非常复杂的，假设一个视图只有 4 种状态，组合起来就有 16 种，再加上时序的不同，情况就更加复杂。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200819183846.png)
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200819183833.png)

SwiftUI 的框架提供了几个核心概念：

1. 统一的 body 属性，SwiftUI 自动从当前 App 状态集自动生成基于当前状态的快照 View。

2. 统一的数据流动原语。


## 与UIKit结合

[与UIKit结合-官方](https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit)


## 总结

* SwiftUI 的 view 是值,而非对象:它们是不可变的,用来暂时描述屏幕上应该显示什么。
* 我们在一个 view 上几乎所有的方法调用 (像是 frame 或 background) 都会将 view 包装在一个修饰器中。因此,这些调用的顺序很重要,这一点和 UIView 里的属性不同。
* 布局是自上而下的:父 view 向子 view 提供它们的可用空间,子 view 基于这个空间来决定自己的尺寸。
* 我们不能直接更新屏幕上的内容。相反,我们必须修改状态属性 (比如 @State 或@ObservedObject),然后让 SwiftUI 去找出 view 树的变化方式。

## TODO

1. 学习拓展库 [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX)