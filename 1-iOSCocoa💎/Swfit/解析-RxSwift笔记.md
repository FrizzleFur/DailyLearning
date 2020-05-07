
## 1、创建事件序列 - 向订阅者发送新产生的事件信息
create : 通过传入的元素来创建可观测序列

```swift
///通过传入的元素来创建可观测序列
let myJust = { (element: String) -> Observable<String> in
      return Observable.create { observer in
          observer.on(.next(element))
          observer.on(.completed)
          return Disposables.create()
      }
  }
/// 创建一个包含 🔴 的可观测序列
let newObserver = myJust("🔴")
/// 订阅观测序列
newObserver.subscribe { print($0) }.disposed(by: disposeBag)
```

never : 创建一个序列，不会终止也不会发出任何事件。

```swift
/// 创建一个永远不会执行的序列
Observable<String>.never().subscribe { _ in
          print("This will never be printed")
  }
```empty : 创建一个空的序列，只会发出一个完成事件。

```swift
/// 创建一个销毁包
let disposeBag = DisposeBag()
/// 创建一个空的可观测序列
let emptyObservable = Observable<Any>.empty()
/// 订阅空的观察者
emptyObservable.subscribe { event in
print("empty")
}.disposed(by: disposeBag)
```

just : 创建一个单个元素的序列。

```swift
/// 创建单个元素/事件的可观测序列
Observable.just("🔴")
.subscribe { event in
print(event)
}
.disposed(by: disposeBag)
/// 打印结果：🔴
```

of : 使用固定数量的元素创建一个序列。

```swift
/// 创建包含多个元素的可观测序列
Observable.of("🐶", "🐱", "🐭", "🐹")
      .subscribe(onNext: { element in
          print(element)
      })
      .disposed(by: disposeBag)
/// 打印结果：
🐶
🐱
🐭
🐹

```
from : 从一个序列创建一个可被观察的序列。

```swift
/// 创建包含一个集合的可观测序列，集合可以是Array，Dictionary，Set
Observable.from(["🐶", "🐱", "🐭", "🐹"])
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
/// 打印结果：
🐶
🐱
🐭
🐹
```

range : 创建一个发出一系列顺序整数然后终止的序列。

```swift
/// 创建一个序列，发送范围内integer类型数据
Observable.range(start: 1, count: 10)
      .subscribe { print($0) }
      .disposed(by: disposeBag)
```

error : 创建一个没有元素并以错误终止的序列。

```swift
/// 创建一个序列，没有事件，而是error，且立即停止执行
Observable<Int>.error(TestError.test)
      .subscribe { print($0) }
      .disposed(by: disposeBag)

```

generate : 创建一个满足指定条件的序列。

```swift
/// 创建一个序列，当给出的条件为真时，会一直发送信号
Observable.generate(
          initialState: 0,
          condition: { $0 < 3 },
          iterate: { $0 + 1 }
      )
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)

```
deferred : 只有当有订阅者订阅的时候才会去创建序列。

```swift
/// 创建一个序列，为每一个订阅者都提供一个新的序列，为了保证订阅者拿到的是最新的数据时，可以使用此方法
var count = 1

  let deferredSequence = Observable<String>.deferred {
      print("Creating \(count)")
      count += 1

      return Observable.create { observer in
          print("Emitting...")
          observer.onNext("🐶")
          observer.onNext("🐱")
          observer.onNext("🐵")
          return Disposables.create()
      }
  }

  deferredSequence
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)

  deferredSequence
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
```

repeatElement : 创建一个给予元素的无限序列。

```swift
/// 创建一个序列，发送已给定的元素，take的参数表示repead的次数
Observable.repeatElement("🔴")
      .take(3)
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
```

interval : 创建一个可以连续发送信号的Observable，参数一为时间间隔

## 2、Subject - 相当于一个桥梁或者代理，它既可以作为一个observer也可以作为一个Observable。
PublishSubject : PublishSubject只会发送给订阅者订阅之后的事件，之前发生的事件将不会发送。

```swift
/// method 1
/// 创建销毁包
let disposeBag = DisposeBag()
/// 创建subject
let subject = PublishSubject<String>()
/// 实现订阅,下面订阅方法二选一，订阅需要在发送信号之前实现，对应MVVM中一个思路：在拿到数据之前就要实现拿到数据之后的操作
subject.addObserver("1").disposed(by: disposeBag) // 上文中封装的订阅
subject.subscribe { print($0) }.disposed(by: disposeBag) // 原生订阅方法
/// 发送事件🐶
subject.onNext("🐶")
/// 发送事件🐱
subject.onNext("🐱")
/// 打印结果
--- PublishSubject example ---
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
```

ReplaySubject : 不管订阅者什么时候订阅的都可以把所有发生过的事件发送给订阅者。

```swift
let disposeBag = DisposeBag()
let subject = ReplaySubject<String>.create(bufferSize: 2)
/// 订阅者1
subject.addObserver("1").disposed(by: disposeBag)
subject.onNext("lol")
subject.onNext("🐶")
subject.onNext("🐱")
/// 订阅者2  
subject.addObserver("2").disposed(by: disposeBag)
subject.onNext("🅰️")
subject.onNext("🅱️")
/// 打印结果
--- ReplaySubject example ---
Subscription: 1 Event: next(lol)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐶)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
```

BehaviorSubject : 广播所有事件给订阅者，对于新的订阅者，广播最近的一个事件或者默认值。

```swift
let disposeBag = DisposeBag()
let subject = BehaviorSubject(value: "🔴")
/// 第一个订阅者
subject.addObserver("1").disposed(by: disposeBag) subject.onNext("🐶")
subject.onNext("🐱")
/// 第二个订阅者
subject.addObserver("2").disposed(by: disposeBag)
subject.onNext("🅰️")
subject.onNext("🅱️")
/// 第三个订阅者
subject.addObserver("3").disposed(by: disposeBag)
subject.onNext("🍐")
subject.onNext("🍊")
/// 打印结果
--- BehaviorSubject example ---
Subscription: 1 Event: next(🔴)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
Subscription: 3 Event: next(🅱️)
Subscription: 1 Event: next(🍐)
Subscription: 2 Event: next(🍐)
Subscription: 3 Event: next(🍐)
Subscription: 1 Event: next(🍊)
Subscription: 2 Event: next(🍊)
Subscription: 3 Event: next(🍊)
```

Variable （已弃用） 是早期添加到 RxSwift 的概念，通过 “setting” 和 “getting”， 他可以帮助我们从原先命令式的思维方式，过渡到响应式的思维方式。

但这只是我们一厢情愿的想法。许多开发者滥用 Variable，来构建 重度命令式 系统，而不是 Rx 的 声明式 系统。这对于新手很常见，并且他们无法意识到，这是代码的坏味道。所以在 RxSwift 4.x 中 Variable 被轻度弃用，仅仅给出一个运行时警告。

在 RxSwift 5.x 中，他被官方的正式的弃用了，并且在需要时，推荐使用 BehaviorRelay 或者 BehaviorSubject。

BehaviorSubject
当观察者对 BehaviorSubject 进行订阅时，它会将源 Observable 中最新的元素发送出来（如果不存在最新的元素，就发出默认元素）。然后将随后产生的元素发送出来。
如果源 Observable 因为产生了一个 error 事件而中止， BehaviorSubject 就不会发出任何元素，而是将这个 error 事件发送出来。


```swift
let disposeBag = DisposeBag()
let subject = BehaviorSubject(value: "🔴")

subject
  .subscribe { print("Subscription: 1 Event:", $0) }
  .disposed(by: disposeBag)

subject.onNext("🐶")
subject.onNext("🐱")

subject
  .subscribe { print("Subscription: 2 Event:", $0) }
  .disposed(by: disposeBag)

subject.onNext("🅰️")
subject.onNext("🅱️")

subject
  .subscribe { print("Subscription: 3 Event:", $0) }
  .disposed(by: disposeBag)

subject.onNext("🍐")
subject.onNext("🍊")
输出结果：

Subscription: 1 Event: next(🔴)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
Subscription: 3 Event: next(🅱️)
Subscription: 1 Event: next(🍐)
Subscription: 2 Event: next(🍐)
Subscription: 3 Event: next(🍐)
Subscription: 1 Event: next(🍊)
Subscription: 2 Event: next(🍊)
Subscription: 3 Event: next(🍊)
```

### RxRelay
RxRelay 既是 可监听序列 也是 观察者。

**他和 Subjects 相似，唯一的区别是不会接受 onError 或 onCompleted 这样的终止事件。**

在将非 Rx 样式的 API 转化为 Rx 样式时，Subjects 是非常好用的。不过一旦 Subjects 接收到了终止事件 onError 或 onCompleted。他就无法继续工作了，也不会转发后续任何事件。有些时候这是合理的，但在多数场景中这并不符合我们的预期。

在这些场景中一个更严谨的做法就是，**创造一种特殊的 Subjects，这种 Subjects 不会接受终止事件**。有了他，我们将 API 转化为 Rx 样式时，就不必担心一个意外的终止事件，导致后续事件转发失效。

我们将这种特殊的 Subjects 称作 RxRelay：

#### PublishRelay

PublishRelay 就是 PublishSubject 去掉终止事件 onError 或 onCompleted。

```swift
let disposeBag = DisposeBag()
let relay = PublishRelay<String>()

relay
    .subscribe { print("Event:", $0) }
    .disposed(by: disposeBag)

relay.accept("🐶")
relay.accept("🐱")
输出结果：

Event: next(🐶)
Event: next(🐱)
```

#### BehaviorRelay
BehaviorRelay 就是 BehaviorSubject 去掉终止事件 onError 或 onCompleted。

```swift
let disposeBag = DisposeBag()
let relay = BehaviorRelay(value: "🔴")

relay
    .subscribe { print("Event:", $0) }
    .disposed(by: disposeBag)

relay.accept("🐶")
relay.accept("🐱")
输出结果：

Event: next(🔴)
Event: next(🐶)
Event: next(🐱)
```

BehaviorRelay 将取代 Variable，因为 Variable 很容易会引导我们使用命令式编程，而不是声明式编程。

## Rx 操作符

3、合并操作 - 合并多个序列或者值成单个序列。

startWith : 在序列触发值之前插入一个多个元素的特殊序列。

```swift
/// 我们用subject来玩这个功能
let disposeBag = DisposeBag()
let subject = PublishSubject<String>()
/// 订阅信号之前先接收到first信号
subject.startWith("first")
  .subscribe { (event) in
      print(event.element!)
      }.disposed(by: disposeBag)
subject.onNext("test one")
subject.onNext("test two")
/// 还可以这样用,在订阅之前需要进行多组操，注意這里要逆序写！
subject.startWith("third")
      .startWith("second")
      .startWith("first")
      .subscribe { (event) in
      print(event.element!)
      }.disposed(by: disposeBag)
/// 打印结果
first
second
third
test one
test two
```
merge : 把多个序列合并成单个序列，并按照事件触发的先后顺序，依次发射值。当其中某个序列发生了错误就会立即把错误发送到合并的序列并终止。


```swift
let disposeBag = DisposeBag()
/// 创建两个subject
let subject1 = PublishSubject<String>()
let subject2 = PublishSubject<String>()
/// 将两个subject进行融合
let mergeSubject = Observable.of(subject1, subject2).merge()
mergeSubject.subscribe({ (event) in
      print(event.element!)
  }).disposed(by: disposeBag)
/// 发送事件
subject1.onNext("one")
subject2.onNext("two")
/// 打印结果
one
two

```
zip : 把多个序列组合成到一起并触发一个值，但只有每一个序列都发射了一个值之后才会组合成一个新的值并发出来。

```swift
let disposeBag = DisposeBag()
/// 创建两个被绑定subject
let stringSubject = PublishSubject<String>()
let intSubject = PublishSubject<Int>()
/// 创建绑定subject
let zipSubject = Observable.zip(stringSubject, intSubject)
  zipSubject.subscribe({ (event) in
  print(event.element!)
  }).disposed(by: disposeBag)
/// 发送事件
stringSubject.onNext("️hello")
stringSubject.onNext("️hi")
intSubject.onNext(1)
intSubject.onNext(2)
stringSubject.onNext("U")
intSubject.onNext(3)
/// 打印结果
("hello", 1)
("hi", 2)
("U", 3)
```

combineLatest : 获取两个序列的最新值，并通过某个函数对其进行处理，处理完之后返回一个新的发射值。

```swift
let disposeBag = DisposeBag()
/// 创建subjects
let stringSubject = PublishSubject<String>()
let intSubject = PublishSubject<Int>()
/// 进行组合
let combineSubject = Observable.combineLatest(stringSubject, intSubject)
/// 订阅
combineSubject.subscribe({ (event) in
      print(event.element?.0, event.element?.1)
}).disposed(by: disposeBag)
/// 发送事件
stringSubject.onNext("️Sun")
stringSubject.onNext("️Moon")
intSubject.onNext(1)
intSubject.onNext(2)
stringSubject.onNext("sunday")
/// 打印结果
Optional("Sun") Optional(1)
Optional("Moon") Optional(2)
Optional("sunday") Optional(2)
```

switchLatest : 这个也是用来合并序列的，不过不同的是，每当一个新的序列发射时，原来序列将被丢弃。


```swift
let disposeBag = DisposeBag()
let subject1 = BehaviorSubject(value: "sub1")
let subject2 = BehaviorSubject(value: "sub2")
/// 
let variable = Variable(subject1)      
variable.asObservable()
      .switchLatest()
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
subject1.onNext("66")
subject2.onNext("333")  
/// 
variable.value = subject2 
subject1.onNext("mei")
subject2.onNext("mu")
/// 打印结果
sub1
66
333
mie
/// 当variable的value发生更改时，可以拿到该subject最近一次所发送的事件，如果subject2 不发送“333”事件，那么订阅者拿到的事件就是sub2
```
sample : 当收到目标事件，就会从源序列取一个最新的事件，发送到序列，如果两次目标事件之间没有源序列的事件，则不发射值。

```swift
let source = PublishSubject<Int>()
let target = PublishSubject<String>()
let subscription = source
    .sample(target)
    .subscribe { event in
        print(event)
}
source.onNext(1)
target.onNext("A")  //获取最新的source
source.onNext(2)
source.onNext(3)
target.onNext("B")  //获取最新的source
target.onNext("C")  //没有最新的source，不发射
output:
next(1)
next(3)
```

4、转换操作 - 对当前序列的值进行转换发射一个新的序列。
map : 和Swift里面的map类似，转换其中的每一个元素。


```swift
let disposeBag = DisposeBag()
let mapSubject = PublishSubject<Int>()

  mapSubject.map({ (num) -> Int in
      return num * num
  }).subscribe({ (event) in
      print(event.element!)
  }).disposed(by: disposeBag)
  mapSubject.onNext(2)
```

faltMap : 把当前序列的元素转换成一个新的序列，并把他们合并成一个序列，这个在我们的一个可被观察者序列本身又会触发一个序列的时候非常有用，比如发送一个新的网络请求。


```swift
let disposeBag = DisposeBag()

  struct Player {
      var score: Variable<Int>
  }

  let boy = Player(score: Variable(80))
  let girl = Player(score: Variable(90))

  let player = Variable(boy)

  player.asObservable()
      .flatMap { $0.score.asObservable() } // Change flatMap to flatMapLatest and observe change in printed output
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)

  boy.score.value = 85

  player.value = girl

  boy.score.value = 95 // Will be printed when using flatMap, but will not be printed when using flatMapLatest
  girl.score.value = 100
/// 打印结果
80
85
90
95
100
```
flatMapLatest : 和faltMap不同的是，flatMapLatest在收到一个新的序列的时候，会丢弃原有的序列。flatMapLatest相当于map和switchLatest操作的组合。

scan : 和Swift里面的reduce类似，给予一个初始值，依次对每个元素进行操作，最后返回操作的结果。


```swift
let subject = PublishSubject<Int>()
  /// 参数2 是aggregateValue的初始值，newValue为接收到是事件，当操作完成后，返回的值成为aggregateValue
  subject.scan(2, accumulator: { (aggregateValue, newValue) -> Int in
      return aggregateValue * newValue
  }).subscribe({ (event) in
      print(event.element ?? 0)
  }).disposed(by: disposeBag)

  subject.onNext(1)
  subject.onNext(2)
  subject.onNext(3)
/// 打印结果
2
4
132
```

5、过滤和条件操作
filter : 和Swift里面的filter类似，用来过滤序列中指定条件的值。


```swift
let disposeBag = DisposeBag()
  Observable.of(
      "🐱", "🐰", "🐶",
      "🐸", "🐱", "🐰",
      "🐹", "🐸", "🐱")
      .filter {
          $0 == "🐱"
      }
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
/// 打印结果
🐱
🐱
🐱
```

distinctUntilChanged : 过滤掉连续发射的重复元素。

```swift
let disposeBag = DisposeBag()

  Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐱")
      .distinctUntilChanged()
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
/// 打印结果
🐱
🐷
🐱
🐵
🐱
```

elementAt : 只发送指定位置的值。

```swift
let disposeBag = DisposeBag()

  Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
      .elementAt(3)
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
/// 打印结果
🐸
```

single : 发送单个元素，或者满足条件的第一个元素，如果有多个元素或者没有元素都会抛出错误。

```swift
/// 不带条件的single，返回接收到的第一个事件
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
      .single()
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
      
output:
🐱
```
take : 获取序列前多少个值。


```swift
let disposeBag = DisposeBag()
    
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .take(3)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
}
output:
🐱
🐰
🐶
```

takeLast : 获取序列后多少个值。

```swift
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
      .takeLast(3)
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
      
output:
🐸
🐷
🐵
```

takeWhile : 发射值值到条件变成false，**变成false后，后面满足条件的值也不会发射**。


```swift
let disposeBag = DisposeBag()
    
Observable.of(1, 2, 3, 4, 5, 6)
    .takeWhile { $0 < 4 }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
output:
1
2
3
```

takeUntil : 发射原序列，直到新的序列发射了一个值。

```swift
let disposeBag = DisposeBag()
    
let sourceSequence = PublishSubject<String>()
let referenceSequence = PublishSubject<String>()
sourceSequence
    .takeUntil(referenceSequence)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
sourceSequence.onNext("🐱")
sourceSequence.onNext("🐰")
sourceSequence.onNext("🐶")
referenceSequence.onNext("🔴")
sourceSequence.onNext("🐸")
sourceSequence.onNext("🐷")
sourceSequence.onNext("🐵")
output:
next(🐱)
next(🐰)
next(🐶)
completed
```

skip : 跳过开头指定个数的值。


```swift
let disposeBag = DisposeBag()
    
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .skip(2)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
output:
🐶
🐸
🐷
🐵
```

skipWhile : 跳过满足条件的值到条件变成false，变成false后，后面满足条件的值也不会跳过。


```swift
let disposeBag = DisposeBag()
    
Observable.of(1, 2, 3, 4, 5, 6)
    .skipWhile { $0 < 4 }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
output:
4
5
6
```

skipWhileWithIndex : 和skipWhile类似，只不过带上了index。
let disposeBag = DisposeBag()
    

```swift
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .skipWhileWithIndex { element, index in
        index < 3
    }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
output:
🐸
🐷
🐵
```

skipUntil : 和takeUntil相反，跳过原序列，直到新序列发射了一个值。


```swift
let disposeBag = DisposeBag()
    
let sourceSequence = PublishSubject<String>()
let referenceSequence = PublishSubject<String>()
sourceSequence
    .skipUntil(referenceSequence)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
sourceSequence.onNext("🐱")
sourceSequence.onNext("🐰")
sourceSequence.onNext("🐶")
referenceSequence.onNext("🔴")
sourceSequence.onNext("🐸")
sourceSequence.onNext("🐷")
sourceSequence.onNext("🐵")
output:
🐸
🐷
🐵
```

6、聚合操作

toArray : 把一个序列转成一个数组，然后作为新的一个值发射。

```swift
let disposeBag = DisposeBag()
Observable.range(start: 1, count: 10)
    .toArray()
    .subscribe { print($0) }
    .disposed(by: disposeBag)
output:
next([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
completed
```

reduce : 给一个初始值，然后和序列里的每个值进行运行，最后返回一个结果，然后把结果作为单个值发射出去。

```swift
let disposeBag = DisposeBag()
    
Observable.of(10, 100, 1000)
    .reduce(1, accumulator: +)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
output:
1111
```

concat : 串联多个序列，下一个序列必须等前一个序列完成才会发射出来。

```swift
let disposeBag = DisposeBag()
    
let subject1 = BehaviorSubject(value: "🍎")
let subject2 = BehaviorSubject(value: "🐶")
let variable = Variable(subject1)
variable.asObservable()
    .concat()
    .subscribe { print($0) }
    .disposed(by: disposeBag)
subject1.onNext("🍐")
subject1.onNext("🍊")
variable.value = subject2
subject2.onNext("I would be ignored")
subject2.onNext("🐱")
subject1.onCompleted()
subject2.onNext("🐭")
output:
next(🍎)
next(🍐)
next(🍊)
next(🐱)
next(🐭)
```

7、连接操作 - 可连接的序列和一般序列没有不同，除了只有当调用connect()之后才会开始发射值，通过这种方式，你可以等所有的订阅者订阅后才发射值。
publish : 把一个序列转成一个可连接的序列。

```swift
/// 创建可同步序列，需要注意的是，可同步序列必须完成connect()操作订阅者才能够执行订阅操作
let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
      .publish()
/// 订阅事件1，但是不会执行
intSequence
      .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
/// 对观测序列进行connect操作，在实际情况中应该在序列初始化时进行此操作，这里为了查看测试效果，延时2s建立联系
delay(2) { _ = intSequence.connect() }
/// 4s后订阅事件2
delay(4) {
      intSequence
          .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
  }
/// 6s后订阅事件3
delay(6) {
      intSequence
          .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
  }
/// 打印结果
// 2s间隔,订阅1和2接收事件
Subscription 1:, Event: 0
Subscription 1:, Event: 1
Subscription 2:, Event: 1
Subscription 1:, Event: 2
Subscription 2:, Event: 2
// 6s后
Subscription 1:, Event: 3
Subscription 2:, Event: 3
Subscription 3:, Event: 3
Subscription 1:, Event: 4
Subscription 2:, Event: 4
Subscription 3:, Event: 4
```

replay : 把源序列转换可连接的序列，并会给新的订阅者发送之前bufferSize个的值。

```swift
let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
      .replay(5)
/// 订阅1  
_ = intSequence
      .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
/// 延时2s进行连接
delay(2) { _ = intSequence.connect() }
/// 延时4s订阅2
delay(4) {
      _ = intSequence
          .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
  }
/// 延时8s订阅3
delay(8) {
      _ = intSequence
          .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
  }
///打印结果
// 2s间隔，订阅1和2同时接收事件
Subscription 1:, Event: 0
Subscription 2:, Event: 0
Subscription 1:, Event: 1
Subscription 2:, Event: 1
Subscription 1:, Event: 2
Subscription 2:, Event: 2
Subscription 1:, Event: 3
Subscription 2:, Event: 3
Subscription 1:, Event: 4
Subscription 2:, Event: 4
// 8s后订阅3接收所有事件，与订阅1，2同步
Subscription 3:, Event: 0
Subscription 3:, Event: 1
Subscription 3:, Event: 2
Subscription 3:, Event: 3
Subscription 3:, Event: 4
Subscription 1:, Event: 5
Subscription 2:, Event: 5
Subscription 3:, Event: 5
Subscription 1:, Event: 6
Subscription 2:, Event: 6
Subscription 3:, Event: 6
...
```

multicast : 传入一个Subject，每当序列发射都会触发这个Subject的发射。

```swift
let subject = PublishSubject<Int>()
/// 订阅subject 
_ = subject
      .subscribe(onNext: { print("Subject: \($0)") })
/// 序列转换 
let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
      .multicast(subject)
/// 订阅1   
_ = intSequence
      .subscribe(onNext: { print("\tSubscription 1:, Event: \($0)") })
/// connect
delay(2) { _ = intSequence.connect() }
/// 订阅2  
delay(4) {
      _ = intSequence
          .subscribe(onNext: { print("\tSubscription 2:, Event: \($0)") })
  }
/// 订阅3    
delay(6) {
      _ = intSequence
          .subscribe(onNext: { print("\tSubscription 3:, Event: \($0)") })
  }
/// 打印结果
Subject: 0
  Subscription 1:, Event: 0
Subject: 1
  Subscription 1:, Event: 1
  Subscription 2:, Event: 1
Subject: 2
  Subscription 1:, Event: 2
  Subscription 2:, Event: 2
Subject: 3
  Subscription 1:, Event: 3
  Subscription 2:, Event: 3
  Subscription 3:, Event: 3
Subject: 4
  Subscription 1:, Event: 4
  Subscription 2:, Event: 4
  Subscription 3:, Event: 4
...
```

8、错误操作
catchErrorJustReturn : 捕获到错误的时候，返回指定的值，然后终止。

```swift
let disposeBag = DisposeBag()
let sequenceThatFails = PublishSubject<String>()
/// 捕捉到错误后返回😊，执行onCompleted，销毁sequenceThatFails
sequenceThatFails
  .catchErrorJustReturn("😊")
  .subscribe { print($0) }
  .disposed(by: disposeBag)
sequenceThatFails.onNext("😬")
sequenceThatFails.onNext("😨")
/// 模拟发生错误
sequenceThatFails.onError(TestError.test)
/// 打印结果
next(😬)
next(😨)
next(😊)
completed
```

catchError : 捕获一个错误值，然后切换到新的序列。

```swift
let disposeBag = DisposeBag()
/// 创建两个subject
let sequenceThatFails = PublishSubject<String>()
let recoverySequence = PublishSubject<String>()
/// shit happend! 捕捉到error时，返回recoverySequence，sequenceThatFails发送complete，销毁sequenceThatFails。
sequenceThatFails
  .catchError {
      print("Error:", $0)
      return recoverySequence
  }
  .subscribe { print($0) }
  .disposed(by: disposeBag)
sequenceThatFails.onNext("😬")
sequenceThatFails.onNext("😨")
sequenceThatFails.onError(TestError.test)
recoverySequence.onNext("😊")
/// 打印结果
next(😬)
next(😨)
Error: test
next(😊)
```

retry : 捕获到错误的时候，重新订阅该序列。retry(_:) 表示最多重试多少次。 retry(3)

```swift
let disposeBag = DisposeBag()
var count = 1
let sequenceThatErrors = Observable<String>.create { observer in
  observer.onNext("🍎")
  observer.onNext("🍐")
/// 模拟发生错误  
  if count == 1 {
      observer.onError(TestError.test)
      print("Error encountered")
      count += 1
  }
  observer.onNext("🐶")
  observer.onNext("🐱")
  observer.onCompleted()
  return Disposables.create()
}
sequenceThatErrors
  .retry()
  .subscribe(onNext: { print($0) })
  .disposed(by: disposeBag)
```
9、调试操作
debug : 打印所有的订阅者、事件、和处理。

```swift
let disposeBag = DisposeBag()
var count = 1
let sequenceThatErrors = Observable<String>.create { observer in
  observer.onNext("🍎")
  observer.onNext("🍐")
  observer.onNext("🍊")
  if count < 5 {
      observer.onError(TestError.test)
      print("Error encountered")
      count += 1
  }
  observer.onNext("🐶")
  observer.onNext("🐱")
  observer.onNext("🐭")
  observer.onCompleted()
  return Disposables.create()
}
sequenceThatErrors
  .retry(3)
  .debug()
  .subscribe(onNext: { print($0) })
  .disposed(by: disposeBag)
```

RxSwift.Resources.total : 提供所有Rx申请资源的数量，似于引用计数，在检查内存泄露的时候非常有用。
print(RxSwift.Resources.total)
    

```swift
let disposeBag = DisposeBag()
print(RxSwift.Resources.total)
let variable = Variable("🍎")
let subscription1 = variable.asObservable().subscribe(onNext: { print($0) })
print(RxSwift.Resources.total)
let subscription2 = variable.asObservable().subscribe(onNext: { print($0) })
print(RxSwift.Resources.total)
subscription1.dispose()
print(RxSwift.Resources.total)
subscription2.dispose()
print(RxSwift.Resources.total)
output:
0
2
🍎
8
🍎
10
9
8
```

# Rx 系列库

* [RxAppState](https://github.com/pixeldock/RxAppState): 扩展UIApplicationDelegate方法来观察应用程序状态的变化

* [Reactant](https://github.com/Brightify/Reactant) Reactant is a reactive architecture for iOS

* [RxAlamofire](https://github.com/RxSwiftCommunity/RxAlamofire) 使用RxSwift对Alamofire的进行包装

* [ReactorKit](https://github.com/ReactorKit/ReactorKit) 单向数据流架构

* [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) 对 UITableView 和 UICollectionView 进行响应式扩展

* [RxViewController](https://github.com/devxoul/RxViewController) 对UIViewController和NSViewController的响应式包装

* [ReusableKit](https://github.com/devxoul/ReusableKit) 提供了一些API来管理可重用单元格和视图的生命周期

* [RxFeedback](https://github.com/devxoul/RxFeedback) RxSwift架构

* [RxShortcuts](https://github.com/sunshinejr/RxShortcuts) Shortcuts for RxSwift & RxCocoa.

* [NSObject-Rx](https://github.com/RxSwiftCommunity/NSObject-Rx) Handy RxSwift extensions on NSObject, including rx_disposeBag.

* RxAutomaton RxSwift + State Machine

* RxOptional RxSwift extensions for Swift optionals and "Occupiable" types

* RxPermission RxSwift bindings for Permissions API in iOS.

* RxSwiftExt Additional operators not found in the core RxSwift distribution

* RxKeyboard Reactive Keyboard in iOS

* RxGesture RxSwift reactive wrapper for view gestures

* Action Abstracts actions to be performed in RxSwift.

* RxIGListKit IGListKit with RxSwift🚀

* RxWebKit RxWebKit is a RxSwift wrapper for WebKit

* RxExpect RxSwift测试框架

* RxNimble Nimble extensions that making unit testing with RxSwift easier 🎉


# Ref

* [](https://github.com/jhw-dev/RxSwift-CN)