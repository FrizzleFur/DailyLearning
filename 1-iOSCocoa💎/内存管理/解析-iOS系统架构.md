# 解析-iOS系统架构

> 虽然iOS系统内核使用极简的微内核架构，但内容依然十分庞大，所以会分
系统架构、进程调度、内存管理和文件系统四个部分进行阐述。

## 系统架构

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216150040.png)

### iOS的架构

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216141730.png)

* UI层： 主要有SpringBoard、Spotlight等UI交互界面
* 应用框架层：主要有 Cocoa Touch
* 核心框架层：主要有 OpenGL、Quartz等图形、多媒体组件
* Darwin：操作系统核心，包括XNU内核和UNIX shell

### Mach

Mach 是 XNU的原子核，是一个微内核轻量级操作系统，仅处理最核心的任务

* 进程和线程抽象
* 任务调度
* 进程间通讯和消息传递
* 虚拟内存管理

### iOS 进化史

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216141657.png)

### iOS 使用的技术


#### bundle

平时开发中，我们经常会听到bundle这个词，在阿里大多数情况下bundle表示一个模块或者一个pod 库。实际上，bundle的概念来源于OS X，最先由NeXTSTEP使用。苹果的给出的定义是：** 一个标准化的有层次的结构，保存了可执行的代码以及该代码所需要的资源。**
bundle是framework、plugin、widgets、内核扩展的根基。


#### FSEvents

提供有关文件系统通知的API，通过这个API，用户应用程序可以简单快速地响应文件添加、修改和删除时间，OC中CoreServices框架（Carbon）提供的FSEventStreamCreate及其它相关API是对FSEvents的封装。


####  通知NSNotificationCenter

分布式IPC的一种形式，进程可以通过这种机制广播或监听事件。


####  GCD

Grand Central Dispatch(GCD) 是 Apple 开发的一个多核编程的较新的解决方法。它主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。它是一个在线程池模式的基础上执行的并发任务。在 Mac OS X 10.6 雪豹中首次推出，也可在 iOS 4 及以上版本使用。


#### iOS 的安全机制

* 代码签名：使用SSL验证身份，通过发布者的私钥对公钥进行签名，来验证应用程序的来源以及在传输过程中是否被篡改
* 隔离机制（沙盒化）：不受信任的应用程序必须在一个独立的隔间中运行，隔间实际上就是一个隔离的环境，在这个环境所有的操作都会受到限制，采用“黑名单”风格方法来阻止已知的危险操作，只有在列表具有足够的限制性时才有效果
* Entitlement：更为严格的沙盒，采用“白名单”的方式，只允许那些已知是安全的操作，其他所有操作都不允许，替换当前沙盒机制中采用的“黑名单”方式
* MAC层：强制访问控制 Mandatory Access Control 是iOS沙盒机制的基础，控制应用程序只能访问指定的数据。属于 BSD 相关特性
* MAC中的关键概念是label，label指的是一个预定义的分类，如果请求访问某个对象或者操作时没有提供匹配的label，那么MAC会拒绝访问请求。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216141912.png)


### 用户态和内核态

#### 内核态/用户态转换机制

用户态和内核态的转换机制有两种类型：

#### 自愿转换：

当应用程序要求内核服务的时候，应用程序可以进行一个调用进入内核态，通过一个预定义的硬件指令可以开始进入内核态的切换。这些内核服务称为系统调用

#### 非自愿转换：

当发生执行异常、中断或处理器陷阱的时候，代码的执行会被挂起，并且保留发生错误时候的完整状态。控制权被转交给预定义的内核态错误处理程序或中断服务程序（interrupt service rountine，ISR）

当用户态的程序需要内核服务的时候，会发出一个系统调用，系统调用将控制权转换交给内核。实现系统调用的方法有两种：

* 模拟中断：SVC和SWI指令
* 指令：SYSENTRY 和 SYSCALL

#### Mach Trap

在 iOS 上系统调用编号为负，那么内核流程进入Mach陷阱处理的流程，而不是BSD 系统调用的处理。Mach 陷阱的处理程序成为mach_call_munger[64]
Mach 陷阱是由 mach_mall_munger[64] 处理的。UNIX 和 Mach 调用的参数都要进程 mung 处理，32 位的 unix_syscall 依然包含 munging 操作的代码
mach_trap_table 是一个mach_trap_t 结构体数组。之后跟着是mach_syscall_name_table，其中保存了对应的名字。



## 进程调度

### 进程

进程是独立运行、独立分配资源和独立接受调度的基本单位。进程有三个基本状态。

### 就绪状态

当进已分配到除CPU外的所有必要资源后，只要再获得CPU，便可立即执行，进程这时的状态称为就绪状态。在系统中处于就绪状态的进程往往会有多个，通常将这些进程存入一个队列中，称为就绪队列。

### 执行状态

进程已获得CPU，其程序正在执行。

### 睡眠状态（阻塞状态）

正在执行的进程由于某些事件暂时无法继续执行，便放弃CPU占用转入暂停。阻塞状态的进程也会排入队列中，现代操作系统会根据阻塞原因的不同将处于阻塞状态的进程排入多个队列。导致阻塞的事件有：请求I/O，申请缓冲空间。

### iOS进程生命周期

在iOS中进程通过Progress ID(进程ID，即PID)来唯一辨识。进程还会将其和父进程的亲属关系保存在父进程ID（Parent Progress ID, PPID）中。父进程可以通过fork(或通过posix_spawn)创建子进程，并且预期子进程会消亡。子进程返回的整数由其父进程收集。

进程状态切换 —— 图片引用自《深入解析Mac OS X & iOS 操作系统》

![进程状态切换 —— 图片引用自《深入解析Mac OS X & iOS 操作系统》](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190216150347.png)


### 线程 Thread

* 线程是利用CPU的基本单位，进程是占有资源的基本单位。为了最大化利用进程时间片的方法，引入线程的概念。通过使用多个线程，程序的指向可以分割表面上看上去并发执行的子任务。线程之间切换的开销比较小，只要保存和恢复寄存器即可。多核处理器更是特别和适合线程，因为多个处理器核心共享同样的cache和ARM，为线程间的共享虚拟内存提供了基础。一般一个进程会包括多个线程
* 线程是Mach中的最小的执行单元。线程表示的是底层的机器寄存器状态以及各种调度统计数据。线程从设计上提供了所需要的大量信息，同时又尽可能地维持最小开销。
* 在Mach中线程的数据结构非常巨大，因此大部分的线程创建时都是从一个通用的模板复制而来的，这个模板使用默认值填充这个数据结构，这个模板名为thread_template，内核引导过程中被调用的thread_bootstrap( )负责填充这个模板。thread_create_internal( )函数分配新的线程数据结构，然后将换这个模板的内容负责到新的线程数据结构中。
* Mach API thread_create( ) 就是通过thread_create_internal( )实现的。


### 调度 Scheduling

多进程程序系统中，作业被提交后，必须经过处理机调度，才能被处理机执行。进程调度主要有两种方式，非抢占式和抢占式。现在面向用户的操作系统基本上都采用抢占式调度方式，包括iOS。主要的抢占原则有：

* 优先权原则
* 短作业优先原则
* 时间片原则

由于Mach具有处理器集的抽象，所以 Mach 比Linux 和 Windows 更擅长管理多核处理器：Mach 可以将同一个CPU 的多个核心放在同一个pset管理，并且通过不同的pset管理不同的CPU。

#### 上下文切换（content switch）


上下文切换是暂停某个线程的执行，并且将其寄存器状态记录在某个预定义的内存位置中。寄存器状态是和及其相关的。当一个线程被抢占时，CPU 寄存器中会价值另一个线程保存的线程状态，从而恢复到那个线程的执行。


#### 消息发送实现


Mach 消息发送的逻辑在内核中的两处实现：Mach_msg_overwrite_trap( ) 和 mach_msg_send( )。后者只用于内核态的消息传递，在用户态不可见。
两种情形的逻辑都差不多，遵循以下的流程：

* 调用current_space( ) 获得当前的IPC空间
* 调用current_map( ) 获得的当前的VM空间（vm_map）
* 对消息的大小进行正确性检查
* 计算要分配的消息大小：从send_size参数获得大小，然后加上硬编码的MAX_REAILER_SIZE
* 通过ipc_kmsg_alloc 分配消息
* 复制消息（复制消息send_size字节的部分），然后在消息头设置msgh_size
* 复制消息关联的端口权限，然后通过ipc_kmsg_copyin 将所有out-of-line 数据内存复制到当前的vm_map。ipc_kmsg_copyin 函数调用了ipc_kmsg_copyin_header 和 ipc_kmsg_copyin_body
* 调用ipc_kmsg_send( )发送消息：
* 首先，获得msgh_remote_port 引用，并锁定端口
* 如果端口是一个内核端口（即端口的ip_receiver是内核IPC空间），那么通过ipc_kobject_server( ) 函数处理消息。这个函数会在内核中找到相应的函数来执行消息（或者调用ipc_kobject_notify( )来执行），而且一个会生成消息的应答。
* 不论是哪种端口：也就是说如果端口不在内核空间中，或者从ipc_kobjct_server( ) 返回了应答，这个函数会贯穿到传递消息（或应答消息）的部分，调用ipc_mqueue_send( )，这个函数将消息直接复制到端口的ip_messgaes 队列中并唤醒任何正在等待的线程

#### 消息接收实现


和消息发送的情形类似，Mach 消息接收的逻辑也是现在内核中的两个地方，和发送一样，mach_msg_overwrite_trap( ) 从用户态接收请求，而内核态通过mach_msg_receive( ) 接收消息

* 调用current_space( ) 获得当前的IPC空间
* 调用current_map( ) 获得当前的VM控件（vm_map）
* 不对消息的大小进行检查。这种检查没有必要，因为消息在发送时已经验证过了
* 通过调用ipc_mqueue_copyin( ) 获得IPC队列
* 持有当前线程的一个引用。使用当前线程的引用可使它适应使用Mach 的续体（continuation）模型，续体模型可以避免维护完整线程栈的必要性
* 调用ipc_mqueue_receive( )从队列中取出消息
* 最后，调用mach_msg_receive_results( ) 函数。这个函数也可以从续体中调用


## 内存管理


* 基于栈的内存分配：通常由编译器处理，因为栈中填充的通常是程序的自动变量
* 基于堆的内存分配：用于动态内存分配，只限于用户态使用，在内层面，既没有用户对也没有栈的存在。


## alloca 栈分配

按照传统，**栈一般都是保存自动变量，正常情况栈由系统管理，但是在iOS中某些情况下，程序员也可以选择用栈来动态分配内存**，方法是使用鲜为人知的alloca( ) 这个函数的原型和malloc( )是一样的，区别在于这个函数返回的指针是栈上的地址而不是堆中的地址。
从实现角度，alloca( )从两方面优于malloc( )

在栈中非配空间只不过是简单的修改栈指针寄存器，时间消耗低，不用担心页面错误
当分配空间的函数返回时，栈中分配的空间会自动释放，解决内存地址泄露问题
但是栈空间通常比堆空间受限很多，所以alloca( )非常适合名称较短的函数中对小空间的分配

## 堆分配


堆是由C语言运行时维护的用户态数据结构，通过堆的使用，程序可以不用直接在页面的层次处理内存分配。Darwin的libC 采用了一个基于分配区域（allocation zone）的特殊分配算法
2 BSD内存管理
在iOS中内存的管理是由在Mach层中进行的，BSD只是对Mach接口进行了POSIX封装，方便用户态进程调用。
XNU内存管理的核心机制是虚拟内存管理，在Mach 层中进行的，Mach 控制了分页器，并且向用户态导出了各种 vm_ 和 mach_vm_ 消息接口。 为方便用户态进程使用BSD对Mach 调用进行了封装，通过current_map( ) 获得当前的Mach 内存映射，最后再调用底层的Mach 函数。
2.1 MALLOC 和 zone
BSD 的malloc 系列函数<bsd/sys/malloc.h> 头文件中。函数名为_MALLOC、_FREE、_REALLOC、_MALLOC_ZONE、_FREE_ZONE


#### mcache 和 slab 分配器
mcache机制是BSD 提供的基于缓存的非常高效的内存分配方法。默认实现基于mach zone，通过mach zone提供预分配好的缓存内存。
mcache具有可扩展架构，可以使用任何后端 slab 分配器。
使用mcache 机制的主要优点是速度：内存分配和维护是在每一个 CPU 自有的cache中进行的，因此可以映射到CPU的物理cache，从而极大地提升访问速度。


#### 内存压力
Mach VM层支持VM pressure 的机制，这个机制是可用RAM量低到危险程度的处置，下面我们会详细讲，这里不展开。
当RAM量低到危险时，Mach的pageout 守护程序会查询一个进程列表，查询驻留页面数，然后向驻留页面数最高的进程发送NOTE_VM_PRESSURE ，会在进程队列中发出一个事件。被选中的进程会响应这个压力通知，iOS中的运行时会调用 didReceiveMemoryWarning 方法。
然而有些时候这些操作没有效果，当内存压力机制失败之后，** 非常时间要用非常手段 **， Jetsam机制介入。


## 文件系统


操作系统管理所有的硬件资源，操作系统内核管理最核心的资源CPU和内存。上两篇阐述了Mach通过进程调度机制管理CPU资源以及VM机制管理内存资源。
内核的一个重要内容是管理数据，这些数据包括用户数据和系统数据。为了达到这个目的，数据按照文件和目录的方式组织，文件和目录保存在各种类型的文件系统上。同CPU和内存不同，XNU的文件系统是由BSD负责的。BSD文件系统使用了一个名为虚拟文件系统交换（VFS）的框架。


## 总结

iOS的核心是Darwin，Darwin的核心是XNU，XNU有两个核心，外层的BSD和内层的Mach。由于有两个内核所有有两种系统调用方式。造成这种现象的原因是OS X作为一款PC操作系统希望运行针对UNIX开发的应用，而iOS作为OS X的分支继承了这个特性。

## 参考

1. [iOS OSX Mach Darwin XNU - 简书](https://www.jianshu.com/p/d8d79912dd97)
2. [深入浅出iOS系统内核（1）— 系统架构 - 简书](https://www.jianshu.com/p/029cc1b039d6#1%20iOS%20%E8%BF%9B%E5%8C%96%E5%8F%B2)
3. [深入浅出iOS系统内核（2）— 进程调度 - 简书](https://www.jianshu.com/p/e56c3d28e77d)

