# iOS UIWebView 与 WKWebView

一、概述

UIWebView自iOS2就有，WKWebView从iOS8才有，毫无疑问WKWebView将逐步取代笨重的UIWebView。WKWebView只能用代码创建，而且自身就支持了右滑返回手势allowsBackForwardNavigationGestures和加载进度estimatedProgress等一些UIWebView不具备却非常好用的属性。通过简单的测试即可发现UIWebView占用过多内存，且内存峰值更是夸张。WKWebView网页加载速度也有提升，但是并不像内存那样提升那么多。下面列举一些其它的优势：

更多的支持HTML5的特性
官方宣称的高达60fps的滚动刷新率以及内置手势
Safari相同的JavaScript引擎
将UIWebViewDelegate与UIWebView拆分成了14类与3个协议(官方文档说明)
另外用的比较多的，增加加载进度属性：estimatedProgress``
 

二、UIWebView的用法

1、加载网页或本地文件

```objc
// 网页url
NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
// 网络请求
NSURLRequest *request =[NSURLRequest requestWithURL:url];
// 加载网页
[self.webview loadRequest:request];
```

注意，如果上述的：

```objc
// 网页url
NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
```

改为：

```objc
// 网页url
NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
```

会无法加载网页并有如下提示：

2017-02-07 15:29:46.768 WebViewTest[12469:1020441] App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.
原因为ATS禁止了HTTP的明文传输，因为它不安全。可以修改Info.plist文件，让它临时允许明文传输。

解决办法：
在Info.plist文件中添加”App Transport SecuritySettings”，Type为”Dictionary”，再添加一个item为”Allow Arbitray Loads”，Type 为”Boolean”，“Value”为“YES”即可。
 

2、网页导航刷新有关函数

// 刷新
- (void)reload;
// 停止加载
- (void)stopLoading;
// 后退函数
- (void)goBack;
// 前进函数
- (void)goForward;
// 是否可以后退
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
// 是否可以向前
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
// 是否正在加载
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
3、相关代理协议

#pragma mark - UIWebViewDelegate
// 是否允许加载网页
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"允许加载网页");
    return YES;
}

// 开始加载网页时调用
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载网页");
}

// 网页加载完成时调用
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"网页加载完成");
}

// 网页加载错误时调用
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"网页加载错误时调用");
}
4、与JS交互

（1）OC调用JS

OC调用JS主要通过下面方法：

- (nullable NSString )stringByEvaluatingJavaScriptFromString:(NSString )script;
我们只需要传入要执行的JS代码块即可，如果有返回值，可以接收NSString类型返回值。

例如，我们获取网页Title并赋值给导航控制器Title：

/**
 "调用JS"按钮点击事件
 */
-(void)rightAction{
    
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];

}
运行结果：

Snip20170208_15

点击“调用JS”按钮后：

Snip20170208_16

 

（2）JS调用OC

JS是不能执行OC代码的，但是可以变相的执行，JS可以将要执行的操作封装到网络请求里面，然后OC拦截这个请求，获取URL里面的字符串解析即可，这里用到代理协议的如下方法：

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
例如：

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // 获取请求路径
    NSString *url = request.URL.absoluteString;
    // 定义的协议
    NSString *scheme = @"ios://";
    if ([url hasPrefix:scheme]) {
        // 获得协议后面的路径
        NSString *path = [url substringFromIndex:scheme.length];
        // 利用?切割路径 分割方法与参数
        NSArray *subpaths = [path componentsSeparatedByString:@"?"];
        // 方法名 methodName == sendMessage:number2:
        NSString *methodName = [subpaths firstObject];
        // 参数  如：200&300
        NSArray *params = nil;
        if (subpaths.count == 2) {
            params = [[subpaths lastObject] componentsSeparatedByString:@"&"];
        }
        // 调用本地函数
        [self performSelector:NSSelectorFromString(methodName) withObjects:params];
        return NO;
    }
    NSLog(@"想加载其他请求，不是想调用OC的方法");
    return YES;
}
三、WKWebView的用法

WKWebView 和 UIWebView 的基本使用方法相类似，但是需要导入头文件 #import <WebKit/WebKit.h>。

1、加载网页

加载网页方法与UIWebView相同：

// 网页url
NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
// 网络请求
NSURLRequest *request =[NSURLRequest requestWithURL:url];
// 加载网页
[self.webview loadRequest:request];
2、加载文件

// 创建url(可以随便从桌面拉张图片)
NSURL *url = [NSURL fileURLWithPath:@"/Users/ios/Desktop/图片/xxx.jpg"];
// 加载文件
[webView loadFileURL:url allowingReadAccessToURL:url];
其他几个加载方法：

// 其它三个加载函数
- (WKNavigation *)loadRequest:(NSURLRequest *)request;
- (WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL;
3、网页导航刷新有关函数

@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
- (WKNavigation *)goBack;
- (WKNavigation *)goForward;
- (WKNavigation *)reload;
- (WKNavigation *)reloadFromOrigin; // 增加的函数
- (WKNavigation *)goToBackForwardListItem:(WKBackForwardListItem *)item; // 增加的函数
- (void)stopLoading;
reloadFromOrigin会比较网络数据是否有变化，没有变化则使用缓存，否则从新请求。
goToBackForwardListItem：比向前向后更强大，可以跳转到某个指定历史页面
 

4、常用属性

allowsBackForwardNavigationGestures：BOOL类型，是否允许左右划手势导航，默认不允许
estimatedProgress：加载进度，取值范围0~1
title：页面title
scrollView.scrollEnabled：是否允许上下滚动，默认允许
backForwardList：WKBackForwardList类型，访问历史列表，可以通过前进后退按钮访问，或者通过goToBackForwardListItem函数跳到指定页面
 

5、相关代理协议

几个常用代理协议：

（1）WKNavigationDelegate

最常用，和UIWebViewDelegate功能类似，追踪加载过程，有是否允许加载、开始加载、加载完成、加载失败。下面会对方法做简单的说明，并用数字标出调用的先后次序：1-2-3-4-5

三个是否允许加载方法：

// 接收到服务器跳转请求之后调用 (服务器端redirect)，不一定调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation; 

// 3 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

// 1 在发送请求之前，决定是否跳转 
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
追踪加载过程方法:

// 2 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;

// 4 开始获取到网页内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
 

（2）WKUIDelegate

UI界面相关，原生控件支持，三种提示框：输入、确认、警告。首先将web提示框拦截然后再做处理。

// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler;

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler;

// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
6、与JS交互

（1）WKWebView加载JS

//JS文件路径
NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
//读取JS文件内容
NSString *jsContent = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
//创建用户脚本对象，
//WKUserScriptInjectionTimeAtDocumentStart :HTML文档创建后，完成加载前注入，类似于<head>中
//WKUserScriptInjectionTimeAtDocumentEnd :HTML文件完成加载后注入,类似于<body>中
WKUserScript *script = [[WKUserScript alloc] initWithSource:jsContent injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
//添加用户脚本
[webView.configuration.userContentController addUserScript:script];
（2）WKWebView执行JS方法

//执行JS方法
```swift
[webView evaluateJavaScript:@"test()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    //result为执行js方法的返回值
    if(error){
        NSLog(@"Success");
    }else{
        NSLog(@"Fail");
    }
}];
```


# 参考

[iOS UIWebView与WKWebView | 李峰峰博客](https://imlifengfeng.github.io/article/528/)