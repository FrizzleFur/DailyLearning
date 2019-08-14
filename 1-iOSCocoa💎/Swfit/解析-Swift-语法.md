# Swift-语法


## 类

Swift 中类和结构体有很多共同点。共同处在于：

* 定义属性用于存储值
* 定义方法用于提供功能
* 定义附属脚本用于访问值
* 定义构造器用于生成初始化值
* 通过扩展以增加默认实现的功能
* 符合协议以对某类提供标准功能

与结构体相比，类还有如下的附加功能：

* 继承允许一个类继承另一个类的特征
* 类型转换允许在运行时检查和解释一个类实例的类型
* 解构器允许一个类实例释放任何其所被分配的资源
* 引用计数允许对一个类的多次引用

## 协议 Protocol

* 协议规定了用来实现某一特定功能所必需的方法和属性。

* 任意能够满足协议要求的类型被称为遵循(conform)这个协议。

* 类，结构体或枚举类型都可以遵循协议，并提供具体实现来完成协议定义的方法和功能。

Swift中定义一个协议和定义枚举、结构体或者类的格式类似，使用protocol关键字：

> 
```swift
//定义一个名字为学生协议
protocol Student {
}
```

这里Student是使用**protocol **关键字声明的一个协议，和枚举、结构体、类命名原则相似，Student首字母大写表示在以后的使用中很可能会将Student看作是一个类型使用。
协议中定义属性
协议中定义属性表示遵循该协议的类型具备了某种属性，具体来说只能使用var关键字声明并且必须明确规定该属性是可读的get、还是可读可写的get set，另外还可以通过关键字static声明一个类型属性。示例如下：

```swift
protocol Student {
    //定义一个可读可写的 name 属性
    var name: String { get set }
    //定义一个可读的 birthPlace 属性
    var birthPlace: String { get }
    //定义一个类属性 record
    static var qualification: String {get}
}
```


和定义方法一样，我们只需要确定该属性具体是什么类型并且添加对应的关键字，不需要具体的实现，更不能为他们赋上初始值（类似于计算属性）。定义好属性之后，我们就可以利用属性来做点事情了。

```swift
struct Puple: Student {
    static var qualification: String = "小学"
    var name: String
    var birthPlace: String = "北京"
}
var p1 = Puple(name: "小明", birthPlace: "上海")

```
定义一个Puple结构体遵循Student协议，该结构体中必须存在协议要求声明的三个属性matrikelnummer、name、birthPlace,static修饰的类型属性必须被有初始值或者存在get、set方法。对于普通的实例属性协议并不关心是计算型属性还是存储型属性。实例中的属性同样可以被修改：


#### 为什么要使用协议

* 协议可以作为类型使用
* 协议作为一种类型是苹果在Swift中提出的，并且在官方文档中还为我们具体指出了可以将协议当做类型使用的场景：

1. 在函数、方法或者初始化器里作为形式参数类型或者返回类型；
2. 作为常量、变量或者属性的类型；
3. 作为数组、字典或者其他存储器的元素的类型。

[Swift中协议的简单介绍 - 简书](https://www.jianshu.com/p/e70bd6645d88)


## Tuple

很多时候，我们需要把多个不同类型的值，打包成一个单位处理。例如，返回一个HTTP状态信息：

*   状态码: 200; 状态消息: HTTP OK
*   状态码: 404; 状态消息: File not found

或者，返回一条数据库用户信息记录：`姓名: Mars; 工号: 11; 电子邮件: 11@boxue.io`。在Swift里，我们可以使用Tuple 来很方便的处理类似的问题。

### 定义一个Tuple

我们使用下面的方式，来定义一个Tuple：

```swift
(value1, value2, value3...)

```

例如，定义我们开始提到的HTTP状态码：

```swift
//: #### Define a tuple

let success = (200, "HTTP OK")
let fileNotFound = (404, "File not found")

```

我们还可以给Tuple中的每一个数据成员指定一个名字，例如，定义一个表达用户信息记录的Tuple：

```swift
(name1: value1, name2: value2, name3: value3...)

//: #### Define a tuple
let me = (name: "Mars", no: 11, email: "11@boxue.io")

```

### 访问Tuple中的数据成员

定义好Tuple之后，我们可以使用下面的方式访问Tuple中的数据成员：

```swift
//: #### Access tuple content

success.0
success.1

fileNotFound.0
fileNotFound.1

```

如果我们在定义Tuple时，指定了Tuple成员的名字，我们就可以像下面这样访问这些数据成员：

```swift
//: #### Access tuple content

me.name
me.no
me.email

```

### Tuple Decomposition

我们在定义Tuple的时候，还可以把一个Tuple的值，一一对应的拆分到不同的变量上，这叫做Tuple Decomposition。例如，对于之前定义过的`success`，我们可以这样定义一个新的Tuple：

```swift
var (successCode, successMessage) = success

print(successCode) // 200
print(successMessage) // HTTP OK

```

之后，就可以直接访问`successCode`和`successMessage`的值了。这可以提高我们处理Tuple成员时的代码可读性。但要说明的是，我们这里是使用`success`的值，构建了一个新的Tuple，因此修改`succeCode`或`successMessage`的值，不会影响到原来的`success`。

例如，我们修改`successCode`：

```swift
successCode = 201

success // (200, "HTTP OK")

```

从结果我们可以看到，之前的`success`的值没有被修改。另外，如果我们只是想对应到Tuple中特定的成员，而忽略其它成员，我们可以使用下划线'_'来代表那些不需要被对应的成员。例如：

```swift
let (_, errorMessage) = fileNotFound
print(errorMessage)

```

### Tuple type

每一个Tuple的类型，都是由Tuple中所有数据成员一起决定给的。例如，对于一开始我们定义的success和me，它们的类型就分别是：`(Int, String)`和`(String, Int, String)`。当我们需要用type annotation定义一个Tuple的时候，我们可以这样写：

```swift
var redirect: (Int, String) = (302, "temporary redirect")

```

### Tuple comparison

当我们比较两个Tuple类型的变量时，要遵循下面的规则：

首先，只有元素个数相同的Tuple变量之间，才能进行比较。例如，下面的代码会引发编译错误：

```swift
let tuple12 = (1, 2)
let tuple123 = (1, 2, 3)

tuple2 < tuple3

```

![tuple compare error](https://o8lw4gkx9.qnssl.com/packdata-by-tuple-1@2x.png)

从上面的结果就能看到，包含两个`Int`的Tuple不能和包含三个`Int`的Tuple进行比较。

其次，当Tuple中元素个数相同时，比较是按照Tuple中元素的位置从前向后依次进行的：

*   如果Tuple中，相同位置的两个元素相等，则继续比较下一个位置的两个元素，并根据第一个同一位置不相等的两个元素的大小关系，确定两个Tuple变量的关系；
*   如果两个Tuple中所有位置的元素都相等，则两个Tuple变量相等；

因此，对于下面这个例子，`tuple11 < tuple12`的结果是`true`：

```swift
let tuple11 = (1, 1)
let tuple12 = (1, 2)

tuple11 < tuple12 // true

```

但是，有一点要说明的是，我们只可以对最多包含6个元素的Tuple变量进行比较，超过这个数量，Swift会报错。例如对于下面这段代码：

```swift
let largeTuple1 = (1, 2, 3, 4, 5, 6, 7)
let largeTuple2 = (1, 2, 3, 4, 5, 6, 7)

largeTuple1 == largeTuple2 // Error !!!

```

编译器就会提示类似下面这样的错误：

![tuple compare error](https://o8lw4gkx9.qnssl.com/packdata-by-tuple-2@2x.png)



## 泛型

泛型：编译器多态，在编译期检查类型。  

* Swift 提供了泛型让你写出灵活且可重用的函数和类型。

* Swift 标准库是通过泛型代码构建出来的。

* Swift 的数组和字典类型都是泛型集。


```swift
func swapTwoInts(inout a: Int, inout b: Int)
func swapTwoValues<T>(inout a: T, inout b: T)

```

这个函数的泛型版本使用了占位类型名字（通常此情况下用字母T来表示）来代替实际类型名（如Int、String或Double）。占位类型名没有提示T必须是什么类型，但是它提示了a和b必须是同一类型T，而不管T表示什么类型。只有swapTwoValues函数在每次调用时所传入的实际类型才能决定T所代表的类型。

另外一个不同之处在于这个泛型函数名后面跟着的占位类型名字（T）是用尖括号括起来的（<T>）。这个尖括号告诉 Swift 那个T是swapTwoValues函数所定义的一个类型。因为T是一个占位命名类型，Swift 不会去查找命名为T的实际类型。

### 泛型类型


通常在泛型函数中，Swift 允许你定义你自己的泛型类型。这些自定义类、结构体和枚举作用于任何类型，如同Array和Dictionary的用法。

这里展示了如何写一个非泛型版本的栈，Int值型的栈：


```swift
struct IntStack {
    var items = Int[]()
    mutating func push(item: Int) {
        items.append(item)
    }
    mutating func pop() -> Int {
        return items.removeLast()
    }
}
```

这个结构体在栈中使用一个Array性质的items存储值。Stack提供两个方法：push和pop，从栈中压进一个值和移除一个值。这些方法标记为可变的，因为它们需要修改（或转换）结构体的items数组。

上面所展现的IntStack类型只能用于Int值，不过，其对于定义一个泛型Stack类（可以处理任何类型值的栈）是非常有用的。

这里是一个相同代码的泛型版本：


```swift
struct Stack<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
}
```


类型约束语法
你可以写一个在一个类型参数名后面的类型约束，通过冒号分割，来作为类型参数链的一部分。这种作用于泛型函数的类型约束的基础语法如下所示（和泛型类型的语法相同）：


```swift
func someFunction<T: SomeClass, U: SomeProtocol>(someT: T, someU: U) {
    // function body goes here
}

```

上面这个假定函数有两个类型参数。第一个类型参数T，有一个需要T必须是SomeClass子类的类型约束；第二个类型参数U，有一个需要U必须遵循SomeProtocol协议的类型约束。


## 基本操作符（Basic operators）

操作符，是一个编程语言中完成各种运算不可或缺的元素。Swift中的大部分操作符，都符合我们对各种运算的理解。因此，在这篇文档里，我们将带着大家快速过一遍Swift中的各种操作符，并对其中大家可能不太熟悉的部分，做一些特别的说明。


### 赋值操作符

这个最简单，我们之前已经用过多次，等号右边的值赋值给等号左边的变量：

```swift
//: #### Basic assignment
let a = 20
var b = 10

```

### 基本算术运算操作符

```swift
let sum = a + b
let sub = a - b
let mul = a * b
let div = a / b
let mod = a % b

```

> “Swift 3不再允许浮点数取模。例如：8 ％ 2.5这样的写法在Swift 3中将会报错。如果要对浮点数取模，只能这样： `8.truncatingRemainder(dividingBy: 2.5)`。”

### 复合运算操作符

Swift还支持把赋值和算数运算符组合起来：

```swift
//: #### Compound assignment

b += 10 // b = b + 10
b -= 10 // b = b - 10
b *= 10 // b = b * 10
b /= 10 // b = b / 10
b %= 10 // b = b % 10

```

> “Swift不会把数字自动转换成`Bool`类型。在需要`Bool`值的地方，你必须明确使用一个`Bool`变量。”
> 
> “Swift 3中不再支持自增（++）和自减（--）操作符，使用它们的前缀和后缀版本都会得到一个编译器错误。因此，需要+1/-1的时候，只能使用`b += 1`和`b -= 1`来实现。”

### 比较操作符

Swift支持以下常用的比较操作：

```swift
//: #### Comparison
let isEqual     = sum == 10
let isNotEqual  = sum != 10
let isGreater   = sum >  10
let isLess      = sum <  10
let isGe        = sum >= 10
let isLe        = sum <= 10

```

除此之外，Swift还支持两个用于比较对象引用的操作符：Identity operator，它们用来判断两个操作数是否引用同一个对象，我们在后面讲到面向对象编程的时候，会进一步提到这两个操作符。

```swift
//: Identity operator

//===
//!==

```

### 三元操作符

```swift
/*
* if condition {
*     expression1
* }
* else {
*     expression2
* }
*
*/

let isSumEqualToTen = isEqual ? "Yes" : "No"

```

在Swift里，一些“日常”的`if...else...`判断，可以使用下面的三元操作符来替代：`cond ? expr1 : expr2`。

### Nil Coalescing Operator

这是一个Swift特有的操作符，用来处理和Optional有关的判断：

```swift
// opt != nil ? opt! : b

var userInput: String? = "A user input"
let value = userInput ?? "A default input"

```

如果`opt`是一个optional，当其不为`nil`时，就使用optional变量自身的值，否则，就使用`??`后面的“默认值”。

### Range operator

#### 闭区间range operator

我们用下面的方式表达一个包含begin和end的闭区间：`begin ... end`：

```swift
//: Closed range operator
// begin...end

for index in 1...5 {
    print(index)
}

```

##### 半开半闭区间range operator

我们用下面的方式表达一个[begin, end)的半开半闭区间：`begin ..< end`：

```swift
//: Half-open range operator
// begin..<end [begin, end)

for index in 1..<5 {
    print(index)
}

```

### 逻辑运算符

Swift支持三种常用的逻辑运算：NOT，AND和OR。它们都返回一个`Bool`：

```swift
//: #### Logic operator

let logicalNot = !isEqual
let logicalAnd = isNotEqual && isLess
let logicalOR  = isGreater  || (isLess && isLe)

```

## 修饰符

* open,public 对应的级别是该模块或者是引用了该模块的模块可以访问 即 a belong to A , B import A 这两种情况都可以对 a进行访问

* public： 类用public(或级别更加等级更低的约束(如private等))修饰后只能在本模块（sdk）中被继承，如果public是修饰属性的话也是只能够被这个module(sdk)中的子类重写

* open：用open修饰的类可以在本某块(sdk),或者其他引入本模块的(sdk,module)继承，如果是修饰属性的话可以被此模块或引入了此某块(sdk)的模块（sdk）所重写

    * 这个元素可以在其他作用域被访问
    * 这个元素可以在其他作用域被继承或者override

* internal 是在模块内部可以访问，在模块外部不可以访问，a belong A , B import A, A 可以访问 a, B 不可以访问a.比如你写了一个sdk。那么这个sdk中有些东西你是不希望外界去访问他，这时候你就需要internal这个关键字（我在导入第三方框架时发现其实没有定义的话sdk里面是默认internal的）

* fileprivate 这个修饰跟名字的含义很像，file private 就是文件之间是private的关系，也就是在同一个source文件中还是可以访问的，但是在其他文件中就不可以访问了  a belong to file A, a not belong to file B , 在 file A 中 可以访问 a，在 file B不可以访问a

* private 这个修饰约束性比fileprivate的约束性更大，private 作用于某个类，也就是说，对于 class A ,如果属性a是private的，那么除了A外其他地方都不能访问了(fileprivate 和private都是一种对某个类的限制性约束。fileprivate的适用场景可以是某个文件下的extension，如果你的类中的变量定义成了private那么这个变量在你这个类在这个类的文件的拓展中就无法访问了，这时就需要定义为fileprivate)

open

open 修饰的 class 在 Module 内部和外部都可以被访问和继承
open 修饰的 func 在 Module 内部和外部都可以被访问和重载（override）

Public

public 修饰的 class 在 Module 内部可以访问和继承，在外部只能访问
public 修饰的 func 在 Module 内部可以被访问和重载（override）,在外部只能访问

Final

* final 修饰的 class 任何地方都不能不能被继承
* final 修饰的 func 任何地方都不能被 Override

## Optional

```swift
public enum Optional<Wrapped> : ExpressibleByNilLiteral {

    /// The absence of a value.
    ///
    /// In code, the absence of a value is typically written using the `nil`
    /// literal rather than the explicit `.none` enumeration case.
    case none

    /// The presence of a value, stored as `Wrapped`.
        case some(Wrapped) 
```

* none: 没有值
* Optional(variable) 可选值
* !, 强制解包，从可选值中获取非空值，不推荐用，须为！负责

## 使用“Markdown方言”编写代码注释

作为伴随Swift 3发布的API设计指南中的要求，**使用Swift Markdown为代码编写注释**已经进一步从一个道义提升为了一种行为准则。一方面，Markdown对开发者来说，足够熟悉，学习难度并不高；另一方面，Xcode可以在Playground和代码提示中，对Markdown注释进行漂亮的渲染，让代码在开发者之间交流起来更加容易。既然如此，我们就通过这段视频，带着大家快速过一遍Swift中的Markdown注释机制，了解它们在Xcode哪些地方会被渲染出来。

### 从一个包含playground文件的Single View Application开始

为了演示Markdown注释在Xcode中的各种效果，我们创建一个Single View Application，并向其中添加了一个MyPlayground文件以及一个包含`struct IntArray`类型的源代码文件。因为，在Xcode在Playground和项目源代码中，使用了两种不同的Markdown注释格式，我们要分别了解它们。

为了能快速切换Markdown注释在Playground中的渲染效果，我们可以按`Command + ,`打开属性对话框，选择“Key Bindings”

![Key bindings](https://o8lw4gkx9.qnssl.com/br-markdown-comment-1@2x.jpg)

在“Filter”中，输入`Show rendered`，Xcode会为我们自动过滤出筛选的菜单项目，“Show rendered Markup”用于在Playground里，切换Markdown注释的渲染。双击右侧的空白，为它设定一个快捷键，例如：`option + M`：

![Show rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-2@2x.jpg)

这样，我们就能通过设置的快捷键在Playground中快速切换Markdown的渲染效果了。接下来，我们就来看各种常用的Markdown用法。

* * *

#### Playground

*   包含Markdown的单行注释用`//:`表示：

```swift
//: # Heading 1

```

*   包含Markdown的多行注释用下面的代码表示：

```swift
/*:
  * item1
  * item2
  * item3
 */

```

按`Option + M`，Playground就会自动为我们渲染注释了：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-3@2x.jpg)

* * *

#### Symbol documentation

如果是在Xcode项目的源代码中：

*   包含Markdown的单行注释用`///`表示：

```swift
/// A **demo** function
func demo() {}

```

*   包含Markdown的多行注释用下面的代码表示：

```swift
/**
  * item1
  * item2
  * item3
*/
func demo1() {
}

```

我们这样添加的注释会显示在哪呢？主要有两个地方，Apple管它们叫做symbol documentation，我们可以用两种方式来查阅它：

*   把光标放到`demo1`所在的行上，按住`option`点一下，就会弹出这个函数的说明，可以看到Xcode已经把markdown注释渲染了；

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-4@2x.jpg)

*   按`Option + Command + 2`打开Quick Help Inspector，保持光标在demo1()所在行，同样，我们可以看到被渲染过的Markdown注释；

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-5@2x.jpg)

> 简单来说，在Playground里编写markdown注释时，注释起始的第三个字符用`:`，在项目源代码中编写markdown注释时，注释起始的第三个字母分别用`/`和`*`。

* * *

#### 常用的注释范式

接下来，我们看来一些在Playground和项目代码中经常会用到的注释范式。至于其中用到的Markdown语法，大家应该都比较熟悉，我们就不一一去解释了。大家也可以在[这里查看Apple官方的Swift markdown语法说明](https://developer.apple.com/library/mac/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html#//apple_ref/doc/uid/TP40016497-CH2-SW1)。

* * *

##### 标记重要事项

当我们用Playground告知开发者代码中的重要事项时，可以采用下面这种类似的方式进行注释：

```swift
/*:
  > # IMPORTANT: something important you want to mention:
  A general descripiton here.
  1\. item1
  1\. item2
  1\. item3
  ---
  [More info - Access boxueio.com](https://boxueio.com)
 */

```

*   一行简短的重要提示标题；
*   一段内容摘要；
*   一个注意事项列表；
*   一个提供更多内容的链接；

在Playground里，上面的注释可以被渲染成这样：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-6@2x.jpg)

如果我们要把上面的注释放在项目代码里，出了要使用`/**`开始外，我们还要去掉第一行的`>`，因为Quick Help不支持这样的Markdown：

```swift©
/**
  # IMPORTANT: something important you want to mention:
  A general descripiton here.
  1\. Start with
  1\. Write anything important you want to emphasize
  1\. End with  at a new line.
  ---
  [More info - Access boxueio.com](https://boxueio.com)
 */

```

这样，它看起来，就是这样的：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-7@2x.jpg)

有关函数自身的注释范式，稍后我们会看到。接下来，我们先看一个简化注释输入的方法。

* * *

##### 在Playground之间跳转

有时，为了演示一个项目的不同用法和功能，我们可能会在项目中使用多个Playground文件。为了方便在注释中浏览，我们可以在Playground markdown注释中，添加文件跳转链接。

选中项目中的MyPlayground，点击右键，选择“New Playground Page”，添加2个新的page进来，我们把这些页面分别命名成Page1 / Page2 / Page3。

在新添加进来的page2和page3里，先分别添加一个标题注释以方便区分它们。然后我们可以看到，在Playground页面的头部和尾部，Xcode已经为我们自动添加了两个链接：

```swift
//: [Previous](@previous)

//: [Next](@next)

```

按`Option + M`，切换到渲染模式，分别点击页面上的Previous和Next链接，就会发现可以在页面间前后跳转了。实际上，这里用了两个关键字，`@previous`和`@next`，Xcode会自动把它们渲染成跳转到项目文件列表中前、后两个文件的链接。

当然，我们也可以实现跨文件跳转，打开Page1，这次在括号里写上要跳转到的目标Playground页面的名字：

```
//: [To Page3](Page3)

```

再切换到渲染模式，点击“To Page3”，就可以跳转到相应的Playground页面了。接下来，我们来看如何通过Xcode Code Snippet Library简化复杂注释的输入。

* * *

### Code Snippet Library

首先，把之前我们用过的注释块，抽象成一个内容模板：

```swift
/*:
  > # IMPORTANT: <#something important#>
  <#General description#>
  1\. <#item1#>
  1\. <#item2#>
  1\. <#item3#>
  ---
  [More info - <#ref#>](<#Link#>)
*/

```

基本内容和之前还是一样的，只不过，我们把其中需要输入内容的地方用一对`<# ... #>`包围了起来，这用于告诉Xcode，这些内容是需要每次用户单独输入的。

其次，我们选中要添加的代码块，先不要着急拖动，按住等待一会儿，直到鼠标从输入状态变回指针状态；

第三、把代码块拖动到Code Snippet Library：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-8@2x.jpg)

这样，在Code Snippet Library里，就会多出来一项，表示我们新添加的代码片段，在图标的左下角，左右一个“User”字样，表示这是我们自定义的代码片段：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-9@2x.jpg)

第四、点击“Edit”按钮，编辑一下这个代码片段：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-10@2x.jpg)

其中：

*   `Title`表示代码片段的名称；
*   `Summary`表示代码片段的简单说明；
*   `Platform`表示代码片段在 iOS / macOS / watchOS / tvOS / All 中使用；
*   `Language`表示代码片段生效的语言；
*   `Completion Shortcut`表示如何调出这个代码片段，在这里我们选择输入`importantnote`，当然你可以设置成任何方便使用的内容；
*   `Completion Scopes`表示上面设置的`Completion Shortcut`生效范围，All表示在任意位置都生效；

设置完成后，点击"Done"。这样当我们在Swift代码里输入`importantnote`的时候，就能调出需要的注释片段，我们只要直接设置其中的内容就好了。

接下来，我们将看到一些常用的注释范式，它不仅可以让代码易于维护和交流，就像API设计指南中的描述的那样，可以有效的激发我们的设计灵感。

* * *

#### 标记自定义类型的常用范式

对于一个自定义类型来说，我们要在注释中说明以下问题：

*   一句话描述；
*   类型主要功能；
*   常用的初始化方法以及拷贝语义；
*   补充说明；

而对这些问题的阐述，正是我们设计这个类型的过程。因此，在编码前设计注释文档，可以很好的帮我们整理设计思路。

例如，我们创建一个包含整数的`struct IntArray`，在Playground里添加下面的注释：

```swift
/*:
 `IntArray` is a C-like random access collection of integers.

 ## Overview
 An `IntArray` stores values of integers in an ordered list.
 The same value can appear in an IntArray multiple times at
 different positions.

 ## Initializers
 You can create an IntArray in the following ways:

    // An empty IntArray
    var empty: IntArray = []

    // Initialzied by an array literal
    var odds: IntArray = [0, 2, 4, 6, 8]

    // Initialized by a default value
    var tenInts: IntArray = IntArray(repeating: 0, count: 10)

 ## Value semantics
 - important:
 `IntArray` object perform value type semantics. But we have the COW optimization.

 Like all value types, `IntArray` use a COW optimization.
 Multiple copies of `IntArray` share the same storage as long as
 none of the copies are modified.

 ---

 - note:
 Check [Swift Standard Library](https://developer.apple.com/reference/swift/array)
 for more informaton about arrays.
 */

```

上面的注释被Xcode渲染出来是这样的：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-11@2x.jpg)

而把这段注释移植到Xcode项目代码中，在Quick Help中看到的结果是这样的：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-12@2x.jpg)

当然，你可以任意在注释里添加希望其它开发者了解的内容，例如访问、存取、修改数组的方法等。也可以通过Snippet library，把它保存起来。

在上面的注释里，有几个用法是要特别说明下的：

*   我们可以在注释中使用`single line of code`来插入单行代码；
*   在注释中插入代码块时，**代码块的缩进要和当前最近的一个内容缩进有4个以上的空格**，否则Xcode不会识别；
*   我们在注释中使用了两个用`-`开始的标记，它们叫做callout，实际上你可以选择使用加号、减号或乘号来表示一个callout。Xcode可以识别它们，并突出显示其中的内容。大家可以在[这里](https://developer.apple.com/library/mac/documentation/Xcode/Reference/xcode_markup_formatting_ref/MarkupFunctionality.html#//apple_ref/doc/uid/TP40016497-CH54-SW1)找到所有的callout元素列表。要说明的是，并不是所有callout都可以同时在Playground和Quick Help中使用，选择的时候，要注意这点；
*   最后，我们可以**使用三个及以上的**`-`，表示一条分割线，用来区分正文和内容引用的部分；

* * *

#### 标记函数或方法的常用范式

通常，对一个方法的描述，更多是用在Quick Help里。对于一个函数来说，最重要的内容无非有以下：

*   一句话功能描述；
*   常见应用场景；
*   参数；
*   返回值；
*   时间复杂度；

如果我们要在上面`IntArray`里，添加一个“返回不包括末尾N个元素的IntArray”的方法：

```swift
public func dropLast(_ n: Int) -> IntArray

```

它的注释可以是这样的：

```swift
/// Returns a subsequence containing all but the specified number of final
/// elements.
///
/// If the number of elements to drop exceeds the number of elements in the
/// collection, the result is an empty subsequence.
///
///     let numbers = [1, 2, 3, 4, 5]
///     print(numbers.dropLast(2))
///     // Prints "[1, 2, 3]"
///     print(numbers.dropLast(10))
///     // Prints "[]"
///
/// - Parameter n: The number of elements to drop off the end of the collection.
///   `n` must be greater than or equal to zero.
///
/// - Returns: A subsequence that leaves off `n` elements from the end.
///
/// - Complexity: O(*n*), where *n* is the number of elements to drop.

```

通常，多行的代码注释也可以使用这种多个单行注释拼接的形式来编写，因为有时多行缩进的不同，会让整个注释从头部看起来比较混乱（大家可以对比下前面我们对`IntArray`的注释），而使用多个`///`则看起来会整齐一些。

在这个例子里，我们使用了三个callout，分别表示了方法的参数、返回值和时间复杂度，**如果算法复杂度是O(1)，那默认是可以省略的**。

在Quick Help里，它看上去是这样的：

![Rendered markdown](https://o8lw4gkx9.qnssl.com/br-markdown-comment-13@2x.jpg)

* * *

#### 标记属性的常用范式

关于属性的注释，我们只强调一点，就是对于computed property来说，**如果它的算法复杂度不是O(1)，必须在注释中予以说明**。因为对于绝大多数人来说，不会预期访问一个属性会带来严重的性能开销。

以上，就是在Swift 3 API设计指南中，关于注释的内容。**在编码前，用写文档的方式来编写注释**，可能在初期会让我们觉得不适应，或者觉得没必要，但至少在设计一个新的类型或方法时，尝试着去做它们，它会让你明确类型表达的语意，理清方法功能的边界，进而让你的代码，更加易于理解和交流。

[](https://boxueio.com/series/swift-up-and-running/ebook/5)



### 字符串的处理




```swift

//: # Markdown
/*:
 > # IMPORTANT: something important you want to mention:
 A general descripiton here.
 1. item1
 1. item2
 1. item3
 ---
 [More info - Access boxueio.com](https://boxueio.com)
 */



var hello = "hello"
//print(hello.substring(to: 1))
print(hello.startIndex)


String(hello.characters.prefix(3))

var mixStr = "Swift很有趣"

if let index = mixStr.characters.index(of: "很") {
    mixStr.replaceSubrange(cnIndex ..< mixStr.endIndex, with: " is interesting")
}


```

#### Map函数

 map：可以对数组中的每一个元素做一次处理


## enum、struct、class和protocol


Swift主要为我们提供了以下四种”named types“ 分别是：enum、struct、class和protocol。相信熟悉iOS开发的同学们对于枚举、结构体和类的概念一点都不陌生。相比于前辈Objective-C中的这三者，Swift将enum和struct变得更加灵活且强大，并且赋予了他们很多和class相同的属性实现更加丰富多彩的功能，以至于有时候我们很难分清他们到底有什么区别以及我该什么时候用哪种类型，接下来本文将重点介绍一下在Swift中enum和struct的定义和新特性以及两者与class之间的异同，也是自己学习Swift以来的阶段性总结。

* [Swift中enum、struct、class三者异同 - 简书](https://www.jianshu.com/p/78a6a4941516)


## 结构体

### 结构体应用
* 在你的代码中，你可以使用结构体来定义你的自定义数据类型。

* 结构体实例总是通过值传递来定义你的自定义数据类型。

* 按照通用的准则，当符合一条或多条以下条件时，请考虑构建结构体：

* 结构体的主要目的是用来封装少量相关简单数据值。
* 有理由预计一个结构体实例在赋值或传递时，封装的数据将会被拷贝而不是被引用。
* 任何在结构体中储存的值类型属性，也将会被拷贝，而不是被引用。
* 结构体不需要去继承另一个已存在类型的属性或者行为。
* 举例来说，以下情境中适合使用结构体：

* 几何形状的大小，封装一个width属性和height属性，两者均为Double类型。
* 一定范围内的路径，封装一个start属性和length属性，两者均为Int类型。
* 三维坐标系内一点，封装x，y和z属性，三者均为Double类型。
* 结构体实例是通过值传递而不是通过引用传递。

* 以上两点就是我们为Student结构体内部添加changeMath(num:)的原因，他让我们把类型相关的计算表现的更加自然和统一，即自己的事情应该用自己的方法实现不应该被别人关心。值得一提的是在结构体内部方法中如果修改了结构体的成员，那么该方法之前应该加入：mutating关键字。

### 总结

关于枚举、结构体的介绍这里仅仅是冰山一角，他们还有更加丰富的功能需要读者在阅读完本文后深入学习。了解这些基础内容，可以帮助我们在Swift开发中更熟练的使用他们。这里根据官方文档介绍结合自己的理解简单的做一下总结：

**枚举、结构体、类的共同点：**

1. 定义属性和方法；
2. 下标语法访问值；
3. 初始化器；
4. 支持扩展增加功能；
5. 可以遵循协议；

**类特有的功能：**

1. 继承；
2. 允许类型转换；
3. 析构方法释放资源；
4. 引用计数；

**类是引用类型**

* 引用类型(reference types，通常是类)被复制的时候其实复制的是一份引用，两份引用指向同一个对象。所以在修改一个实例的数据时副本的数据也被修改了(s1、s2)。
* 枚举，**结构体是值类型**
* 值类型(value types)的每一个实例都有一份属于自己的数据，在复制时修改一个实例的数据并不影响副本的数据(p1、p2)。值类型和引用类型是这三兄弟最本质的区别。


#### 我该如何选择

* 关于在新建一个类型时如何选择到底是使用值类型还是引用类型的问题其实在理解了两者之间的区别后是非常简单的，在这苹果官方已经做出了非常明确的指示（以下内容引自苹果官方文档）：

* 当你使用Cocoa框架的时候，很多API都要通过NSObject的子类使用，所以这>时候必须要用到引用类型class。在其他情况下，有下面几个准则：
* 什么时候该用值类型：
    * 要用==运算符来比较实例的**数据**时
    * **你希望那个实例的拷贝能保持独立的状态时**
    * **数据会被多个线程使用时**

* 什么时候该用引用类型（class）：
    * 要用==运算符来比较实例**身份**的时候
    * 你希望有创建一个共享的、可变对象的时候
## 类和结构体

在swift中，为了安全性的考虑，将`Int`,`Double`类型都用`Struct`结构体来标识
```swift
/// A signed integer value type.
///
/// On 32-bit platforms, `Int` is the same size as `Int32`, and
/// on 64-bit platforms, `Int` is the same size as `Int64`.
public struct Int : FixedWidthInteger, SignedInteger {

    /// A type that represents an integer literal.
    public typealias IntegerLiteralType = Int
    
    /// A double-precision, floating-point value type.
public struct Double {

    /// Creates a value initialized to zero.
    public init()
    
public struct CGFloat {

```

#### 比较结构体和类

* 类是引用类型
* 结构体是值类型

Swift 中结构体和类有很多共同点，二者皆可：

* 定义属性以存储值
* 定义方法以提供功能
* 定义下标以提供下标语法访问其值
* 定义构造器以设置其初始化状态
* 通过扩展以增加默认实现功能
* 遵循协议以提供某种标准功能
* 每当你定义一个新的结构体或类都是定义一个全新的 Swift 类型

类又有一些结构体没有的额外功能：

* 继承让一个类可以继承另一个类的特征
* 类型转换让你在运行时可以检查和解释一个类实例
* 析构器让一个类的实例可以释放任何被其所分配的资源
* 引用计数允许对一个类实例进行多次引用
* 更多信息请参阅 继承，类型转换，析构过程 和 自动引用计数。

```swift
struct SomeStructure {
    // structure definition goes here
}
class SomeClass {
    // class definition goes here
}

struct Resolution {
    var width = 0
    var height = 0
}
class VideoMode {
    var resolution = Resolution()
    var interlaced = false
    var frameRate = 0.0
    var name: String?
}

// 结构体与类实例
// 结构体和类创建实例的语法非常相似：
let someResolution = Resolution()
let someVideoMode = VideoMode()

```

* 结构体类型的成员构造器
    * 所有结构体都有一个用于初始化结构体实例的成员属性，并且是自动生成的成员构造器。实例属性的初始化值通过属性名称传递到成员构造器中：
* 与结构体不同，类没有默认的成员构造器

```swift
let vga = Resolution(width: 640, height: 480)
```


#### 值类型的结构体和枚举

* 值类型是一种赋值给变量或常量，或传递给函数时，**值会被拷贝的**类型。
* 其实你在之前的章节中已广泛的使用了值类型。其实 Swift 中的所有基本类型 --- 整数，浮点数，布尔，字符串，数组和字典 --- 它们都是值类型，其底层也是以结构体实现的。


这个示例用了上面的 Resolution 结构体：

```swift
let hd = Resolution(width: 1920, height: 1080)
var cinema = hd
```

声明了一个名为 hd 的常量并使用全高清视频的宽高（ 1920 像素宽，1080 像素高 ）将其初始化为 Resolution 的实例。

还声明了一个名为 cinema 的变量并使用当前 hd 的值为其赋值。 **因为 Resolution 是一个结构体，所以会制作一个当前实例的副本赋值给 cinema 。虽然 hd 和 cinema 现在有同样的宽高，但是他们在底层是完全不同的两个实例**。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190814133621.png)

#### 类是引用类型

* 与值类型不同，赋值给变量或常量，或是传递给函数时，引用类型并不会拷贝。引用的不是副本而是已经存在的实例。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190814133858.png)


以上的例子还显示了引用类型推断有多费劲。如果 tenEighty 和 alsoTenEighty 在你的代码中相距甚远，那么可能很难找到改变视频模式的所有地方。无论你在哪里使用 tenEighty，都需要考虑用到 alsoTenEighty 的代码，反之亦然。相反，值类型就很好推断，因为在你的源文件中相同值相互作用的所有代码是紧密相连的。

### 恒等运算符

因为类是引用类型，在底层可能多个常量和变量引用同一个类的实例。（ 同样的理论对结构体和枚举来说并不有效，因为当它们赋值给常量或变量，或是传递给函数时，总是拷贝的。）

有时找出两个常量或变量是否引用同一个类的实例很有帮助。为此，Swift 提供了恒等运算符：

* 等价于 (===)
* 非等价 (!==)
 使用他们来检查两个常量或变量是否引用同一个实例：
 
```swift
if tenEighty === alsoTenEighty {
    print("tenEighty and alsoTenEighty refer to the same VideoMode instance.")
    }
// 打印 "tenEighty and alsoTenEighty refer to the same VideoMode instance."
```

*  == is the equality operator, test 2 things are equal, for whatever definition of “equal” ,For example, 5 == 5 is true.
*  `===` is the identity operator, which checks whether two instances of a class point to the same memory. This is different from equality, because two objects that were created independently using the same values will be considered equal using `==` but not `===` **because they are different objects**.

 [What’s the difference between == and ===? - free Swift 5.0 example code and tips](https://www.hackingwithswift.com/example-code/language/whats-the-difference-between-equalsequals-and-equalsequalsequals)


## 闭包

* 闭包是引用类型
* 闭包(Closures)是自包含的功能代码块，可以在代码中使用或者用来作为参数传值。
* 说的通俗一点，一个函数加上它捕获的变量一起，才算一个closure
* Swift 中的闭包与 C 和 Objective-C 中的代码块（blocks）以及其他一些编程语言中的 匿名函数比较相似。
* 全局函数和嵌套函数其实就是特殊的闭包。
* 闭包是函数的一种，匿名函数.

```swift
{(parameters) -> return type in
   statements
}
```

### 闭包的形式

全局函数 | 嵌套函数 | 闭包表达式
--- | --- | --- 
有名字但不能捕获任何值 | 有名字，也能捕获封闭函数内的值。 | 无名闭包，使用轻量级语法，可以根据上下文环境捕获值。

Swift中的闭包有很多优化的地方:

* 根据上下文推断参数和返回值类型
* 从单行表达式闭包中隐式返回（也就是闭包体只有一行代码，可以省略return）
* 可以使用简化参数名，如$0, $1(从0开始，表示第i个参数...)
* 提供了尾随闭包语法(Trailing closure syntax)

```swift
let divide = {(val1: Int, val2: Int) -> Int in 
   return val1 / val2 
}
let result = divide(200, 20)
print (result)
```

[Swift中闭包的简单使用 - 简书](https://www.jianshu.com/p/7c599b96815b)



### 尾随闭包

作为函数的最后一个入参的闭包。

尾随闭包是一个书写在函数括号之后的闭包表达式，函数支持将其作为最后一个参数调用。


### 闭包是引用类型


上面的例子中，incrementByTen是常量，但是这些常量指向的闭包仍然可以增加其捕获的变量值。

这是因为函数和闭包都是引用类型。

无论您将函数/闭包赋值给一个常量还是变量，您实际上都是将常量/变量的值设置为对应函数/闭包的引用。 上面的例子中，incrementByTen指向闭包的引用是一个常量，而并非闭包内容本身。

这也意味着如果您将闭包赋值给了两个不同的常量/变量，两个值都会指向同一个闭包：


### 闭包和闭包expression


* 闭包(Closures) = 函数+函数捕获的变量。

* 闭包expression = 函数


```swift

//MARK: -closure expression就是函数的一种简写形式
简单来说，closure expression就是函数的一种简写形式。例如，对于下面这个计算参数平方的函数：
func add(num1: Int , num2 : Int) -> Int{
    return  num1 * num2
}

//MARK: -  声明了方法
var addExp :(Int,Int)-> (Int) = { (a,b) -> (Int) in
    return a * b
}

```

##  Swift：细说实体访问等级

Swift 有5种不同的访问等级，等级越高表示访问受限性越小。访问等级从高到低，由关键字依次表示为：
open > public > internal > fileprivate > private。默认的访问等级是 internal
模块与源文件
Swift 中实体之间的访问是基于模块和源文件的，所以，首先了解一下 Swift 的模块与源文件：

模块 (Module)
一个模块是代码分布中一个单一的单元。比如一个能被其它模块通过 import 关键字导入的framework 或 程序
在 Xcode 中，每一个 Target 都是一个独立的模块
源文件 (Source file)
这个很好理解，就是你工程里新建的代码文件

区分访问等级

open , public
open 和 public 定义的实体可以被相同Module 中的源文件访问，也可以通过 import 其它Module ，被这些Module 的源文件访问。但 open 和 public是有区别的：
open只作用于类和类成员
除了 open，被其它4个关键字修饰的类，只能被相同 Module 中的其它类继承
除了 open，被其它4个关键字修饰的类成员，只能被相同 Module 中的子类重写
open 修饰的类，既可以被相同 Module 中的类继承，又可以被通过 import 导入的Module 中的类继承
open 修饰的类成员，既可以被相同 Module 中的子类重写，又可以被通过 import 导入的Module 中的子类重写
internal
internal 定义的实体只能被相同 Module 中的源文件访问，但不能被其它Module 的源文件访问
fileprivate
fileprivate 定义的实体只能在它被定义的源文件中使用，如果你不想让别人知道某个功能的详细实现，使用fileprivate 来修饰这个方法，那么它的实现过程将被隐藏
private
private 定义的实体，只在它被定义的大括号{}内有效

Swift 有5种不同的访问等级，等级越高表示访问受限性越小。访问等级从高到低，由关键字依次表示为：
`open` > `public` > `internal` > `fileprivate` > `private`。**默认的访问等级是 `internal`**

##### 模块与源文件

Swift 中实体之间的访问是基于模块和源文件的，所以，首先了解一下 Swift 的模块与源文件：

*   模块 (`Module`)

*   一个模块是代码分布中一个单一的单元。比如一个能被其它模块通过 `import` 关键字导入的`framework` 或 程序

*   在 Xcode 中，每一个 `Target` 都是一个独立的模块

*   源文件 (`Source file`)

*   这个很好理解，就是你工程里新建的代码文件

##### 区分访问等级

*   `open` , `public`
    `open` 和 `public` 定义的实体可以被相同`Module` 中的源文件访问，也可以通过 `import` 其它`Module` ，被这些`Module` 的源文件访问。但 `open` 和 `public`是有区别的：

*   `open`只作用于类和类成员

*   除了 `open`，被其它4个关键字修饰的类，只能被相同 `Module` 中的其它类继承

*   除了 `open`，被其它4个关键字修饰的类成员，只能被相同 `Module` 中的子类重写

*   `open` 修饰的类，既可以被相同 `Module` 中的类继承，又可以被通过 `import` 导入的`Module` 中的类继承

*   `open` 修饰的类成员，既可以被相同 `Module` 中的子类重写，又可以被通过 `import` 导入的`Module` 中的子类重写

*   `internal`
    `internal` 定义的实体只能被相同 `Module` 中的源文件访问，但不能被其它`Module` 的源文件访问

*   `fileprivate`
    `fileprivate` 定义的实体只能在它被定义的源文件中使用，如果你不想让别人知道某个功能的详细实现，使用`fileprivate` 来修饰这个方法，那么它的实现过程将被隐藏

*   `private`
    `private` 定义的实体，只在它被定义的大括号`{}`内有效

##### 子类的访问等级

子类的访问等级不能超过他的父类。但是对于里面可以重载的 **类成员**(属性，方法，构造器)，却有着独特的一面

*   被子类重载的类成员，可以拥有比在父类里更高的访问等级，如下面的两个类，类 `B` 重载了父类的 `someMethod` 方法，并且赋予了它新的更高的访问等级 `internal`

```
public class A {
      private func someMethod() {}
}
internal class B:A {
      override internal func someMethod() {}
}

```

*   子类成员可以调用父类成员，并且这个父类成员比这个子类成员的访问等级低。这个父类成员需要符合两条原则：父类和子类定义在**相同的源文件**中，对于**父类的`private`成员**；父类和子类定义在**相同的`Module`** 中，对于**父类的 `internal` 成员**

```
//两个类在相同的源文件中
public class A {
      private func someMethod() {}
}
internal class B:A {
      override internal func someMethod() {
         super.someMethod()
      }
}

```

##### Getter 与 Setter

`getter` 与 `setter` 默认和原属性访问等级相同，但是Swift 允许我们给 `setter` 设置比原属性低的访问等级，这样可以起到有效的 **读写保护**。语法是，在 `var`前写上`fileprivate(set)`, `private(set)` 或 `internal(set)`（`set` 可以换成 `get`）

```
struct TrackedString {
    private(set) var numberOfEdits = 0 //记录 value 被修改的次数
    var value: String = "" {
        didSet {
           numberOfEdits += 1          //每次 value 被修改之后，numberOfEdits 都会自动加1
        }
    }
}

```

上面的函数中，我们单独设置了变量 `numberOfEdits` 的`setter`为 `private`，而 `getter` 的访问等级依然是 `internal` （注意：`internal` 可以显式的写在`private(set)` 前）。这样，在外部 `numberOfEdits` 呈现出了 `read-only` 的属性而不能被修改，因为它只能在被定义的大括号`{}` 区域内被修改。

```
var stringToEdit = TrackedString()
stringToEdit.value = "Value changed once"
stringToEdit.value = "Value changed twice"
stringToEdit.value = "Value changed three times"
print("The number of edits is \(stringToEdit.numberOfEdits)") // 打印出 "The number of edits is 3"

```

##### 枚举的访问等级

如果一个枚举的访问等级为 `public`(或其它)，那么它的`case` 会自动接收相同的 `public`(或其它) 访问等级。并且你不能给 `case` 指定访问等级，它只能随从它所属的枚举。

##### 嵌套类型的访问等级

嵌套类型的访问等级，基本呈现出逐层降低的现象

*   在 `private` 类型里定义的嵌套，自动为 `private`
*   在 `fileprivate`类型里定义的嵌套，自动为 `private`
*   在 `public` 或 `internal`类型里定义的嵌套，自动为 `internal`。另外，如果你想把一个在 `public` 里定义的嵌套变为公有的，那么你需要显示声明这个嵌套为 `public`

##### 元组的访问等级

元组类型的访问等级比较严格，如果它由两个不同类型组成，一个是 `private` ,一个是`internal`，那么它们组合成的元组类型的访问等级将是 `private`

##### 定义访问等级的原则

定义一个实体时，这个实体的访问等级，不能高于它所参照的实体的访问等级 :

*   一个公共变量，不能被定义为`internal`, `fileprivate` 或 `private`类型，因为在这个公共变量使用的地方，这些类型并不一定都是有效的
*   一个函数的访问等级，不能高于它的参数类型和返回类型的访问等级，比如下面的函数，分析一下，该用哪种访问等级 ？

```
func someFunction() -> (SomeInternalClass, SomePrivateClass) {
    // function implementation goes here
}

```

可以看到，它的返回类型是个元组类型，这个元组类型最终的访问等级将是`private`(至于为什么会是`private` 请参考上面的**元组的访问等级**)。根据原则，这个函数要使用 `private` 修饰。

```swift
private func someFunction() -> (SomeInternalClass, SomePrivateClass) {
    // function implementation goes here
}
```
 
### Key Considerations

*   Files are organized in the following order:
    *   Default header created by Xcode
    *   Import statements
    *   Delegate protocols that are associated only with the major type declaration of the file
    *   The major type declaration of the file
    *   Inner type declarations
    *   Properties
        *   Inherited
        *   Protocol
        *   `IBOutlet`s
        *   Open
        *   Public
        *   Internal
        *   Private
    *   Functions
        *   Inherited
        *   Protocol
        *   Open
        *   Public
        *   Internal
        *   Private
    *   Extension Protocol Conformances


## 参考

* [把“The Swift Programming Language”读薄 - Hawstein的博客](http://hawstein.com/2014/07/01/make-thiner-tspl/#Inheritance)
* [构造过程 |《Swift 编程语言》| iOS 开发者论坛](https://learnku.com/docs/the-swift-programming-language/4.2/Initialization/3535)
* [swift-best-practices/OrganizationWithinAFile.md at master · Lickability/swift-best-practices](https://github.com/Lickability/swift-best-practices/blob/master/OrganizationWithinAFile.md)