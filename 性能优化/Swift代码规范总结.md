# Swift代码规范总结

----

<h1><details>
<summary>Swift 编码规范</summary>
A guide to our Swift style and conventions.
</details></h1>

<details><summary>按大概的先后顺序，本文尝试做到以下几点：</summary>
This is an attempt to encourage patterns that accomplish the following goals (in
rough priority order):
</details>

1. <details><summary>增进精确，减少程序员犯错的可能</summary>Increased rigor, and decreased likelihood of programmer error</details>
1. <details><summary>明确意图</summary>Increased clarity of intent</details>
1. <details><summary>减少冗余</summary>Reduced verbosity</details>
1. <details><summary>减少关于美的争论</summary>Fewer debates about aesthetics</details>

<details>
<summary>如果你有什么建议，请看我们的 <a href="./CONTRIBUTING.md">贡献导引</a>，然后开个 <code>pull request</code>. :zap:
</summary>

If you have suggestions, please see our [contribution guidelines](CONTRIBUTING.md),
then open a pull request. :zap:
</details>

----

<h3><details><summary>留空白</summary>Whitespace</details></h3>

<ul>
<li><details><summary>用 tab，而非 空格</summary>Tabs, not spaces.</details></li>
<li><details><summary>文件结束时留一空行</summary>End files with a newline.</details></li>
<li><details><summary>用足够的空行把代码分割成合理的块</summary>Make liberal use of vertical whitespace to divide code into logical chunks.</details></li>
<li><details><summary>不要在一行结尾留下空白</summary>Don’t leave trailing whitespace.</details>
	<ul><li><details><summary>千万别在空行留下缩进</summary>Not even leading indentation on blank lines.</details></li></ul>
</li>
</ul>

<h3><details>
<summary>能用 <code>let</code> 尽量用 <code>let</code> 而不是 <code>var</code></summary>

Prefer `let`-bindings over `var`-bindings wherever possible
</details></h3>

<details>
<summary>
尽可能的用 <code>let foo = ...</code> 而不是 <code>var foo = ...</code> （并且包括你疑惑的时候）。万不得已的时候，再用 <code>var</code> （就是说：你 <i>知道</i> 这个值会改变，比如：有 <code>weak</code> 修饰的存储变量）。
</summary>

Use `let foo = …` over `var foo = …` wherever possible (and when in doubt). Only use `var` if you absolutely have to (i.e. you *know* that the value might change, e.g. when using the `weak` storage modifier).
</details>

<details>
<summary>
<i>理由：</i> 这俩关键字 无论意图还是意义 都很清楚了，但是 <code>let</code> 可以产生安全清晰的代码。
</summary>

_Rationale:_ The intent and meaning of both keywords are clear, but *let-by-default* results in safer and clearer code.
</details>

<br />

<details>
<summary>
<code>let</code> 保障它的值的永远不会变，对程序猿也是个 <i>清晰的标记</i>。因此对于它的用法，之后的代码可以做个强而有力的推断。</summary>

A `let`-binding guarantees and *clearly signals to the programmer* that its value will never change. Subsequent code can thus make stronger assumptions about its usage.
</details>

<details>
<summary>
理解代码也更容易了。不然一旦你用了 <code>var</code>，还要去推测值会不会变，这时候你就不得不人肉去检查。
</summary>

It becomes easier to reason about code. Had you used `var` while still making the assumption that the value never changed, you would have to manually check that.
</details>

<details>
<summary>
相应地，无论何时你看到 <code>var</code>，就假设它会变，并问自己为啥。
</summary>

Accordingly, whenever you see a `var` identifier being used, assume that it will change and ask yourself why.
</details>

<h3><details><summary>
尽早地 <code>return</code> 或者 <code>break</code></summary>

Return and break early</details></h3>

<details>
<summary>当你遇到某些操作需要通过条件判断去执行，应当尽早地退出判断条件：你不应该用下面这种写法</summary>

When you have to meet certain criteria to continue execution, try to exit early. So, instead of this:
</details>

```swift
if n.isNumber {
	// Use n here
} else {
	return
}
```

<details><summary>用这个：</summary>use this:</details>

```swift
guard n.isNumber else {
	return
}
// Use n here
```

<details>
<summary>或者你也可以用 <code>if</code> 声明，但是我们推荐你使用 <code>guard</code></summary>

You can also do it with `if` statement, but using `guard` is prefered
</details>

<details>
<summary><i>理由：</i> 你一但声明 <code>guard</code> 编译器会强制要求你和 <code>return</code>, <code>break</code> 或者 <code>continue</code> 一起搭配使用，否则会产生一个编译时的错误。</summary>

because `guard` statement without `return`, `break` or `continue` produces a compile-time error, so exit is guaranteed.
</details>

<h3><details><summary>避免对 可选类型 强解包</summary>Avoid Using Force-Unwrapping of Optionals</details></h3>

<details><summary>如果你有个 <code>FooType?</code> 或 <code>FooType!</code> 的 <code>foo</code>，尽量不要强行展开它（<code>foo!</code>）以得到它的关联值。</summary>

If you have an identifier `foo` of type `FooType?` or `FooType!`, don't force-unwrap it to get to the underlying value (`foo!`) if possible.
</details>

<details><summary>取而代之的，推荐这样：</summary>Instead, prefer this:</details>

```swift
if let foo = foo {
	// Use unwrapped `foo` value in here
} else {
	// If appropriate, handle the case where the optional is nil
}
```

<details><summary>或者使用可选链，比如：</summary>

Alternatively, you might want to use Swift's Optional Chaining in some of these cases, such as:
</details>

```swift
// Call the function if `foo` is not nil. If `foo` is nil, ignore we ever tried to make the call
foo?.callSomethingIfFooIsNotNil()
```

<details><summary><i>理由：</i> <code>if let</code> 绑定可选类型产生了更安全的代码，强行展开很可能导致运行时崩溃。</summary>

_Rationale:_ Explicit `if let`-binding of optionals results in safer code. Force unwrapping is more prone to lead to runtime crashes.
</details>

<h3><details><summary>避免隐式解析的可选类型</summary>Avoid Using Implicitly Unwrapped Optionals</details></h3>

<details><summary>如果 foo 可能为 <code>nil</code> ，尽可能的用 <code>let foo: FooType?</code> 代替 <code>let foo: FooType!</code>（注意：一般情况下，<code>?</code> 可以代替 <code>!</code>）</summary>

Where possible, use `let foo: FooType?` instead of `let foo: FooType!` if `foo` may be nil (Note that in general, `?` can be used instead of `!`).
</details>

<details><summary><i>理由：</i> 明确的可选类型产生了更安全的代码。隐式解析的可选类型也可能会挂。</summary>

_Rationale:_ Explicit optionals result in safer code. Implicitly unwrapped optionals have the potential of crashing at runtime.
</details>

<h3><details><summary>对于只读属性和 <code>subscript</code>，选用隐式的 getters 方法</summary>

Prefer implicit getters on read-only properties and subscripts
</details></h3>

<details><summary>如果可以，省略只读属性和 <code>subscript</code> 的 <code>get</code> 关键字</summary>

When possible, omit the `get` keyword on read-only computed properties and
read-only subscripts.</details>

<details><summary>所以应该这样写：</summary>So, write these:</details>

```swift
var myGreatProperty: Int {
	return 4
}

subscript(index: Int) -> T {
	return objects[index]
}
```

<details><summary>……而不是：</summary>… not these:</details>

```swift
var myGreatProperty: Int {
	get {
		return 4
	}
}

subscript(index: Int) -> T {
	get {
		return objects[index]
	}
}
```

<details><summary><i>理由：</i> 第一个版本的代码意图已经很清楚了，并且用了更少的代码</summary>

_Rationale:_ The intent and meaning of the first version are clear, and results in less code.
</details>

<h3><details><summary>对于顶级定义，永远明确的列出权限控制</summary>Always specify access control explicitly for top-level definitions</details></h3>

<details><summary>顶级函数，类型和变量，永远应该有着详尽的权限控制说明符</summary>

Top-level functions, types, and variables should always have explicit access control specifiers:
</details>

```swift
public var whoopsGlobalState: Int
internal struct TheFez {}
private func doTheThings(things: [Thing]) {}
```

<details><summary>然而在这些函数/类型的内部，可以在合适的地方使用隐式权限控制：</summary>However, definitions within those can leave access control implicit, where appropriate:
</details>

```swift
internal struct TheFez {
	var owner: Person = Joshaber()
}
```

<details><summary><i>理由：</i> 顶级定义指定为 <code>internal</code> 很少有恰当的，要明确的确保经过了仔细的判断。在定义的内部重用同样的权限控制说明符就显得重复，而且默认的通常是合理的。</summary>

_Rationale:_ It's rarely appropriate for top-level definitions to be specifically `internal`, and being explicit ensures that careful thought goes into that decision. Within a definition, reusing the same access control specifier is just duplicative, and the default is usually reasonable.
</details>

<h3><details><summary>当指定一个类型时，把 冒号和标识符 连在一起</summary>

When specifying a type, always associate the colon with the identifier
</details></h3>

<details><summary>当指定标示符的类型时，冒号要紧跟着标示符，然后空一格再写类型</summary>

When specifying the type of an identifier, always put the colon immediately
after the identifier, followed by a space and then the type name.
</details>

```swift
class SmallBatchSustainableFairtrade: Coffee { ... }

let timeToCoffee: NSTimeInterval = 2

func makeCoffee(type: CoffeeType) -> Coffee { ... }
```

<details><summary><i>理由：</i> 类型区分号是对于标示符来说的，所以要跟它连在一起。</summary>

_Rationale:_ The type specifier is saying something about the _identifier_ so
it should be positioned with it.
</details>

<br />

<details><summary>此外，指定字典类型时，键类型后紧跟着冒号，接着加一个空格，之后才是值类型。</summary>

Also, when specifying the type of a dictionary, always put the colon immediately after the key type, followed by a space and then the value type.
</details>

```swift
let capitals: [Country: City] = [sweden: stockholm]
```

<h3><details><summary>需要时才写上 <code>self</code></summary>

Only explicitly refer to `self` when required
</details></h3>

<details><summary>当调用 <code>self</code> 的属性或方法时，默认隐式引用<code>self</code>：</summary>

When accessing properties or methods on `self`, leave the reference to `self` implicit by default:
</details>

```swift
private class History {
	var events: [Event]

	func rewrite() {
		events = []
	}
}
```

<details><summary>必要的时候再加上 <code>self</code>, 比如在（逃逸）闭包里，或者 参数名冲突了：</summary>

Only include the explicit keyword when required by the language—for example, in a closure, or when parameter names conflict:
</details>

```swift
extension History {
	init(events: [Event]) {
		self.events = events
	}

	var whenVictorious: () -> () {
		return {
			self.rewrite()
		}
	}
}
```

<details><summary><i>原因:</i> 在闭包里用 <code>self</code> 更加凸显它捕获 <code>self</code> 的语义，别处避免了冗长</summary>

_Rationale:_ This makes the capturing semantics of `self` stand out more in closures, and avoids verbosity elsewhere.
</details>

<h3><details><summary>首选 <code>struct</code> 而非 <code>class</code></summary>

Prefer structs over classes
</details></h3>

<details><summary>除非你需要 <code>class</code> 才能提供的功能（比如 identity 或 <code>deinit</code>ializers），不然就用 <code>struct</code></summary>

Unless you require functionality that can only be provided by a class (like identity or deinitializers), implement a struct instead.
</details>

<details><summary>要注意到继承通常 <strong>不</strong> 是用 类 的好理由，因为 多态 可以通过 协议 实现，重用 可以通过 组合 实现。</summary>

Note that inheritance is (by itself) usually _not_ a good reason to use classes, because polymorphism can be provided by protocols, and implementation reuse can be provided through composition.
</details>

<details><summary>比如，这个类的分级</summary>

For example, this class hierarchy:
</details>

```swift
class Vehicle {
	let numberOfWheels: Int

	init(numberOfWheels: Int) {
		self.numberOfWheels = numberOfWheels
	}

	func maximumTotalTirePressure(pressurePerWheel: Float) -> Float {
		return pressurePerWheel * Float(numberOfWheels)
	}
}

class Bicycle: Vehicle {
	init() {
		super.init(numberOfWheels: 2)
	}
}

class Car: Vehicle {
	init() {
		super.init(numberOfWheels: 4)
	}
}
```

<details><summary>可以重构成酱紫：</summary>

could be refactored into these definitions:
</details>

```swift
protocol Vehicle {
	var numberOfWheels: Int { get }
}

func maximumTotalTirePressure(vehicle: Vehicle, pressurePerWheel: Float) -> Float {
	return pressurePerWheel * Float(vehicle.numberOfWheels)
}

struct Bicycle: Vehicle {
	let numberOfWheels = 2
}

struct Car: Vehicle {
	let numberOfWheels = 4
}
```

<details><summary><i>理由：</i> 值类型更简单，容易分析，并且 <code>let</code> 关键字的行为符合预期。</summary>

_Rationale:_ Value types are simpler, easier to reason about, and behave as expected with the `let` keyword.
</details>

<h3><details><summary>默认 <code>class</code> 为 <code>final</code></summary>

Make classes `final` by default
</details></h3>

<details><summary><code>class</code> 应该用 <code>final</code> 修饰，并且只有在继承的有效需求已被确定时候才能去使用子类。即便在这种情况（前面提到的使用继承的情况）下，根据同样的规则（<code>class</code> 应该用 <code>final</code> 修饰的规则），类中的定义（属性和方法等）也要尽可能的用 <code>final</code> 来修饰
</summary>

Classes should start as `final`, and only be changed to allow subclassing if a valid need for inheritance has been identified. Even in that case, as many definitions as possible _within_ the class should be `final` as well, following the same rules.
</details>

<details><summary><i>理由：</i> 组合通常比继承更合适，选择使用继承则很可能意味着在做出决定时需要更多的思考。</summary>

_Rationale:_ Composition is usually preferable to inheritance, and opting _in_ to inheritance hopefully means that more thought will be put into the decision.
</details>

<h3><details><summary>能不写类型参数的就别写了</summary>

Omit type parameters where possible
</details></h3>

<details><summary>当对接收者来说一样时，参数化类型的方法可以省略接收者的类型参数。比如：</summary>

Methods of parameterized types can omit type parameters on the receiving type when they’re identical to the receiver’s. For example:
</details>

```swift
struct Composite<T> {
	…
	func compose(other: Composite<T>) -> Composite<T> {
		return Composite<T>(self, other)
	}
}
```

<details><summary>可以改成这样：</summary>could be rendered as:</details>

```swift
struct Composite<T> {
	…
	func compose(other: Composite) -> Composite {
		return Composite(self, other)
	}
}
```

<details><summary><i>理由：</i> 省略多余的类型参数让意图更清晰，并且通过对比，让返回值为不同的类型参数的情况也清楚了很多。</summary>

_Rationale:_ Omitting redundant type parameters clarifies the intent, and makes it obvious by contrast when the returned type takes different type parameters.
</details>

<h3><details><summary>定义操作符 两边留空格</summary>

Use whitespace around operator definitions
</details></h3>

<details><summary>当定义操作符时，两边留空格。不要酱紫：</summary>

Use whitespace around operators when defining them. Instead of:
</details>

```swift
func <|(lhs: Int, rhs: Int) -> Int
func <|<<A>(lhs: A, rhs: A) -> A
```

<details><summary>应该写：</summary>write:</details>

```swift
func <| (lhs: Int, rhs: Int) -> Int
func <|< <A>(lhs: A, rhs: A) -> A
```

<details><summary><i>理由：</i> 操作符 由标点字符组成，当立即连着类型或者参数值，会让代码非常难读。加上空格分开他们就清晰了</summary>

_Rationale:_ Operators consist of punctuation characters, which can make them difficult to read when immediately followed by the punctuation for a type or value parameter list. Adding whitespace separates the two more clearly.
</details>

### 其他语言

* [English Version](https://github.com/github/swift-style-guide)
* [日本語版](https://github.com/jarinosuke/swift-style-guide/blob/master/README_JP.md)
* [한국어판](https://github.com/minsOne/swift-style-guide/blob/master/README_KR.md)
* [Versión en Español](https://github.com/antoniosejas/swift-style-guide/blob/spanish/README-ES.md)
* [Versão em Português do Brasil](https://github.com/fernandocastor/swift-style-guide/blob/master/README-PTBR.md)
* [فارسی](https://github.com/mohpor/swift-style-guide/blob/Persian/README-FA.md)


# SwiftLint代码规范属性说明(一)

> 上一篇[Xcode代码规范之SwiftLint配置](https://www.jianshu.com/p/328091791033)介绍了SwiftLint的安装和使用

> 下面来具体介绍一下SwiftLint的具体的代码规则的相关说明
> 
> *   [Github 公布的 Swift 代码规范--原文](https://link.jianshu.com/?t=https%3A%2F%2Fgithub.com%2Fgithub%2Fswift-style-guide)
> *   [Github 公布的 Swift 代码规范--中文](https://link.jianshu.com/?t=https%3A%2F%2Fgithub.com%2FArtwalk%2Fswift-style-guide%2Fblob%2Fmaster%2FREADME_CN.md)
> *   [官方的SwiftLint规则说明](https://link.jianshu.com/?t=https%3A%2F%2Fgithub.com%2Frealm%2FSwiftLint%2Fblob%2Fmaster%2FRules.md)

## 以下个属性均按照字母顺序排列

### 规则1: closing_brace

在使用Swift 3.2或更高版本时，首选系统的KVO 的API和keypath

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| block_based_kvo | 启用 | no | idiomatic |

官方示例:

```
//编译通过
let observer = foo.observe(\.value, options: [.new]) { (foo, change) in
   print(change.newValue)
}

//会触发警告
class Foo: NSObject {
   override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {}
}

```

### 规则2: class_delegate_protocol

委托协议应该只是class类，可以被弱引用(官方解释,先放出官方示例吧)

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| class_delegate_protocol | 启用 | no | lint |

示例:

```
//不会触发warning
protocol FooDelegate: class {}
protocol FooDelegate: class, BarDelegate {}
protocol Foo {}
class FooDelegate {}
@objc protocol FooDelegate {}
@objc(MyFooDelegate)
protocol FooDelegate {}
protocol FooDelegate: BarDelegate {}
protocol FooDelegate: AnyObject {}
protocol FooDelegate: NSObjectProtocol {}

//会触发warning
protocol FooDelegate {}
protocol FooDelegate: Bar {}

```

### 规则3: closing_brace

类似小括号包含大括号的不能用空格

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| closing_brace | 启用 | yes | style |

具体示例:

```
//不会触发warning
[1, 2].map({ $0 })

[1, 2].map(
  { $0 }
)

//会触发warning
[1, 2].map({ $0 } )
[1, 2].map({ $0 }   )
[1, 2].map( { $0 })

```

### 规则4: closure_end_indentation

闭包的封闭端和开始端有相同的缩进, 意思就是 大括号（一般是方法）上下对齐的问题，这样使code看起来更加整洁

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| closure_end_indentation | 未启用 | no | style |

具体示例:

```
//不会触发closure_end_indentation
[1, 2].map { $0 + 1 }
//不会触发closure_end_indentation
SignalProducer(values: [1, 2, 3])
   .startWithNext { number in
       print(number)
   }
//不会触发closure_end_indentation
function {
    ..........
}

//会触发closure_end_indentation
SignalProducer(values: [1, 2, 3])
   .startWithNext { number in
       print(number)
}
//不会触发closure_end_indentation
function {
    ..........
  }

```

### 规则5: closure_parameter_position

闭包参数位置， 闭包参数应该和大括号左边在同一行, 推荐使用

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| closure_parameter_position | 启用 | no | style |

具体示例:

```
/// number 和 { 在同一行, 不会触发warning
let names = [1, 2, 3]
names.forEach { (number) in
    print(number)
}

let names = [1, 2, 3]
names.map { number in
    number + 1
}

/// 这样不行，违背 closure_parameter_position规则, 触发warning
let names = [1, 2, 3]
names.forEach { 
    (number) in
    print(number)
}

 let names = [1, 2, 3]
 names.map {
     number in
     number + 1
 }

```

### 规则6: closure_spacing

在闭包的{}中间要有一个空格,如map({ $0 })

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| closure_spacing | 未启用 | yes | style |

以下示例:

```
不会触发警告
map({ $0 })
[].map ({ $0.description })

//会触发警告
map({$0 })
map({ $0})
map({$0})
[].map ({$0.description     })

```

### 规则7: colon

冒号的使用， swiftlint的这个colon属性规则很简单，要求“ ：”紧靠所定义的常量或变量等，必须没有空格，与所指定的类型之间必须只有一个空格，多一个或少一个都不行，如果是用在Dictionary中，则要求紧靠Key，与Value之间必须有且仅有一个空格。这个规则我觉得应该强制推荐使用

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| colon | 启用 | yes | style |

具体示例:

```
//不会触发警告
let abc: String = "jun"
let abc = [1: [3: 2], 3: 4]
let abc = [1: [3: 2], 3: 4]

//会触发警告
let jun:Void
let jun : Void
let jun :Void
let jun:   Void

```

### 规则8: comma

逗号使用只要遵循“前不离身后退一步”就行了，这个也强制推荐使用

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| comma | 启用 | yes | style |

具体示例:

```
//不触发警告
[a, b, c, d]

//触发警告
[a ,b]

```

### 规则9: compiler_protocol_init

编译器协议初始化, 不建议.init等初始化方式, 建议使用简单的初始化形式

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| compiler_protocol_init | 启用 | no | lint |

官方示例:

```
    public static let description = RuleDescription(
        identifier: "compiler_protocol_init",
        name: "Compiler Protocol Init",
        description: "The initializers declared in compiler protocols such as `ExpressibleByArrayLiteral` " +
                     "shouldn't be called directly.",
        kind: .lint,
        nonTriggeringExamples: [
            "let set: Set<Int> = [1, 2]\n",
            "let set = Set(array)\n"
        ],
        triggeringExamples: [
            "let set = ↓Set(arrayLiteral: 1, 2)\n",
            "let set = ↓Set.init(arrayLiteral: 1, 2)\n"
        ]
    )

```

### 规则10: conditional_returns_on_newline

条件语句不能写在同一行, 条件返回语句应该在新的一行。 当有条件返回的时候应该换行返回，而不是在同一行

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| conditional_returns_on_newline | 未启用 | no | style |

具体示例:

```
/// swiftlint 不推荐的写法, 否则会触发warning
if true { return }
guard true else { return }

/// swiftlint 推荐的写法
if true {
    return
}

guard true else {
    return 
}

```

### 规则11: contains_over_first_not_nil

类似first函数不能判断是否为nil

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| contains_over_first_not_nil | 未启用 | no | performance |

具体示例:

```
//推荐写法
let first = myList.first(where: { $0 % 2 == 0 })
let first = myList.first { $0 % 2 == 0 }

//不推荐写法
myList.first { $0 % 2 == 0 } != nil
myList.first(where: { $0 % 2 == 0 }) != nil

```

### 规则12: control_statement

控制语句, for，while，do，catch语句中的条件不能包含在()中

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| control_statement | 启用 | no | style |

具体示例:

```
//建议写法
if condition {
if (a, b) == (0, 1) {

//不建议写法
if (condition) {
if(condition) {
if ((a || b) && (c || d)) {

```

### 规则13: custom_rules

自定义规则。 这个属性可以通过提供正则表达式来创建自定义规则， 可选指定语法类型搭配， 安全、级别和要陈列的什么信息。 这个属性只要熟悉使用正则表达式的人使用，目前可以不适用

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| custom_rules | 启用 | no | style |

### 规则14: cyclomatic_complexity

循环复杂度。函数体的复杂度应该要限制，这个属性主要约束条件句、循环句中的循环嵌套问题， 当嵌套太多的循环时，则会触发swiftlint中的warning和error，当达到10个循环嵌套时就会报warning，达到20个循环嵌套时就会报error

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| cyclomatic_complexity | 启用 | no | metrics |

### 规则15: discarded_notification_center_observer

当使用注册的通知时, 应该存储返回的观察者, 便于用完之后移除通知

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| discarded_notification_center_observer | 启用 | no | lint |

代码示例:

```
//推荐写法
let foo = nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil) { }

let foo = nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil, using: { })

func foo() -> Any {
   return nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil, using: { })
}

//不推荐写法
nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil) { }

nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil, using: { })

@discardableResult func foo() -> Any {
   return nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil, using: { })
}

```

### 规则16: discouraged_direct_init

阻止直接初始化导致的错误类型, 有类方法的,用类方法初始化(不建议直接init初始化)

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| discouraged_direct_init | 启用 | no | lint |

代码示例:

```
//建议写法
let foo = UIDevice.current
let foo = Bundle.main
let foo = Bundle(path: "bar")
let foo = Bundle(identifier: "bar")

//不建议写法
let foo = UIDevice()
let foo = Bundle()
let foo = bar(bundle: Bundle(), device: UIDevice())

```

### 规则17: discouraged_optional_boolean

不建议使用可选布尔值

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| discouraged_optional_boolean | 未启用 | no | idiomatic |

代码示例:

```
//建议写法
var foo: Bool
var foo: [String: Bool]
var foo: [Bool]
let foo: Bool = true

//不建议写法
var foo: Bool?
var foo: [String: Bool?]
var foo: [Bool?]
let foo: Bool? = nil

```

### 规则18: discouraged_object_literal

优先使用对象初始化方法, 不建议使用代码块初始化

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| discouraged_object_literal | 未启用 | no | idiomatic |

代码示例:

```
//不建议写法
let white = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
let image = ↓#imageLiteral(resourceName: "image.jpg")

```

### 规则19: dynamic_inline

避免一起使用 dynamic 和 @inline(_ _always)， 否则报 error

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| dynamic_inline | 启用 | no | lint |

代码示例:

```
/// 正确的做法
class LangKe {
    dynamic func myFunction() {

    }
}

class LangKe {
    @inline(__always) func myFunction() {

    }
}

class LangKe {
    @inline(never) dynamic func myFunction() {

    }
}

/// 只要同时使用 dynamic 和 @inline(_ _always)都报错 error！！！
class LangKe {
    @inline(__always) public dynamic func myFunction() {

    }
}

```

### 规则20: array_init

序列转化成数组时, 优先使用数组转化, 而不是seq.map {$ 0}将序列转换为数组

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| array_init | 未启用 | no | lint |

官方示例:

```
    public static let description = RuleDescription(
        identifier: "array_init",
        name: "Array Init",
        description: "Prefer using Array(seq) than seq.map { $0 } to convert a sequence into an Array.",
        kind: .lint,

        //以下示例不会触发警告
        nonTriggeringExamples: [
            "Array(foo)\n",
            "foo.map { $0.0 }\n",
            "foo.map { $1 }\n",
            "foo.map { $0() }\n",
            "foo.map { ((), $0) }\n",
            "foo.map { $0! }\n",
            "foo.map { $0! /* force unwrap */ }\n",
            "foo.something { RouteMapper.map($0) }\n"
        ],

        //以下示例会触发警告
        triggeringExamples: [
            "↓foo.map({ $0 })\n",
            "↓foo.map { $0 }\n",
            "↓foo.map { return $0 }\n",
            "↓foo.map { elem in\n" +
            "   elem\n" +
            "}\n",
            "↓foo.map { elem in\n" +
            "   return elem\n" +
            "}\n",
            "↓foo.map { (elem: String) in\n" +
                "   elem\n" +
            "}\n",
            "↓foo.map { elem -> String in\n" +
            "   elem\n" +
            "}\n",
            "↓foo.map { $0 /* a comment */ }\n"
        ]
    )

```

### 规则21: empty_count

建议使用isEmpty判断,而不是使用count==0判断

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| empty_count | 未启用 | no | performance |

代码示例:

```
/// swiftlint不建议这样使用
let number = "long"
if number.characters.count == 0 {
    print("为空")
} else {
    print("不为空")
}

/// swiftlint建议这种正式风格
if number.isEmpty {
    print("为空")
} else {
    print("不为空")
}

```

### 规则22: empty_enum_arguments

当枚举与关联类型匹配时，如果不使用它们，参数可以省略

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| empty_enum_arguments | 启用 | yes | style |

代码示例:

```
//SwiftLint建议写法
switch foo {
    case .bar: break
}
switch foo {
    case .bar(let x): break
}
switch foo {
    case let .bar(x): break
}
switch (foo, bar) {
    case (_, _): break
}
switch foo {
    case "bar".uppercased(): break
}

//SwiftLint不建议写法
switch foo {
    case .bar(_): break
}
switch foo {
    case .bar(): break
}
switch foo {
    case .bar(_), .bar2(_): break
}

```

### 规则23: empty_parameters

闭包参数为空时,建议使用() ->Void, 而不是Void ->Void

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| empty_parameters | 启用 | yes | style |

代码示例:

```
/// 01 不会触发warning
let abc: () -> Void

func foo(completion: () -> Void) {

}

/// 02 直接报错
let bcd: Void -> Void

func foo(completion: Void -> Void) {

}

```

### 规则24: empty_parentheses_with_trailing_closure

在使用尾随闭包的时候， 应该尽量避免使用空的圆括号

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| empty_parentheses_with_trailing_closure | 启用 | yes | style |

代码示例:

### 规则25: aaa

...

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| aaa | 未启用 | no | style |

代码示例:

```
//不会触发warning
[1, 2].map { $0 + 1 }
[1, 2].map({ $0 + 1 })
[1, 2].reduce(0) { $0 + $1 }
[1, 2].map { number in
   number + 1 
}

//会触发warning
[1, 2].map() { $0 + 1 }
[1, 2].map( ) { $0 + 1 }
[1, 2].map() { number in
   number + 1 
}
[1, 2].map(  ) { number in
   number + 1 
}

```

### 规则26: explicit_acl

...所有属性和方法的声明, 都应该明确指定修饰关键字

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| explicit_acl | 未启用 | no | idiomatic |

官方代码示例:

```
//非触发示例
internal enum A {}
public final class B {}
private struct C {}
internal func a() { let a =  }
private struct C { let d = 5 }
internal class A { deinit {} }
internal protocol A {
    func b()
    var c: Int
}

//触发示例
enum A {}
final class B {}
internal struct C { let d = 5 }
public struct C { let d = 5 }
func a() {}
internal let a = 0
func b() {}

```

### 规则27: explicit_type_interface

声明的属性应该明确其类型, 如: var myVar: Int = 0

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| explicit_type_interface | 未启用 | no | idomatic |

代码示例:

```
//推荐写法
class Foo {
  var myVar: Int? = 0
  let myLet: Int? = 0
}

//不建议写法
class Foo {
  var myVar = 0
  let myLet = 0
}

```

### 规则28: extension_access_modifier

在自定义类中,推荐使用extension扩展

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| extension_access_modifier | 未启用 | no | idiomatic |

代码示例:

### 规则29: no_extension_access_modifier

在extension扩展前面,不建议使用(fileprivate, public)等修饰符

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| no_extension_access_modifier | 未启用 | no | idiomatic |

代码示例:

```
//不建议以下写法
private extension String {}
public extension String {}
open extension String {}
internal extension String {}
fileprivate extension String {}

```

### 规则30: fallthrough

switch语句中不建议使用fallthrough

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| fallthrough | 启用 | no | idiomatic |

代码示例:

```
//推荐写法
switch foo {
case .bar, .bar2, .bar3:
    something()
}

//不建议写法
switch foo {
case .bar:
    fallthrough
case .bar2:
    something()
}

```

### 规则31: fatal_error_message

执行fatalError错误时,建议有一个提示信息; 如:fatalError("Foo")

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| fatal_error_message | 未启用 | no | idiomatic |

代码示例:

```
//推荐写法
required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

//不建议
required init?(coder aDecoder: NSCoder) {
    fatalError("")
}

```

### 规则32: file_header

文件头。新建的文件开始的注释应该一样

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| aaa | 未启用 | no | style |

代码示例:

```
/// 不会触发warning
/// 如果我新建一个工程，在ViewController.swift文件中， 开始的注释应该是：

//  ViewController.swift
//  SwiftLint
//
//  Created by langke on 17/1/17.
//  Copyright © 2017年 langke. All rights reserved.
//

改变一下变为：
//
//  MyViewController.swift...................由于这里和外面的文件名不一样，所以触发warning（实际上在swift 3.0上测试这个属性暂时没有任何作用！！）
//  SwiftLint
//
//  Created by langke on 17/1/17.
//   Copyright © 2017年 langke. All rights reserved................官方terminal表示，Copyright和Created没有对齐，也会触发warning！！！
//

```

### 规则33: file_length

文件内容行数, 超过400行warning, 超过1000行给error

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| file_length | 启用 | no | metrics |

代码示例:

### 规则34: first_where

不建议在使用filter和map函数后直接使用.first

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| first_where | 未启用 | no | performance |

官方代码示例:

```
    public static let description = RuleDescription(
        identifier: "first_where",
        name: "First Where",
        description: "Prefer using `.first(where:)` over `.filter { }.first` in collections.",
        kind: .performance,

        //不会触发警告
        nonTriggeringExamples: [
            "kinds.filter(excludingKinds.contains).isEmpty && kinds.first == .identifier\n",
            "myList.first(where: { $0 % 2 == 0 })\n",
            "match(pattern: pattern).filter { $0.first == .identifier }\n",
            "(myList.filter { $0 == 1 }.suffix(2)).first\n"
        ],
        //以下写法会触发警告
        triggeringExamples: [
            "↓myList.filter { $0 % 2 == 0 }.first\n",
            "↓myList.filter({ $0 % 2 == 0 }).first\n",
            "↓myList.map { $0 + 1 }.filter({ $0 % 2 == 0 }).first\n",
            "↓myList.map { $0 + 1 }.filter({ $0 % 2 == 0 }).first?.something()\n",
            "↓myList.filter(someFunction).first\n",
            "↓myList.filter({ $0 % 2 == 0 })\n.first\n",
            "(↓myList.filter { $0 == 1 }).first\n"
        ]
    )

```

### 规则35: for_where

在for循环中,不建议使用单个if语句或者只使用一次循环变量,可使用where或者if{}else{}语句

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| for_where | 启用 | no | idiomatic |

代码示例:

```
//推荐写法
for user in users where user.id == 1 { }
for user in users {
   if let id = user.id { }
}
for user in users {
   if var id = user.id { }
}
for user in users {
   if user.id == 1 { } else { }
}
for user in users {
   if user.id == 1 { }
   print(user)
}
for user in users {
   let id = user.id
   if id == 1 { }
}
for user in users {
   if user.id == 1 && user.age > 18 { }
}

//不建议写法
for user in users {
   if user.id == 1 { return true }
}

```

### 规则36: force_cast

不建议直接强解类型

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| force_cast | 启用 | no | idiomatic |

代码示例:

```
//建议写法
NSNumber() as? Int

//不推荐
NSNumber() ↓as! Int

```

### 规则37: force_try

对会抛出异常(throws)的方法,不建议try!强解

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| force_try | 启用 | no | idiomatic |

代码示例:

```
func myFunction() throws { }

/// 这样写是可以的，不会触发 error
do {
    try myFunction()
} catch {

}

/// 这样直接触发 error
try! myFunction()

```

### 规则38: force_unwrapping

强制解包/拆包。我们知道，当一个类型是可选类型的时候，当我们获取值时，需要强制解包（也叫隐式解包）, 通常我们是在一个变量或者所需要的常量、类型等后面加一个“ ！”， 然而，swiftlint建议强制解包应该要避免， 否则将给予warning

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| force_unwrapping | 未启用 | no | idiomatic |

代码示例:

```
/// 将触发warning
navigationController!.pushViewController(myViewController, animated: true)

let url = NSURL(string: "http://www.baidu.com")!
print(url)

return cell!

/// 不会触发warning
navigationController?.pushViewController(myViewController, animated: true)

```

### 规则39: function_body_length

函数体长度， 函数体不应该跨越太多行， 超过40行给warning， 超过100行直接报错

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| function_body_length | 启用 | no | metrics |

代码示例:

### 规则40: function_parameter_count

*   函数参数个数， 函数参数数量(init方法除外)应该少点， 不要太多，swiftlint规定函数参数数量超过5个给warning， 超过8个直接报error
*   注：`function_parameter_count: error` 这样并不能改变它的警告或错误，该属性不允许修改，但是可以禁用

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| function_parameter_count | 启用 | no | metrics |

代码示例:

### 规则41: generic_type_name

泛型类型名称只能包含字母数字字符，以大写字母开头，长度介于1到20个字符之间

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| generic_type_name | 未启用 | no | idiomatic |

代码示例:

```
//推荐写法
func foo<T>() {}
func foo<T>() -> T {}
func foo<T, U>(param: U) -> T {}
func foo<T: Hashable, U: Rule>(param: U) -> T {}

//不推荐写法
func foo<T_Foo>() {}
func foo<T, U_Foo>(param: U_Foo) -> T {}
func foo<TTTTTTTTTTTTTTTTTTTTT>() {}
func foo<type>() {}

```

### 规则42: identifier_name

变量标识符名称应该只包含字母数字字符，并以小写字母开头或只应包含大写字母。在上述例外情况下，当变量名称被声明为静态且不可变时，变量名称可能以大写字母开头。变量名称不应该太长或太短

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| identifier_name | 启用 | no | style |

官方给出的示例:

```
internal struct IdentifierNameRuleExamples {
    //不会触发error
    static let nonTriggeringExamples = [
        "let myLet = 0",
        "var myVar = 0",
        "private let _myLet = 0",
        "class Abc { static let MyLet = 0 }",
        "let URL: NSURL? = nil",
        "let XMLString: String? = nil",
        "override var i = 0",
        "enum Foo { case myEnum }",
        "func isOperator(name: String) -> Bool",
        "func typeForKind(_ kind: SwiftDeclarationKind) -> String",
        "func == (lhs: SyntaxToken, rhs: SyntaxToken) -> Bool",
        "override func IsOperator(name: String) -> Bool"
    ]

    //会触发error
    static let triggeringExamples = [
        "↓let MyLet = 0",
        "↓let _myLet = 0",
        "private ↓let myLet_ = 0",
        "↓let myExtremelyVeryVeryVeryVeryVeryVeryLongLet = 0",
        "↓var myExtremelyVeryVeryVeryVeryVeryVeryLongVar = 0",
        "private ↓let _myExtremelyVeryVeryVeryVeryVeryVeryLongLet = 0",
        "↓let i = 0",
        "↓var id = 0",
        "private ↓let _i = 0",
        "↓func IsOperator(name: String) -> Bool",
        "enum Foo { case ↓MyEnum }"
    ]
}

```

### 规则44: implicit_getter

对于只有只读属性不建议重写get方法

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| implicit_getter | 启用 | no | style |

代码示例:

```
//不会触发error
//重写get和set方法
class Foo {
  var foo: Int {
    get {
      return 3
    }
    set {
      _abc = newValue 
    }
  }
}
//只读
class Foo {
  var foo: Int {
     return 20 
  } 
}

class Foo {
  static var foo: Int {
     return 20 
  } 
}

//会触发error
class Foo {
  var foo: Int {
    get {
      return 20 
    } 
  } 
}

class Foo {
  var foo: Int {
    get{
      return 20 
    } 
  } 
}

```

### 规则45: implicit_return

建议使用隐式返回闭包; 如: foo.map({ $0 + 1 })

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| implicit_return | 未启用 | no | style |

代码示例:

```
//推荐写法
foo.map { $0 + 1 }
foo.map({ $0 + 1 })
foo.map { value in value + 1 }

//不建议写法
foo.map { value in
  return value + 1
}
foo.map {
  return $0 + 1
}

```

### 规则46: implicitly_unwrapped_optional

尽量避免隐式解析可选类型的使用

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| implicitly_unwrapped_optional | 未启用 | no | idiomatic |

下面吗给出官方示例:

```
    public static let description = RuleDescription(
        identifier: "implicitly_unwrapped_optional",
        name: "Implicitly Unwrapped Optional",
        description: "Implicitly unwrapped optionals should be avoided when possible.",
        kind: .idiomatic,

        //不会触发warning
        nonTriggeringExamples: [
            "@IBOutlet private var label: UILabel!",
            "@IBOutlet var label: UILabel!",
            "@IBOutlet var label: [UILabel!]",
            "if !boolean {}",
            "let int: Int? = 42",
            "let int: Int? = nil"
        ],

        //会触发warning
        triggeringExamples: [
            "let label: UILabel!",
            "let IBOutlet: UILabel!",
            "let labels: [UILabel!]",
            "var ints: [Int!] = [42, nil, 42]",
            "let label: IBOutlet!",
            "let int: Int! = 42",
            "let int: Int! = nil",
            "var int: Int! = 42",
            "let int: ImplicitlyUnwrappedOptional<Int>",
            "let collection: AnyCollection<Int!>",
            "func foo(int: Int!) {}"
        ]
    )

```

### 规则47: is_disjoint

初始化集合Set时,推荐使用Set.isDisjoint(), 不建议:Set.intersection

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| is_disjoint | 启用 | no | idiomatic |

代码示例:

```
//推荐写法
_ = Set(syntaxKinds).isDisjoint(with: commentAndStringKindsSet)
let isObjc = !objcAttributes.isDisjoint(with: dictionary.enclosedSwiftAttributes)

```

### 规则48: joined_default_parameter

joined方法使用默认分隔符时, 建议使用joined()方法, 而不是joined(separator: "")方法

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| joined_default_parameter | 未启用 | yes | idiomatic |

代码示例:

```
//建议写法
let foo = bar.joined()
let foo = bar.joined(separator: ",")
let foo = bar.joined(separator: toto)

//不建议写法
let foo = bar.joined(separator: "")
let foo = bar.filter(toto).joined(separator: "")

```

### 规则49: large_tuple

定义的元组成员个数,超过两个warning

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| large_tuple | 启用 | no | metrics |

代码示例:

```
//不会触发warning
let foo: (Int, Int)
let foo: (start: Int, end: Int)
let foo: (Int, (Int, String))

//会触发warning
let foo: (Int, Int, Int)
let foo: (start: Int, end: Int, value: String)
let foo: (Int, (Int, Int, Int))

```

### 规则50: leading_whitespace

文件开始不应该有空格或者换行, 否则就会触发warning

| 识别码 | 默认是否启用 | 是否支持自动更正 | 类型 |
| --- | --- | --- | --- |
| leading_whitespace | 启用 | yes | style |

代码示例:

```
/// 不会触发warning
//
//  ViewController.swift
//  SwiftLint
//
//  Created by langke on 17/1/12.
//  Copyright © 2017年 langke. All rights reserved.
//

/// 会触发warning
 //..................................这里有一个空格
//  ViewController.swift
//  SwiftLint
//
//  Created by langke on 17/1/12.
//  Copyright © 2017年 langke. All rights reserved.
//

/// 会触发warning
......................................这里是一个空行
//
//  ViewController.swift
//  SwiftLint
//
//  Created by langke on 17/1/12.
//  Copyright © 2017年 langke. All rights reserved.
//

```

> 参考文档
> [SwiftLint规则官方文档](https://link.jianshu.com/?t=https%3A%2F%2Fgithub.com%2Frealm%2FSwiftLint%2Fblob%2Fmaster%2FRules.md%23array-init)
> [SwiftLint个规则详细介绍](https://link.jianshu.com/?t=https%3A%2F%2Fgithub.com%2Frealm%2FSwiftLint%2Ftree%2Fmaster%2FSource%2FSwiftLintFramework%2FRules

## 参考

* [swift-style-guide/README_CN.md at master · Artwalk/swift-style-guide](https://github.com/Artwalk/swift-style-guide/blob/master/README_CN.md)