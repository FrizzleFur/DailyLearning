## WKWebView

> WKWebView 是苹果在 WWDC 2014 上推出的新一代 webView 组件，用以替代 UIKit 中笨重难用、内存泄漏的 UIWebView。WKWebView 拥有60fps滚动刷新率、和 safari 相同的 JavaScript 引擎等优势。



在 UIWebView 上当内存占用太大的时候，App Process 会 crash；而在 WKWebView 上当总体的内存占用比较大的时候，WebContent Process 会 crash，从而出现白屏现象。在 WKWebView 中加载下面的测试链接可以稳定重现白屏现象:



### WKWebView Cookie存储


业界普遍认为 WKWebView 拥有自己的私有存储，不会将 Cookie 存入到标准的 Cookie 容器 NSHTTPCookieStorage 中。

实践发现 WKWebView 实例其实也会将 Cookie 存储于 NSHTTPCookieStorage 中，但存储时机有延迟，在iOS 8上，当页面跳转的时候，当前页面的 Cookie 会写入 NSHTTPCookieStorage 中，而在 iOS 10 上，JS 执行 document.cookie 或服务器 set-cookie 注入的 Cookie 会很快同步到 NSHTTPCookieStorage 中，FireFox 工程师曾建议通过 reset WKProcessPool 来触发 Cookie 同步到 NSHTTPCookieStorage 中，实践发现不起作用，并可能会引发当前页面 session cookie 丢失等问题。

WKWebView Cookie 问题在于 WKWebView 发起的请求不会自动带上存储于 NSHTTPCookieStorage 容器中的 Cookie。


### WKProcessPool
苹果开发者文档对 WKProcessPool 的定义是：A WKProcessPool object represents a pool of Web Content process. 通过让所有 WKWebView 共享同一个 WKProcessPool 实例，可以实现多个 WKWebView 之间共享 Cookie（session Cookie and persistent Cookie）数据。不过 WKWebView WKProcessPool 实例在 app 杀进程重启后会被重置，导致 WKProcessPool 中的 Cookie、session Cookie 数据丢失，目前也无法实现 WKProcessPool 实例本地化保存。


### Workaround

由于许多 H5 业务都依赖于 Cookie 作登录态校验，而 WKWebView 上请求不会自动携带 Cookie, 目前的主要解决方案是：

a、WKWebView loadRequest 前，在 request header 中设置 Cookie, 解决首个请求 Cookie 带不上的问题；
WKWebView * webView = [WKWebView new]; 
NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://h5.qzone.qq.com/mqzone/index"]]; 

[request addValue:@"skey=skeyValue" forHTTPHeaderField:@"Cookie"]; 
[webView loadRequest:request];
b、通过 document.cookie 设置 Cookie 解决后续页面(同域)Ajax、iframe 请求的 Cookie 问题；
注意：document.cookie()无法跨域设置 cookie

WKUserContentController* userContentController = [WKUserContentController new]; 
WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: @"document.cookie = 'skey=skeyValue';" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]; 

[userContentController addUserScript:cookieScript];
这种方案无法解决302请求的 Cookie 问题，比如，第一个请求是 www.a.com，我们通过在 request header 里带上 Cookie 解决该请求的 Cookie 问题，接着页面302跳转到 www.b.com，这个时候 www.b.com 这个请求就可能因为没有携带 cookie 而无法访问。当然，由于每一次页面跳转前都会调用回调函数：

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
可以在该回调函数里拦截302请求，copy request，在 request header 中带上 cookie 并重新 loadRequest。不过这种方法依然解决不了页面 iframe 跨域请求的 Cookie 问题，毕竟-[WKWebView loadRequest:]只适合加载 mainFrame 请求。



### WKWebView相比于UIWebView：

* 速度快了一倍，内存却减少为原来的一半；
* cookie不再是自动携带，需要手动设置；
* 交互更加顺畅，比如app底部四个tabBar也都是网页的，在UIWebView下点击，整个H5页面都会闪白一下，但是在WKWebView下点击，四个tabBar效果与原生app效果更加类似，不会有闪白现象。
* 增减了一些代理方法，更方便的进行协议拦截和进度条展示

* 如果WKWebView在加载url的时候需要添加cookie，需要先手动获取当前NSHTTPCookieStorage中的所有cookie，然后将cookie放到NSMutableURLRequest请求头中

```objc
- (void)loadRequestWithUrlString:(NSString *)urlString {
    
    // 在此处获取返回的cookie
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:cookieValue forHTTPHeaderField:@"Cookie"];

    [self loadRequest:request];
}

```

## 参考

1. [WKWebView 那些坑](https://mp.weixin.qq.com/s?__biz=MzA3NTYzODYzMg==&mid=2653578513&idx=1&sn=961bf5394eecde40a43060550b81b0bb&chksm=84b3b716b3c43e00ee39de8cf12ff3f8d475096ffaa05de9c00ff65df62cd73aa1cff606057d&mpshare=1&scene=23&srcid=0119VtvRXXpX8zD7Hon2AcE0#rd)
2. [iOS的Cookie存取看我绝对够！！ - 简书](https://www.jianshu.com/p/d2c478bbcca5))