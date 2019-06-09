## Introducing Swift

8. 类（class）和结构体（struct）有什么区别？
Swift 中，类是引用类型，结构体是值类型。值类型在传递和赋值时将进行复制，而引用类型则只会使用引用对象的一个"指向"。所以他们两者之间的区别就是两个类型的区别。

举个简单的例子，代码如下


```swift
class Temperature {
  var value: Float = 37.0
}

class Person {
  var temp: Temperature?

  func sick() {
    temp?.value = 41.0
  }
}

let A = Person()
let B = Person()
let temp = Temperature()

A.temp = temp
B.temp = temp

A.sick()

```
上面这段代码，由于 Temperature 是 class ，为引用类型，故 A 的 temp 和 B 的 temp指向同一个对象。A 的 temp修改了，B 的 temp 也随之修改。这样 A 和 B 的 temp 的值都被改成了41.0。如果将 Temperature 改为 struct，为值类型，则 A 的 temp 修改不影响 B 的 temp。

内存中，引用类型诸如类是在堆（heap）上，而值类型诸如结构体实在栈（stack）上进行存储和操作。相比于栈上的操作，堆上的操作更加复杂耗时，所以苹果官方推荐使用结构体，这样可以提高 App 运行的效率。

class有这几个功能struct没有的：

class可以继承，这样子类可以使用父类的特性和方法
类型转换可以在runtime的时候检查和解释一个实例的类型
可以用deinit来释放资源
一个类可以被多次引用
struct也有这样几个优势：

结构较小，适用于复制操作，相比于一个class的实例被多次引用更加安全。
无须担心内存memory leak或者多线程冲突问题



##  字典

* Swift 字典用来存储无序的**相同类型**数据的集合，Swift 字典会强制检测元素的类型，如果类型不同则会报错。
* Swift 字典每个值（value）都关联唯一的键（key），键作为字典中的这个值数据的标识符。
* 和数组中的数据项不同，字典中的数据项并没有具体顺序。我们在需要通过标识符（键）访问数据的时候使用字典，这种方法很大程度上和我们在现实世界中使用字典查字义的方法一样。
* Swift 字典的key没有类型限制可以是整型或字符串，但必须是唯一的。
* 如果创建一个字典，并赋值给一个变量，则创建的字典就是可以修改的。这意味着在创建字典后，可以通过添加、删除、修改的方式改变字典里的项目。如果将一个字典赋值给常量，字典就不可修改，并且字典的大小和内容都不可以修改。


* Swift取消了Objective C的指针及其他不安全访问的使用
* 舍弃Objective C早期应用Smalltalk的语法，全面改为句点表示法提供了
* 类似Java的名字空间(namespace)、泛型(generic)、运算对象重载
* (operator overloading) Swift 被简单的形容为“没有C的Objective-
* C”(Objective-C without theC)为苹果开发工具带来了Xcode .
* Playgrounds功能，该功能提供强大的互动效果，能让Swift源代码在撰写
* 过程中实时显示出其运行结果;
* 基于C和Objective-C，而却没有C的一些兼容约束;
* 采用了安全的编程模式;
* 界面基于Cocoa和Cocoa Touch框架;
* 保留了Smalltalk的动态特性

## 参考

1. [集合类型 - Swift编程语言（Swift 5）](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html)
2. []()