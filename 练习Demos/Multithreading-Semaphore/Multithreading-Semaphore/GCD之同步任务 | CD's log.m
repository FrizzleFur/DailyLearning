//
//  GCD之同步任务 | CD's log.m
//  Multithreading-Semaphore
//
//  Created by MichaelMao on 2018/8/22.
//  Copyright © 2018年 frizzlefur. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 [GCD之同步任务 | CD's log](https://chdo002.github.io/2018/03/28/GCD%E4%B9%8B%E5%90%8C%E6%AD%A5%E4%BB%BB%E5%8A%A1/)
 
 Dispatch Group
 需要在大量任务都执行完成后，执行其他任务，可以用 Dispatch Group
 
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
 2018年4月18日更新
 对于网络请求这种异步任务，还需要使用 dispatch_group_enter和dispatch_group_leave,来手动处理下，先上代码
 
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
 输出为
 
 17:31:39.314251+0800 testP[29849:2247791] 任务2开始
 17:31:39.314251+0800 testP[29849:2247785] 任务1开始
 17:31:40.317949+0800 testP[29849:2247791] 任务2结束
 17:31:41.318231+0800 testP[29849:2247785] 任务1结束
 17:31:41.318588+0800 testP[29849:2247785] 完成了
 可以看到任务1和任务2同时执行，因为任务1耗时2秒，所以在任务2后1秒完成，然后发出通知，
 
 dispatch_group_enter和dispatch_group_leave总是成对出现，不然可能导致group没有被释放，从而没有notify；或者group提前释放，导致EXC_BAD_INSTRUCTION,group提前释放
 
 dispatch_group_enter和dispatch_group_leave可以理解为给group添加手动计数，dispatch_group_enter会给group加1，dispatch_group_leave就是减一，group初始计数为0。
 
 当group初始计数为0时，就会执行notify通知，比如如下代码
 
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
 输出为
 
 17:45:46.296758+0800 testP[30209:2259157] 任务2开始
 17:45:46.296758+0800 testP[30209:2259158] 任务1开始
 17:45:46.296766+0800 testP[30209:2259150] 完成了
 17:45:47.301499+0800 testP[30209:2259157] 任务2结束
 17:45:48.299812+0800 testP[30209:2259158] 任务1结束
 将dispatch_group_notify移到最前，就不会在group完成后得到notify，而是提前执行了
 
 dispatch_barrier_sync 和 dispatch_barrier_async
 网上找到的
 
 dispatch_async(queue, ^{
 NSLog(@"1");
 });
 dispatch_async(queue, ^{
 NSLog(@"2");
 });
 dispatch_async(queue, ^{
 NSLog(@"3");
 });
 // dispatch_barrier_sync 这个和  dispatch_async与dispatch_sync之间的区别类似
 dispatch_barrier_async(queue, ^{
 NSLog(@"000000");
 });
 dispatch_async(queue, ^{
 NSLog(@"4");
 });
 dispatch_async(queue, ^{
 NSLog(@"5");
 });
 dispatch_async(queue, ^{
 NSLog(@"6");
 });
 dispatch_semaphore
 1、dispatch_semaphore_create 创建一个semaphore  就是创建一个全局的变量，小于0时会阻塞当前线程
 2、dispatch_semaphore_signal 发送一个信号       给信号量加1
 3、dispatch_semaphore_wait 等待信号   给信号量减1
 这个东西本质是就是立flag，让flag小于0，线程就阻塞了，只有让flag大于0，才能继续
 
 网上的说明例子
 
 // 创建队列组
 dispatch_group_t group = dispatch_group_create();
 // 创建信号量，并且设置值为10
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 for (int i = 0; i < 100; i++){
 /*
 *  由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，
 *  从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
 *
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
dispatch_group_async(group, queue, ^{
    NSLog(@"%i",i);
    sleep(2);
    // 每次发送信号则semaphore会+1，
    dispatch_semaphore_signal(semaphore);
});
}
应用1 网络请求

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
应用2 获取权限

//创建通讯簿的引用
addBook=ABAddressBookCreateWithOptions(NULL, NULL);
//创建一个出事信号量为0的信号
dispatch_semaphore_t sema=dispatch_semaphore_create(0);
//申请访问权限
ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error)
{
    //greanted为YES是表示用户允许，否则为不允许
    if (!greanted) {
        tip=1;
    }
    //发送一次信号
    dispatch_semaphore_signal(sema);
});
//等待信号触发
dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

 */
