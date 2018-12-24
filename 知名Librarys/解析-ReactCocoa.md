
## ReactiveCocoa

> 作为iOS开发人员，您编写的几乎所有代码都是对某些事件的反应;按钮点击，收到的网络消息，属性更改（通过键值观察）或通过CoreLocation更改用户位置都是很好的例子。但是，这些事件都以不同的方式编码;作为行动，代表，KVO，回调等。 ReactiveCocoa定义了事件的标准接口，因此可以使用一组基本工具更轻松地链接，过滤和组合它们。


ReactiveCocoa结合了几种编程风格：

* 函数式编程，即以其他函数作为参数的函数
* 响应式编程，重点关注数据流和变化传播

#### 二.ReactiveCocoa常见类

1.`RACSignal`信号类
`RACSignal`信号类表示当数据改变时,在信号内部会利用订阅者发送数据.`RACSignal`默认是一个`冷信号`,只有被订阅以后才会变成热信号.
`RACSignal`信号类的简单使用:

```
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 3.利用订阅者发送数据
        // 只有当有订阅者订阅时,才会调用这个block
        [subscriber sendNext:@"这是发送的数据"];
        return nil;
    }];

    // 2.订阅信号
    [signal subscribeNext:^(id x) {
       NSLog(@"接收到数据:%@",x);
    }];

```

2.`RACSubscriber`订阅者
`RACSubscriber`是一个协议,任何遵循`RACSubscriber`协议的对象并且实现协议方法都可以是一个订阅者,订阅者可以帮助信号发送数据.
`RACSubscriber`协议中有四个方法.

```
- (void)sendNext:(id)value;
- (void)sendError:(NSError *)error;
- (void)sendCompleted;
- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable;

```

3.`RACDisposable`
`RACDisposable`用于取消订阅和清理资源,当信号发送完成或发送错误时会自动调用.

```
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 3.利用订阅者发送数据
        [subscriber sendNext:@"这是发送的数据"];
        // 如果为未调用,当信号发送完成或发送错误时会自动调用
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"资源被清理了");
        }];
    }];

    // 2.订阅信号
    [signal subscribeNext:^(id x) {
       NSLog(@"接收到数据:%@",x);
    }];

```

4.`RACSubject`信号提供者
`RACSubject`继承`RACSignal`,又遵循了`RACSubscriber`协议,所以既可以充当信号,又可以发送信号,通常用它代替代理.

```
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];

    // 2.订阅信号
    [subject subscribeNext:^(id x) {
       NSLog(@"接收到数据:%@",x);
    }];

    // 3.发送信号
    [subject sendNext:@"发送数据"];

```

`RACSubject`的底层实现

*   在执行`[RACSubject subject]`时,`RACSubject`会在初始化时创建`disposable`对象属性和`subscribers`订阅者数组.

![](//upload-images.jianshu.io/upload_images/1444844-7eff1016f615b48e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/762/format/webp)

image.png

*   在执行`subscribeNext`订阅信号时,会创建一个订阅者`RACSubscriber`,并将订阅者`RACSubscriber`添加到`subscribers`订阅者数组.

![](//upload-images.jianshu.io/upload_images/1444844-bcc1aa287c6184a7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

image.png

*   在执行`sendNext`发送信号时,会遍历`subscribers`订阅者数组,执行`sendNext`

![](//upload-images.jianshu.io/upload_images/1444844-eec0a2267fa4a4bf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/826/format/webp)

image.png

5.`RACReplaySubject`
`RACReplaySubject`重复提供信号类，`RACSubject`的子类.由于`RACReplaySubject`的底层实现和`RACSubject`不同,**`RACReplaySubject`可以先发送数据,再订阅信号**.

```
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];

    // 2.订阅信号
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"订阅信号,%@",x);
    }];

    // 3.发送数据
    [replaySubject sendNext:@"发送的数据"];

```

`RACReplaySubject`的底层实现

*   在执行`[RACReplaySubject subject]`时,创建一个`valuesReceived`数组

![](//upload-images.jianshu.io/upload_images/1444844-e11464101524a438.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

image.png

*   在执行`subscribeNext`时,创建订阅者,遍历valuesReceived数组,利用订阅者执行`sendNext`发送`valuesReceived`中的数据.

![](//upload-images.jianshu.io/upload_images/1444844-751dfd1b1bf2bf85.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

image.png

*   在执行`sendNext`时,将要发送的数据保存到valuesReceived数组中,执行`sendNext`

![](//upload-images.jianshu.io/upload_images/1444844-c9a82f3c8be9777b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

image.png

6.`RACMulticastConnection`
我们在使用`RACsignal`,`RACReplaySubject`或者`RACReplaySubject`时,当一个信号被多个订阅者订阅时,在信号内部的`block`或被调用多次,有时这样并不能满足我们的需求,我们想要信号被多个订阅者订阅时,**信号内部的`block`只被执行一次**,那么`RACMulticastConnection`就能帮助我们完成需求.

```
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 3.发送数据
        NSLog(@"发送数据");
        [subscriber sendNext:@"发送数据"];
        return nil;
    }];

    RACMulticastConnection *connection = [signal publish];

    // 2.订阅信号
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"接收到数据1:%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"接收到数据2:%@",x);
    }];

    // 4.激活信号
    [connection connect];

```

在`log`中的打印如下

```
2017-06-20 16:55:50.809 MVVMRACDemoOC[2848:856666] 发送数据
2017-06-20 16:55:50.810 MVVMRACDemoOC[2848:856666] 接收到数据1:发送数据
2017-06-20 16:55:50.810 MVVMRACDemoOC[2848:856666] 接收到数据2:发送数据

```

7.`RACCommand`
`RACCommand`是处理事件的类,可以把事件如何处理,事件中的数据如何传递，包装到这个类中.
使用一个`demo`说明`RACCommand`:`监听按钮的点击,发送网络请求.`

```
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"接收到命令:%@", input);
        // 返回一个信号,不能为空.(信号中的信号)
        // 3.创建信号用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"信号中的信号发送的数据"];
            // 注意:数据传递完成,要调用sendCompleted才能执行完毕
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    self.command = command;

    // 2.订阅信号中的信号(必须要在执行命令前订阅)
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"接收到信号中的信号发送的数据:%@",x);
    }];

    // 4.执行命令
    [command execute:@1];

    [[command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"未开始/执行完成");
        }
    }];

```

在`log`中的打印

```
2017-06-20 17:26:28.013 MVVMRACDemoOC[3166:970238] 接收到命令:1
2017-06-20 17:26:28.016 MVVMRACDemoOC[3166:970238] 正在执行
2017-06-20 17:26:28.016 MVVMRACDemoOC[3166:970238] 接收到信号中的信号发送的数据:信号中的信号发送的数据
2017-06-20 17:26:28.017 MVVMRACDemoOC[3166:970238] 未开始/执行完成

```

#### 三.常见宏

1.  `RAC(TARGET, [KEYPATH, [NIL_VALUE]])`给某个对象的某个属性做绑定.

```
// 只要passwordTextField内容变化,accountTextField的text就会跟着改变
RAC(self.accountTextField, text) = self.passwordTextField.rac_textSignal;

```

1.  `RACObserve(self, name)`监听某个对象的某个属性,返回信号

```
    // 监听passwordTextField背景色的改变
    [RACObserve(self.passwordTextField, backgroundColor) subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

```

1.  `@weakify(Obj)`和`@strongify(Obj)`一般用来防止循环引用,组合使用.
2.  `RACTuplePack`把数据包装成RACTuple（元组类）

```
    // 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@1,@2);

```

1.  `RACTupleUnpack`把RACTuple（元组类）解包成对应的数据

```
    // 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@"OneAlon",@"HangZhou");

    // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
    RACTupleUnpack(NSString *name,NSNumber *address) = tuple;

```

#### 四.常见用法

1.  代替代理
    代替代理有两种方法,一种是使用`RACSubject`代替代理,另一种是使用`rac_signalForSelector`方法代替代理.
    这里模拟一个需求:`自定义一个红色的view,在view中有一个按钮,监听按钮的点击.`
    如果不使用`RAC`,在红色的`view`中定义一个代理属性,点击按钮的时候通知代理做事情.
    如果使用`RAC`,直接让红色的`view`调用`rac_signalForSelector`方法即可.

```
    [[self.redView rac_signalForSelector:@selector(buttonClick:)] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

```

2.代替KVO
监听红色`view`的背景色的改变

```
    [[self.redView rac_valuesAndChangesForKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

```

3.监听事件

```
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"按钮被点击了");
    }];

```

4.代替通知

```
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];

```

5.监听文本框文字改变

```
   [_textField.rac_textSignal subscribeNext:^(id x) {

       NSLog(@"文字改变了%@",x);
   }];

```

6.处理当界面有多次请求时，需要都获取到数据时，才能展示界面,`rac_liftSelector:withSignalsFromArray:Signals`


## 参考

1. [ReactiveCocoa Tutorial – The Definitive Introduction: Part 1/2 | raywenderlich.com](https://www.raywenderlich.com/2493-reactivecocoa-tutorial-the-definitive-introduction-part-1-2)
2. [ReactiveCocoa(OC版) - 简书](https://www.jianshu.com/p/a2baf302d0b9)

### 延伸阅读

*   官方文档
    *   [ReactiveCocoa/ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
    *   [ReactiveCocoa/ReactiveObjC](https://github.com/ReactiveCocoa/ReactiveObjC)
    *   [ReactiveCocoa/ReactiveViewModel](https://github.com/ReactiveCocoa/ReactiveViewModel#reactivecocoa)
*   基础教程
    *   [深入浅出－iOS Reactive Cocoa的常见用法](http://www.jianshu.com/p/e63261712172)
    *   [最快让你上手ReactiveCocoa之基础篇](http://www.jianshu.com/p/87ef6720a096)
    *   [ReactiveCocoa 学习之路(史上最全攻略)](https://runningyoung.github.io/2015/06/30/2015-07-20-ReactiveCocoa/)
*   相关讨论
    *   [ReactiveCocoa 讨论会 - 唐巧的技术博客](http://blog.devtang.com/2016/01/03/reactive-cocoa-discussion/#%E8%AE%A8%E8%AE%BA%EF%BC%9A%E6%9C%89%E4%BB%80%E4%B9%88%E5%AD%A6%E4%B9%A0-RAC-%E5%A5%BD%E7%9A%84%E8%B5%84%E6%96%99%E5%90%97%EF%BC%9F)
    *   [Reactive​Cocoa - NSHipster](http://nshipster.cn/reactivecocoa/)
    *   [ReactiveCocoa - iOS开发的新框架 - InfoQ](http://www.infoq.com/cn/articles/reactivecocoa-ios-new-develop-framework)