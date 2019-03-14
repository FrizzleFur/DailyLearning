# YYCache解析

最近拜读
了一下YYCache的源码，发现ibireme大神对内存优化的独特风格值得学习。查了一些网上的资源，找到一些比较有用的信息，在这里说一说…

## [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#YYCache%E7%9A%84%E6%A6%82%E8%A6%81 "YYCache的概要")YYCache的概要

### [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E7%BB%93%E6%9E%84%E5%9B%BE "结构图")结构图

简单的看一下代码结构，盗个图来表示
[![logo](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/a.png)](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/a.png)

### [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E9%94%81 "锁")锁

#### [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E7%AE%80%E5%8D%95%E5%AF%B9%E6%AF%94%EF%BC%9A "简单对比：")简单对比：

[![logo](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/b.png)](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/b.png)
备注：TMCache的同步读操作是通过dispatch_semaphore_t阻碍当前线程，异步获取value

#### [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E7%AE%80%E5%8D%95%E8%AF%B4%E4%B8%80%E4%B8%8B-NSCache "简单说一下 NSCache")简单说一下 NSCache

NSCache 是苹果提供的一个简单的内存缓存，它有着和 NSDictionary 类似的 API，不同点是它是线程安全的，并且不会 retain key。我在测试时发现了它的几个特点：NSCache 底层并没有用 NSDictionary 等已有的类，而是直接调用了 libcache.dylib，其中线程安全是由 pthread_mutex 完成的。另外，它的性能和 key 的相似度有关，如果有大量相似的 key (比如 “1”, “2”, “3”, …)，NSCache 的存取性能会下降得非常厉害，大量的时间被消耗在 CFStringEqual() 上，不知这是不是 NSCache 本身设计的缺陷。

#### [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E4%B8%8D%E5%86%8D%E5%AE%89%E5%85%A8%E7%9A%84-OSSpinLock "不再安全的 OSSpinLock")不再安全的 OSSpinLock

[不再安全的 OSSpinLock](https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/)
自从 OSSpinLock 被公布不安全，第三方库纷纷用pthread_mutex 替换 OSSpinLock。
OSSpinLock不安全的主要原因发生在低优先级线程拿到锁时，高优先级线程进入忙等(busy-wait)状态，消耗大量 CPU 时间，从而导致低优先级线程拿不到 CPU 时间，也就无法完成任务并释放锁。这种问题被称为优先级反转。

## [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#YYCache%E7%9A%84%E4%BC%98%E5%8A%BF "YYCache的优势")YYCache的优势

### [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#MemoryCache "MemoryCache")MemoryCache

TMMemoryCache 的同步访问的逻辑，内部是把操作放到其他线程去执行，等待其完成后再回到当前线程（通过dispatch_semaphore_t实现的），这就会让同步访问的方法内部产生线程切换等很重的操作， 性能就会非常差并存在造成死锁的风险


```

- (id)objectForKey:(NSString *)key{

//...

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self objectForKey:key block:^(TMMemoryCache *cache, NSString *key, id object) {

        objectForKey = object;

        dispatch_semaphore_signal(semaphore);

    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

// ...

}
```

 

PINMemoryCache 同步读的时候，是真正的同步读，并且用信号量控制了同步读在并发队列的并行量，避免了线程切换带来的巨大开销，也避免了可能的死锁，这性能就没问题了。

 


```
- (nullable id)objectForKey:(NSString *)key

{

    if (!key)

        return nil;

    NSDate *now = [[NSDate alloc] init];

    [self lock];

    id object = nil;

    // If the cache should behave like a TTL cache, then only fetch the object if there's a valid ageLimit and  the object is still alive

    if (!self->_ttlCache || self->_ageLimit <= 0 || fabs([[_dates objectForKey:key] timeIntervalSinceDate:now]) < self->_ageLimit) {

        object = _dictionary[key];

    }

    [self unlock];

    // 维护 _dates字典 -> LRU

    if (object) {

        [self lock];

        _dates[key] = now;

        [self unlock];

    }

    return object;

}


```

YYMemoryCache 缓存内部用双向链表和 NSDictionary 实现了 LRU 淘汰算法，而TMMemoryCache & PINMemoryCache 通过维护一个dictio记录object 最后一次访问的时间，通过排序时间来实现的LRU，YYMemoryCache相对于它们算是一点进步吧



```
- (id)objectForKey:(id)key {

    if (!key) return nil;

    pthread_mutex_lock(&_lock);

    // node对象中的 _value就是查询的值，_time记录当前时间->LRU

    _YYLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));

    if (node) {

        node->_time = CACurrentMediaTime();

        [_lru bringNodeToHead:node];

    }

    pthread_mutex_unlock(&_lock);

    return node ? node->_value : nil;

}

```
### [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#DiskCache "DiskCache")DiskCache

TMDiskCache & PINDiskCache 都是基于文件系统的， 即一个 Value 对应一个文件 ，通过文件读写来缓存数据。他们的实现都比较简单，性能也都相近，缺点也是同样的：不方便扩展、没有元数据、难以实现较好的淘汰算法、数据统计缓慢。

YYDiskCache 采用了 SQLite & 文件系统 一起的方式实现的。作者测试SQLite发现：

*   单条数据小于 20K 时，SQLite读取性能越高
*   单条数据大于 20K 时，写文件更快
*   所以YYDiskCache就以20k作为判断使用哪种方式的条件

## [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E5%86%85%E5%AD%98%E4%BC%98%E5%8C%96-%F0%9F%98%84%E4%BA%AE%E7%82%B9 "内存优化 😄亮点")内存优化 😄亮点

看源码时，对[holder count]; // release in queue感到不解。



```if (holder.count) {

    dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();

    dispatch_async(queue, ^{

        [holder count]; // release in queue

    });

}

```

查了一下[作者的blog](https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)，发现原因如下：

1.  让block来retain一下对象？
    应该是holder在执行完这个方法后就出了作用域了，reference会减1，但是此时holder不会被dealloc，因为block 中retain了node，使得holder的reference count为1，当执完block后，holder的reference count又-1，此时node就会在block对应的queue上release了。的确很巧妙！😄

2.  为什么需要在指定queue销毁对象？
    放到其他线程去销毁对象，减轻当前线程压力，一般都是减轻main thread的压力

> iOS保持界面流畅的技巧 对象的销毁虽然消耗资源不多，但累积起来也是不容忽视的。通常当容器类持有大量对象时，其销毁时的资源消耗就非常明显。同样的，如果对象可以放到后台线程去释放，那就挪到后台线程去

## [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E5%AE%9A%E6%97%B6%E6%A3%80%E6%9F%A5-gt-LUR "定时检查->LUR")定时检查->LUR

通过 dispatch_after延时递归实现 定时器的效果

```
- (void)_trimRecursively {

    __weak typeof(self) _self = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        __strong typeof(_self) self = _self;

        if (!self) return;

        [self _trimInBackground];

        [self _trimRecursively];

    });

}
```


## [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E4%B8%BA%E4%BB%80%E4%B9%88%E4%BD%BF%E7%94%A8pthread-mutex-trylock "为什么使用pthread_mutex_trylock")为什么使用`pthread_mutex_trylock`

有些人可能不知道，在`pthread_mutex`中函数返回值为0代表成功，非0代表各种错误！
[pthread_mutex详解](http://docs.oracle.com/cd/E19253-01/819-7051/6n919hpag/index.html)

源码中，用`pthread_mutex_trylock` 来尝试获取锁，为什么不直接加锁呢？原因是：尽量避免与其他访问线程产生冲突，毕竟删除过期数据的优先级不高。

```
NSMutableArray *holder = [NSMutableArray new];

while (!finish) {

    if (pthread_mutex_trylock(&_lock) == 0) {

        if (_lru->_totalCost > costLimit) {

            _YYLinkedMapNode *node = [_lru removeTailNode];

            if (node) [holder addObject:node];

        } else {

            finish = YES;

        }

        pthread_mutex_unlock(&_lock);

    } else {

        usleep(10 * 1000); //10 ms

    }

}

```

## [](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/#%E4%BD%BF%E7%94%A8%E6%B3%A8%E6%84%8F "使用注意")使用注意

使用YYCache时 如果需要DiskCache的话， object 需要遵循NSCoding，如果只需要MemoryCache，可以不用遵循NSCoding，当然可以直接使用YYMemoryCache。
简单使用YYCache，来测试一下 LRU。


```- (void)testLRU {

    YYCache *yyCache=[YYCache cacheWithName:@"LCJCache"];

    [yyCache.memoryCache setCountLimit:50];//内存最大缓存数据个数

    [yyCache.memoryCache setCostLimit:1*1024];//内存最大缓存开销 目前这个毫无用处

    [yyCache.diskCache setCostLimit:10*1024];//磁盘最大缓存开销

    [yyCache.diskCache setCountLimit:50];//磁盘最大缓存数据个数

    [yyCache.diskCache setAutoTrimInterval:60];//设置磁盘lru动态清理频率 默认 60秒

    for(int i=0 ;i<100;i++){

        //模拟数据

        NSString *value=@"I want to know who is lcj ?";

        //模拟一个key

        NSString *key=[NSString stringWithFormat:@"key%d",i];

        [yyCache setObject:value forKey:key];

    }

    NSLog(@"yyCache.memoryCache.totalCost:%lu",(unsigned long)yyCache.memoryCache.totalCost);

    NSLog(@"yyCache.memoryCache.costLimit:%lu",(unsigned long)yyCache.memoryCache.costLimit);

    NSLog(@"yyCache.memoryCache.totalCount:%lu",(unsigned long)yyCache.memoryCache.totalCount);

    NSLog(@"yyCache.memoryCache.countLimit:%lu",(unsigned long)yyCache.memoryCache.countLimit);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSLog(@"yyCache.diskCache.totalCost:%lu",(unsigned long)yyCache.diskCache.totalCost);

        NSLog(@"yyCache.diskCache.costLimit:%lu",(unsigned long)yyCache.diskCache.costLimit);

        NSLog(@"yyCache.diskCache.totalCount:%lu",(unsigned long)yyCache.diskCache.totalCount);

        NSLog(@"yyCache.diskCache.countLimit:%lu",(unsigned long)yyCache.diskCache.countLimit);

        for(int i=0 ;i<100;i++){

            //模拟一个key

            NSString *key=[NSString stringWithFormat:@"key%d",i];

            id vuale=[yyCache objectForKey:key];

            NSLog(@"key ：%@ value : %@",key ,vuale);

        }

    });

}
```


参考：
[YYCache 设计思路](https://blog.ibireme.com/2015/10/26/yycache/)
[不再安全的 OSSpinLock](https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/)
[iOS 保持界面流畅的技巧](https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)

 [](https://wangdetong.github.io/2017/04/02/20170402AppleScript%E8%AE%A9iMessage%E6%9B%B4%E5%A5%BD%E7%8E%A9/ "AppleScript让iMessage更好玩")


## 参考

1. [YYCache 设计思路 | Garan no dou](https://blog.ibireme.com/2015/10/26/yycache/)
2. [聊一聊YYCache | 夏虫不可语冰](https://wangdetong.github.io/2017/05/08/20170508%E8%81%8A%E4%B8%80%E8%81%8AYYCache/)
3. [源码解析--YYCache - 简书](https://www.jianshu.com/p/88b33bfa82ca)
4. [YYCache源码分析(一) - 简书](https://www.jianshu.com/p/b8dcf6634fab)

