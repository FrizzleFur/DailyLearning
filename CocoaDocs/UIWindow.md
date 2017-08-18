##  UIWindow

```
inherits From
UIView
  UIResponder
    NSObject
```

>一个`UIWindow`对象为您的应用程序的用户界面提供了背景，提供了重要的事件处理行为。Windows没有自己的可视化外观，但它们对于显示应用程序的视图至关重要。屏幕上出现的每一个视图都被一个`UIWindow`所包围，每个`UIWindow`与应用程序中的其他`UIWindow`无关。应用程序接收到的事件最初路由到相应的`UIWindow`对象，然后将这些事件转发到相应的视图中。`UIWindow`与视图控制器一起工作，以实现方向更改和执行许多其他对应用程序操作至关重要的任务。

Windows是应用程序的一个基本部分，但在代码中只与它们进行最低限度的交互。UIKit处理大多数窗口相关的相互作用，与其他对象所需的许多应用程序行为。但是，您需要在应用程序中执行以下操作：

* 提供一个主窗口来显示应用程序的内容。
* 创建附加窗口（如需要）显示附加内容。

大多数应用程序只需要一个窗口，它在设备的主屏幕上显示应用程序的内容。您可以创建额外的窗口，并显示在设备的主屏幕上，但额外的窗口通常用于显示附加外部显示器上的内容。

除了为应用程序的内容提供窗口对象之外，您还可以为其他几个任务使用窗口对象：

* 设置窗口的z轴级别，这将影响窗口相对于其他窗口的可见性。
* 显示窗口并使其成为键盘事件的目标。
* 将坐标值转换为窗口坐标系。
* 更改窗口的根视图控制器。
* 更改显示窗口的屏幕。

你应该很少需要UIWindow类。您可能在窗口中实现的各种行为通常更容易在更高级别的视图控制器中实现。你可能想子几次是覆盖becomekeywindow或resignkeywindow方法来实现自定义行为当一个窗口的关键地位的变化。

![](http://oc98nass3.bkt.clouddn.com/2017-08-16-15028741926601.jpg)



alertView是怎么弹出的？网上查找资料说是，每次执行[alertView show]，这个方法的时候是新建了一个window，将alertView显示在了window上面。代码验证的确是这样的。

代码验证alertView是添加到哪里的。


```- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    tempBtn.frame = CGRectMake(100, 100, 100, 100);
    tempBtn.backgroundColor = [UIColor cyanColor];
    [tempBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tempBtn];

}

- (void)clickBtn:(UIButton *)sender
{
    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"title1" message:@"message1" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert1 show];

 NSLog(@"alert1.window = %@   alert1.window.windowLevel = %f",alert1.window,alert1.window.windowLevel);
    NSLog(@"app.window = %@",app.window);
    NSLog(@"windows == %@",[UIApplication sharedApplication].windows);
}

```

测试结果：


```alert1.window = <_UIAlertControllerShimPresenterWindow: 0x7f9ee8c07940; frame = (0 0; 414 736); opaque = NO; gestureRecognizers = <NSArray: 0x618000056aa0>; layer = <UIWindowLayer: 0x6180000240a0>>   alert1.window.windowLevel = 2001.000000
app.window = <UIWindow: 0x7f9ee8f03f80; frame = (0 0; 414 736); autoresize = W+H; gestureRecognizers = <NSArray: 0x608000052f60>; layer = <UIWindowLayer: 0x608000022100>>
 windows == (
    "<UIWindow: 0x7f9ee8f03f80; frame = (0 0; 414 736); autoresize = W+H; gestureRecognizers = <NSArray: 0x608000052f60>; layer = <UIWindowLayer: 0x608000022100>>"
)
```
通过打印的结果可以看出：
1、alert1.window没有在[UIApplication sharedApplication].windows中出现window和windows的关系参考：http://www.jianshu.com/p/75befce85623，windows中只有app.window也就是当前的最底层的控件。
2、alert1.window的windowLevel是2001比app.window的大，APP.window的windowLevel是0，所以alertView显示在了app.window的上面。相关windowLevel的问题参考：http://www.jianshu.com/p/f60471a7d935

搞懂了alertView显示的大致原理了，那么往我们的需求上靠


## UIScreen

```
inherits From
NSObject
```

一个`UIScreen`对象定义了一个基于硬件的显示相关的属性。iOS设备有主屏幕和零个或多个附加屏幕。一个TVOS装置具有电视连接到设备的主屏幕。使用这个类获取连接到设备上的每个显示器的屏幕对象。每个屏幕对象定义关联显示的边界矩形和其他有趣的属性，如亮度。

当用户连接或断开一个显示iOS设备，系统发出适当的通知你的应用程序。始终注意应用程序的长寿命对象的通知，比如应用程序委托。连接和断开通知可以随时出现，即使您的应用程序在后台暂停。如果您的应用程序在通知到达时被挂起，通知将一直排队，直到您的应用程序在前台或后台再次运行，此时将它交付给您的观察对象。


### objc_setAssociatedObject

使用给定的键和关联策略设置给定对象的关联值。

```
#import "UIViewController+CustomHUD.h"
#import <objc/runtime.h>

@implementation UIViewController (CustomHUD)

static char customHUDKey;
- (CustomHUD *)hud {
    CustomHUD *hud = objc_getAssociatedObject(self, &customHUDKey);
    if (hud == nil) {
        hud = [[CustomHUD alloc] init];
        objc_setAssociatedObject(self, &customHUDKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [hud removeHUD];
    return hud;
}

@end
```
#### objc_getAssociatedObject

返回给定对象与给定对象相关联的值。

```
id objc_getAssociatedObject(id object, const void *key);
```

