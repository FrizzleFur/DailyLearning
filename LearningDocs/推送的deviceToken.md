# [iPhone的UDID与push中使用的device token的关系](http://blog.csdn.net/xyxjn/article/details/40898073)

[iPhone的UDID与push中使用的device token的关系](http://www.360doc.com/content/12/1116/09/10941785_248142762.shtml)
  先简单介绍下push的机制


<img src="http:///oc98nass3.bkt.clouddn.com/201612/1497234041921.png" width="250"/>


客户端通过

(void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types
这个函数向APNs（Apple Push Service）注册push，types可标明接收的push的类型，声音，数字等。

(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
当app成功注册通知后，会调用这个函数，并把deviceToken返回给应用。

然后我们的程序就会把返回的这个deviceToken以及设备的udid及软件版本（淘宝 for iPhone还是淘宝 for iPad）及系统版本，用户名等发送到我们的服务器（下图中的provider）上，然后存储在数据库里。整个获取device token的过程可参见下图所示：


在需要发送push时，我们的服务端就会取出要发送的设备的device token，然后以下图所示的结构，组成符合特定结构的字符串，然后将其发送到的APNs


APNs可以根据与APNs建立连接的Provider所使用的证书判断是要哪个app请求发送的notification，继而把这个notification发送到的设备上。

下图为一个简单的从Provider到Device发送push的过程：


device token到底是什么呢？ 不同的app的device token相同么？ 一个设备会产生多个device token么？ 一个的device token可能对应多个UDID么？

结论：device token是对APNs来说，设备的标识符，与app无关，所以同一台设备上，不同的app获得的device token是一样的; 一个设备可能会产生多个device token, 一个device token也可能对应多个UDID，下面进行解释。

device token是什么？

文档中如下描述的：


对于APS来说，token是设备的标识符。device token不同于UIDevice的uniqueIdentifier（即UDID），因为出于安全和隐私原因，当设备被擦除后，token必须变化。
所以也就是说，一般情况下，token是不变的，但是在设备被擦除后，token会变的。

今天无心说在我们的服务器上的数据库里，存在同一个UDID对应有多个token的情况，之前是没有考虑到设备擦除的情况，所以就怀疑是不是同一个 设备上同时装了taobao4iphone和taobao4ipad，而token是与app关联的，所以产生的这种情况，于是就找了杨匡的ipad来做 测试，结果发现taobao4iphone和taobao4ipad收到的token是相同的，所以token应该是与app无关的，而是针对设备的（文 档上也是如此描述的），是设备的标识，那除了设备被擦除的情况外，设备的device token 应该是相同的，可是杨匡说之前崇厚给他查出来的他的iPad的token和我log出来的device token是不同的，后来就想到了，**push是有两套的，development和product，即调试和release，在这两种情况下，服务端使用 的push证书是不一样的，而程序使用的证书也不一样，那同一个设备在development和distribution情况下收到的device token**是否一样呢，于是就做了实验，实际结果如下

实验设备：iPad 1
<img src="http:///oc98nass3.bkt.clouddn.com/201612/1497234191810.png" width="304"/>


可以看出，同一个设备在development和distribution情况下，收到的device token是不同的，而token是与app无关的。

综合文档及上述实验结果可以得到以下结果：

同一个udid对应有不同的device token的情况暂时有如下两种：

设备擦除过，token变化过，老的新的都存储在数据库里
设备同时装过development和distribution的程序
不知道还有没有其它原因造成的同一个设备有不同的device token的情况，大家如果有什么相关的经验，可以补充一下。

无心说数据库里也有同一个device token对应多个UDID的情况，这种情况就比较诡异了，按理说不应该的，比较APNs把token作为设备的标识的，如果同一个device token可以对应多个udid，那发push不是就会混乱了么，在网上查了相关资料，发现还真的有这种情况，参见

http://blog.csdn.net/sjzsp/article/details/6314896， 文章里写的很详细，下面把重点部分提出来，详情自己去看，呵呵

设备令牌是怎么生成的呢？是每次建立TLS连接时，APNS通过前一层次(TLS层)里我们提到的每台正常的iPhone唯一的设备证书(unique device certificate)，并用令牌密钥(token key)加密生成的。

最重要的部分——每台iPhone独有的设备证书和密钥的来历

正常的iPhone刷系统之后，是没有设备证书和密钥的。这就是为什么iPhone会需要连接到iTunes上进行激活——激活过程中，Apple会分配给每台iPhone独一无二的设备证书(device certificate)和密钥(key) 。

iPhone OS 3.X 使用blacksn0w进行解锁 的过程，是不经过iTunes的，而blacksn0w本身又不生成对应的设备证书(device certificate)和密钥(key) ，因此这样解锁完的iPhone根本不可能与APNS建立任何的TLS链接，Push自然废了。

但当多个iPhone的设备证书(device certificate)完全一致时，就存在一定几率使得多个iPhone获得相同的设备令牌(device token)

要修补这个问题，唯一的办法就是重新生成唯一且有效的设备证书(device certificate)和密钥(key) 。于是，最早，dev team推出了一个测试版补丁，Push fix by dev team（通过他们的twitter发布的，因此官网没有消息）。这个补丁初期很有效。但是仅在iPhone 2G上比较正常。之后某人士发布pushfix 1.0了。由于使用了不同的生成方法，因此在新版本iPhone上也正常工作了。于是风靡一时。

然而，以上两个补丁都有严重的隐患——他们使用了一个固定的证书作为设备证书(device certificate)。因此在不同iPhone上的区别仅仅在于生成的密钥(key)不同。 （待确认）

而随着这两个补丁的使用人数不断增加，使得出现获得相同设备令牌(device token)的iPhone数量大大增加了。

当这些相同设备令牌(device token)的iPhone上启用了同一个应用程序的Push的时候，就极有可能出现彼此间的Push串发的现象。——如某论坛目前N多人抱怨QQ的Push到别人iPhone上的情况就是如此。

以上大概解释了同一个device token对应多个UDID的原因，

由于我们后续也会把与用户相关的信息push到用户的设备上，所以这个问题，我们也要考虑下应该怎么处理，否则也可能会出现，收到别人的物流的push。。。

另外，由于iOS5.0后，UIDevice中的uniqueIdentifier会逐步被废弃，所以，后面的版本中，我们会使用把设备的mac地 址md5计算后的结果做为设备的唯一标识，用其去代替UDID上传到我们的服务端上，但是无论是UDID还是mac地址的md5值，都只是作为设备的标 识，在发送push时，唯一需要与设备相关的信息就是device token，所以这个应该不影响我们的push。



