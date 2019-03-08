//
//  ViewController.m
//  MultiThreadDemo-多线程
//
//  Created by MichaelMao on 2019/3/8.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

// MARK: - test method


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

//    [self initSyncBarrier];
    [self initAsyncBarrier];
//    [self testSemaphore];
//    [self testLoopSemaphore];
}


// MARK: - GCD Semaphore

- (void) testSemaphore {
    dispatch_semaphore_t lock  = dispatch_semaphore_create(1);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        NSLog(@"%s","First task starting");
        sleep(1);
        NSLog(@"%s", "First task is done");
        sleep(1);
        dispatch_semaphore_signal(lock);
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        NSLog(@"%s","Second task starting");
        sleep(1);
        NSLog(@"%s", "Second task is done");
        sleep(1);
        dispatch_semaphore_signal(lock);
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        NSLog(@"%s","Thrid task starting");
        sleep(1);
        NSLog(@"%s", "Thrid task is done");
        sleep(1);
        dispatch_semaphore_signal(lock);
        
    });
}


- (void)testLoopSemaphore {
    
    // 1. 创建锁🔐
    
    dispatch_semaphore_t lock  = dispatch_semaphore_create(4); //设置信号总量
    
    NSLog(@"11111111");
    
    // 2. 拿到全局队列，循环创建第一种任务
    
    for (NSInteger i = 0; i < 10; i++) {
        // 由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
        //参考https://www.jianshu.com/p/04ca5470f212
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER); //信号量-1
            sleep(2);
            NSLog(@"0~~~~~~~~%zd~~~~~~~~~%@", i, [NSThread currentThread]);
            dispatch_semaphore_signal(lock);  //信号量+1
        });
    }
    
    NSLog(@"2222222222");
    
    // 3. 拿到全局队列，循环创建第二种任务
    
    for (NSInteger i = 0; i < 10; i++) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            sleep(2);
            NSLog(@"1~~~~~~~~%zd~~~~~~~~~%@", i, [NSThread currentThread]);
            dispatch_semaphore_signal(lock);
        });
        
    }
    // 4. 打印结束
    
    NSLog(@"3333333333");
    
}

// MARK: - GCD dispatch barrier


// dispatch_barrier_sync
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

// dispatch_barrier_async
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




// MARK: - GCD Dead Lock


/**< 线程死锁 */
- (void)threadLockExample{
    NSLog(@"currentThread = %@", [NSThread currentThread]);
    
    NSLog(@"1"); // 任务1
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2"); // 任务2
        NSLog(@"currentThread = %@", [NSThread currentThread]);
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"3"); // 任务3
            NSLog(@"currentThread = %@", [NSThread currentThread]);
        });
        NSLog(@"4"); // 任务4
        NSLog(@"currentThread = %@", [NSThread currentThread]);
    });
    NSLog(@"5"); // 任务5
}






@end
