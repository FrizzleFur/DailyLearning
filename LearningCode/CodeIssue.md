--------------------2017-08-18--------------------

> 今天在做捕手一个弹出的提示的时候，想模仿之前做的会员商品的提示，使用一个VC来控制，但是，这个出现了不走代理方法的情况

![](http://oc98nass3.bkt.clouddn.com/2017-08-18-15030194584149.jpg)

其实这以前是参考分享页面所写的方法，以下是代码：

### MemberProductAlertView
```
#import "MemberProductAlertView.h"
@protocol MemberProductAlertViewDelegate <NSObject>

- (void)highPricePage;
- (void)memberApplyPage;
- (void)closeMemberProductAlertView;

@end

@interface MemberProductAlertView : UIView

@property (nonatomic, assign)MemberProductType memberProductType;
@property (nonatomic, weak)id <MemberProductAlertViewDelegate> delegate;

- (instancetype)initWithType:(MemberProductType)memberProductType;

@end
```

### MemberProductAlertViewController

```

- (void)setupUI{
    shadowView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    shadowView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    [shadowView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shadowView];
    
    memberProductAlertView = [[MemberProductAlertView alloc] initWithType:_memberProductType];
    memberProductAlertView.frame = self.view.bounds;
    memberProductAlertView.delegate = self;
    memberProductAlertView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:memberProductAlertView];
    
    CGFloat contentWidth = 270;
    memberProductAlertView.width = contentWidth;
    memberProductAlertView.height = _memberProductType == MemberProductTypeEnjoy?240:288;
    memberProductAlertView.centerX = self.view.width/2;
    memberProductAlertView.centerY = self.view.height/2;
}

```

代理`MemberProductAlertViewDelegate`
```

#pragma mark - MemberProductAlertViewDelegate

- (void)closeMemberProductAlertView{
    [self dismiss];
}


- (void)memberApplyPage{
    if ([self.delegate respondsToSelector:@selector(pushToMemberApplyVC)]) {
        [self.delegate pushToMemberApplyVC];
    }
}

- (void)highPricePage{
    if ([self.delegate respondsToSelector:@selector(pushToHighPriceVC)]) {
        [self.delegate pushToHighPriceVC];
    }
}
```

但是`MemberProductAlertView`的代理都不响应了，点击按钮和点击`shadowView`的时候，都没有响应, `debug`发现, 点击时候的`self.delegate`是`nil`, 

```

- (void)clickCancelBtn{
    if ([self.delegate respondsToSelector:@selector(clickBindNameCheckViewCancelBtn)]) {
        [self.delegate clickBindNameCheckViewCancelBtn];
    }
}

- (void)clickConfirmBtn{
    NSString *nameTextFieldStr = nameTextField.text;
    if (nameTextFieldStr.length == 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(clickBindNameCheckViewConfirmBtn:)]) {
        NSString *confirmName = Format(@"%@%@", nameTextField.text, nameLabel.text);
        [self.delegate clickBindNameCheckViewConfirmBtn:confirmName];
    }
}
```


我对比了以前做的会员商品的实现，发现差别只在于,在商品详情中，会员提示控制器`memberProductAlertVC`是作为一个全局变量的。

```
//会员商品提示
- (void)handleMemberProductWithType:(MemberProductType)memberProductType{
    memberProductAlertVC = [[MemberProductAlertViewController alloc] initWithType:memberProductType];
    memberProductAlertVC.delegate = self;
    memberProductAlertVC.rootVC = self;
    [memberProductAlertVC showInWindowWithType:self.detail.memberProductType];
}
```


而在账号提示`BindWechatAccountController`类中，提示类`BindNameCheckViewController`是作为一个局部变量存在，是因为这样就找不到代理了吗？

```
- (void)clickOldAccountLoginBtn{
        BindNameCheckViewController *bindNameCheckVC = [[BindNameCheckViewController alloc] init];
        [bindNameCheckVC showInWindow];
}
```


### 思考

我感觉，因为在展示遮罩的`VC`的时候，其实，这个`VC`是不在导航控制器的栈的`ViewControllers`中的,所以如果是局部变量的话，这个`clickOldAccountLoginBtn`方法执行完后，bindNameCheckVC就不再被当前展示的界面类（账号登录）所持持有，虽然在`bindNameCheckView.delegate = self`,提示的`bindNameCheckView`代理赋值给了`bindNameCheckVC`，但是`bindNameCheckVC`已经不在栈里面了，只是它的`View`还在
`keyWindow`上面，但是控制器已经不在内存中了，所以`debug``bindNameCheckView.delegate`会发现是`nil`.


```
- (void)showInWindow{
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    shadowControl.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        shadowControl.alpha = 1.0;
    } completion:^(BOOL finished) {
        shadowControl.alpha = 1.0;
    }];
}
```

```
- (void)clickOldAccountLoginBtn{
    BindNameCheckViewController *bindNameCheckVC = [[BindNameCheckViewController alloc] init];
    [bindNameCheckVC showInWindow];
}
```

所以最好让当前展示的界面类持有遮罩的`VC`，这样，当前展示的界面类没有消失的时候，遮罩的`VC`作为一个属性，还是在的，所以点击的一些交互，遮罩的`VC`作为提示View的代理，可以实现交互。
```
//会员商品提示
- (void)handleMemberProductWithType:(MemberProductType)memberProductType{
    memberProductAlertVC = [[MemberProductAlertViewController alloc] initWithType:memberProductType];
    memberProductAlertVC.delegate = self;
    memberProductAlertVC.rootVC = self;
    [memberProductAlertVC showInWindowWithType:self.detail.memberProductType];
}
```

然后注意一点：每次遮罩的`VC`消失的时候，就清将提示的遮罩`VC`和提示的view清除掉

```
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if (memberProductAlertVC) [memberProductAlertVC dismiss];
//    if (bindNameCheckVC) [bindNameCheckVC dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25 animations:^{
        bindNameCheckView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
```
------------------------------------------------------------------------

