
# KVO解析.md

## 键值监听KVO
	• KVO提供一种机制，指定一个被观察对象(例如A类)，当对象某个属性(例如A中的字符串name)发生更改时，监听对象会获得通知，并作出相应处理；【且不需要给被观察的对象添加任何额外代码，就能使用KVO机制】在MVC设计架构下的项目，KVO机制很适合实现mode模型和view视图之间的通讯。

我们知道在WPF、Silverlight中都有一种双向绑定机制，如果数据模型修改了之后会立即反映到UI视图上，类似的还有如今比较流行的基于 MVVM设计模式的前端框架，例如Knockout.js。其实在ObjC中原生就支持这种机制，它叫做Key Value Observing（简称KVO）。KVO其实是一种观察者模式，利用它可以很容易实现视图组件和数据模型的分离，当数据模型的属性值改变之后作为监听器 的视图组件就会被激发，激发时就会回调监听器自身。在ObjC中要实现KVO则必须实现NSKeyValueObServing协议，不过幸运的是 NSObject已经实现了该协议，因此几乎所有的ObjC对象都可以使用KVO。
在ObjC中使用KVO操作常用的方法如下：
	• 注册指定Key路径的监听器： addObserver: forKeyPath: options:  context:
	• 删除指定Key路径的监听器： removeObserver: forKeyPath、removeObserver: forKeyPath: context:
	• 回调监听： observeValueForKeyPath: ofObject: change: context:
 

```


//  GoodsSortView.m
static NSString * const WJSortKeyPathContentOffset = @"contentOffset"; //kvo

static CGFloat const hiddenSortViewTime = 0.3;//动画时间
static CGFloat const scrollVelocity = 900;//拖动速度

#pragma mark - KVO监听
- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [scrollView addObserver:self forKeyPath:WJSortKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers {
    [scrollView removeObserver:self forKeyPath:WJSortKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.userInteractionEnabled || self.hidden) return;
    if ([keyPath isEqualToString:WJSortKeyPathContentOffset]) {
        NSValue *oldValue = change[NSKeyValueChangeOldKey];
        CGFloat oldY = [oldValue CGPointValue].y; //旧值
        CGFloat newY = scrollView.contentOffset.y ; //新值
        if (newY == oldY) return;
        if (newY < oldY) {  //往下拖动
		 //过滤在控件不在顶部隐藏的时候
            if (self.top != scrollView.top - self.height) return;
            UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer; //获取scrollView的平移手势
            CGPoint velocity = [pan velocityInView:pan.view];//获取scrollView的平移手势的平移速度
		   // 过滤 内容已偏下的时候 &  为达标的平移速度，
            if (scrollView.contentOffset.y > self.height && velocity.y <= scrollVelocity) return;
            [UIView animateWithDuration:hiddenSortViewTime animations:^{
                self.top = scrollView.top;//显示隐藏控件
            }];
        }else {//往上拖动
		 //过滤往上偏移未超过控件高度，& 控件收缩的时候
            if (scrollView.contentOffset.y <= self.height || self.top != scrollView.top) return;
		 //超过了就保持在顶部，
            [UIView animateWithDuration:hiddenSortViewTime animations:^{
                self.top = scrollView.top - self.height;//收缩隐藏控件
            }];
        }
    }
}
# 
```

	1. 这两个判断很给力

```
        //过滤在控件不在顶部隐藏的时候
            if (self.top != scrollView.top - self.height) return;

            if (scrollView.contentOffset.y <= self.height || self.top != scrollView.top) return;
		 //超过了就保持在顶部，
```

#### KVO的使用步骤：

	1. 通过addObserver: forKeyPath: options: context:为被监听对象（它通常是数据模型）注册监听器
	2. 重写监听器的observeValueForKeyPath: ofObject: change: context:方法
 
由于我们还没有介绍过IOS的界面编程，这里我们还是在上面的例子基础上继续扩展，假设当我们的账户余额balance变动之后我们希望用户可以及 时获得通知。那么此时Account就作为我们的被监听对象，需要Person为它注册监听（使用addObserver: forKeyPath: options: context:）;而人员Person作为监听器需要重写它的observeValueForKeyPath: ofObject: change: context:方法，当监听的余额发生改变后会回调监听器Person监听方法（observeValueForKeyPath: ofObject: change: context:）。下面通过代码模拟上面的过程：

```
  Account.h 
#import <Foundation/Foundation.h> 
@interface Account : NSObject
#pragma mark - 属性
#pragma mark 余额
@property (nonatomic,assign) float balance;
@end

Account.m
#import "Account.h"
 
@implementation Account
 
@end
```

```
Person.h
 
#import <Foundation/Foundation.h>
@class Account;
 
@interface Person : NSObject{
@private
    int _age;
}
#pragma mark - 属性
#pragma mark 姓名
@property (nonatomic,copy) NSString *name;
#pragma mark 账户
@property (nonatomic,retain) Account *account;
 
#pragma mark - 公共方法
#pragma mark 显示人员信息
-(void)showMessage;
@end

Person.m
  Person.m
  KVCAndKVO
 #import "Person.h"
#import "Account.h"
 
@implementation Person
#pragma mark - 公共方法
#pragma mark 显示人员信息
-(void)showMessage{
 
    NSLog(@"name=%@,age=%d",_name,_age);
}

#pragma mark 设置人员账户
-(void)setAccount:(Account *)account{
    _account=account;
 
    添加对Account的监听
    [self.account addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionNew context:nil];
}
 
#pragma mark - 覆盖方法
#pragma mark 重写observeValueForKeyPath方法，当账户余额变化后此处获得通知
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
 
    if([keyPath isEqualToString:@"balance"]){//这里只处理balance属性
        NSLog(@"keyPath=%@,object=%@,newValue=%.2f,context=%@",keyPath,object,[[change objectForKey:@"new"] floatValue],context);
 
    }
}
 
#pragma mark 重写销毁方法
-(void)dealloc{
    [self.account removeObserver:self forKeyPath:@"balance"]; 移除监听
   
[super dealloc]; 注意启用了ARC，此处不需要调用
}
@end
 
main.m
 
#import <Foundation/Foundation.h>
#import "Person.h"
#import "Account.h"
 
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Person *person1=[[Person alloc]init];
        person1.name=@"Kenshin";
        Account *account1=[[Account alloc]init];
        account1.balance=100000000.0;
        person1.account=account1;
        
        account1.balance=200000000.0; 注意执行到这一步会触发监听器回调函数observeValueForKeyPath: ofObject: change: context:
结果：keyPath=balance,object=<Account: 0x100103aa0>,newValue=200000000.00,context=(null)
        
    }
    return 0;
}

```

在上面的代码中我们在给人员分配账户时给账户的balance属性添加了监听，并且在监听回调方法中输出了监听到的信息，同时在对象销毁时移除监听，这就构成了一个典型的KVO应用。

### 注意

* `setValue：forKey：`中key的参数只能够是`NSString`类型，而`setObject：forKey：`的可以是任何类型
这个是不对的，`setValue：forKey`和`setObject：forKey`都可以是`objectType`。

在使用NSMutableDictionary的时候经常会使用setValue forKey与setObject forKey，他们经常是可以交互使用的，代码中经常每一种的使用都有。
1.先看看`setValue： forKey：`的定义

扩展NSMutableDictionary的一个类别，上面注释说的很清楚，发送setObject:forKey 给接收者，也就是调用setObject:forKey方法，除非value为nil的时候，调用方法removeObject:forKey
2.看看setObject：forKey：的定义

注意：setObject：forKey：中Key的对象是一个id类型，并不是NSString，只不过我们经常使用NSString而已。
3.总结两者的区别：

* setObject：forked：中object是不能够为nil的，不然会报错。
* setValue：forKey：中value能够为nil，但是当value为nil的时候，会自动调用removeObject：forKey方法
* setValue：forKey：中key的参数只能够是NSString类型，而setObject：forKey：的可以是任何类型
注意：setObject：forKey：对象不能存放nil要与下面的这种情况区分：


```
[imageDictionary setObject:[NSNullnull] forKey:indexNumber];
```

[NSNull null]表示的是一个空对象，并不是nil，注意这点
setObject：forKey：中Key是NSNumber对象的时候，如下：

```
[imageDictionary setObject:obj forKey:[NSNumber numberWithInt：10]];
```

上面说的区别是针对调用者是dictionary而言的。setObject:forKey:方法`NSMutabledictionary`特有的,`而setValue:forKey`:方法是KVC（键-值编码）的主要方法。
当 setValue:forKey:方法调用者是对象的时候： setValue:forKey:方法是在NSObject对象中创建的，也就是说所有的oc对象都有这个方法，所以可以用于任何类。
4.使用:

```
SomeClass *someObj = [[SomeClass alloc] init];
[someObj setValue:self forKey:@"delegate"];
```

表示的意思是：对象someObj设置他的delegate属性的值为当前类，当然调用此方法的对象必须要有delegate属性才能设置，不然调用了也没效果

### 参考

1. [kvo 实践使用总结](http://www.jianshu.com/p/b878aa3194c6)
2. [setValue和setObject的区别 - taylor的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/itianyi/article/details/8661997)
3.  [Key-Value Observing - NSHipster](http://nshipster.cn/key-value-observing/)



