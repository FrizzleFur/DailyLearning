
# 断言(NSAssert)的使用


NSAssert()是一个宏，用于开发阶段调试程序中的Bug，通过为NSAssert()传递条件表达式来断定是否属于Bug，满足条件返回真值，程序继续运行，如果返回假值，则抛出异常，并且可以自定义异常描述。
NSAssert()是这样定义的：


#define NSAssert(condition, desc)

condition是条件表达式，值为YES或NO；desc为异常描述，通常为NSString。当conditon为YES时程序继续运行，为NO时，则抛出带有desc描述的异常信息。NSAssert()可以出现在程序的任何一个位置。

#### NSAssert和assert 区别

NSAssert和assert都是断言,主要的差别是assert在断言失败的时候只是简单的终止程序,而NSAssert会报告出错误信息并且打印出来.所以只使用NSAssert就好,可以不去使用assert。

#### NSAssert/NSCAssert

iOS中用的最多的是两对断言, NSAssert/NSCAssert 和 NSParameterAssert/NSCparameterAssert. 要知道他们的区别,我们先来看看他们定义.

```
    #if !defined(NS_BLOCK_ASSERTIONS)
    #if !defined(_NSAssertBody)
    #define NSAssert(condition, desc, ...)  \\\\
    do {              \\\\
    __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \\\\
    if (!(condition)) {       \\\\
    [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \\\\
    object:self file:[NSString stringWithUTF8String:__FILE__] \\\\
    lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \\\\
    }             \\\\
    __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \\\\
    } while(0)
    #endif
    #if !defined(_NSCAssertBody)
    #define NSCAssert(condition, desc, ...) \\\\
    do {              \\\\
    __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \\\\
    if (!(condition)) {       \\\\
    [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \\\\
    file:[NSString stringWithUTF8String:__FILE__] \\\\
    lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \\\\
    }             \\\\
    __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \\\\
    } while(0)
    #endif

```

从定义可以看出来，前者是适合于ObjectC的方法，_cmd 和 self 与运行时有关. 后者是适用于C的函数。
NSParameterAssert/NSCparameterAssert 两者的区别也是前者适用于Objective-C的方法,后者适用于C的函数。
实际开发中就用前者就可以了。

NSAssert/NSCAssert 和 NSParameterAssert/NSCparameterAssert 的区别是前者是针对条件断言, 后者只是针对参数是否存在的断言, 调试时候可以结合使用,先判断参数，再进一步断言，确认原因.

#### NSAssert的用法

```
    int a = 1;
    NSCAssert(a == 2, @"a must equal to 2"); //第一个参数是条件,如果第一个参数不满足条件,就会记录并打印后面的字符串

```

运行则会崩溃并在控制台输出信息如下：

```
*** Assertion failure in -[ViewController viewDidLoad](), /Users/yinwentao/Desktop/MYAssert/MYAssert/ViewController.m:32
*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'a must equal to 2'

```

#### NSParameterAssert的用法

```
- (void)assertWithPara:(NSString *)str
{
    NSParameterAssert(str); //只需要一个参数,如果参数存在程序继续运行,如果参数为空,则程序停止打印日志
    //further code ...
}

```

如果 调用方法 assertWithPara: 传入参数为空则有如下日志

```
*** Assertion failure in -[ViewController assertWithPara:], /Users/yinwentao/Desktop/MYAssert/MYAssert/ViewController.m:45
*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid parameter not satisfying: str'

```

日志中的数字是告诉你 第多少行代码出错了。

Xcode 已经默认将release环境下的断言取消了, 免除了忘记关闭断言造成的程序不稳定. 所以不用担心 在开发时候大胆使用。

![](//upload-images.jianshu.io/upload_images/550988-b32c25336fe6c94e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/584/format/webp)

release下是不用担心的.png

#### 自定义NSAssertionHandler

NSAssertionHandler实例是自动创建的，用于处理错误断言。如果 NSAssert和NSCAssert条件评估为错误，会向 NSAssertionHandler实例发送一个表示错误的字符串。每个线程都有它自己的NSAssertionHandler实例。
我们可以**自定义处理方法**，从而使用断言的时候，控制台输出错误，但是程序不会直接崩溃。

```
#import "MyAssertHandler.h"

@implementation MyAssertHandler

//处理Objective-C的断言
- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,...
{
    NSLog(@"NSAssert Failure: Method %@ for object %@ in %@#%li", NSStringFromSelector(selector), object, fileName, (long)line);
}
//处理C的断言
- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,...
{
    NSLog(@"NSCAssert Failure: Function (%@) in %@#%li", functionName, fileName, (long)line);
}

@end

```

给线程添加处理类

```
NSAssertionHandler *myHandler = [[MyAssertHandler alloc] init];
//给当前的线程
[[[NSThread currentThread] threadDictionary] setValue:myHandler
                                               forKey:NSAssertionHandlerKey];

```

自定义NSAssertionHandler后,程序能够获得断言失败后的信息,但是程序可以继续运行,不会强制退出程序.

## 参考

1. [断言(NSAssert)的使用 - 简书](https://www.jianshu.com/p/6e444981ab45)