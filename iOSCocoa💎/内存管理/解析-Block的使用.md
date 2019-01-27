## Block的使用

###  block的语法结构

```objc
 * 定义Block： 返回类型 + （标识^ + block名称）+ 参数类型 + 参数
 * Block作为参数： 返回类型 + （标识^） + 参数类型 + 参数 + block名称
 * Block实现：  标识^ + 返回类型 + (参数类型 + 参数)
```

## typedef

```objc
typedef NSString *(^NameBlock)(NSString *inputValue);
@property(nonatomic, copy)NameBlock nameBlock;
```
## 定义Block属性

block怎么声明，就如何定义成属性

```objc
@property (nonatomic, copy) void (^myBlock)(void);
void (^myBlock)(void) = ^{};
myBlock();
```

## Block作为参数

* 什么时候需要把block当做参数去使用:做的事情由外界决定, 但是什么时候做由内部决定.（封装一个计算器,提供一个计算方法,怎么计算由外界决定,什么时候计算由内部决定.）
* Block作为参数时，注意需要写明入参的名字

```objc
- (void)appendMsgWithMsgBlock:(NSString *(^)(NSString *receiveMsg))myBlock sendMsg:(NSString *)sendMsg{
    if (myBlock) {
        NSString *returnMsg =  myBlock(sendMsg);
        NSLog(@"returnMsg = %@", returnMsg);
    }
}

[self appendMsgWithMsgBlock:^NSString *(NSString *receiveMsg) {
    NSString *returnMsg = [receiveMsg stringByAppendingString:@"this is a message send by me."];
    return returnMsg;
} sendMsg:@"你好，"];

```

2. 一种情况在非ARC下是无法编译的：

```objc
typedef int(^blk_t)(int);

blk_t func(int rate){

    return ^(int count){return rate*count;}

}
```

这是因为：block捕获了栈上的rate自动变量，此时rate已经变成了一个结构体，而block中拥有这个结构体的指针。即如果返回block的话就是返回局部变量的指针。而这一点恰是编译器已经断定了。在ARC下没有这个问题，是因为ARC使用了autorelease了。

3. 有时候我们需要调用block 的copy函数，将block拷贝到堆上。看下面的代码：

```objc
-(id) getBlockArray{  
  int val =10;
  return [[NSArray alloc]initWithObjects:        ^{NSLog(@"blk0:%d",val);},  ^{NSLog(@"blk1:%d",val);}, nil];
} 

id obj = getBlockArray();

typedef void (^blk_t)(void);

blk_t blk = (blk_t)[obj objectAtIndex:0];

blk();
```

这段代码在最后一行blk()会异常，因为数组中的block是栈上的。因为val是栈上的。解决办法就是调用copy方法。

4. 不管block配置在何处，用copy方法复制都不会引起任何问题。在ARC环境下，如果不确定是否要copy block尽管copy即可。ARC会打扫战场。

注意：在栈上调用copy那么复制到堆上，在全局block调用copy什么也不做，在堆上调用block 引用计数增加

【注意】本人用Xcode 5.1.1 iOS sdk 7.1 编译发现：并非《Objective-C》高级编程这本书中描述的那样

int val肯定是在栈上的，我保存了val的地址，看看block调用前后是否变化。输出一致说明是栈上，不一致说明是堆上。

```objc
typedef int (^blkt1)(void) ;
-(void) stackOrHeap{  
  __block int val =10;    
  int *valPtr = &val;//使用int的指针，来检测block到底在栈上，还是堆上   
     blkt1 s= ^{     
        NSLog(@"val_block = %d",++val);    
        return val;
    }; 
    s();
    NSLog(@"valPointer = %d",*valPtr);
}
```

在ARC下——block捕获了自动变量，那么block就被会直接生成到堆上了。 val_block = 11 valPointer = 10

在非ARC下——block捕获了自动变量，该block还是在栈上的。 val_block = 11 valPointer = 11

调用copy之后的结果呢：

```objc
- (void) stackOrHeap{   
   __block int val =10;  
   int *valPtr = &val;//使用int的指针，来检测block到底在栈上，还是堆上    
   blkt1 s= ^{ 
       NSLog(@"val_block = %d",++val);        
       return val;
   };  
    blkt1 h = [s copy];  
    h();   
    NSLog(@"valPointer = %d",*valPtr);
}
在ARC下>>>>>>>>>>>无效果。 val_block = 11 valPointer = 10

在非ARC下>>>>>>>>>确实复制到堆上了。 val_block = 11 valPointer = 10

```

用这个表格来表示

![](https://img-blog.csdn.net/20140818115519771)

在ARC下：似乎已经没有栈上的block了，要么是全局的，要么是堆上的

在非ARC下：存在这栈、全局、堆这三种形式。

更详细的描述专题[打开链接](http://blog.csdn.net/hherima/article/details/38620175)

## block使用场景

1. 在一个类中定义，在另外一个类中调用
2. 在一个方法中定义，在另外一个方法调用，（使用方法Method封装更合适）
3. 保存代码到Model模型中，比如cell的一些操作回调
4. 在不同模块间传值
    * 顺传:给需要传值的对象，直接定义属性就能传值
    * 逆传:用代理, block,就是利用block去代替代理

## 参考

1. [【block第四篇】实现 - CSDN博客](https://blog.csdn.net/hherima/article/details/38586101)
