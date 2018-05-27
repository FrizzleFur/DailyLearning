
# Charles学习总结

> `Charles`是一个代理服务器，这意味着它位于你的应用程序和计算机的网络连接之间。当查尔斯自动配置您的网络设置时，它改变了您的网络配置以路由所有通过它的流量。这允许查尔斯检查计算机上的所有网络事件。
>代理服务器处于强大的地位，但这也意味着滥用的可能性。这就是为什么SSL如此重要：数据加密防止代理服务器和其他中间件窃听敏感信息。
>`Charles`还可以生成自己的自签名证书，您可以在`Mac`和`iOS`设备上安装`SSL / TLS`加密。由于此证书不是由受信任的证书颁发者颁发的，所以您需要告诉您的设备显式地信任它。一旦安装并受信任，查尔斯将能够解密SSL事件！

<!-- more -->

![Charles代理截取网络请求](http://upload-images.jianshu.io/upload_images/225323-7a91242f018bec1e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 安装`Charles`的`Profile`证书文件

#### iOS

### 安装`Charles`的`Profile`证书文件

#### iOS

* 1. 打开`Safari`，输入 `https://chls.pro/ssl`. Safari 将促进你安装 `SSL`证书.

* 2. 安装 `SSL Profile`

![SSL Profile](http://upload-images.jianshu.io/upload_images/225323-665eded9be1c8d59.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这样就可以抓`SSL`请求了，I guess~

`SSL`(Secure Sockets Layer 安全套接层)

`SSL`加密敏感请求和响应信息。你可能认为这会让查尔斯对所有`HTTPS`事件都毫无意义，对吧？不!查尔斯有一个偷偷摸摸的绕过加密的方法，你很快就会知道的

#### MacOS

在`Charles`中，到Help菜单中，选择SSL代理安装`Charles Root`证书，钥匙链访问将打开。找到`Charles`代理…输入，双击获取信息。展开信任部分，在使用此证书时，请将其更改为始终信任的使用系统默认值。然后关闭证书信息窗口，您将会提示您的管理员密码来更新系统信任设置。

您可能需要退出并重新打开Safari来查看更改。

###  过滤抓取请求

开始抓包后，随着时间的推移，抓取到的网络包越来越多，这是我们可以使用过滤功能，来过滤出我们想要的网络请求。

在`Proxy -> Recording Settings` 中可以设置网络包的过滤选项。

![Proxy -> Recording Settings](http://upload-images.jianshu.io/upload_images/225323-7f1a0730d7e4a603.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

过滤选项中有`Include` 和 `Exclude` 两种选项。只有当 `Include` 为空时，`Exclude` 中的设置才会生效。过滤条件支持通配符。

###  模拟慢速网络


在做iPhone开发的时候，我们常常需要模拟慢速网络或者高延迟的网络，以测试在移动网络下，应用的表现是否正常。Charles对此需求提供了很好的支持。

在`Charles`的菜单上，选择"Proxy"->"Throttle Setting"项，在之后弹出的对话框中，我们可以勾选上“Enable Throttling”，并且可以设置`Throttle Preset`的类型。如下图所示：

![Charles模拟慢速网络](http://upload-images.jianshu.io/upload_images/225323-8a6a2fc64a8e317a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### 修改网络包

#### 修改历史请求

可以将历史的请求修改后，再次发送。

只需选中某个请求，点击上方工具栏中的蓝色钢笔按钮（第四个），就可以进行修改。完成修改后，点击下方的`Execute`执行请求。

![修改历史请求](http://upload-images.jianshu.io/upload_images/225323-77f7b7557087c523.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 添加断点

窗口上方的工具栏中，第四个按钮就是`Enable BreakPoints`，用来启用或禁用断点。也可以在 `Proxy -> BreakPoints Setting`中设置更多具体内容。

在`Charles`中可以像调试程序一样添加断点。方法是右键点击左侧窗口的某个请求，选择`BreakPoints`添加断点。这样当这个请求发出或者收到`response`的时候，就会先被`Charles`拦截下来，并触发断点。

![](http://oc98nass3.bkt.clouddn.com/2017-06-16-14975811405296.jpg)

触发断点后，可以对断点的网络包进行各种编辑，然后再继续。点击`Execute`就可以继续。

同时，也可以在`Proxy -> BreakPoints Setting`设置断点的各种规则。例如，是在`request`的时候触发还是 `response`的时候。

![](http://oc98nass3.bkt.clouddn.com/2017-06-16-14975811567801.jpg)

由于设置断点时，`Charles`是先拦截下整个网络包，再触发断点，当网络包比较大的时候，常常会导致应用超时，触发网络错误的警告，因此，自动地根据规则修改网络包有时显得尤为重要。这就是下面要说的篡改。

拦截后可以修改`post`参数

![](http://oc98nass3.bkt.clouddn.com/2017-06-16-14975814097323.jpg)

然后可以修改`Response`，不用去麻烦测试修改数据，很爽有木有~

![](http://oc98nass3.bkt.clouddn.com/2017-06-16-14975818540454.jpg)

下面要介绍的就是直接`Rewrite`了啦~

### 篡改（Rewrite）

`Rewrite` 是按照一组事先设置的规则，篡改特定的网络包中的数据。

在 `Tools -> Rewrite` 中，选中`Enable Rewrite` 来开启 `Rewrite`。

#### Rewrite

勾选 `Debug in Error Log` 选项，就能在 `Charles` 控制台中看到 `Rewrite` 的记录。

首先要在右侧的规则列表中添加一个新规则。在新规则中添加要`Rewrite`的`Location`，然后再下方添加具体的篡改规则。规则中可以使用通配符。

![](http://oc98nass3.bkt.clouddn.com/2017-06-16-14975830449452.jpg)

这样稍后匹配条件的网络包到达的时候，`Charles`就会自动将其中的内容按规则篡改。

### 映射Map 

`Charles`提供的映射功能可以将本地文件或者远程的服务器作为某个请求的`Response`。可以方便地进行一些特殊的测试。

1. Map Local

本地映射，在 `Tools -> Map Local`。可以选择一个本地文件作为某个请求的`Response`，并且 `Charles`会帮你封装好`Response`。

2. Remote Remote

远程映射和本地映射的功能类似，只是将数据源换成了远程服务器。相当于将请求交给另一个服务器处理

网络环境模拟

`Charles` 还可以模拟不同网速环境，可以很方便地测试应用在网络差的情况下的bug。

在 `Proxy -> Throttle Settings` 中勾选 `Enable Throttling`，或者直接点击窗口上方的工具栏中的乌龟🐢按钮就可以启用，这个按钮十分形象。

在`Proxy -> Throttle Settings` 中，添加要针对的`Locations`，如果选中`Only for selected hosts`，并且`Locations`中有数据，则只有 `Locations`列表中的请求会被限速，否则会对全局限速。在`Throttle Configuration`中可以对网络环境进行十分详细的配置，包括网络的稳定程度、网速、环境等。

![Throttle Setting.jpg](http://oc98nass3.bkt.clouddn.com/15274446735157.jpg)

### SSL 代理

在使用 `Charles` 的过程中，我们会发现，只有未加密的 `Http` 请求才能被`Charles` 正确的解析出数据，其余的`Https` 请求都处于加锁的状态，但我们不可避免的需要抓取 `Https` 的包。`SSL`代理就可以完美解决这个问题。

要启用 `SSL` 代理，先要在 `Proxy -> SSL Proxying Settings` 中勾选 `Enable SSL Proxying`，然后配置要代理的 `Location`，一般可以直接填星号，以匹配所有请求。

![SSL 代理设置.jpg](http://oc98nass3.bkt.clouddn.com/15274447179251.jpg)接下来还要安装 Charles 的证书。

`Charles`中的`HTTPS`代理的原理是，`Charles` 充当一个中间人，针对目标服务器动态地生成一个使用`Charles`根证书（Charles CA Certificate）签名的证书；请求发生的时候， `Charles`会接收web 服务器的证书，而把自己生成的证书给客户端看。

因此在在使用`Charles`作为`HTTPS`代理时，客户端在请求`HTTPS`接口的时候会弹出安全警告，提示`Charles`根证书不被信任。我们需要添加`Charles`根证书为信任证书中。

方法如下：

1、点击`Help -> SSL Proxying`，根据被抓包设备的类型，来选择对应的安装选项（如果是 `OSX` 就直接选择`Install Charles Root Certificate`）；

2、如果是`iOS`真机，则会弹出下面的提示，此时不用按上面的提示来配置代理，只要按照上文的步骤配置过代理了就可以了。然后在`Safari`中打开`chls.pro/ssl`安装`Charles`的证书，就 OK 了。

![提示.jpg](http://oc98nass3.bkt.clouddn.com/15274447915315.jpg)

设置好 `SSL` 代理后，`HTTPS` 请求就统统解锁啦！

![SSL 代理设置完成后.jpg](http://oc98nass3.bkt.clouddn.com/15274447540047.jpg)注意：iOS9以上系统要使用 Charles 作为 SSL 代理的话要关闭 APP Transport Security ，关闭方法为在APP的info.plist文件添加以下key：

```xml
<key>NSAppTransportSecurity</key>
<dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
</dict>
```
Charles 是一个强大的抓包调试工具，它的功能远不止这些，但本篇作为一篇入门的博客，就先介绍这么多啦，更多功能等待大家探索~
套餐

**注意** 对于一些抓取请求的处理，关闭`Charles`后可能不会保存，所以可以到处文件哦~


### 配合Postman

`Postman`是一个测试`API`的利器。

![Postman.png](http://oc98nass3.bkt.clouddn.com/15274446343146.jpg)
`Charles`搭配`Postman`更好用噢~
`Postman`是`Chrome`浏览器中的一个小应用，可以在`Chrome`应用商城中找到。是居家旅行测试`Web API`的好帮手！

## Todo

学习[Postman](https://www.getpostman.com/)

## 参考

1. [老司机活动中心的个人空间 - 哔哩哔哩 ( ゜- ゜)つロ 乾杯~ Bilibili](http://space.bilibili.com/96624811?from=search&seid=4588586201256310704#!/)

2.  [OSX/iOS 抓包工具 Charles 入门 - 简书](http://www.jianshu.com/p/dbcf1ef87a63)

3. [Charles Proxy Tutorial for iOS](https://www.raywenderlich.com/154244/charles-proxy-tutorial-ios)

4. [Charles Proxy: Getting Started](https://videos.raywenderlich.com/screencasts/836-charles-proxy-getting-started) 


