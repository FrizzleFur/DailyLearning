## WebViewJavascriptBridge

> WebViewJavascriptBridge是一个Objective-C与JavaScript进行消息互通的三方库。通过WebViewJavascriptBridge，我们可以很方便的实现OC和Javascript互调的功能。

### WebViewJavascriptBridge实现互调的过程

是在OC环境和Javascript环境各自保存一个相互调用的bridge对象
每一个调用之间都有`id`和`callbackid`来找到两个环境对应的处理。

### 核心类主要包含如下几个：

* WebViewJavascriptBridge_JS：Javascript环境的Bridge初始化和处理。负责接收OC发给Javascript的消息，并且把Javascript环境的消息发送给OC。
* WKWebViewJavascriptBridge/WebViewJavascriptBridge：主要负责OC环境的消息处理，并且把OC环境的消息发送给Javascript环境。
* WebViewJavascriptBridgeBase：主要实现了OC环境的Bridge初始化和处理。

### OC环境的初始化

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20190215154647.png)

【结论】：所有与Javascript之间交互的信息都存储在messageHandlers和responseCallbacks中。这两个属性记录了OC环境与Javascript交互的信息。


### OC环境注册方法

```objc
//注册OC方法，以供Javascript调用
[self.bridge registerHandler:@"testClientCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"Javascript传递数据: %@", data);
    responseCallback(@"OC发给JS的返回值");
}];

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    _base.messageHandlers[handlerName] = [handler copy];
}
```

4. API

4.1 Objective-C API
// 为指定的 web view （WKWebView/UIWebView/WebView）创建一个 JavaScript Bridge 
+ (instancetype)bridgeForWebView:(id)webView;
// 注册一个名称为 handlerName 的 handler 给 JavaScript 调用
// 当在 JavaScript  中调用 WebViewJavascriptBridge.callHandler("handlerName")  时，该方法的 WVJBHandler 参数会收到回调
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
// 调用 JavaScript 中注册过的 handler
// data 参数为调用 handler 时要传递给 JavaScript 的参数，responseCallback 传给 JavaScript 用来回调
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
// 如果你需要监听 web view 的代理方法的回调，可以通过该方法设置你的 delegate
- (void)setWebViewDelegate:(id)webViewDelegate;
4.2 JavaScript API
// 注册一个  handler 给 Objective-C 调用
registerHandler(handlerName: String, handler: function);
// 调用 Objective-C 中注册过的 handler
callHandler(handlerName: String);
callHandler(handlerName: String, data: undefined);
callHandler(handlerName: String, data: undefined, responseCallback: function);


## 参考

* [WebViewJavascriptBridge 从原理到实战 - 简书](https://www.jianshu.com/p/6f34903be630)
1. [WebViewJavascriptBridge 原理解析 - iOS - 掘金](https://juejin.im/entry/58e4a76a44d904006d2a7778#OC%E5%8F%91%E6%B6%88%E6%81%AF%E7%BB%99WEB)
2. [WebViewJavascriptBridge的详细使用 - 简书](https://www.jianshu.com/p/ba6358b1eec3)