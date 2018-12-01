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

![](https://i.loli.net/2018/12/01/5c023dde1f043.jpg)

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



## 参考

1. [WebViewJavascriptBridge 原理解析 - iOS - 掘金](https://juejin.im/entry/58e4a76a44d904006d2a7778#OC%E5%8F%91%E6%B6%88%E6%81%AF%E7%BB%99WEB)
2. [WebViewJavascriptBridge的详细使用 - 简书](https://www.jianshu.com/p/ba6358b1eec3))