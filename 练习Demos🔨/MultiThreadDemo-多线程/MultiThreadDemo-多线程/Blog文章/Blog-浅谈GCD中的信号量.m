//
//  Blog-浅谈GCD中的信号量.m
//  MultiThreadDemo-多线程
//
//  Created by MichaelMao on 2019/3/8.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 [浅谈GCD中的信号量 - 简书](https://www.jianshu.com/p/04ca5470f212)
 
 浅谈GCD中的信号量
 纸简书生 关注
 2016.03.26 00:04* 字数 1087 阅读 19517评论 39喜欢 66
 在客户端开发中，我们很少用到信号量，并发数。甚至有些同学根本就没听说过这两个概念。今天就简单说说GCD中的信号量。
 
 基本概念
 ** 关于iOS开发中，多线程基本的概念和基本使用，我在这里就不在重复说了**。但是为了照顾到有的同学可能还不是对基本的概念不熟悉，可以参考一下这篇文章并发其实很简单
 
 说说信号量，并发数
 如果你有计算机基础，那么下面这段话应该很简单就能理解
 
 信号量就是一个资源计数器，对信号量有两个操作来达到互斥，分别是P和V操作。 一般情况是这样进行临界访问或互斥访问的： 设信号量值为1， 当一个进程1运行是，使用资源，进行P操作，即对信号量值减1，也就是资源数少了1个。这是信号量值为0。系统中规定当信号量值为0是，必须等待，知道信号量值不为零才能继续操作。 这时如果进程2想要运行，那么也必须进行P操作，但是此时信号量为0，所以无法减1，即不能P操作，也就阻塞。这样就到到了进程1排他访问。 当进程1运行结束后，释放资源，进行V操作。资源数重新加1，这是信号量的值变为1. 这时进程2发现资源数不为0，信号量能进行P操作了，立即执行P操作。信号量值又变为0.次数进程2咱有资源，排他访问资源。 这就是信号量来控制互斥的原理
 
 ** 简单来讲 信号量为0则阻塞线程，大于0则不会阻塞。则我们通过改变信号量的值，来控制是否阻塞线程，从而达到线程同步。**
 
 当然再NSoperation下可以直接设置并发数，就没有这么麻烦了。
 
 GCD如何使用信号量
 我们使用GCD的时候如何让线程同步，目前我能想到的就三种
 
 1.dispatch_group
 2.dispatch_barrier
 3.dispatch_semaphore
 1和2比较简单，也是比较常用的。这里不在介绍。如果不清楚可以参考并发其实很简单
 这里主要讲讲dispatch_semaphore
 
 在GCD中有三个函数是semaphore的操作，
 分别是：
 
 dispatch_semaphore_create 创建一个semaphore
 dispatch_semaphore_signal 发送一个信号
 dispatch_semaphore_wait 等待信号
 简单的介绍一下这三个函数，第一个函数有一个整形的参数，我们可以理解为信号的总量，dispatch_semaphore_signal是发送一个信号，自然会让信号总量加1，dispatch_semaphore_wait等待信号，当信号总量少于0的时候就会一直等待，否则就可以正常的执行，并让信号总量-1，根据这样的原理，我们便可以快速的创建一个并发控制来同步任务和有限资源访问控制。
 
 看代码
 
 // 创建队列组
 dispatch_group_t group = dispatch_group_create();
 // 创建信号量，并且设置值为10
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 for (int i = 0; i < 100; i++)
 {   // 由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
 dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
 dispatch_group_async(group, queue, ^{
 NSLog(@"%i",i);
 sleep(2);
 // 每次发送信号则semaphore会+1，
 dispatch_semaphore_signal(semaphore);
 });
 }
 上面的注释已经把如何通过控制信号量来控制线程同步解释的比较浅显了。关键就是这句：
 
 // 由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
 
 实际应用
 在开发中我们需要等待某个网络回调完之后才执行后面的操作，根据啥给你们分析的过程，可以写出如下代码，达到这种效果。
 
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
 在具体一点，做通讯录的时候需要判断权限，才能获取通讯录。如果我没记错。再iOS9之前可以通过如下方式获得。这也是我第一次实际应用信号量的时候。
 获取通讯录
 
 //创建通讯簿的引用
 addBook=ABAddressBookCreateWithOptions(NULL, NULL);        //创建一个出事信号量为0的信号
 dispatch_semaphore_t sema=dispatch_semaphore_create(0);        //申请访问权限
 ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error)
 {
 //greanted为YES是表示用户允许，否则为不允许
 if (!greanted) {
 tip=1;
 }            //发送一次信号            dispatch_semaphore_signal(sema);
 
 });        //等待信号触发
 dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
 
 
 */
