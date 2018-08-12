
# NSNotification.md



### 


>只要往NSNotificationCenter注册了，就必须有remove的存在，这点是大家共识的。但是大家在使用的时候发现，在UIViewController 中addObserver后没有移除，好像也没有挂！我想很多人可能和我有一样的疑问，是不是因为使用了ARC？在你对象销毁的时候自动置为nil了呢？或者苹果在实现这个类的时候用了什么神奇的方式呢？下面我们就一步步来探究下。

我们可以发现，向野指针对象发送了消息，所以挂掉了。从这点来看，苹果实现也基本差不多是这样的，只保存了个对象的地址，并没有在销毁的时候置为nil。

这点就可以证明，addObserver后，必须要有remove操作。

怎么样？是不是可以证明系统的UIViewController在销毁的时候调用了这个方法。（不建议大家在开发的时候用类别的方式覆盖原有的方法，由于类别方法具有更高的优先权，所以有可能影响到其他地方。这里只是调试用）。

以上也提醒我们，在你不是销毁的时候，千万不要直接调用[[NSNotificationCenter defaultCenter] removeObserver:self]; 这个方法，因为你有可能移除了系统注册的通知。



### Helpful Links

1. [Testing in iOS](https://videos.raywenderlich.com/courses/39-testing-in-ios/lessons/2)
2. [iOS NSNotificationCenter 使用姿势详解](http://www.jianshu.com/p/a4d519e4e0d5)



