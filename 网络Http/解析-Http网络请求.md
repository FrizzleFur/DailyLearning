# HTTP请求
            
```objc
typedef void (^completion_t)(id result);

//获得参数
[self writeImages:saveImages completion:^(id result) {
    DBLog(@"Result: %@", result);
}];
    
- (void)writeImages:(NSMutableArray*)images
     completion:(void ^(id result))completionHandler {
if ([images count] == 0) {
    if (completionHandler) {
        completionHandler(@"所有图片都成功保存");
    }
    return;
}

```
* IP协议对应于网络层，TCP协议对应于传输层，而HTTP协议对应于应用层。
* socket则是对TCP/IP协议的封装和应用。
* TCP/IP协议是传输层协议，主要解决数据如何在网络中传输。
* HTTP是应用层协议，主要解决如何包装数据。
* 我们在传输数据时，可以只使用(传输层)TCP/IP协议，但是那样的话，如果没有应用层，便无法识别数据内容。
* socket是对TCP/IP协议的封装，Socket本身并不是协议，而是一个调用接口(API).通过Socket，我们才能使用TCP/IP协议。TCP/IP只是一个协议栈，就像操作系统的运行机制一样，必须要具体实现，同时还要提供对外的操作接口。

![ISO模型的七个分层](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15166637371115.gif)

#### HTTP请求方法

根据HTTP标准，HTTP请求可以使用多种请求方法。
HTTP1.0定义了三种请求方法： GET, POST 和 HEAD方法。
HTTP1.1新增了五种请求方法：OPTIONS, PUT, DELETE, TRACE 和 CONNECT 方法。

```
GET     请求指定的页面信息，并返回实体主体。
HEAD     类似于get请求，只不过返回的响应中没有具体的内容，用于获取报头
POST     向指定资源提交数据进行处理请求（例如提交表单或者上传文件）。数据被包含在请求体中。POST请求可能会导致新的资源的建立和/或已有资源的修改。
PUT     从客户端向服务器传送的数据取代指定的文档的内容。
DELETE      请求服务器删除指定的页面。
CONNECT     HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器。
OPTIONS     允许客户端查看服务器的性能。
TRACE     回显服务器收到的请求，主要用于测试或诊断。
```

## HTTP请求 Request

HTTP 的请求报文分为三个部分 请求行、请求头和请求体，格式如图：
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15357999658842.jpg)

一个典型的请求消息头域，如下所示：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-09-04-15045083200378.jpg)


```
　　POST/GET http://download.microtool.de:80/somedata.exe 
　　Host: download.microtool.de 
　　Accept:*/* 
　　Pragma: no-cache 
　　Cache-Control: no-cache 
　　Referer: http://download.microtool.de/ 
　　User-Agent:Mozilla/4.04[en](Win95;I;Nav) 
　　Range:bytes=554554- 
```

### HTTP请求行

请求行（Request Line）分为三个部分：请求方法、请求地址和协议及版本，以CRLF(rn)结束。
HTTP/1.1 定义的请求方法有8种：GET、POST、PUT、DELETE、PATCH、HEAD、OPTIONS、TRACE,最常的两种GET和POST，如果是RESTful接口的话一般会用到GET、POST、DELETE、PUT。

### HTTP请求头

包含了对客户端的环境描述、客户端请求信息等

### HTTP请求体

* 客户端发给服务器的具体数据（请求参数），比如文件数据(POST请求才会有)
* 注意，仅有POST、PUT以及PATCH这三个动词时会包含请求体，而GET、HEAD、DELETE、CONNECT、TRACE、OPTIONS这几个动词时不包含请求体。

## HTTP响应 Response

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15358006676079.jpg)

```
HTTP/1.1 200 OK
Date: Sat, 31 Dec 2005 23:59:59 GMT
Content-Type: text/html;charset=ISO-8859-1
Content-Length: 122

＜html＞
＜head＞
＜title＞Wrox Homepage＜/title＞
＜/head＞
＜body＞
＜!-- body goes here --＞
＜/body＞
＜/html＞
```
 

响应体内容

(1)响应首行：其内容是”HTTP/1.1  200  OK”

* HTTP/1.1 ：表示协议版本
* 200 ：表示响应状态码，200表示响应成功。
* OK ：表示响应成功，对响应状态码的解释。

(2)响应头信息：类似于请求消息中的请求头，其格式和请求头信息格式一样，即响应头：响应头值。

* Server响应头：该响应头是服务器告诉浏览器，当前响应的服务类型和版本。
* Content-Type响应头：服务器告诉浏览器响应内容是什么类型，以及采用的是什么字符编码。该响应头的值现在为：text/html;charset=utf-8。说明响应信息的类型是文本类型中的html，使用的字符编码是utf-8。
* Content-Length响应头：服务器告诉浏览器，响应内容的长度，该响应内容的长度现在是624个字节。
* Date响应头：表示是服务器是在什么时候响应回浏览器，注意这里的时间是按照美国时间来计算。

(3)空行：响应头和响应体由空行连接。

(4)响应体：该响应消息的响应体是一个html文档。浏览器可以直接识别这个html文件。而我们访问的是一个jsp文件，响应回去的是一个html文件。说明服务器将该jsp翻译成了一个html，然后再响应给浏览器。

###  HTTP响应头

包含了对服务器的描述、对返回数据的描述

###  HTTP响应体

服务器返回给客户端的具体数据，比如文件数据

### HTTP之状态码

状态代码有三位数字组成，第一个数字定义了响应的类别，共分五种类别:
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15358008791376.jpg)

* 200 - 请求成功
* 301 - 资源（网页等）被永久转移到其它URL
* 307	Temporary Redirect	临时重定向。与302类似。使用GET请求重定向
* 404 - 请求的资源（网页等）不存在
* 403	Forbidden	服务器理解请求客户端的请求，但是拒绝执行此请求
* 500 - 内部服务器错误
* 502	Bad Gateway	充当网关或代理的服务器，从远端服务器接收到了一个无效的请求
* 505	HTTP Version not supported	服务器不支持请求的HTTP协议的版本，无法完成处理

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-06-08-14969148476130.jpg)

## GET请求


 举例：
 
```
127.0.0.1 - - [03/Oct/2016 15:45:50] "GET /readme.png HTTP/1.1" 200 -
```

看看日期和时间之后的部分。在这里，它说“把/ readme.png HTTP / 1.1”。这是浏览器发送给服务器的请求行的文本。本日志是服务器告诉你它收到一个请求，说，从字面上看，得到`readme.png HTTP / 1.1`。

GET请求有3各部分：

1. 单词GET是正在使用的方法或HTTP动词;这说明正在提出什么样的要求。 GET是客户端希望服务器发送资源（例如网页或图像）时使用的动词

2. `/readme.png` 是被请求资源的路径。注意，客户端没有在这里发送资源的整个URI。这并不是说，`https://localhost:8000/readme.png`。它只发送路径。

3. 最后，HTTP / 1.1是请求的协议。多年来，HTTP的工作方式发生了一些变化。客户必须告诉服务器他们说的是哪一种方言。HTTP / 1.1是当今最常见的版本。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15236304256994.jpg)

由于浏览器和服务器对URL长度有限制，因此在URL后面附带的参数是有限制的，
通常不能超过1KB

## POST请求

POST的本质是向服务器发送数据,也可以获得服务器处理之后的结果,效率不如GET.POST请求不可以被缓存,每次刷新之后都需要重新提交表单.

```
POST / HTTP1.1
Host:www.wrox.com
User-Agent:Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)
Content-Type:application/x-www-form-urlencoded
Content-Length:40
Connection: Keep-Alive

name=Professional%20Ajax&publisher=Wiley
```

* 第一部分：请求行，第一行明了是post请求，以及http1.1版本。
* 第二部分：请求头部，第二行至第六行。
* 第三部分：空行，第七行的空行。
* 第四部分：请求数据，第八行。

### 不同点

1. GET提交，请求的数据会附在URL之后（就是把数据放置在HTTP协议头中），以?分割URL和传输数据，多个参数用&连接；例 如：login.action?name=hyddd&password=idontknow&verify=%E4%BD%A0 %E5%A5%BD。如果数据是英文字母/数字，原样发送，如果是空格，转换为+，如果是中文/其他字符，则直接把字符串用BASE64加密，得出如： %E4%BD%A0%E5%A5%BD，其中％XX中的XX为该符号以16进制表示的ASCII。

POST提交：把提交的数据放置在是HTTP包的包体中。上文示例中红色字体标明的就是实际的传输数据

因此，GET提交的数据会在地址栏中显示出来，而POST提交，地址栏不会改变

2. 传输数据的大小：首先声明：HTTP协议没有对传输的数据大小进行限制，HTTP协议规范也没有对URL长度进行限制。

而在实际开发中存在的限制主要有：

GET: 特定浏览器和服务器对URL长度有限制，例如 IE对URL长度的限制是2083字节(2K+35)。对于其他浏览器，如Netscape、FireFox等，理论上没有长度限制，其限制取决于操作系 统的支持。

因此对于GET提交时，传输数据就会受到URL长度的 限制。

POST: 由于不是通过URL传值，理论上数据不受 限。但实际各个WEB服务器会规定对post提交数据大小进行限制，Apache、IIS6都有各自的配置。

3. 安全性

POST的安全性要比GET的安全性高。比如：通过GET提交数据，用户名和密码将明文出现在URL上，因为(1)登录页面有可能被浏览器缓存；(2)其他人查看浏览器的历史纪录，那么别人就可以拿到你的账号和密码了，除此之外，使用GET提交数据还可能会造成Cross-site request forgery攻击

4. Http get,post,soap协议都是在http上运行的

（1）get：请求参数是作为一个key/value对的序列（查询字符串）附加到URL上的
查询字符串的长度受到web浏览器和web服务器的限制（如IE最多支持2048个字符），不适合传输大型数据集同时，它很不安全

（2）post：请求参数是在http标题的一个不同部分（名为entity body）传输的，这一部分用来传输表单信息，因此必须将Content-type设置为:application/x-www-form- urlencoded。post设计用来支持web窗体上的用户字段，其参数也是作为key/value对传输。
但是：它不支持复杂数据类型，因为post没有定义传输数据结构的语义和规则。

（3）soap：是http post的一个专用版本，遵循一种特殊的xml消息格式
Content-type设置为: text/xml 任何数据都可以xml化。

Http协议定义了很多与服务器交互的方法，最基本的有4种，分别是GET,POST,PUT,DELETE. 一个URL地址用于描述一个网络上的资源，而HTTP中的GET, POST, PUT, DELETE就对应着对这个资源的查，改，增，删4个操作。 我们最常见的就是GET和POST了。GET一般用于获取/查询资源信息，而POST一般用于更新资源信息.

##### 我们看看GET和POST的区别

GET提交的数据会放在URL之后，以?分割URL和传输数据，参数之间以&相连，如`EditPosts.aspx?name=test1&id=123456` .POST方法是把提交的数据放在HTTP包的Body中.

GET提交的数据大小有限制（因为浏览器对URL的长度有限制），而POST方法提交的数据没有限制.

GET方式需要使用`Request.QueryString`来取得变量的值，而POST方式通过`Request.Form`来获取变量的值。

GET方式提交数据，会带来安全问题，比如一个登录页面，通过GET方式提交数据时，用户名和密码将出现在URL上，如果页面可以被缓存或者其他人可以访问这台机器，就可以从历史记录获得该用户的账号和密码.

## HTTP请求过程

通过TCP三次握手建立链接 ——> 在此链接基础上进行Http的请求和响应 ——> 通过TCP四次挥手进行链接的释放

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15343911190241.jpg)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15343910887788.jpg)

## TCP协议详解

### TCP/IP协议分层

[TCP协议详解](http://www.jianshu.com/p/ef892323e68f)


* TCP是一种面向连接的单播协议，在发送数据前，通信双方必须在彼此间建立一条连接。所谓的“连接”，其实是客户端和服务器的内存里保存的一份关于对方的信息，如ip地址、端口号等。
* TCP可以看成是一种字节流，它会处理IP层或以下的层的丢包、重复以及错误问题。在连接的建立过程中，双方需要交换一些连接的参数。这些参数可以放在TCP头部。
* TCP提供了一种可靠、面向连接、字节流、传输层的服务，采用三次握手建立一个连接。采用4次挥手来关闭一个连接。
* 一个TCP连接由一个4元组构成，分别是两个IP地址和两个端口号。一个TCP连接通常分为三个阶段：启动、数据传输、退出（关闭）。
* 当TCP接收到另一端的数据时，它会发送一个确认，但这个确认不会立即发送，一般会延迟一会儿。ACK是累积的，一个确认字节号N的ACK表示所有直到N的字节（不包括N）已经成功被接收了。这样的好处是如果一个ACK丢失，很可能后续的ACK就足以确认前面的报文段了。

* 一个完整的TCP连接是双向和对称的，数据可以在两个方向上平等地流动。给上层应用程序提供一种双工服务。一旦建立了一个连接，这个连接的一个方向上的每个TCP报文段都包含了相反方向上的报文段的一个ACK。

* 序列号的作用是使得一个TCP接收端可丢弃重复的报文段，记录以杂乱次序到达的报文段。因为TCP使用IP来传输报文段，而IP不提供重复消除或者保证次序正确的功能。另一方面，TCP是一个字节流协议，绝不会以杂乱的次序给上层程序发送数据。因此TCP接收端会被迫先保持大序列号的数据不交给应用程序，直到缺失的小序列号的报文段被填满。




### ACK； SYN； FIN

* ACK: (Acknowledgement 确认），确认标志,是一种确认应答，在数据通信传输中，接收站发给发送站的一种传输控制字符。它表示确认发来的数据已经接受无误。
* SYN: (Synchronous 建立联机)同步标志,攻击属于DOS攻击的一种，它利用TCP协议缺陷，通过发送大量的半连接请求，耗费CPU和内存资源。是最常见又最容易被利用的一种攻击手法。
* FIN:（Finish）结束标志,是用来扫描保留的端口，发送一个FIN包（或者是任何没有ACK或SYN标记的包）到目标的一个开放的端口，然后等待回应。许多系统会返回一个复位标记。

### TCP三次握手

所谓三次握手（Three-Way Handshake）即建立TCP连接，就是指建立一个TCP连接时，需要客户端和服务端总共发送3个包以确认连接的建立。在socket编程中，这一过程由客户端执行connect来触发，整个流程如下图所示：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15357980816024.jpg)

* TCP服务器进程先创建传输控制块TCB，时刻准备接受客户进程的连接请求，此时服务器就进入了LISTEN（监听）状态；
* TCP客户进程也是先创建传输控制块TCB，然后向服务器发出连接请求报文，这是报文首部中的同部位SYN=1，同时选择一个初始序列号 seq=x ，此时，TCP客户端进程进入了 SYN-SENT（同步已发送状态）状态。TCP规定，SYN报文段（SYN=1的报文段）不能携带数据，但需要消耗掉一个序号。
* TCP服务器收到请求报文后，如果同意连接，则发出确认报文。确认报文中应该 ACK=1，SYN=1，确认号是ack=x+1，同时也要为自己初始化一个序列号 seq=y，此时，TCP服务器进程进入了SYN-RCVD（同步收到）状态。这个报文也不能携带数据，但是同样要消耗一个序号。
* TCP客户进程收到确认后，还要向服务器给出确认。确认报文的ACK=1，ack=y+1，自己的序列号seq=x+1，此时，TCP连接建立，客户端进入ESTABLISHED（已建立连接）状态。TCP规定，ACK报文段可以携带数据，但是如果不携带数据则不消耗序号。
* 当服务器收到客户端的确认后也进入ESTABLISHED状态，此后双方就可以开始通信了。 

1. 建立连接时，客户端发送SYN包（SYN=i）到服务器，并进入到SYN-SEND状态，等待服务器确认

2. 服务器收到SYN包，必须确认客户的SYN（ack=i+1）,同时自己也发送一个SYN包（SYN=k）,即SYN+ACK包，此时服务器进入SYN-RECV状态

3. 客户端收到服务器的SYN+ACK包，向服务器发送确认报ACK（ack=k+1）,此包发送完毕，客户端和服务器进入established(确认建立)状态，完成三次握手，客户端与服务器开始传送数据。

#### 三次握手解析

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-06-08-14969143989779.jpg)

* 为什么TCP客户端最后还要发送一次确认呢？

主要防止已经失效的连接请求报文突然又传送到了服务器，从而产生错误。
如果只有两次通信的话，这时候Sever不确定Client是否收到了确认消息，有可能这个确认消息由于某些原因丢了。

如果使用的是两次握手建立连接，假设有这样一种场景，客户端发送了第一个请求连接并且没有丢失，只是因为在网络结点中滞留的时间太长了，由于TCP的客户端迟迟没有收到确认报文，以为服务器没有收到，此时重新向服务器发送这条报文，此后客户端和服务器经过两次握手完成连接，传输数据，然后关闭连接。**此时此前滞留的那一次请求连接，网络通畅了到达了服务器，这个报文本该是失效的，但是，两次握手的机制将会让客户端和服务器再次建立连接，这将导致不必要的错误和资源的浪费。**

如果采用的是三次握手，就算是那一次失效的报文传送过来了，服务端接受到了那条失效报文并且回复了确认报文，但是客户端不会再次发出确认。由于服务器收不到确认，就知道客户端并没有请求连接。

#### SYN攻击：

在三次握手过程中，Server发送SYN-ACK之后，收到Client的ACK之前的TCP连接称为半连接（half-open connect），此时Server处于SYN_RCVD状态，当收到ACK后，Server转入ESTABLISHED状态。SYN攻击就是Client在短时间内伪造大量不存在的IP地址，并向Server不断地发送SYN包，Server回复确认包，并等待Client的确认，由于源地址是不存在的，因此，Server需要不断重发直至超时，这些伪造的SYN包将产时间占用未连接队列，导致正常的SYN请求因为队列满而被丢弃，从而引起网络堵塞甚至系统瘫痪。**SYN攻击时一种典型的DDOS攻击，检测SYN攻击的方式非常简单，即当Server上有大量半连接状态且源IP地址是随机的，则可以断定遭到SYN攻击了**，使用如下命令可以让之现行：

```
netstat -nap | grep SYN_RECV
```

### TCP四次挥手

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15357985879750.jpg)

数据传输完毕后，双方都可释放连接。最开始的时候，客户端和服务器都是处于ESTABLISHED状态，然后客户端主动关闭，服务器被动关闭。

* 客户端进程发出连接释放报文，并且停止发送数据。释放数据报文首部，FIN=1，其序列号为seq=u（等于前面已经传送过来的数据的最后一个字节的序号加1），此时，客户端进入FIN-WAIT-1（终止等待1）状态。 TCP规定，FIN报文段即使不携带数据，也要消耗一个序号。
* 服务器收到连接释放报文，发出确认报文，ACK=1，ack=u+1，并且带上自己的序列号seq=v，此时，服务端就进入了CLOSE-WAIT（关闭等待）状态。TCP服务器通知高层的应用进程，客户端向服务器的方向就释放了，这时候处于半关闭状态，即客户端已经没有数据要发送了，但是服务器若发送数据，客户端依然要接受。这个状态还要持续一段时间，也就是整个CLOSE-WAIT状态持续的时间。
* 客户端收到服务器的确认请求后，此时，客户端就进入FIN-WAIT-2（终止等待2）状态，等待服务器发送连接释放报文（**在这之前还需要接受服务器发送的最后的数据**）。
* **服务器将最后的数据发送完毕后，就向客户端发送连接释放报文**，FIN=1，ack=u+1，由于在半关闭状态，服务器很可能又发送了一些数据，假定此时的序列号为seq=w，此时，服务器就进入了LAST-ACK（最后确认）状态，等待客户端的确认。
* 客户端收到服务器的连接释放报文后，必须发出确认，ACK=1，ack=w+1，而自己的序列号是seq=u+1，此时，客户端就进入了TIME-WAIT（时间等待）状态。注意此时TCP连接还没有释放，必须经过2∗MSL（最长报文段寿命）的时间后，当客户端撤销相应的TCB后，才进入CLOSED状态。
* 服务器只要收到了客户端发出的确认，立即进入CLOSED状态。同样，撤销TCB后，就结束了这次的TCP连接。可以看到，服务器结束TCP连接的时间要比客户端早一些。

#### 为什么建立连接是三次握手，而关闭连接却是四次挥手呢？

这是因为Server端在LISTEN状态下，收到建立连接请求的SYN报文后，把ACK和SYN放在一个报文里发送给客户端。

**而关闭连接时，当收到Client的FIN报文时，仅仅表示Client不再发送数据了但是还能接收数据，Server方也未必全部数据都发送给Client方了，所以Server方可以立即close，也可以发送一些数据给Client对方后，再发送FIN报文给Client方来表示同意现在关闭连接**，因此，Server方ACK和FIN一般都会分开发送。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15357990111865.jpg)

    TIME_WAIT的状态是为了等待连接上所有的分组的消失。单纯的想法，发送端只需要等待一个MSL就足够了。这是不够的，假设现在一个MSL的时候，接收端需要发送一个应答，这时候，我们也必须等待这个应答的消失，这个应答的消失也是需要一个MSL，所以我们需要等待2MSL。（更多的内容参考 《UNIX 网络编程》第3版 2.7 节）

    2MSL即两倍的MSL，TCP的TIME_WAIT状态也称为2MSL等待状态，当TCP的一端发起主动关闭，在发出最后一个ACK包后，即第3次握手完成后发送了第四次握手的ACK包后就进入了TIME_WAIT状态，必须在此状态上停留两倍的MSL时间，等待2MSL时间主要目的是怕最后一个ACK包对方没收到，那么对方在超时后将重发第三次握手的FIN包，主动关闭端接到重发的FIN包后可以再发一个ACK应答包。在TIME_WAIT状态时两端的端口不能使用，要等到2MSL时间结束才可继续使用。当连接处于2MSL等待阶段时任何迟到的报文段都将被丢弃。不过在实际应用中可以通过设置SO_REUSEADDR选项达到不必等待2MSL时间结束再使用此端口。

## IP

* IP（Internet Protocol， 网协） 网络之间互连的协议

* 网络互连设备，如以太网、分组交换网等，它们相互之间不能互通，不能互通的主要原因是因为它们所传送数据的基本单元（技术上称之为“帧”）的格式不同。

* IP协议实际上是一套由软件、程序组成的协议软件，它把各种不同“帧”统一转换成“网协数据包”格式

### IP地址

* 所谓IP地址就是给每个连接在互联网上的主机分配的一个32位地址。

* 按照TCP/IP（Transport Control Protocol/Internet Protocol，传输控制协议/Internet协议）协议规定，IP地址用二进制来表示.

* 每个IP地址长32bit，比特换算成字节，就是4个字节。例如一个采用二进制形式的IP地址是一串很长的数字，人们处理起来也太费劲了。

* 为了方便人们的使用，IP地址经常被写成十进制的形式，中间使用符号“.”分开不同的字节。

* 于是，上面的IP地址可以表示为“10.0.0.1”。IP地址的这种表示法叫做“点分十进制表示法”，这显然比1和0容易记忆得多。

* IP地址是IP网络中数据传输的依据，它标识了IP网络中的一个连接，一台主机可以有多个IP地址。IP分组中的IP地址在网络传输中是保持不变的。

* 互联网通过IP地址告诉计算机;

* 互联网上的每一项网络流量都标有发送和接收计算机的IP地址。

* 每个计算机必须有一个 IP 地址才能够连入因特网。

* 每个 IP 包必须有一个地址才能够发送到另一台计算机。

网络上每一个节点都必须有一个独立的Internet地址（也叫做IP地址）。现在，通常使用的IP地址是一个32bit的数字，也就是我们常说的IPv4标准，这32bit的数字分成四组，也就是常见的255.255.255.255的样式。IPv4标准上，地址被分为五类，我们常用的是B类地址。具体的分类请参考其他文档。需要注意的是IP地址是网络号+主机号的组合，这非常重要。

CP/IP 使用 32 个比特来编址。一个计算机字节是 8 比特。所以 TCP/IP 使用了 4 个字节。
一个计算机字节可以包含 256 个不同的值：
00000000、00000001、00000010、00000011、00000100、00000101、00000110、00000111、00001000 ....... 直到 11111111。
现在，你知道了为什么 TCP/IP 地址是介于 0 到 255 之间的 4 个数字。

#### 地址格式：

* IP地址=网络地址+主机地址

*  IP地址=网络地址+子网地址+主机地址。

#### 本地服务器

* 在一个文件目录中启动Python 本地服务器，端口`8000`

您的浏览器发送的每个请求的条目的服务器日志：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15234622040759.jpg)

然后在浏览器中访问：`http://localhost:8000/ `

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15234622850793.jpg)

这就是Python演示服务器，在自己的计算机上运行。它提供本地磁盘上的文件，以便您可以在浏览器中查看它们。

你在你的浏览器中输入`localhost8000` 时，你的浏览器向运行的Python程序发送一个HTTP请求。您的浏览器将该程序的响应数据在UI上展现。在这种情况下，它显示了一个作为一块HTML的目录列表。您还可以使用浏览器的开发工具查看它发送的HTML。

#### IP 路由器

* 当一个 IP 包从一台计算机被发送，它会到达一个 IP 路由器。

* IP 路由器负责将这个包路由至它的目的地，直接地或者通过其他的路由器。

* 在一个相同的通信中，一个包所经由的路径可能会和其他的包不同。而路由器负责根据通信量、网络中的错误或者其他参数来进行正确地寻址。

## 域名

12个阿拉伯数字很难记忆。使用一个名称更容易。

用于 TCP/IP 地址的名字被称为域名。w3school.com.cn 就是一个域名。

当你键入一个像 http://www.w3school.com.cn 这样的域名，域名会被一种 `DNS` 程序翻译为数字。

在全世界，数量庞大的 DNS 服务器被连入因特网。DNS 服务器负责将域名翻译为 TCP/IP 地址，同时负责使用新的域名信息更新彼此的系统。

当一个新的域名连同其 TCP/IP 地址一同注册后，全世界的 DNS 服务器都会对此信息进行更新。

#### DNS

DNS（Domain Name System，域名系统），因特网上作为**域名和IP地址相互映射的一个分布式数据库**，能够使用户更方便的访问互联网，而不用去记住能够被机器直接读取的IP数串。通过主机名，最终得到该主机名对应的IP地址的过程叫做域名解析（或主机名解析）。DNS协议运行在UDP协议之上，使用端口号53。在RFC文档中RFC 2181对DNS有规范说明，RFC 2136对DNS的动态更新进行说明，RFC 2308对DNS查询的反向缓存进行说明。

#### content-type

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-09-04-15045100047341.jpg)

[HTTP 请求头与请求体 - 某熊的全栈之路 - SegmentFault](https://segmentfault.com/a/1190000006689767)

content-type是必须的，它包括一个类似标志性质的名为boundary的标志，

这算是最常见的 POST 提交数据的方式了。浏览器的原生 <form> 表单，如果不设置 enctype 属性，那么最终就会以 application/x-www-form-urlencoded 方式提交数据。请求类似于下面这样（无关的请求头在本文中都省略掉了）：

```
POST http://www.example.com HTTP/1.1
Content-Type: application/x-www-form-urlencoded;charset=utf-8
title=test&sub%5B%5D=1&sub%5B%5D=2&sub%5B%5D=3
```
首先，Content-Type 被指定为 application/x-www-form-urlencoded；这里的格式要求就是URL中Query String的格式要求：多个键值对之间用&连接，键与值之前用=连接，且只能用ASCII字符，非ASCII字符需使用UrlEncode编码。大部分服务端语言都对这种方式有很好的支持。例如 PHP 中，$_POST['title'] 可以获取到 title 的值，$_POST['sub'] 可以得到 sub 数组。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-09-04-15045099311373.jpg)


#### 文件分割

第三种请求体的请求体被分成为多个部分，文件上传时会被使用，这种格式最先应该是被用于邮件传输中，每个字段/文件都被boundary（Content-Type中指定）分成单独的段，每段以-- 加 boundary开头，然后是该段的描述头，描述头之后空一行接内容，请求结束的标制为boundary后面加--，结构见下图：

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-09-04-15045099842386.jpg)

### HTML

Hypertext Markup Language 超文本链接标示语言

* 加载简单的Web页面可能需要很多个请求，需要请求不同的服务器索取资源：HTML页面本身、图像或其他媒体

* HTTP请求总是涉及客户端和服务器。

* 前端：针对浏览器的开发，代码在浏览器运行

* 后端：针对服务器的开发，代码在服务器运行

* 您现在使用的是HTTP客户端——Web浏览器。

* 您的浏览器向Web服务器发送HTTP请求，服务器将响应发送回浏览器。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15234610574722.jpg)

* 浏览器拥有所有的用户界面、动画和图形内容。

* 服务器只需要做一件事：处理传入的请求。

* 服务器只是一个程序，它接受来自网络上其他程序的连接。

当你启动一个服务器程序时，它会等待客户端连接到它，就像演示服务器等待Web浏览器请求页面一样。然后，当一个连接出现时，服务器运行一段代码，比如调用一个函数来处理每个传入的连接。从这个意义上说，一个连接就像一个电话：它是一个通道，通过它，客户端和服务器可以相互通信。Web客户端通过这些连接发送请求，服务器将响应发送回。


## URI

Web地址也被称为统一资源标识符的URI（Uniform Resource Identifier）。你以前见过很多这样的。从Web用户的角度来看，URI是一个文本，放在Web浏览器中，告诉它要到哪个页面。从Web开发人员的角度来看，它有点复杂。

### URL

URL: Uniform Resource Locator

URL是网络上资源的URI。由于URI稍微精确一些，不要过分担心这个区别。这里是一个例子：`https://en.wikipedia.org/wiki/fish` 这个URI有三个可见部分，用一点点标点符号隔开：

* https 是该方案Scheme；

* en.wikipedia.org 是主机名；

* wiki/fish 是路径。

不同的URI可以有不同的部分

### Scheme方案
    
URI的第一部分是该方案，它告诉客户如何访问资源。您以前见过的一些URI方案包括HTTP、HTTPS和File。File的URI告诉客户端访问本地文件系统中的文件。HTTP和HTTPS URI指向资源由Web服务器提供。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15236036510993.jpg)

### Hostname主机名

在一个HTTP URI方案后是一个主机名--比如：`www.udacity.com`或`localhost`，告诉客户端去连接哪个服务器。 URI中的主机名也可以是IP地址：例如，如果您在浏览器中放置了`http://216.58.194.174/`，则最终会在Google上显示。

为了连接到诸如`www.google.com`之类的网络服务器，客户端需要将主机名转换为IP地址。您的操作系统的网络配置使用域名服务（DNS:它作为将域名和IP地址相互映射的一个分布式数据库，能够使人更方便地访问互联网。）

* 从URL中找到主机名

* 寻找一个IP地址

* 通过IP的端口建立HTTP链接

* 为什么叫做主机？在网络术语中，主机是网络上一台可以提供服务的计算机。

* 当客户端向服务器请求资源时，它必须指定它想要与之通话的主机名。

#### Localhost

Localhost是指“此计算机本身”的特殊地址 - 用于客户端（如浏览器）访问自己计算机上的服务器时。主机名localhost引用这些特殊地址。

### 路径

在HTTP URI（以及许多其他）中，接下来出现的是路径，该路径标识服务器上的特定资源。服务器可以有很多资源，比如不同的网页、视频或API。路径告诉服务器客户机正在寻找的资源。

当你写一个URI没有路径，如http://udacity.com，浏览器填写默认路径，它是用一个斜线。这就是为什么http://udacity.com是http://udacity.com/相同（最后用一个斜线）。

用一个斜杠写的路径也被称为根。当你看演示服务器根URI HTTP：/本地：8000 / -你不看你的电脑的整个文件系统的根。它只是Web服务器提供的资源的根。演示服务器不会让Web浏览器访问正在运行的目录之外的文件。

### URI相对路径

```
<a href="cliffsofinsanity.png">cliffsofinsanity.png</a>
```

在这样一个没有一个方案，或一个主机名-只是一个路径。这是一个相对URI引用。它与它出现的上下文是“相对的”——具体地说，是它所在的页面。这个URI不包含服务器的主机名或端口，但浏览器可以发现从上下文。如果您单击其中一个链接，浏览器就知道它需要从同一个服务器中获取原始页面。

### URI其他部分

`#`标志称为片段。浏览器甚至不会发送到Web服务器。它让一个链接指向资源的一个特定的命名部分；在HTML页面中，它通过ID链接到一个元素。



## 端口Port

你看到的大多数网址都没有端口号。这是因为客户端通常从URI的Scheme(协议)中找出端口号。

例如，HTTP URI隐含的端口号为80，而HTTPS URI隐含的端口号为443.您的Python演示Web服务器在端口8000上运行。由于这不是默认端口，因此您必须将端口号写入它的URI。

 IP地址区分计算机，端口Port号码区分这些计算机上的程序。
 
 
## 以前后端 MVC 的开发模式

*   Model（模型层）：提供/保存数据
*   Controller（控制层）：数据处理，实现业务逻辑
*   View（视图层）：展示数据，提供用户界面

那时候前端只是后端 MVC 的 V。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15235259440725.jpg)


## Http简历持久链接


HTTP Persistent Connections(HTTP keep alive)
持久连接的特点是，只要任意一端没有明确提出断开连接，则保持TCP连接状态。


持久连接的好处在于减少了TCP连接的重复建立和断开所造成的
额外开销，减轻了服务器端的负载。另外，减少开销的那部分时间，使
HTTP请求和响应能够更早地结束，这样Web页面的显示速度也就相应
提高了



## cookie 状态管理

* HTTP是无状态协议，它不对之前发生过的请求和响应的状态进行管理。也就是说，无法根据之前的状态进行本次的请求处理。

* 假设要求登录认证的Web页面本身无法进行状态的管理(不记录
* 已登录的状态),那么每次跳转新页面不是要再次登录，就是要在每次请求报文中附加参数来管理登录状态。

* Cookie 技术通过在请求和响应报文中写人Cookie信息来控制客户端的状态。
* Cookie会根据从服务器端发送的响应报文内的-一个叫做Set-Cookie的首部字段信息，通知客户端保存Cookie。当下次客户端再往该服务器发送请求时，客户端会自动在请求报文中加入Cookie值后发送出去。
* 服务器端发现客户端发送过来的Cookie后，会去检查究竟是从哪-个客户端发来的连接请求，然后对比服务器上的记录，最后得到之前的状态信息。

## Http缓存

对于强制缓存，服务器通知浏览器一个缓存时间，在缓存时间内，下次请求，直接用缓存，不在时间内，执行比较缓存策略。
对于比较缓存，将缓存信息中的Etag和Last-Modified通过请求发送给服务器，由服务器校验，返回304状态码时，浏览器直接使用缓存。

浏览器第一次请求时：
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15357959994287.jpg)

浏览器再次请求时：
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15357960028738.jpg)



### 加密处理防止被窃听

1. 通信的加密

一种方式就是将通信加密。HTTP 协议中没有加密机制，但可以通过和 SSL（Secure Socket Layer，安全套接层）或 TLS（Transport Layer Security，安全层传输协议）的组合使用，加密 HTTP 的通信内容。

用 SSL 建立安全通信线路之后，就可以在这条线路上进行 HTTP 通信了。与 SSL 组合使用的 HTTP 被称为 HTTPS（HTTP Secure，超文本传输安全协议）或 HTTP over SSL。

2. 内容加密

由于 HTTP 协议中没有加密机制，那么就对 HTTP 协议传输的内容本身加密。即把 HTTP 报文里所含的内容进行加密处理。

在这种情况下，客户端需要对 HTTP 报文进行加密处理后再发送请求。

有一点必须引起注意，由于该方式不同于 SSL 或 TLS 将整个通信线路加密处理，所以内容仍有被篡改的风险。稍后我们会加以说明。



![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-06-08-14969149972962.jpg)


### 公钥加密，私钥解密。私钥数字签名，公钥验证。

一、公钥加密 
假设一下，我找了两个数字，一个是1，一个是2。我喜欢2这个数字，就保留起来，不告诉你们(私钥），然后我告诉大家，1是我的公钥。
我有一个文件，不能让别人看，我就用1加密了。别人找到了这个文件，但是他不知道2就是解密的私钥啊，所以他解不开，只有我可以用
数字2，就是我的私钥，来解密。这样我就可以保护数据了。
我的好朋友x用我的公钥1加密了字符a，加密后成了b，放在网上。别人偷到了这个文件，但是别人解不开，因为别人不知道2就是我的私钥，
只有我才能解密，解密后就得到a。这样，我们就可以传送加密的数据了。

 
二、私钥签名
如果我用私钥加密一段数据（当然只有我可以用私钥加密，因为只有我知道2是我的私钥），结果所有的人都看到我的内容了，因为他们都知
道我的公钥是1，那么这种加密有什么用处呢？
但是我的好朋友x说有人冒充我给他发信。怎么办呢？我把我要发的信，内容是c，用我的私钥2，加密，加密后的内容是d，发给x，再告诉他
解密看是不是c。他用我的公钥1解密，发现果然是c。
这个时候，他会想到，能够用我的公钥解密的数据，必然是用我的私钥加的密。只有我知道我得私钥，因此他就可以确认确实是我发的东西。
这样我们就能确认发送方身份了。这个过程叫做数字签名。当然具体的过程要稍微复杂一些。用私钥来加密数据，用途就是数字签名。
 
总结：公钥和私钥是成对的，它们互相解密。
公钥加密，私钥解密。
私钥数字签名，公钥验证。
 
## Socket

我们知道两个进程如果需要进行通讯最基本的一个前提能能够唯一的标示一个进程，在本地进程通讯中我们可以使用PID来唯一标示一个进程，但PID只在本地唯一，网络中的两个进程PID冲突几率很大，这时候我们需要另辟它径了，我们知道IP层的ip地址可以唯一标示主机，而TCP层协议和端口号可以唯一标示主机的一个进程，这样我们可以利用ip地址＋协议＋端口号唯一标示网络中的一个进程。

能够唯一标示网络中的进程后，它们就可以利用socket进行通信了，什么是socket呢？我们经常把socket翻译为套接字，socket是在应用层和传输层之间的一个抽象层，它把TCP/IP层复杂的操作抽象为几个简单的接口供应用层调用已实现进程在网络中通信。

Socket是什么呢？
Socket是应用层与TCP/IP协议族通信的中间软件抽象层，它是一组接口。在设计模式中，Socket其实就是一个门面模式，它把复杂的TCP/IP协议族隐藏在Socket接口后面，对用户来说，一组简单的接口就是全部，让Socket去组织数据，以符合指定的协议。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15166639010683.jpg)



### 一.TCP/IP连接

手机能够使用联网功能是因为手机底层实现了TCP/IP协议，可以使手机终端通过无线网络建立TCP连接。TCP协议可以对上层网络提供接口，使上层网络数据的传输建立在“无差别”的网络之上。

建立起一个TCP连接需要经过“三次握手”：

```
第一次握手：客户端发送syn包(syn=j)到服务器，并进入SYN_SEND状态，等待服务器确认；

第二次握手：服务器收到syn包，必须确认客户的SYN（ack=j+1），同时自己也发送一个SYN包（syn=k），即SYN+ACK包，此时服务器进入SYN_RECV状态；

第三次握手：客户端收到服务器的SYN＋ACK包，向服务器发送确认包ACK(ack=k+1)，此包发送完毕，客户端和服务器进入ESTABLISHED状态，完成三次握手。
```

握手过程中传送的包里不包含数据，三次握手完毕后，客户端与服务器才正式开始传送数据。理想状态下，TCP连接一旦建立，在通信双方中的任何一方主动关闭连接之前，TCP 连接都将被一直保持下去。断开连接时服务器和客户端均可以主动发起断开TCP连接的请求，断开过程需要经过“四次握手”（过程就不细写了，就是服务器和客户端交互，最终确定断开）.

### 二.HTTP连接

HTTP协议即超文本传送协议(Hypertext Transfer Protocol )，是Web联网的基础，也是手机联网常用的协议之一，HTTP协议是建立在TCP协议之上的一种应用。

HTTP连接最显著的特点是客户端发送的每次请求都需要服务器回送响应，在请求结束后，会主动释放连接。从建立连接到关闭连接的过程称为“一次连接”。

在HTTP 1.0中，客户端的每次请求都要求建立一次单独的连接，在处理完本次请求后，就自动释放连接。

在HTTP 1.1中则可以在一次连接中处理多个请求，并且多个请求可以重叠进行，不需要等待一个请求结束后再发送下一个请求。

由于HTTP在每次请求结束后都会主动释放连接，因此HTTP连接是一种“短连接”，要保持客户端程序的在线状态，需要不断地向服务器发起连接请求。通常的做法是即时不需要获得任何数据，客户端也保持每隔一段固定的时间向服务器发送一次“保持连接”的请求，服务器在收到该请求后对客户端进行回复，表明知道客户端“在线”。若服务器长时间无法收到客户端的请求，则认为客户端“下线”，若客户端长时间无法收到服务器的回复，则认为网络已经断开。

### 三  SOCKET原理

套接字（socket）概念

套接字（socket）是通信的基石，是支持TCP/IP协议的网络通信的基本操作单元。它是网络通信过程中端点的抽象表示，包含进行网络通信必须的五种信息：连接使用的协议，本地主机的IP地址，本地进程的协议端口，远地主机的IP地址，远地进程的协议端口。

应用层通过传输层进行数据通信时，TCP会遇到同时为多个应用程序进程提供并发服务的问题。多个TCP连接或多个应用程序进程可能需要通过同一个 TCP协议端口传输数据。为了区别不同的应用程序进程和连接，许多计算机操作系统为应用程序与TCP／IP协议交互提供了套接字(Socket)接口。应用层可以和传输层通过Socket接口，区分来自不同应用程序进程或网络连接的通信，实现数据传输的并发服务。

#### 建立socket连接

建立Socket连接至少需要一对套接字，其中一个运行于客户端，称为ClientSocket ，另一个运行于服务器端，称为ServerSocket 。

套接字之间的连接过程分为三个步骤：服务器监听，客户端请求，连接确认。

服务器监听：服务器端套接字并不定位具体的客户端套接字，而是处于等待连接的状态，实时监控网络状态，等待客户端的连接请求。

客户端请求：指客户端的套接字提出连接请求，要连接的目标是服务器端的套接字。为此，客户端的套接字必须首先描述它要连接的服务器的套接字，指出服务器端套接字的地址和端口号，然后就向服务器端套接字提出连接请求。

连接确认：当服务器端套接字监听到或者说接收到客户端套接字的连接请求时，就响应客户端套接字的请求，建立一个新的线程，把服务器端套接字的描述发给客户端，一旦客户端确认了此描述，双方就正式建立连接。而服务器端套接字继续处于监听状态，继续接收其他客户端套接字的连接请求。

### 四.SOCKET连接与TCP/IP连接

创建Socket连接时，可以指定使用的传输层协议，Socket可以支持不同的传输层协议（TCP或UDP），当使用TCP协议进行连接时，该Socket连接就是一个TCP连接。

socket则是对TCP/IP协议的封装和应用（程序员层面上）。也可以说，TPC/IP协议是传输层协议，主要解决数据 如何在网络中传输，而HTTP是应用层协议，主要解决如何包装数据。关于TCP/IP和HTTP协议的关系，网络有一段比较容易理解的介绍：

“我们在传输数据时，可以只使用（传输层）TCP/IP协议，但是那样的话，如 果没有应用层，便无法识别数据内容，如果想要使传输的数据有意义，则必须使用到应用层协议，应用层协议有很多，比如HTTP、FTP、TELNET等，也 可以自己定义应用层协议。WEB使用HTTP协议作应用层协议，以封装HTTP文本信息，然后使用TCP/IP做传输层协议将它发到网络上。”

我们平时说的最多的socket是什么呢，实际上socket是对TCP/IP协议的封装，Socket本身并不是协议，而是一个调用接口（API），通过Socket，我们才能使用TCP/IP协议。 实际上，Socket跟TCP/IP协议没有必然的联系。Socket 编程 接口在设计的时候，就希望也能适应其他的网络协议。所以说，Socket的出现，只是使得程序员更方便地使用TCP/IP协议栈而已，是对TCP/IP协议的抽象，从而形成了我们知道的一些最基本的函数接口，比如create、 listen、connect、accept、send、read和write等等。网络有一段关于socket和TCP/IP协议关系的说法比较容易理解：

“TCP/IP只是一个协议栈，就像操作系统的运行机制一样，必须要具体实现，同时还要提供对外的操作接口。这个就像操作系统会提供标准的编程接口，比如win32编程接口一样，TCP/IP也要提供可供程序员做网络开发所用的接口，这就是Socket编程接口。”

实际上，传输层的TCP是基于网络层的IP协议的，而应用层的HTTP协议又是基于传输层的TCP协议的，而Socket本身不算是协议，就像上面所说，它只是提供了一个针对TCP或者UDP编程的接口。socket是对端口通信开发的工具,它要更底层一些.

### 五.Socket连接与HTTP连接

由于通常情况下Socket连接就是TCP连接，因此Socket连接一旦建立，通信双方即可开始相互发送数据内容，直到双方连接断开。但在实际网络应用中，客户端到服务器之间的通信往往需要穿越多个中间节点，例如 路由器 、网关、防火墙等，大部分防火墙默认会关闭长时间处于非活跃状态的连接而导致 Socket 连接断连，因此需要通过轮询告诉网络，该连接处于活跃状态。

而HTTP连接使用的是“请求—响应”的方式，不仅在请求时需要先建立连接，而且需要客户端向服务器发出请求后，服务器端才能回复数据。

很多情况下，需要服务器端主动向客户端推送数据，保持客户端与服务器数据的实时与同步。此时若双方建立的是Socket连接，服务器就可以直接将数据传送给客户端；若双方建立的是HTTP连接，则服务器需要等到客户端发送一次请求后才能将数据传回给客户端，因此，客户端定时向服务器端发送连接请求，不仅可以保持在线，同时也是在“询问”服务器是否有新的数据，如果有就将数据传给客户端。

http协议是应用层的协义

有个比较形象的描述：HTTP是轿车，提供了封装或者显示数据的具体形式；Socket是发动机，提供了网络通信的能力。

两个计算机之间的交流无非是两个端口之间的数据通信,具体的数据会以什么样的形式展现是以不同的应用层协议来定义的如HTTP、FTP...

## HTTPS

HTTPS加密过程

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359240544677.jpg)
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15359242716342.jpg)

### 1.https简单说明

HTTPS并非是应用层的一种新协议。只是HTTP通信接口部分用
SSL ( Secure Socket Layer )和TLS ( Transport Layer Security)协议代替
而已。
    HTTPS（全称：Hyper Text Transfer Protocol over Secure Socket Layer），是以安全为目标的HTTP通道，简单讲是HTTP的安全版。
    即HTTP下加入SSL层，HTTPS的安全基础是SSL，因此加密的详细内容就需要SSL。 它是一个URI scheme（抽象标识符体系），句法类同http:体系。用于安全的HTTP数据传输。
    https:URL表明它使用了HTTP，但HTTPS存在不同于HTTP的默认端口及一个加密/身份验证层（在HTTP与TCP之间）。
    HTTPS 全称为 HTTP Over TLS。（SSL/TLS 是一系列承前启后的加密协议族，此处统称为 TLS。）

#### 2.HTTPS和HTTP的区别主要为以下四点：

* https协议需要到ca申请证书，一般免费证书很少，需要交费。
* http是超文本传输协议，信息是明文传输，https 则是具有安全性的ssl加密传输协议。
* http和https使用的是完全不同的连接方式，用的端口也不一样，前者是80，后者是443。
* http的连接很简单，是无状态的；HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络协议，比http协议安全。

#### 3.简单说明

1. HTTPS的主要思想是在不安全的网络上创建一安全信道，并可在使用适当的加密包和服务器证书可被验证且可被信任时，对窃听和中间人攻击提供合理的保护。
2. HTTPS的信任继承基于预先安装在浏览器中的证书颁发机构（如VeriSign、Microsoft等. （意即“我信任证书颁发机构告诉我应该信任的”) 。
3. 因此，一个到某网站的HTTPS连接可被信任，如果服务器搭建自己的https 也就是说采用自认证的方式来建立https信道，这样一般在客户端是不被信任的。
4. 所以我们一般在浏览器访问一些https站点的时候会有一个提示，问你是否继续。

#### 4.对开发的影响。

4.1 如果是自己使用NSURLSession来封装网络请求，涉及代码如下。

```objc
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask *task =  [session dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];
}

/*
 只要请求的地址是HTTPS的, 就会调用这个代理方法
 我们需要在该方法中告诉系统, 是否信任服务器返回的证书
 Challenge: 挑战 质问 (包含了受保护的区域)
 protectionSpace : 受保护区域
 NSURLAuthenticationMethodServerTrust : 证书的类型是 服务器信任
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    //    NSLog(@"didReceiveChallenge %@", challenge.protectionSpace);
    NSLog(@"调用了最外层");
    // 1.判断服务器返回的证书类型, 是否是服务器信任
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSLog(@"调用了里面这一层是服务器信任的证书");
        /*
         NSURLSessionAuthChallengeUseCredential = 0,                     使用证书
         NSURLSessionAuthChallengePerformDefaultHandling = 1,            忽略证书(默认的处理方式)
         NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,     忽略书证, 并取消这次请求
         NSURLSessionAuthChallengeRejectProtectionSpace = 3,            拒绝当前这一次, 下一次再询问
         */
//        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];

        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential , card);
    }
}
```

4.2 如果是使用AFN框架，那么我们不需要做任何额外的操作，AFN内部已经做了处理。

### 什么是 TLS

TLS 中文名称为安全传输层协议，其目的是在客户端与服务端之间建立一个 防窃听、防篡改 的可信信息传递通道。

HTTPS工作在客户端和服务器端之间。以上故事中，客户端可以看作为大师A，服务器端可以看作为大师B。客户端和服务器本身都会自带一些加密的算法，用于双方协商加密的选择项。
1、客户端首先会将自己支持的加密算法，打个包告诉服务器端。
2、服务器端从客户端发来的加密算法中，选出一组加密算法和HASH算法（注，HASH也属于加密），并将自己的身份信息以证书的形式发回给客户端。而证书中包含了网站的地址，加密用的公钥，以及证书的颁发机构等；
  这里有提到公钥的概念是故事中没有的。我们常见的加密算法一般是一些对称的算法，如凯撒加密；对称算法即加密用的密钥和解密用的密钥是一个。如故事中的密钥是4。还有一种加密解密算法称之为非对称算法。这种算法加密用的密钥（公钥）和解密用的密钥（私钥）是两个不同的密钥；通过公钥加密的内容一定要使用私钥才能够解密。
  这里，服务器就将自己用来加密用的公钥一同发还给客户端，而私钥则服务器保存着，用户解密客户端加密过后的内容。

3、客户端收到了服务器发来的数据包后，会做这么几件事情：

 1）验证一下证书是否合法。一般来说，证书是用来标示一个站点是否合法的标志。如果说该证书由权威的第三方颁发和签名的，则说明证书合法。
 2）如果证书合法，或者客户端接受和信任了不合法的证书，则客户端就会随机产生一串序列号，使用服务器发来的公钥进行加密。这时候，一条返回的消息就基本就绪。
 3）最后使用服务器挑选的HASH算法，将刚才的消息使用刚才的随机数进行加密，生成相应的消息校验值，与刚才的消息一同发还给服务器。

4、服务器接受到客户端发来的消息后，会做这么几件事情：
 1）使用私钥解密上面第2）中公钥加密的消息，得到客户端产生的随机序列号。
 2）使用该随机序列号，对该消息进行加密，验证的到的校验值是否与客户端发来的一致。如果一致则说明消息未被篡改，可以信任。
 3）最后，使用该随机序列号，加上之前第2步中选择的加密算法，加密一段握手消息，发还给客户端。同时HASH值也带上。

5、客户端收到服务器端的消息后，接着做这么几件事情：
 1）计算HASH值是否与发回的消息一致
 2）检查消息是否为握手消息

6、握手结束后，客户端和服务器端使用握手阶段产生的随机数以及挑选出来的算法进行对称加解密的传输。
  为什么不直接全程使用非对称加密算法进行数据传输？这个问题的答案是因为非对称算法的效率对比起对称算法来说，要低得多得多；因此往往只用在HTTPS的握手阶段。
  以下是我们一些经常使用的加密算法，是不是有熟悉的味道？
   非对称加密算法：RSA, DSA/DSS
   对称加密算法： AES, 3DES
   HASH算法：MD5, SHA1, SHA256

这就是HTTPS的基本原理，如果没有简单粗暴，请告诉我，以帮助我持续改进；如果真的简单粗暴，请告诉有需要的人，大家共同进步。


### HTTPS和HTTP的区别

一、https协议需要到ca申请证书，一般免费证书很少，需要交费。
二、http是超文本传输协议，信息是明文传输，https 则是具有安全性的ssl加密传输协议。
三、http和https使用的是完全不同的连接方式，用的端口也不一样，前者是80，后者是443。
四、http的连接很简单，是无状态的；HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络协议，比http协议安全。
 
3.简单说明
1）HTTPS的主要思想是在不安全的网络上创建一安全信道，并可在使用适当的加密包和服务器证书可被验证且可被信任时，对窃听和中间人攻击提供合理的保护。
2）HTTPS的信任继承基于预先安装在浏览器中的证书颁发机构（如VeriSign、Microsoft等）（意即“我信任证书颁发机构告诉我应该信任的”）。
3）因此，一个到某网站的HTTPS连接可被信任，如果服务器搭建自己的https 也就是说采用自认证的方式来建立https信道，这样一般在客户端是不被信任的。
4）所以我们一般在浏览器访问一些https站点的时候会有一个提示，问你是否继续。

### iOS 配置https

AFNetworking 对数据进行https ssl加密

[ios 配置https - 漫步CODE人生 - 博客园](https://www.cnblogs.com/scode2/p/8664478.html)

#### AFNetworking 配置https

```objc
一.项目中的网络交互都是基于AFN，要求AFN版本在3.0及其以上;
 
二.代码部分
设置AFN请求管理者的时候 添加 https ssl 验证。
// 1.获得请求管理者
AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
// 2.加上这个函数，https ssl 验证。
[manager setSecurityPolicy:[self customSecurityPolicy]];
 
// https ssl 验证函数
 
- (AFSecurityPolicy *)customSecurityPolicy {
    
    // 先导入证书 证书由服务端生成，具体由服务端人员操作
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"cer"];//证书的路径
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
         // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES;
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    return securityPolicy;
}
 
 
三.关于证书 参考文章:http://www.2cto.com/Article/201510/444706.html
服务端给的是crt后缀的证书，其中iOS客户端用到的cer证书，是需要开发人员转换：
1.证书转换
在服务器人员，给你发送的crt证书后，进到证书路径，执行下面语句
 
openssl x509 -in 你的证书.crt -out 你的证书.cer -outform der
 
这样你就可以得到cer类型的证书了。双击，导入电脑。
2.证书放入工程
1、可以直接把转换好的cer文件拖动到工程中。
2、可以在钥匙串内，找到你导入的证书，单击右键，导出项目，就可以导出.cer文件的证书了
 
参考链接:http://www.jianshu.com/p/97745be81d64。
 
四.在info.plist去掉之前允许http加载的代码 就是删除下面的代码(么有的就省了这一步)
 <key>NSAppTransportSecurity</key>
	<dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
```

AFN https认证主要的四个步骤：

步骤一：服务器cer证书导入Xcode项目
获得证书cer文件
法一，服务器那边给（我们项目服务器给的cer文件，导入项目中出了点问题，之后用的是自己在网站上导的）；
法二，自己在网站导出（以下面12306网页为例 https://kyfw.12306.cn/otn/lcxxcx/init）
打开上面给的12306链接，点击https旁边的三角感叹号，依次如图操作，则会出现下图
按住箭头所指图片，拖拽到桌面，之后返回到桌面，会发现kyfw.12306.cn.cer文件
导入到Xcode项目中
add file添加到项目中，ok。（这样假如失败的话，可以尝试导入证书之前，先双击证书添加到钥匙串中，之后允许，最后再导出，再重新导入到项目中）
步骤二：xcode info.list文件相关配置
主要是设置ATS开关和白名单（因为是自签名的证书，必须要添加白名单，即自己服务器的域名，否则无法访问）。

notice:图中ATS下面的Allow Arbitrary Loads 若设置成YES的话，则app允许http访问，其实这样绕过了https，但是这种情况确实非常不安全，后面可以看到Charles一抓包，数据全都能看的见。

步骤三：AFN程序代码相关配置

```objc

AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    //配置https
    session.securityPolicy = [self customSecurityPolicy];
    session.securityPolicy.allowInvalidCertificates = YES;

#pragma mark- 配置https
- (AFSecurityPolicy *)customSecurityPolicy
{
    /** https */
    NSString*cerPath = [[NSBundle mainBundle] pathForResource:@"kyfw.12306.cn.cer"ofType:nil];
    NSData*cerData = [NSData dataWithContentsOfFile:cerPath];
    NSSet*set = [[NSSet alloc] initWithObjects:cerData,nil];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:set];
    return policy;
}

```
步骤四：Charles抓包验证
首先检测，google浏览器请求，Charles抓包是否成功，若失败，解决方法如下（cmd+, 快捷键进入浏览器设置界面）


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15343913264534.jpg)

* 连接建立过程中使用非对称加密，很耗时

* 后续通信过程中使用对称加密

> [摘要]为了强制增强数据访问安全， iOS9 默认会把 所有的http请求 所有从NSURLConnection 、 CFURL 、 NSURLSession发出的 HTTP 请求，都改为 HTTPS 请求：iOS9.x-SDK编译时，默认会让所有从NSURLConnection 、 CFURL 、 NSURLSession发出的 HTTP 请求统一采用TLS 1.2 协议。因为 AFNetworking 现在的版本底层使用了 NSURLConnection ，众多App将被影响（基于iOS8.x-SDK的App不受影响）。服务器因此需要更新，以解析相关数据。如不更新，可通过在 Info.plist 中声明，倒退回不安全的网络请求。而这一做法，官方文档称为ATS，全称为App Transport Security，是iOS9的一个新特性。

一个符合 ATS 要求的 HTTPS，应该满足如下条件：
* Transport Layer Security协议版本要求TLS1.2以上
* 服务的Ciphers配置要求支持Forward Secrecy等
* 证书签名算法符合ATS要求等

```
HTTPS =  HTTP+SSL/TLS+TCP 
```
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15335338411873.jpg)

Apple让你的HTTP采用SSL/TLS协议，就是让你从HTTP转到HTTPS。而这一做法，官方文档称为ATS，全称为App Transport Security。


#### Mix & Match（混合）

如果你的服务器不符合ATS要求。

比如当你遇到以下三个不符合 ATS 要求的服务器的域名时：

1.  api.insecuredomain.com
2.  cdn.domain.com
3.  thatotherdomain.com

你可以分别设置如下：

1.  api.insecuredomain.com

Info.plist 配置中的XML源码如下所示:

```text-xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSExceptionDomains</key>
       <dict>
           <key>api.insecuredomain.com</key>
           <dict>

               <!--允许App进行不安全的HTTP请求-->
               <key>NSExceptionAllowsInsecureHTTPLoads</key>
               <true/>

               <!--适用于这个特定域名下的所有子域-->
               <key>NSIncludesSubdomains</key>
               <true/>
           </dict>
       </dict>
   </dict>
```

在 plist 文件里显示如下：

[![enter image description here](https://camo.githubusercontent.com/a45cc829d85c2a08788bd2a676148aef6c5f439a/687474703a2f2f6935392e74696e797069632e636f6d2f6678746b306a2e6a7067)](https://camo.githubusercontent.com/a45cc829d85c2a08788bd2a676148aef6c5f439a/687474703a2f2f6935392e74696e797069632e636f6d2f6678746b306a2e6a7067)

我们定义的第一个“例外”（Exception）告诉ATS当与这个子域交互的时候撤销了必须使用HTTPS的要求。注意这个仅仅针对在“例外”（Exception）中声明了的子域。非常重要的一点是要理解NSExceptionAllowsInsecureHTTPLoads关键字并不仅仅只是与使用HTTPS相关。这个“例外”（Exception）指明了对于那个域名，所有的App Transport Security的要求都被撤销了。


## TODO

进一步阅读

* [Apple官方文档翻译: NSURLSession Programming Guide-codexiu.cn](http://www.codexiu.cn/ios/blog/16902/)
* [urlsession](https://developer.apple.com/documentation/foundation/urlsession)
* [URL Loading System | Apple Developer Documentation](https://developer.apple.com/documentation/foundation/url_loading_system)

## 参考

1. [简析TCP的三次握手与四次分手](http://www.jellythink.com/archives/705)
2. [公钥，私钥和数字签名这样最好理解](http://blog.csdn.net/21aspnet/article/details/7249401)
3. [关于HTTP协议，一篇就够了 - 简书](http://www.jianshu.com/p/80e25cb1d81a)

4. [简单粗暴系列之HTTPS原理](http://www.jianshu.com/p/650ad90bf563)
5. [iOS 配置https - 简书](https://www.jianshu.com/p/8c128d9c9681)
6. [ios 配置https - 漫步CODE人生 - 博客园](https://www.cnblogs.com/scode2/p/8664478.html)
7. [ChenYilong/iOS9AdaptationTips: iOS9适配系列教程（iOS9开发学习交流群：515295083）](https://github.com/ChenYilong/iOS9AdaptationTips#1-demo1_ios9%E7%BD%91%E7%BB%9C%E9%80%82%E9%85%8D_ats%E6%94%B9%E7%94%A8%E6%9B%B4%E5%AE%89%E5%85%A8%E7%9A%84https)
8. [iOS HTTPS适配 - 简书](https://www.jianshu.com/p/25efb6d8ec8c#%E4%B8%80%E3%80%81%E5%87%86%E5%A4%87%E5%B7%A5%E4%BD%9C)
9. [iOS 9 HTTPS适配 - 简书](https://www.jianshu.com/p/b03ae4a1a2d3)
10. [一次完整的HTTP请求过程 - CSDN博客](https://blog.csdn.net/yezitoo/article/details/78193794)
11. [iOS AFN之https配置小结 - 简书](https://www.jianshu.com/p/b254abbe3e13)
