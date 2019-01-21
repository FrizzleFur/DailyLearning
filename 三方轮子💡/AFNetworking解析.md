# AFNetworking解析.md

## AFN框架基本使用
- 0.1 AFN内部结构

```objc
AFN结构体
    - NSURLConnection
        + AFURLConnectionOperation(已经被废弃)
        + AFHTTPRequestOperation(已经被废弃)
        + AFHTTPRequestOperationManager(封装了常用的 HTTP 方法)(已经被废弃)
            * 属性
                * baseURL :AFN建议开发者针对 AFHTTPRequestOperationManager 自定义个一个单例子类，设置 baseURL, 所有的网络访问，都只使用相对路径即可
                * requestSerializer :请求数据格式/默认是二进制的 HTTP
                * responseSerializer :响应的数据格式/默认是 JSON 格式
                * operationQueue
                * reachabilityManager :网络连接管理器
            * 方法
                * manager :方便创建管理器的类方法
                * HTTPRequestOperationWithRequest :在访问服务器时，如果要告诉服务器一些附加信息，都需要在 Request 中设置
                * GET
                * POST

    - NSURLSession
        + AFURLSessionManager
        + AFHTTPSessionManager(封装了常用的 HTTP 方法)
            * GET
            * POST
            * UIKit + AFNetworking 分类
            * NSProgress :利用KVO

    - 半自动的序列化&反序列化的功能
        + AFURLRequestSerialization :请求的数据格式/默认是二进制的
        + AFURLResponseSerialization :响应的数据格式/默认是JSON格式
    - 附加功能
        + 安全策略
            * HTTPS
            * AFSecurityPolicy
        + 网络检测
            * 对苹果的网络连接检测做了一个封装
            * AFNetworkReachabilityManager

建议:
可以学习下AFN对 UIKit 做了一些分类, 对自己能力提升是非常有帮助的
```
- 0.2 AFN的基本使用

（1）发送POST请求的方式
```objc
-(void)post
{
    //1.创建会话管理者
    //AFHTTPSessionManager内部是基于NSURLSession实现的
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //2.创建参数
    NSDictionary *dict = @{
                           @"username":@"520it",
                           @"pwd":@"520it",
                           };

    //3.发送POST请求
    /*
     http://120.25.226.186:32812/login?username=ee&pwd=ee&type=JSON
     第一个参数：NSString类型的请求路径，AFN内部会自动将该路径包装为一个url并创建请求对象
     第二个参数：请求参数，以字典的方式传递，AFN内部会判断当前是POST请求还是GET请求，以选择直接拼接还是转换为NSData放到请求体中传递
     第三个参数：进度回调 此处为nil
     第四个参数：请求成功之后回调Block
     第五个参数：请求失败回调Block
     */
    [manager POST:@"http://120.25.226.186:32812/login" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        //注意：responseObject:请求成功返回的响应结果（AFN内部已经把响应体转换为OC对象，通常是字典或数组）
        NSLog(@"请求成功---%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败---%@",error);
    }];
}
```

（2）使用AFN下载文件
```objc
-(void)download
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];


    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/images/minion_13.png"]];

    //3.创建下载Task
    /*
     第一个参数：请求对象
     第二个参数：进度回调
        downloadProgress.completedUnitCount :已经下载的数据
        downloadProgress.totalUnitCount：数据的总大小
     第三个参数：destination回调，该block需要返回值（NSURL类型），告诉系统应该把文件剪切到什么地方
        targetPath：文件的临时保存路径
        response：响应头信息
     第四个参数：completionHandler请求完成后回调
        response：响应头信息
        filePath：文件的保存路径，即destination回调的返回值
        error：错误信息
     */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"%@\n%@",targetPath,fullPath);
        return [NSURL fileURLWithPath:fullPath];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@",filePath);
    }];

    //4.执行Task
    [downloadTask resume];
}
```

###1.AFN使用技巧

```objc
1.在开发的时候可以创建一个工具类，继承自我们的AFN中的请求管理者，再控制器中真正发请求的代码使用自己封装的工具类。
2.这样做的优点是以后如果修改了底层依赖的框架，那么我们修改这个工具类就可以了，而不用再一个一个的去修改。
3.该工具类一般提供一个单例方法，在该方法中会设置一个基本的请求路径。
4.该方法通常还会提供对GET或POST请求的封装。
5.在外面的时候通过该工具类来发送请求
6.单例方法：
+ (instancetype)shareNetworkTools
{
    static XMGNetworkTools *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 注意: BaseURL中一定要以/结尾
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://120.25.226.186:32812/"]];
    });
    return instance;
}
```

###2.AFN文件上传
```objc
1.文件上传拼接数据的第一种方式
[formData appendPartWithFileData:data name:@"file" fileName:@"xxoo.png" mimeType:@"application/octet-stream"];
2.文件上传拼接数据的第二种方式
 [formData appendPartWithFileURL:fileUrl name:@"file" fileName:@"xx.png" mimeType:@"application/octet-stream" error:nil];
3.文件上传拼接数据的第三种方式
 [formData appendPartWithFileURL:fileUrl name:@"file" error:nil];
4.【注】在资料中已经提供了一个用于文件上传的分类。

/*文件上传相关的代码如下*/
-(void)upload1
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //2.处理参数(非文件参数)
    NSDictionary *dict = @{
                           @"username":@"123"
                           };

    //3.发送请求上传文件
    /*
     第一个参数：请求路径（NSString类型）
     第二个参数：非文件参数，以字典的方式传递
     第三个参数：constructingBodyWithBlock 在该回调中拼接文件参数
     第四个参数：progress 进度回调
        uploadProgress.completedUnitCount:已经上传的数据大小
        uploadProgress.totalUnitCount：数据的总大小
     第五个参数：success 请求成功的回调
        task：上传Task
        responseObject:服务器返回的响应体信息（已经以JSON的方式转换为OC对象）
     第六个参数：failure 请求失败的回调
        task：上传Task
        error：错误信息
     */
    [manager POST:@"http://120.25.226.186:32812/upload" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        UIImage *image = [UIImage imageNamed:@"Snip20160117_1"];
        NSData *imageData = UIImagePNGRepresentation(image);

        //在该block中拼接要上传的文件参数
        /*
         第一个参数：要上传的文件二进制数据
         第二个参数：文件参数对应的参数名称，此处为file是该台服务器规定的（通常会在接口文档中提供）
         第三个参数：该文件上传到服务后以什么名称保存
         第四个参数：该文件的MIMeType类型
         */
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"123.png" mimeType:@"image/png"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"请求成功----%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"请求失败----%@",error);
    }];
}

-(void)upload2
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //2.处理参数(非文件参数)
    NSDictionary *dict = @{
                           @"username":@"123"
                           };

    //3.发送请求上传文件
    /*
     第一个参数：请求路径（NSString类型）
     第二个参数：非文件参数，以字典的方式传递
     第三个参数：constructingBodyWithBlock 在该回调中拼接文件参数
     第四个参数：progress 进度回调
        uploadProgress.completedUnitCount:已经上传的数据大小
        uploadProgress.totalUnitCount：数据的总大小
     第五个参数：success 请求成功的回调
        task：上传Task
        responseObject:服务器返回的响应体信息（已经以JSON的方式转换为OC对象）
     第六个参数：failure 请求失败的回调
        task：上传Task
        error：错误信息
     */
    [manager POST:@"http://120.25.226.186:32812/upload" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        NSURL *fileUrl = [NSURL fileURLWithPath:@"/Users/文顶顶/Desktop/Snip20160117_1.png"];


        //在该block中拼接要上传的文件参数
        //第一种拼接方法
        /*
         第一个参数：要上传的文件的URL路径
         第二个参数：文件参数对应的参数名称，此处为file是该台服务器规定的（通常会在接口文档中提供）
         第三个参数：该文件上传到服务后以什么名称保存
         第四个参数：该文件的MIMeType类型
         第五个参数：错误信息，传地址
         */
        //[formData appendPartWithFileURL:fileUrl name:@"file" fileName:@"1234.png" mimeType:@"image/png" error:nil];


        //第二种拼接方法：简写方法
        /*
         第一个参数：要上传的文件的URL路径
         第二个参数：文件参数对应的参数名称，此处为file
         第三个参数：错误信息
         说明：AFN内部自动获得路径URL地址的最后一个节点作为文件的名称，内部调用C语言的API获得文件的类型
         */
        [formData appendPartWithFileURL:fileUrl name:@"file" error:nil];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"请求成功----%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"请求失败----%@",error);
    }];
}
```

###3.使用AFN进行序列化处理
```objc
/*
1.AFN它内部默认把服务器响应的数据当做json来进行解析，所以如果服务器返回给我的不是JSON数据那么请求报错，这个时候需要设置AFN对响应信息的解析方式。AFN提供了三种解析响应信息的方式，分别是：
1）AFXMLParserResponseSerializer----XML
2) AFHTTPResponseSerializer---------默认二进制响应数据
3）AFJSONResponseSerializer---------JSON

2.还有一种情况就是服务器返回给我们的数据格式不太一致（开发者工具Content-Type:text/xml）,那么这种情况也有可能请求不成功。解决方法:
1） 直接在源代码中修改，添加相应的Content-Type
2） 拿到这个属性，添加到它的集合中

3.相关代码
-(void)srializer
{
    //1.创建请求管理者，内部基于NSURLSession
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    /* 知识点1：设置AFN采用什么样的方式来解析服务器返回的数据*/

    //如果返回的是XML，那么告诉AFN，响应的时候使用XML的方式解析
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];

    //如果返回的就是二进制数据，那么采用默认二进制的方式来解析数据
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    //采用JSON的方式来解析数据
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];


    /*知识点2 告诉AFN，再序列化服务器返回的数据的时候，支持此种类型
    [AFJSONResponseSerializer serializer].acceptableContentTypes = [NSSet setWithObject:@"text/xml"];

    //2.把所有的请求参数通过字典的方式来装载，GET方法内部会自动把所有的键值对取出以&符号拼接并最后用？符号连接在请求路径后面
    NSDictionary *dict = @{
                           @"username":@"223",
                           @"pwd":@"ewr",
                           @"type":@"XML"
                           };

    //3.发送GET请求
    [manager GET:@"http://120.25.226.186:32812/login" parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

        //4.请求成功的回调block
        NSLog(@"%@",[responseObject class]);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

        //5.请求失败的回调，可以打印error的值查看错误信息
        NSLog(@"%@",error);
    }];
}
```

###4.使用AFN来检测网络状态

```objc
/*
说明：可以使用AFN框架中的AFNetworkReachabilityManager来监听网络状态的改变，也可以利用苹果提供的Reachability来监听。建议在开发中直接使用AFN框架处理。
 */
//使用AFN框架来检测网络状态的改变
-(void)AFNReachability
{
    //1.创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];

    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown          = 未知
     AFNetworkReachabilityStatusNotReachable     = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 3G
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;

            default:
                break;
        }
    }];

    //3.开始监听
    [manager startMonitoring];
}

------------------------------------------------------------
//使用苹果提供的Reachability来检测网络状态，如果要持续监听网络状态的概念，需要结合通知一起使用。
//提供下载地址：https://developer.apple.com/library/ios/samplecode/Reachability/Reachability.zip

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //1.注册一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange) name:kReachabilityChangedNotification object:nil];

    //2.拿到一个对象，然后调用开始监听方法
    Reachability *r = [Reachability reachabilityForInternetConnection];
    [r startNotifier];

    //持有该对象，不要让该对象释放掉
    self.r = r;
}

//当控制器释放的时候，移除通知的监听
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)networkChange
{
    //获取当前网络的状态
   if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == ReachableViaWWAN)
    {
        NSLog(@"当前网络状态为3G");
        return;
    }

    if ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == ReachableViaWiFi)
    {
        NSLog(@"当前网络状态为wifi");
        return;
    }

    NSLog(@"当前没有网络");
}
```


 `AFNetworking`的框架：

<img src="http:///oc98nass3.bkt.clouddn.com/201612/1496907785055.png" width="371"/>

`AFNetworking3.0`已经去掉了对废弃的`NSURLConnection`的支持，使用`NSURLSession`来实现

![](http://oc98nass3.bkt.clouddn.com/2017-06-08-14969084170210.jpg)


![](http://oc98nass3.bkt.clouddn.com/2017-06-08-14969092256278.jpg)



```
  1.  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    所有的网络请求,均有manager发起
  2. 需要注意的是,默认提交请求的数据是二进制的,返回格式是JSON
     如果提交数据是JSON的,需要将请求格式设置为AFJSONRequestSerializer

  3. 请求格式
   AFHTTPRequestSerializer            二进制格式
   AFJSONRequestSerializer            JSON
   AFPropertyListRequestSerializer    PList(是一种特殊的XML,解析起来相对容易)

  4. 返回格式
   AFHTTPResponseSerializer           二进制格式
   AFJSONResponseSerializer           JSON
   AFXMLParserResponseSerializer      XML,只能返回XMLParser,还需要自己通过代理方法解析
   AFXMLDocumentResponseSerializer (Mac OS X)
   AFPropertyListResponseSerializer   PList
   AFImageResponseSerializer          Image
   AFCompoundResponseSerializer       组合
```


### 示例代码


```
  一:提交数据是JSON格式
   NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
   [dict setObject:@"apple" forKey:@"brand"];
   NSString *url=@"http://xxxxx";
   AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   manager.responseSerializer = [AFJSONResponseSerializer serializer];//申明返回的结果是json类型
   manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
   manager.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
   [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {

   } failure:^(AFHTTPRequestOperation *operation, NSError *error){

  }
];
  二：提交数据是NSData类型，即默认类型
       NSString *str=[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
       NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
       NSURLRequest *request = [NSURLRequest requestWithURL:url];
       AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
       [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, idresponseObject) {
        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        id dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
         NSLog(@"获取到的数据为：%@",dict);
   }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
}];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
   将所有的网络请求都放入一个线程队列中。

 三：上传图片操作：
     UIImage * image = [UIImage imageNamed:@"imike.png"];
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@", str];
    NSDictionary *parameters = @{@"filename":fileName};

    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
   //如果报接受类型不一致请替换一致text/html或别的
     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:@"http://XXX" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      // 上传图片，以文件流的格式
     [formData appendPartWithFileData:imageData name:@"img" fileName:fileName mimeType:@"image/png"];

   } success:^(AFHTTPRequestOperation *operation, id responseObject){        
        NSLog(@"%@",responseObject);  
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  }];
四：下载图片：
   NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
   AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

   NSURL *URL = [NSURL URLWithString:@"http://192.168.40.10/FileDownload/WebForm1.aspx"];
   NSURLRequest *request = [NSURLRequest requestWithURL:URL];
   NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
   NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
       return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
  } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
       NSLog(@"File downloaded to: %@", filePath);
 }];
   [downloadTask resume];
```


### AFNetworking请求url包含中文

问题原因, 是因为在请求中拼接的URL中，含有中文导致报错
只要把url处理一下

```objc
NSString *url = [NSString stringWithFormat:@"%@%@",SHOPSUOYUAN_BASEURL,dict];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
```

* 如果是POST请求，在请求体的参数中包含中文时，因为请求体调用dataUsingEncoding转码，所以是不需要再次转码。
* 

## 参考

1. [AFNetworking源码解析](http://www.jianshu.com/p/22075e7db6f7)
2. [AFNetworking](https://github.com/AFNetworking/AFNetworking)
3. [AFNetworking到底做了什么？](https://www.jianshu.com/p/856f0e26279d)
4. [AFNetworking到底做了什么？(二) - 简书](https://www.jianshu.com/p/f32bd79233da)
5. [AFNetworking到底做了什么？(终) - 简书](https://www.jianshu.com/p/7ed7c0be15b4)
6. [Alamofire 的设计之道 - iOS - 掘金](https://juejin.im/entry/5947ae51a0bb9f006bdd3241)


