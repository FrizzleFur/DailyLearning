
# KVO解析.md



>setValue：forKey：中key的参数只能够是NSString类型，而setObject：forKey：的可以是任何类型
这个是不对的，setValue：forKey和setObject：forKey都可以是objectType。

在使用NSMutableDictionary的时候经常会使用setValue forKey与setObject forKey，他们经常是可以交互使用的，代码中经常每一种的使用都有。
1.先看看setValue： forKey：的定义

扩展NSMutableDictionary的一个类别，上面注释说的很清楚，发送setObject:forKey 给接收者，也就是调用setObject:forKey方法，除非value为nil的时候，调用方法removeObject:forKey
2.看看setObject：forKey：的定义

注意：setObject：forKey：中Key的对象是一个id类型，并不是NSString，只不过我们经常使用NSString而已。
3.总结两者的区别：

setObject：forked：中object是不能够为nil的，不然会报错。
setValue：forKey：中value能够为nil，但是当value为nil的时候，会自动调用removeObject：forKey方法
setValue：forKey：中key的参数只能够是NSString类型，而setObject：forKey：的可以是任何类型
注意：setObject：forKey：对象不能存放nil要与下面的这种情况区分：

[imageDictionary setObject:[NSNullnull] forKey:indexNumber];
[NSNull null]表示的是一个空对象，并不是nil，注意这点
setObject：forKey：中Key是NSNumber对象的时候，如下：
[imageDictionary setObject:obj forKey:[NSNumber numberWithInt：10]];
上面说的区别是针对调用者是dictionary而言的。setObject:forKey:方法NSMutabledictionary特有的,而setValue:forKey:方法是KVC（键-值编码）的主要方法。
当 setValue:forKey:方法调用者是对象的时候： setValue:forKey:方法是在NSObject对象中创建的，也就是说所有的oc对象都有这个方法，所以可以用于任何类。
4.使用:

SomeClass *someObj = [[SomeClass alloc] init];
[someObj setValue:self forKey:@"delegate"];
表示的意思是：对象someObj设置他的delegate属性的值为当前类，当然调用此方法的对象必须要有delegate属性才能设置，不然调用了也没效果


### 参考

1. [setValue和setObject的区别 - taylor的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/itianyi/article/details/8661997)


2. [Key-Value Observing - NSHipster](http://nshipster.cn/key-value-observing/)

