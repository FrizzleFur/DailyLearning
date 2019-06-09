//
//  RxPractice.swift
//  SwiftLearningDemo
//
//  Created by MichaelMao on 2019/6/9.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class RxPractice: UIViewController {
   
    private lazy var disposebag: DisposeBag = DisposeBag()
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var lb1: UILabel!
    @IBOutlet weak var lb2: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
    
        // 1. test for RxCocoa
        testRxCocoa()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("touchesBegan called")

        // 2. test for observable
//        testObservable()
        // 3. test for subject
//        testSubject()
        // 4. test for operation
        testOperation()
    }
    
}

/// RxSwift Practice

extension RxPractice {
    
    func testRxCocoa() {
        
        btn.rx.tap.subscribe { event in
            print("btn tapped event = \(event)")
        }.disposed(by: self.disposebag)
        

        // old way
        tf1.rx.text.subscribe (onNext: { [weak self] text in
            print("tf1 text = \(text ?? "")")
            self?.lb1.text = text
        }).disposed(by: self.disposebag)
        // Rx better way
        tf2.rx.text.bind(to: lb2.rx.text).disposed(by: self.disposebag)
    }
    
    func testObservable() {

        print("------------ testForObservable --------------")

        // 1. never: 不发出任何信号
        let neverOb = Observable<String>.never()
        neverOb.subscribe(onNext: { (string) in
            print("1-neverOb string = \(string)")
        }, onCompleted: {
            print("1-neverOb only call onCompleted")
        }, onDisposed: {
            print("1-neverOb onDisposed")
        }).disposed(by: self.disposebag)
        
        print("------------------------------------")
        
        // 2. empty: 只发出completed信号
        let emptyOb = Observable<String>.empty()
        emptyOb.subscribe { (event: Event<String>) in
            print("2-emptyOb event = \(event)")
        }.disposed(by: self.disposebag)
        
        print("------------------------------------")
        
        // 3. just: 发出唯一的一个元素
        // just 操作符将某一个元素转换为 Observable。
        let justOb = Observable.just("just obseverble signal")
        justOb.subscribe { (event: Event<String>) in
            print("3-justOb event = \(event)")
        }.disposed(by: self.disposebag)

        print("------------------------------------")
        
        // 4. of: 方法可以接受多个参数来创建实例。
        let ofOb = Observable.of(["a", "b", "c"], ["2"])
        ofOb.subscribe { (event) in
            print("4-ofOb event = \(event)")
        }.disposed(by: self.disposebag)
        
        print("------------------------------------")

        // 5. from: 方法只接收数组作为参数，并抽取出数组里的元素来作为数据流中的元素。代码如下：
        let fromOb = Observable.from(["a", "b", "c"])
        fromOb.subscribe { (event) in
            print("5-fromOb event = \(event)")
        }.disposed(by: self.disposebag)
        
        print("------------------------------------")

        // 6. create: 通过一个构建函数完整的创建一个 Observable，你需要提供一个构建函数，在构建函数里面描述事件（next，error，completed）的产生过程。
        let createOb = Observable.create({ (observer: AnyObserver<Any>) -> Disposable in
            observer.onNext("hello1")
            observer.onNext("hello2")
            observer.onNext("😄")
            observer.onNext("🐶")
            observer.onCompleted()
            
            return Disposables.create()
        })
        createOb.subscribe { (event) in
            print("6-createOb event = \(event)")
        }.disposed(by: self.disposebag)
        
        print("------------------------------------")

        // 7. range: 创建一个sequence，他会发出这个范围中的从开始到结束的所有事件
        let rangeOb = Observable.range(start: 0, count: 10)
        rangeOb.subscribe { (event) in
            print("7-rangeOb event = \(event)")
        }.disposed(by: self.disposebag)
        
        print("------------------------------------")

        // 8. repeatElement:创建一个sequence，发出特定的事件n次
        let repeatElementOb = Observable.repeatElement("repeatElement objects", scheduler: MainScheduler.instance)
        repeatElementOb.take(4).subscribe { (event) in
            print("8-repeatElementOb event = \(event)")
        }.disposed(by: self.disposebag)
        
        print("------------------------------------")
    }
    
    func testSubject() {
        // Subject 可以作为Obsevable,也可以作为Obsever,即可当观察者监听事件，也可做被观察者发送事件
        
        // 1. publishSubject: PublishSubject 将对观察者发送订阅后产生的元素，而在订阅前发出的元素将不会发送给观察者。
        let publishSubject = PublishSubject<String>()
        publishSubject.onNext("element 1")
        publishSubject.subscribe { (event: Event<String>) in
            print("1-publishSubject event = \(event)")
        }.disposed(by: self.disposebag)
        publishSubject.onNext("element 2")
        publishSubject.onNext("element 3")
        
        print("------------------------------------")

        // 2. ReplaySubject: 如果你希望观察者接收到所有的元素
        let replaySubject = ReplaySubject<String>.create(bufferSize: 3)
        replaySubject.onNext("element 1")
        replaySubject.onNext("element 2")
        replaySubject.onNext("element 3")
        replaySubject.onNext("element 4")
        replaySubject.onNext("element 5")
        replaySubject.subscribe { (event: Event<String>) in
            print("2-replaySubject event = \(event)")
        }.disposed(by: self.disposebag)
        replaySubject.onNext("element 7")
        replaySubject.onNext("element 8")

        print("------------------------------------")

        // 3. BehaviorSubject: 当你订阅了BehaviorSubject，你会接受到订阅之前的最后一个事件,订阅之后的事件一定会触发,如果源 Observable 因为产生了一个 error 事件而中止， BehaviorSubject 就不会发出任何元素，而是将这个 error 事件发送出来。
        let behaviorSubject = BehaviorSubject(value: "value")
        behaviorSubject.onNext("A")
        behaviorSubject.onNext("B")
        behaviorSubject.onNext("C")
        behaviorSubject.subscribe { (event: Event<String>) in
            print("3-behaviorSubject event = \(event)")
        }.disposed(by: self.disposebag)
        behaviorSubject.onNext("D")
        behaviorSubject.onNext("E")
        
        print("------------------------------------")

        // 4. Variable(Rx5.0弃用): Variable是BehaviorSubject一个包装箱，就像是一个箱子一样，使用的时候需要调用asObservable()拆箱，里面的value是一个BehaviorSubject，他不会发出error事件，但是会自动发出completed事件。
        let variable = Variable("S")
        variable.value = "A"
        variable.value = "B"
        variable.value = "C"
        variable.asObservable().subscribe { (event: Event<String>) in
            print("4-Variable event = \(event)")
        }.disposed(by: self.disposebag)
        variable.value = "D"
        variable.value = "E"
        
        print("------------------------------------")
        
        // 5. BehaviorRelay 就是 BehaviorSubject 去掉终止事件 onError 或 onCompleted。
        let behaviorRelay = BehaviorRelay(value: "S")
        behaviorRelay.accept("A")
        behaviorRelay.accept("B")
        behaviorRelay.accept("C")
        behaviorRelay.asObservable().subscribe { (event: Event<String>) in
            print("5-behaviorRelay event = \(event)")
            }.disposed(by: self.disposebag)
        behaviorRelay.accept("D")
        behaviorRelay.accept("E")

        print("------------------------------------")
        
    }
    
    func testOperation() {
        
        // 1. map: 通过传入一个函数闭包把原来的sequence转变为一个新的sequence的操作
        Observable.of(1, 2, 3, 4)
            .map({ $0 * $0 })
            .subscribe(onNext: { print("testOperation1. map = \($0)") })
            .disposed(by: self.disposebag)
        
        print("------------------------------------")
        
        // 2. flatMap: 将一个sequence转换为一个sequences，当你接收一个sequence的事件，你还想接收其他sequence发出的事件的话可以使用flatMap，她会将每一个sequence事件进行处理以后，然后再以一个sequence形式发出事件
        //  如果一个model对象A是Observable，其内部一个属性b也是Observable，如果需要监听对象A的属性b,就出现多维的Observable，所以flatMap就u是来实现降维的
        /** map & flatMap
         // [【Tips】map & flatMap - 简书](https://www.jianshu.com/p/1f652500523d)
         map 和 flatMap，两个操作符都是将observable中的元素进行变换。map操作符变换后的元素类型就是闭包返回的类型，所以本文栗子中使用map后，订阅输出的就是RxSwift.%%类型；而flatMap闭包返回的类型都是Observable类型，但是变换后的元素是Observable类型中Element的类型，所以栗子中使用flatMap后输出的依然是 Int类型。
         栗子中flatMap闭包每次返回的Observable将其中的element发送到一个新的Observable，这个新的Observable会被订阅者所订阅，这个新的Observable就可以说明flatMap的降维，也是所谓的flat。
         因为栗子中最初的Observable中有一个元素为空，所以Observable中Element类型应该是Optional，但是经过flatMap后输出的却不是，说明flatMap可以过滤Observable中为空的element。
         之所以能过滤空的element，主要还是因为flatMap会新建一个Observable，因为栗子中闭包，当元素为空的时候返回的是一个空的Observable，所以新的Observable并不会接收到其中的element，之后订阅者所输出的也就不存在空的元素，所以类型自然也就不是Optional。
         */
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        let variable = Variable(subject1)
        variable.asObservable()
            .flatMap { $0 }
            .subscribe(onNext: { print("testOperation2. flatMap = \($0)") })
            .disposed(by: self.disposebag)
        subject1.onNext("B")
        variable.value = subject2
        subject2.onNext("2")
        subject1.onNext("C")
        
        print("------------------------------------")
        
        // 3. flatMapLatest 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。一旦转换出一个新的 Observable，就只发出它的元素，旧的 Observables 的元素将被忽略掉。
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        let variable_flatMapLatest = Variable(first)
        variable_flatMapLatest.asObservable()
            .flatMapLatest { $0 }
            .subscribe(onNext: { print("testOperation3. flatMapLatest = \($0)") })
            .disposed(by: self.disposebag)
        
        first.onNext("🐱")
        variable_flatMapLatest.value = second
        second.onNext("🅱️")
        first.onNext("🐶")

        
        
        
    }
    
}
