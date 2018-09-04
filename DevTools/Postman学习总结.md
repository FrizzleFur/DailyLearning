
# Postman学习总结

[Postman使用手册1——导入导出和发送请求查看响应](http://www.jianshu.com/p/13c8017bb5c8)

>现在的web和移动开发，常常会调用服务器提供restful接口进行数据请求，为了调试，一般会先用工具进行测试，通过测试后才开始在开发中使用。这里介绍一下如何在chrome浏览器利用postman应用进行restful api接口请求测试。

关于Postman的安装方法，可以参考Postman软件安装.

一、导入导出打包的应用

在Postman中导入导出我们的 测试数据包 和 工作环境 非常的方便：

导出数据包：


导出数据包.png
导出工作环境：


导出工作环境 1.png

导出工作环境 2.png
导入数据包：


导入数据包.png
导入工作环境：


导入工作环境.png
二、发送请求和查看响应

1.发送请求

Postman的界面分为 左边的侧边栏 和 右边的请求构建器 两部分。请求构建器允许你可以快速的创建几乎任何类型的请求。一个HTTP请求的四部分：URL、Method、Headers、Body，在Postman中都可以设置。


界面分布.png
URL:

在你构建request请求的时候，首先要设置的就是URL。在URL输入框中输入你请求的链接，你可以单击Params按钮，在编辑器中输入key-value格式的URL参数。

在URL地址栏中的输入和编辑器中输入的key-value参数，不会自动的编码为 URL-encoded，选中要编码的文本，右键选择EncodeURIComponent ，手动编码参数值。

URL设置.png

手动编码.png
你可以单独的添加参数，Postman会自动的把他和URL整合到一起，如果你从其他的地方粘贴了URL过来，Postman也会自动的把 Params中的参数进行设置。

一些API端点使用路径变量，你可以在Postman中设置，他们位于两个 / 中，样式如下：


URL变量样式.png
如果你要设置他，单击Params按钮，你会发现key部分已被自动设置好了，根据需要填写value部分就行。

Headers：

单击Headers切换按钮，你可以在key-value编辑器中设置任何字符串作为header的名称。


编辑headers.png
受限的headers和cookies
不幸的是一些headers收到Chrome和XMLHttpRequest规范的限制，以下headers被屏蔽：

Accept-Charset
Accept-Encoding
Access-Control-Request-Headers
Access-Control-Request-Method
Connection
Content-Length
Cookie
Cookie 2
Content-Transfer-Encoding
Date
Expect
Host
Keep-Alive
Origin
Referer
TE
Trailer
Transfer-Encoding
Upgrade
User-Agent
Via

从Postman v0.9.6版本开始，我们可以使用拦截器来发送这些受限的headers：


拦截器.png
安装完成后点击切换就可以使用这些headers发送请求了。

headers预设
你可以保存常用的headers在headr prest里面：


headers预设.png
Method：

单击HTTP的请求方法按钮，在给出的下拉菜单中选择使用的方法即可，对应的方法需要body的，body部分便被设置为可填写。


Method设置.png
body部分编辑：

当我们发送请求需要填写body部分时，Postman几乎可以让我们发送任何类型的HTTP请求。body编辑器分为4个部分：

form-data


form-data.png
form-data是web表单默认的传输格式，编辑器允许你通过设置key-value形式的数据来模拟填充表单。你可以在最后的选项中选择添加文件。

urlencoded


urlencoded.png
这个编码格式同样可以通过设置key-value的方式作为URL的参数。

raw


raw.png
一个raw请求可以包含任何内容。在这里你可以设置我们常用的JSON 和 XML数据格式。

二进制


二进制.png
在这里你可以发送视频、音频、文本等文件。

2.处理响应

Postman的响应查看器允许你方便的查看API的响应是否正确。

一个API响应器包括Body、Headers、status code三部分。Body 和 Headers在不同的选项卡中，status code在收到响应时在标签行的最右边显示。

保存响应内容


保存响应内容.png
如果你在收藏夹中保存了request请求，你可以在请求收到的对应的响应中单击save按钮，指定一个response的名字，来保存对应额response。一个request对应的所有的response都是有效的。

当我们要查看我们保存的response的时候，只需要点击我们的发送的request选择我们要查看的response即可：


response.png
查看响应

Postman的body标签中有三种查看方式：Pretty、Raw、Preview

Pretty：


pretty.png
Pretty方式，可以让JSON 和 XML的响应内容显示的更美观规整。

Raw：


raw显示.png
显示最原始的数据，可以帮助你判断是否minified

Preview：


preview.png
可以帮你把HTML页面自动解析显示出来。

Headers


headrs.png
这里显示了一些键值对，表示了HTTP请求中header中的信息。

Cookies

Postman v0.8.x 版本可以显示浏览器的cookie。

3.身份验证

Basic Auth


基本认证.png
输入用户名和密码，点击 Update Request 生成 authorization header

Digest Auth


DigestAuth.png
Digest auth 比 Digest auth 更加复杂，使用当前request中的设置来生成authorization header，请确保在生成前你的设置的正确性。

OAuth 1.0


OAuth1.png
Postman的OAuth1.0工具让你可以生成支持OAuth1.0身份认证的请求，目前他不能获取access token。

OAuth 2.0


OAuth 2.0.png
Postman支持获取OAuth 2.0 token，并且可以非常简单的添加到request中。
从OAuth 2.0中获取access token，要遵循下面这些步骤：

在你的APP设置页面设置 https://www.getpostman.com/oauth2/callback 作为 callback URL
获取 authorization URL, 从你的API提供者那里访问 token URL、 client ID 和 client secret。你可以设置一些API需要的参数范围来设置你再API中的访问级别。
按下 Request Token 按钮来启动OAuth 2.0 flow。如果一切设置正确，你将会被重定向到Postman的服务器，他将获取你的access token 并且发送到Postman的app，这样就给Postman添加了token，给他设置一个name，让你在以后可以快速的访问

OAuth 2.0设置.png
access token将被保存在本地，显示在帮助列表。点击token名称，就可以把它添加到request中。
4.Requests History

所有你使用Postman发送的request都将保存在左侧边栏的History中，他会帮助你通过尝试不同的request来生成一个新的request，而不必浪费你太多的时间。你可以通过单击一个request的名字来加载他。


history.png
如果你创建了Postman的账户，你的历史数据将被同步到Postman的服务器，你可以在不同的平台上使用Postman的时候同步你的数据。

5.使用tab来控制多个请求

很多用户可能需要同时打开多个请求，你发送的request将被保持在当前的标签中，当你切换到其他的标签时，不用担心不能及时的接受response。


tabs.png
6.使用拦截器来读写cookie

和Mac上的应用不同，Chrome的应用本身并不支持获取cookie，你可以使用拦截器来实现这个功能。打开拦截器的时候，你可以检索特定域中的cookie，并发送包含cookie的request。

检索cookie：

启动拦截器

interceptor_cookies_1.png
在测试部分，你可以使用responseCookies对象，他将返回一个cookie对象的数组。使用postman.getResponseCookie(cookieName)检索cookie特定的名称。他将返回一个单独的cookie对象。
每个cookie都会包含下面这些属性：
domain、 hostOnly、httpOnly、 name,、path、 secure、 session、 storeId、 value
设置cookie：

确保打开了拦截器

在headers部分包含cookie的头
例如：Cookie: name=value; name2=value2

3.发送request，你设置的cookie将会和你的request一起发送。

7.捕捉request

现在Postman的拦截器可以从Chrome浏览器直接捕捉request，并保存到历史中。这意味着你可以及时的调试你的web应用的api。这里不需要安装或者配置代理，也不需要更改代码。你可以根据基于URL的正则表达式过滤request。

8.设置文件

你可以在Postman的设置中处理重定向


settings.png

重定向设置.png
General

Trim keys and values in request body
如果你使用表单数据或者URL编码模式来发送数据到服务器，这项设为true后就引起所有参数修整。

Send no-cache header
你可能想要这项设置为true，这会确保你收到及时刷新的response。

Send postman-token header
这主要是用来绕过Chrome的一个bug。如果一个XMLHttpRequest 处于等待状态，另一个request 发送了同样的参数，Chrome将会为两个request返回同样的response。发送一个随机的token将会避免这个问题。这同样也会帮助你区分服务器端的request。

XHR Timeout(ms)
设置app等待响应的时间，如果服务器没有响应的话。

Automatically follow redirects
防止我们的request返回一个300系列的response被自动重定向。你需要安装拦截器来防止重定向。

Open history/collection requests in a new tab
设置为 true，当你点击左侧边栏历史或者收藏里面的request时，会在一个新的tab中打开。
设置为false，则会在当前tab中打开。

Response Font Size
设置response视图中的字体大小

UI Size
设置UI的大小

Retain headers on clicking on links
如果你在response中你点击了一个连接，Postman会为这个URL创建一个新的GET request。如果你想要保留headers 在request之前设置他，就设置为true。当你主要方为一些受保护的资源的时候这个功能将会非常有用。

Language detection
如果你测试的API没有在header中返回 Content-Type ，则response不会数据转换成合适的格式。你可以强制指定body的数据类型为JSON等格式。

Variable delimiter
变量是保存在双花括号中的，但是你可以改变成其他的字符，这项并不推荐设置除非你出现了问题需要更改这里。

Force windows line endings
Refer to this Github issue to know more

Instant dialog boxes
禁用 eye-candy 并立即显示所有的对框框模式

Send anonymous usage data to Postman
来禁止匿名用户使用数据的选项，这是的Postman的保护性更好。

Theme

选择你喜欢的两种主题风格

Shortcuts

设置常用的快捷键

Data

导入导出我们设置的环境和数据，这回覆盖你现在的收藏和环境，所以小心使用。当然你可以把你现在的环境先导出作为备份。

Add-ons

Interceptor
Postman proxy

Sync

如果你登录了Postman，你的数据就会被同步更新到Postman的服务器上，者可以确保你再次使用Postman的时候可以同步自己的数据。
你可以强制同步或者禁用他。

Postman 使用手册系列教程：

Postman软件安装
Postman使用手册1——导入导出和发送请求查看响应
Postman使用手册2——管理收藏
Postman使用手册3——环境变量
Postman使用手册4——API test

