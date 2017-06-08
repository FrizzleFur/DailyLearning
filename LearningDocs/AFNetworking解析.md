
# AFNetworking.md

>
>
>


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


### 参考

1. [AFNetworking源码解析](http://www.jianshu.com/p/22075e7db6f7)
2. [AFNetworking](https://github.com/AFNetworking/AFNetworking)
3. 

