## 解析-Weex


## 集成

[开放平台-文档中心](https://open.taobao.com/doc.htm?docId=104829&docType=1)

```
Undefined symbols for architecture x86_64:
  "_OBJC_CLASS_$_SRWebSocket", referenced from:
      objc-class-ref in TBWXDevTool(WXDebugger.o)
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

添加SocketRocket依赖：copy 这里 SRWebSocket.h/m 到自己的工程 （如果你的工程使用了cocoaPods，添加 pod 'SocketRocket' 到Podfie 中即可）



## Weex模块

Weex 在iOS端主要分为几个重要的模块 例如WXSDKEngine, WXSDKInstance, WXBridgeManager, WXComponent, WXModuleProtocol等，下面解读一下:

1. WXSDKEngine 主要用于初始化WeexSDK的环境,加载Weex内置main.js文件以及Weex官方提供的Component,Module,Handler。
2. WXSDKInstance 一个 WXSDKInstance 对应一个Weex页面,如果是SPA应用,就对应一个ViewController,但是我们的大部分场景应该不是SPA,所以基本在Weex项目中，一个 WXSDKInstance 对应一个ViewController。
3. WXBridgeManager,WXBridgeContext,WXJSCoreBridge是JS与iOS进行交互的,所有JS与Native的交互都在这三个类的各层封装中。
4. WXComponent 组件基类，所以跟UI相关的，我们都得自己实现iOS端的组件，都必须继承于 WXComponent
5 .WXImgLoaderProtocol WeexSDK 默认没有实现图片加载，需要自己实WXImgLoaderProtocol协议,于此类似的还有networkprotocol,这样大大方便了开发者去自实现一些功能。

UI Component	JS-OC 通信	自定义Module
WXImageComponent，WXTextComponent等	WXBridgeContext,WXJSCoreBridge等	WXDomModule等
实践自定义Component,Module

## WXDevtool 


WXDevtool也是官方提供的 SDK，结合 weex-toolkit脚手架工具，能够帮助你快速查看 app 运行状态和调试 Weex 中的 JS 代码；相信大家都使用过官方的 Playground App调试过 Weex 页面，为了方便调试项目，我们需要将 ‘扫一扫调试’ 功能集成到自己的项目中，客户端需要做的就是集成 WXDevtool,然后参照Playground App中的 WXScannerVC的实现，或者直接将 WXScannerVC 移植到自己的项目中。


## 加载JS


  在ViewController中通过renderWithURL加载远程js文件。

```objc
_instance = [[WXSDKInstance alloc] init];  
 _instance.viewController = self;  
_instance.frame = self.view.frame;  
__weak typeof(self) weakSelf = self;  
 _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
    };  
_instance.onFailed = ^(NSError *error) {  
        NSLog(@"Weex onFailed");
    }; 
_instance.renderFinish = ^(UIView *view) {  
        NSLog(@"Weex renderFinish");
    };
[_instance renderWithURL:self.url 
 soptions:@{@"bundleUrl":[self.url absoluteString]} data:nil];

```

## Weex的优劣势

通过对比可以得出Weex的优势

轻量级的js框架 Vue 相当于 React 轻量的可不是一点半点
打包可以将基础包和业务包分开,方便缩小业务代码的容量
跨平台这块儿只能说 在Web端 比 React Native 强一些
Weex的劣势:

组件暂不支持本地图片，需指明width和height否则无法显示
不支持z-index
ListView 性能


## Demo

* [zwwill/yanxuan-weex-demo: High quality pure Weex demo / 网易严选 App 感受 Weex 开发](https://github.com/zwwill/yanxuan-weex-demo)