# LearningThinking

-------
### 2017-07-07


> 今天在`Review Code`的时候，发现自己以前写的一个分析类中的代码有几个地方挺有意思的。

比如，经常需要调用分享，然而，点击的分享按钮没有做短时间内的去重点击，而执行调用动画是需要一点时间的， 所以可能在
点击调起分享视图，调起动画还没完成的时候，又执行几次调起动画，就会出现多个分享视图，而解决这一点，只需要加入一个监听状态`isShareVCShowing`就行了，如果正在展示动画，就忽略调起请求。

定义一个属性

```
BOOL isShareVCShowing;      //分享页是否正在弹出
```

放入到展示的方法中：

```
- (void)showInWindow {
    isShareVCShowing = true;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    shareView.top = self.view.height;
    shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
    } completion:^(BOOL finished) {
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
        isShareVCShowing = false;
    }];
}
```

然而这样做会有一个问题，成员变量`isShareVCShowing`暴露在`.h`文件里，可能其他类拿到分享这个视图会进行修改，这样就不太好。所以，做一下处理：


在外部定义一个方法，把`isShareVCShowing`属性放在`.m`文件中，

```
- (BOOL)isShareVCShowing;/**< ShareViewController是否正在展示动画中 */
```

实现其get方法：


```
- (BOOL)isShareVCShowing {
    return isShareVCShowing;
}
```

这样，在别的`VC`中调起分享的时候，只需要获取`ShareVC`的展示状态，加入判断即可。


```
BOOL isShareVCShowing =  [shareVC isShareVCShowing];
if (isShareVCShowing) return;//避免多次点击
```


### Where To Go From here?

我在想，既然是这个展示状态是`ShareVC`的属性，是否可以在`ShareVC`这个类里自己做好处理？

其实很简单，把判断卸载在每次调用的`showInWindow`方法上：

```
- (void)showInWindow {
    if (isShareVCShowing) {
        NSLog(@"isShareVCShowing = %d", isShareVCShowing);
        return;
    }
    isShareVCShowing = true;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    shareView.top = self.view.height;
    shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
    } completion:^(BOOL finished) {
        shareView.bottom = self.view.height;
        shadowView.alpha = 1.0;
        isShareVCShowing = false;
    }];
}
```


-------
### 2017-08-14

[深度重构UIViewController](http://mrpeak.cn/blog/controller/)

如何去定义重构，以我的理解可以归纳为两个关键词：分解，连接。

重构的前提是复杂，臃肿，不直观，重构的手段是分解之后再连接。以映客的直播界面为例，UI元素，用户事件，服务器交互等基础元素都非常之多，以一个简单的MVP去归类代码犹嫌不足，我们还需要进一步的分解成view1,view2…viewN,presenter1,presenter2…presenterN,model1,model2…modelN，第二个问题是如何把这一个个的类文件或者说功能单位合理组织连接起来。完成上述两步我们就完成了一次重构，每一次将代码打散再串联就是一次重构。

分解UIViewController


写了那么多Controller，让你来说下一个Controller都细分为哪些更小的功能单位，你能随口说出来么？只有做过足够多的业务，才能慢慢对Controller的构成有自己的理解。

当然可以回答说MVC或者MVP，但这个答案粒度太粗，一个Controller内部会发生哪些事可以说的更细，我们看下VIPER的答案：

    View: displays what it is told to by the Presenter and relays user input back to the Presenter.
    Interactor: contains the business logic as specified by a use case.
    Presenter: contains view logic for preparing content for display (as received from the Interactor) and for reacting to user inputs (by requesting new data from the Interactor).
    Entity: contains basic model objects used by the Interactor.
    Routing: contains navigation logic for describing which screens are shown in which order
    View不用多说，可以分解成更多的子View，最后合成一个树形结构。

Entity自然是代表Model。

MVC当中的C，MVP当中的P，被细分成了Interactor，Presenter，和Routing。这三个角色各自负责什么职责呢？

Routing比较清楚，处理页面之间的跳转。我见过的项目代码里，很少有把这一部分单独拎出来的，但其实很有意义，这部分代表的是不同Controller之间耦合依赖的方式，无论是从类关系描述的角度还是Debug的角度，都能帮助我们快速定位代码。

Interactor和Presenter初看起来很类似，似乎都是在处理业务逻辑。但业务逻辑其实是个大的归类，可以描述任何一种业务场景和行为。Interactor当中有个很重要的术语：use case，这个术语很多技术文章中都会遇见，它代表的是一个完整的，独立的，细分过后的业务流程，比如我们App当中的登录模块，它是一个业务单位，但它其实可以进一步的细分为很多的use case：

use case 1: 验证邮箱长度

use case 2: 密码强度检验

use case 3: 从Server查询user name是否可用

…

user case N

定义use case有什么好处呢？

好处当然是分门别类，结构清晰。你把100本书堆一堆，或者放书架上按类别摆放，下次找书的时候那种方式你更舒服？独立出一个个的use case还有一个好处是方便unit test，如果项目对每一个use case都有写对应的unit test，每次遇到“前一发动全身“的业务更改，可以边杯茶边写代码。

我见过不少代码都体现不出use case的分类，可以回头看下自己当前项目的登录模块，上面我提到的这些case有没有在类文件当中合理摆放，还是都搅在一起？

所以VIPER当中interactor的说法是强化大家写单独的use case的意识，打开interactor.m，看到一个函数代表一个use case，同一类的use case再用#pragma mark 归在一块，别人看你代码时能不赏心悦目吗？

再说到Presenter，Presenter可以看做是上面一个个use case的使用者和响应者。使用者将各个use case串联起来描述一个完整详细的业务流程，比如我们的登录模块，每次用户点击按钮注册的时候，会触发一系列的use case，从检验用户输入合法性，设备网络状态，服务器资源是否可用，到最后处理结果并展示，这就是一个完整的业务流程，这个流程由Presenter来描述。响应者表示Presenter在接收到服务器反馈之后进一步改变本地的状态，比如view的展示，新的数据修改等，甚至会调用Routing发生页面跳转。

说到这里就比较明了了，interactor和routing都是服务的提供方，presenter是服务的使用和集成方。VIPER说白了不过是对传统的MVC当中的C做了进一步细分。

能不能分的更细呢？

当然可以，VIPER的分法是一种通用的做法，我们还可以从业务的角度去做细分。拿映客的直播界面做例子，比如Presenter当中包含了很多完整的业务流程：

收到用户消息并展示
收到礼品消息并展示
收到弹幕消息并展示
收到用户进出房间的事件，处理并展示
收到XXX，处理并展示
以Objective C语言的特性，我们可以生成更多的Presenter Category来安置这些流程，比如LivePresenter+Message, LivePresenter+Gift, LivePresenter+Danmu, LivePresenter+Room, LivePresenter+XXX。

不要觉得上面几个业务流程很简单，一个presenter处理绰绰有余，我前段时间刚好做过一个直播项目，Presenter类超过1000行代码很轻松。

还可以进一步细分，一个功能复杂繁多的页面基本上离不开UITableView，而tableview的代码量主要在于delegate和datasource。这两个职责当然可以放在presenter当中，或者我们向Android学习，把它们也独立出来放到单独的类文件中去处理，比如叫做Adapter，用代码来说就是：


```
_tableView.delegate = self.adapter;
_tableView.dataSource = self.adapter;

```
和tableView相关的这些代码都搬到了adapter当中：

```
@protocol UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

@end

@protocol UITableViewDataSource<NSObject>

@required
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
```

我们的Presenter就变得更加干净了，看起来和刚大扫除过的房间一样令人愉悦。

好了，到这里我们盘子里的牛排已经被切成很多小块了，可以开始享用这些美味的代码了，继续我们的第二步工作：连接。

连接
先看下我们分解之后有哪些元素：

view(1…N), model(1…N), interactor, presenter(1…N), routing, adapter。看着应该粒度够细了，对于复杂的Controller，我个人习惯的做法和VIPER相近，但略有不同，Interactor当中的use case通过分层的架构被我放到server layer，分层的架构是另一个话题，这里不做细述。其他元素基本一致。

至于怎么连接，手段无非就是OC的几种类交互机制：

Delegate, Target-Action, Block, Notification, KVO。

这几者之间的差异可以参考objc.io的一篇经典文章。选择不同对耦合度，开发便捷性，调试是否方便等都会产生影响，如何应用不同的机制将各个单位串联起来就看架构师自己的积累和理解了，任何一个选择都有其优势和局限性。

如果拿捏不准选哪个好的时候，我个人建议就使用delegate，朴素可靠且直观。delegate需要在不同的元素之间传递，代码量会偏多一些，但优点在protocol定义清晰，耦合在哪里一目了然，记得要注意循环引用的问题。

我早些时候其他几种机制都在实际项目中做过尝试，最后综合比较还是倾向于选择delegate，再后来经过一番脑洞（主要是为了解决传递delegate所带来的额外代码量），利用runtime特性，做了一个CDD机制来自动串联各个功能单位。CDD的详细介绍在之前的博客中有，这里也不细述了，其本质或者说最终目的还是在于连接。

说完了分解和连接，Controller的重构完成了大半，还剩下一个至关重要的概念：状态分享。

尽量避免跨类，跨模块或跨层共享状态
我之前在一篇博客中谈到过对于程序状态的维护。状态是否维护得好对于程序的整体稳定性很有影响，对于Controller当中的状态维护我有一个简单的建议：

传递状态的时候尽可能Copy
之前流行的函数式编程其实就很强调无状态性，无状态不是让大家不定义状态变量，而是避免函数之间的状态共享，具体到OC当中，就是不要在不同的功能单位里使用指向同一块内存拷贝的地址，为什么共享状态是一件危险的事，我在之前的文章中也介绍过。

一般来说，我们从Model Layer或者说数据层拿到的model实例，扔给Controller使用的时候应该是一份新的拷贝，在不同的类单位里共享NSMutableString或者NSMutableArray，NSMutableDictionary很容易让你的代码变得不稳定，而且这类不稳定性一般很难调试，debug填坑的时候经常按下葫芦浮起瓢。

在controller内部传递model或者state的时候，我们应该也尽量使用copy行为，任何state你一旦暴露出去就不再安全，自己创建，自己修改，自己销毁才是正途。说到

我之前介绍Facebook架构的时候就提到过，Facebook当中的model layer是由一个单独开发团队维护的，应用层开发人员（Controller开发人员）获取到的都是新的拷贝，要修改某个属性不一定有接口，甚至要向model的维护团队提交增加接口的申请，对于state维护的谨慎度可见一斑。

### 2018-04-16

[Google 将于明年彻底关闭 Chrome Apps，以后就是 PWA 的天下了_搜狐科技_搜狐网](http://www.sohu.com/a/209075468_115128)

2016 年，Google 提出了 “Progressive Web Apps”（PWA），志在增强 Web 体验。可显著提高加载速度、可离线工作、可被添加至主屏、全屏执行、推送通知消息……等等这些特性可使 Web 应用渐进式地变成 App，甚至与 App 相匹敌。

而现在，Google 正打算以 PWA 完全取代原先的 Chrome Apps，并且，已经将 Chrome Web Store 中“Apps”的部分删除，如果你打算通过以前的网址访问该板块，将会直接跳转到“扩展程序”。此外，还以邮件方式正式告知开发者，他们计划在 2018 年年初彻底关闭 Chrome 浏览器的 App 支持。

尽管两者都旨在使 Web 引用程序更适合本机桌面端，但 PWA 是跨平台和跨浏览器的，而 Chrome Apps 显然局限于谷歌浏览器并使用专有的 Chrome API。


一个PWA, 一个微信小程序，前端就要变成风口，需要拥抱未来的技术变化。

感觉腾讯就像美国的Google, 阿里有点像Apple

