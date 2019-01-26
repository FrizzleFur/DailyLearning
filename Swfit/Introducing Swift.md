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


