//
//  Blog-GCD之同步任务.m
//  MultiThreadDemo-多线程
//
//  Created by MichaelMao on 2019/3/8.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 ## Dispatch Group
 需要在大量任务都执行完成后，执行其他任务，可以用 Dispatch Group
 
 ```objc
 // 可以理解为一个任务组，组内的任务完成后就会调用dispatch_group_notify
 dispatch_group_t group = dispatch_group_create();
 dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
 dispatch_group_async(group, queue, ^{
     for (int i = 0; i < 1000; i++) {
        if (i == 999) {
            NSLog(@"11111111");
        }
    }
 });
 
 dispatch_group_async(group, queue, ^{
    NSLog(@"22222222");
 });
 
 dispatch_group_async(group, queue, ^{
    NSLog(@"33333333");
 });
 
 dispatch_group_notify(group, queue, ^{
    NSLog(@"done");
 });
 
 ```
 
 `2018年4月18日更新`
 
 对于网络请求这种异步任务，还需要使用 `dispatch_group_enter`和`dispatch_group_leave`,来手动处理下，先上代码
 
 ```objc
 
 dispatch_group_t group = dispatch_group_create();
 dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
 dispatch_group_enter(group);
 dispatch_async(queue, ^{
    NSLog(@"任务1开始");
    sleep(2);
    NSLog(@"任务1结束");
    dispatch_group_leave(group);
 });
 
 dispatch_group_enter(group);
 dispatch_async(queue, ^{
     NSLog(@"任务2开始");
     sleep(1);
     NSLog(@"任务2结束");
     dispatch_group_leave(group);
 });
 
 dispatch_group_notify(group, queue, ^{
    NSLog(@"完成了");
 });
 ```
 
 输出为
 
 ```
 17:31:39.314251+0800 testP[29849:2247791] 任务2开始
 17:31:39.314251+0800 testP[29849:2247785] 任务1开始
 17:31:40.317949+0800 testP[29849:2247791] 任务2结束
 17:31:41.318231+0800 testP[29849:2247785] 任务1结束
 17:31:41.318588+0800 testP[29849:2247785] 完成了
 ```
 
 可以看到任务1和任务2同时执行，因为任务1耗时2秒，所以在任务2后1秒完成，然后发出通知，
 
 `dispatch_group_enter`和`dispatch_group_leave`总是成对出现，不然可能导致group没有被释放，从而没有notify；或者group提前释放，导致`EXC_BAD_INSTRUCTION`, group提前释放.
 
 `dispatch_group_enter`和`dispatch_group_leave`可以理解为给group添加手动计数，`dispatch_group_enter`会给group加1，`dispatch_group_leave`就是减一，group初始计数为0。
 
 当group初始计数为0时，就会执行notify通知，比如如下代码
 
 ```objc
 dispatch_group_t group = dispatch_group_create();
 dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
 dispatch_group_notify(group, queue, ^{
    NSLog(@"完成了");
 });
 
 dispatch_group_enter(group);
 dispatch_async(queue, ^{
     NSLog(@"任务1开始");
     sleep(2);
     NSLog(@"任务1结束");
     dispatch_group_leave(group);
 });
 dispatch_group_enter(group);
 dispatch_async(queue, ^{
     NSLog(@"任务2开始");
     sleep(1);
     NSLog(@"任务2结束");
     dispatch_group_leave(group);
 });
 ```
 
 输出为

```objc
 
 17:45:46.296758+0800 testP[30209:2259157] 任务2开始
 17:45:46.296758+0800 testP[30209:2259158] 任务1开始
 17:45:46.296766+0800 testP[30209:2259150] 完成了
 17:45:47.301499+0800 testP[30209:2259157] 任务2结束
 17:45:48.299812+0800 testP[30209:2259158] 任务1结束
 将dispatch_group_notify移到最前，就不会在group完成后得到notify，而是提前执行了
 ```
 
 
 ## dispatch_barrier_sync 和 dispatch_barrier_async

 
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190314102550.png)
 
 ### dispatch_barrier_sync
 
 
 ```objc
 /*!
 * @function dispatch_barrier_sync
 *
 * @abstract
 * Submits a barrier block for synchronous execution on a dispatch queue.
 为队列上的同步执行提交阻塞的代码块。
 *
 * @discussion
 * Submits a block to a dispatch queue like dispatch_sync(), but marks that
 * block as a barrier (relevant only on DISPATCH_QUEUE_CONCURRENT queues).
 将块提交到dispatch_sync（）等调度队列，但将该块标记为阻塞（仅与DISPATCH_QUEUE_CONCURRENT队列相关）。
 *
 * See dispatch_sync() for details.
 *
 * @param queue
 * The target dispatch queue to which the block is submitted.
 * The result of passing NULL in this parameter is undefined.
 block要提交的目标队列，传递NULL参数的结果未定义。
 *
 * @param block
 * The block to be invoked on the target dispatch queue.
 * The result of passing NULL in this parameter is undefined.
 */
 #ifdef __BLOCKS__
 API_AVAILABLE(macos(10.7), ios(4.3))
 DISPATCH_EXPORT DISPATCH_NONNULL_ALL DISPATCH_NOTHROW
 void
 dispatch_barrier_sync(dispatch_queue_t queue,
 DISPATCH_NOESCAPE dispatch_block_t block);
 #endif
  
 ```
 
 
 我们可以看到：
 
 Task1,2,3不是顺序执行的因为是异步，但是都在barrier的前面，Task4,5在barrier的后面执行。
 aa和bb都在主线程进行输出。
 执行完barrier，才会将后面的任务4，5插入到队列执行。

 
 下面大家看一下简单的示例：
 
 ```objc
 - (void)initSyncBarrier{
 
     //1 创建并发队列
     dispatch_queue_t concurrentQueue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
     
     //2 向队列中添加任务
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 1,%@",[NSThread currentThread]);
     });
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 2,%@",[NSThread currentThread]);
     });
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 3,%@",[NSThread currentThread]);
     });
     dispatch_barrier_sync(concurrentQueue, ^{
         [NSThread sleepForTimeInterval:1.0];
         NSLog(@"barrier");
     });
     NSLog(@"aa, %@", [NSThread currentThread]);
     
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 4,%@",[NSThread currentThread]);
     });
     NSLog(@"bb, %@", [NSThread currentThread]);
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 5,%@",[NSThread currentThread]);
     });
 }
 
 ```
 
 看一下输出结果
 
 ```
 2019-03-08 16:21:06.771861+0800 MultiThreadDemo-多线程[10078:8485574] Task 3,<NSThread: 0x600003aa0600>{number = 5, name = (null)}
 2019-03-08 16:21:06.771905+0800 MultiThreadDemo-多线程[10078:8485572] Task 1,<NSThread: 0x600003aada40>{number = 3, name = (null)}
 2019-03-08 16:21:06.771905+0800 MultiThreadDemo-多线程[10078:8485573] Task 2,<NSThread: 0x600003a91480>{number = 4, name = (null)}
 2019-03-08 16:21:07.772210+0800 MultiThreadDemo-多线程[10078:8485082] barrier
 2019-03-08 16:21:07.772518+0800 MultiThreadDemo-多线程[10078:8485082] aa, <NSThread: 0x600003ac2700>{number = 1, name = main}
 2019-03-08 16:21:07.772812+0800 MultiThreadDemo-多线程[10078:8485082] bb, <NSThread: 0x600003ac2700>{number = 1, name = main}
 2019-03-08 16:21:07.772841+0800 MultiThreadDemo-多线程[10078:8485574] Task 4,<NSThread: 0x600003aa0600>{number = 5, name = (null)}
 2019-03-08 16:21:07.773076+0800 MultiThreadDemo-多线程[10078:8485573] Task 5,<NSThread: 0x600003a91480>{number = 4, name = (null)}
 
 ```
 
 我们可以看到：
 
 *   Task1,2,3不是顺序执行的因为是任务是异步的，但是都在barrier的前面，Task4,5在barrier的后面执行。
 *   aa和bb都在主线程进行输出。
 *   执行完barrier，才会将后面的任务4，5插入到队列执行。
 
 
 ### dispatch_barrier_async


 ```objc

 /*!
 * @function dispatch_barrier_async
 *
 * @abstract
 * Submits a barrier block for asynchronous execution on a dispatch queue.
 为队列上的异步执行提交阻塞的代码块。
 *
 * @discussion
 * Submits a block to a dispatch queue like dispatch_async(), but marks that
 * block as a barrier (relevant only on DISPATCH_QUEUE_CONCURRENT queues).
 提交block块到dispatch_async()队列，但是标记该代码块为阻塞（仅与DISPATCH_QUEUE_CONCURRENT队列相关）。
 *
 * See dispatch_async() for details.
 *
 * @param queue
 * The target dispatch queue to which the block is submitted.
 * The system will hold a reference on the target queue until the block
 * has finished.
 * The result of passing NULL in this parameter is undefined.
 block要提交到的目标队列，系统会保持对目标队列的引用，直到block完成。传递NULL参数的结果未定义。
 *
 * @param block
 * The block to submit to the target dispatch queue. This function performs
 * Block_copy() and Block_release() on behalf of callers.
 * The result of passing NULL in this parameter is undefined.
 要提交到的目标队列的block， 这个函数代表调用者执行Block_copy（）和Block_release（）。传递NULL参数的结果未定义。
 */
 #ifdef __BLOCKS__
 API_AVAILABLE(macos(10.7), ios(4.3))
 DISPATCH_EXPORT DISPATCH_NONNULL_ALL DISPATCH_NOTHROW
 void
 dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
 #endif
  ```
 

 下面看一个简单的实例
 
 ```objc
 - (void)initAsyncBarrier{
 
     //1 创建并发队列
     dispatch_queue_t concurrentQueue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
     
     //2 向队列中添加任务
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 1,%@",[NSThread currentThread]);
     });
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 2,%@",[NSThread currentThread]);
     });
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 3,%@",[NSThread currentThread]);
     });
     dispatch_barrier_async(concurrentQueue, ^{
         [NSThread sleepForTimeInterval:1.0];
         NSLog(@"barrier");
     });
     NSLog(@"aa, %@", [NSThread currentThread]);
     
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 4,%@",[NSThread currentThread]);
     });
     
     NSLog(@"bb, %@", [NSThread currentThread]);
     
     dispatch_async(concurrentQueue, ^{
        NSLog(@"Task 5,%@",[NSThread currentThread]);
     });
 }
 
 ```
 
 看一下输出结果
 
 ```
 2019-03-08 16:22:23.692011+0800 MultiThreadDemo-多线程[10174:8486392] aa, <NSThread: 0x600003edd400>{number = 1, name = main}
 2019-03-08 16:22:23.692057+0800 MultiThreadDemo-多线程[10174:8487061] Task 1,<NSThread: 0x600003e8ea40>{number = 3, name = (null)}
 2019-03-08 16:22:23.692115+0800 MultiThreadDemo-多线程[10174:8487062] Task 2,<NSThread: 0x600003ea0080>{number = 4, name = (null)}
 2019-03-08 16:22:23.692136+0800 MultiThreadDemo-多线程[10174:8486491] Task 3,<NSThread: 0x600003ea33c0>{number = 5, name = (null)}
 2019-03-08 16:22:23.692214+0800 MultiThreadDemo-多线程[10174:8486392] bb, <NSThread: 0x600003edd400>{number = 1, name = main}
 2019-03-08 16:22:24.692511+0800 MultiThreadDemo-多线程[10174:8486491] barrier
 2019-03-08 16:22:24.692799+0800 MultiThreadDemo-多线程[10174:8486491] Task 4,<NSThread: 0x600003ea33c0>{number = 5, name = (null)}
 2019-03-08 16:22:24.692799+0800 MultiThreadDemo-多线程[10174:8487062] Task 5,<NSThread: 0x600003ea0080>{number = 4, name = (null)}
 
 ```
 
 大家可以看到：
 
 *   Task1,2,3不是顺序执行的因为是异步，但是都在barrier的前面，Task4,5在barrier的后面执行。
 *   aa和bb都在主线程进行输出。
 *   **不用执行完barrier，就可以将任务4，5插入到队列中，但是仍然需要执行完barrier，才会执行任务4和5。**
 
 * [dispatch_barrier_async和dispatch_barrier_sync的区别... - 简书](https://www.jianshu.com/p/a0ce5e51286d)
 * [dispatch_barrier_sync 和dispatch_barrier_async的区别 - 简书](https://www.jianshu.com/p/e4d5b26b6a36)

共同点：
 
 1. 等待在它前面插入队列的任务先执行完
 2. 等待他们自己的任务执行完再执行后面的任务
 
 不同点：
 
 1. `dispatch_barrier_sync`将自己的任务插入到队列的时候，需要等待自己的任务结束之后才会继续插入被写在它后面的任务，然后执行它们
 2. `dispatch_barrier_async`将自己的任务插入到队列之后，不会等待自己的任务结束，它会继续把后面的任务插入到队列，然后等待自己的任务结束后才执行后面任务。
 3. 你也可以这么理解，它们二者的差别在于插入barrier后面任务的时机不同。后面任务执行顺序都要在barrier之后，这一点是相同的。
 
 ### 相同点
 
 *   等待在它前面插入队列的任务先执行完
 
 *   等待他们自己的任务执行完再执行后面的任务
 
 ### 不同点
 
 *   `dispatch_barrier_sync`将自己的任务插入到队列的时候，需要等待自己的任务结束之后才会继续插入被写在它后面的任务，然后执行它们。
 
 *   `dispatch_barrier_async`将自己的任务插入到队列之后，不会等待自己的任务结束，它会继续把后面的任务插入到队列，然后等待自己的任务结束后才执行后面任务。


 ## dispatch_semaphore
 
 1. `dispatch_semaphore_create` 创建一个semaphore  就是创建一个全局的变量，小于0时会阻塞当前线程
 2. `dispatch_semaphore_signal` 发送一个信号       给信号量加1
 3. `dispatch_semaphore_wait` 等待信号   给信号量减1
 这个东西本质是就是立flag，让flag小于0，线程就阻塞了，只有让flag大于0，才能继续
 
 网上的说明例子
 
 ```objc
 // 创建队列组
 dispatch_group_t group = dispatch_group_create();
 // 创建信号量，并且设置值为10
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 for (int i = 0; i < 100; i++){
     /*
     *  由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，
     *  从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
     */
     
     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
     dispatch_group_async(group, queue, ^{
         NSLog(@"%i",i);
         sleep(2);
         // 每次发送信号则semaphore会+1，
         dispatch_semaphore_signal(semaphore);
     });
 }
 ```
 
 应用1 网络请求

```objc

 _block BOOL isok = NO;
 dispatch_semaphore_t sema = dispatch_semaphore_create(0);
 Engine *engine = [[Engine alloc] init];
 [engine queryCompletion:^(BOOL isOpen) {
    isok = isOpen;
    dispatch_semaphore_signal(sema);
 } onError:^(int errorCode, NSString *errorMessage) {
     isok = NO;
     dispatch_semaphore_signal(sema);
 }];
 dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
 
 // todo what you want to do after net callback
 
 ```
 
 应用2 获取权限
 
 ```objc
 
 //创建通讯簿的引用
 addBook=ABAddressBookCreateWithOptions(NULL, NULL);
 //创建一个出事信号量为0的信号
 dispatch_semaphore_t sema=dispatch_semaphore_create(0);
 //申请访问权限
 ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error){
 
 //greanted为YES是表示用户允许，否则为不允许
 if (!greanted) {
    tip=1;
 }
 //发送一次信号
 dispatch_semaphore_signal(sema);
 
 });
 //等待信号触发
 dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
 ```
 
 ## 参考
 
*  [GCD之同步任务 | CD's log](https://chdo002.github.io/2018/03/28/GCD%E4%B9%8B%E5%90%8C%E6%AD%A5%E4%BB%BB%E5%8A%A1/)

 
 */
