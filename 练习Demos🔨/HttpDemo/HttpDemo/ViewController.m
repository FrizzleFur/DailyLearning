//
//  ViewController.m
//  HttpDemo
//
//  Created by MichaelMao on 2018/9/2.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableData *fileData;/**< 接受响应体的信息 */
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ViewController
@synthesize webView;

#pragma mark -
#pragma mark - init

- (NSMutableData *)fileData {
    if (_fileData == nil) {
        _fileData = [NSMutableData data];
    }
    return _fileData;
}


#pragma mark -
#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
}

- (void)setupUI{
    webView = [[UIWebView alloc] init];
    webView.frame = CGRectInset(self.view.frame, 100, 100);
    webView.layer.borderColor = [UIColor grayColor].CGColor;
    webView.layer.borderWidth = 5;
    [self.view addSubview:webView];
}

#pragma mark -
#pragma mark - Method Calling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self makeHTTPSGetRequest];
}

#pragma mark -
#pragma mark - Get 请求

/** get请求 */
- (void)makeGetRequest{

    //1. 创建一个url
    NSString *requestStr = @"http://www.baidu.com";
    NSURL *url = [NSURL URLWithString:requestStr];
    
    //2. 创建一个请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //3. 创建一个session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //4. 创建一个任务
    /*
     如果是Get请求，可以使用dataTaskWithURL创建Get请求，更方便
     NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {}
     注意:dataTaskWithURL内部会自动的将请求路径作为参数创建-一个请求对象(GET请求)
    */

    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //6. 数据解析
        //data是请求体，response是请求头
        NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"htmlStr = %@", htmlStr);
        NSLog(@"error = %@", error);

        // 使用NSOperation回到主线程
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            __weak typeof(self) weakSelf = self;
            [weakSelf.webView loadHTMLString:htmlStr baseURL:nil];
        }];
        //将任务加入到主队列中
        [[NSOperationQueue mainQueue] addOperation:op];
        
        /* 使用GCD回到主线程
          __weak typeof(self) weakSelf = self;
          dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf.webView loadHTMLString:htmlStr baseURL:nil];
          });
         */
}];
    
    //5. 开启任务, 默认创建后的NSURLSessionTask是关闭的
    [task resume];
}

#pragma mark -
#pragma mark - Post 请求

/** Post请求 */
- (void)makePostRequest{
    
    //1. 创建一个url
    NSString *requestStr = @"https://movie.douban.com/subject_search";// 豆瓣电影搜索
    NSURL *url = [NSURL URLWithString:requestStr];
    
    //2.1 创建一个可变请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //2.2 设置请求方法为post
    request.HTTPMethod = @"POST";
    
    //2.3 设置请求体
    NSString *paraStr = @"search_text=Movie&cat=1002";
    request.HTTPBody = [paraStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //3. 创建一个共享的单例session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //4. 创建一个任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //6. 数据解析
        //data是请求体，response是请求头
        NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"htmlStr = %@", htmlStr);
        NSError *strError;
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error: &strError];
        NSLog(@"attrStr = %@", attrStr);
        NSLog(@"strError = %@", strError);
        
        // 使用NSOperation回到主线程
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            __weak typeof(self) weakSelf = self;
            [weakSelf.webView loadHTMLString:htmlStr baseURL:nil];
        }];
        //将任务加入到主队列中
        [[NSOperationQueue mainQueue] addOperation:op];
        
        /* 使用GCD回到主线程
         __weak typeof(self) weakSelf = self;
         dispatch_async(dispatch_get_main_queue(), ^{
         [weakSelf.webView loadHTMLString:htmlStr baseURL:nil];
         });
         */
    }];
    
    //5. 开启任务, 默认创建后的NSURLSessionTask是关闭的
    [task resume];
}

#pragma mark -
#pragma mark - HTTPS请求

/** Get的HTTPS请求 */
- (void)makeHTTPSGetRequest{
    
    //1. 创建一个url
    NSString *requestStr = @"https://kyfw.12306.cn/otn'";//发送HTTPS请求在未配置HTTPS时候，请求会报错
    NSURL *url = [NSURL URLWithString:requestStr];
    
    //2. 创建一个请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //3. 创建一个session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]	 delegate:self delegateQueue:[NSOperationQueue mainQueue]];//制定代理的队列为主队列
    
    //4. 创建一个任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //6. 数据解析
        //data是请求体，response是请求头
        NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"htmlStr = %@", htmlStr);
        NSLog(@"error = %@", error);        
        NSError *strError;
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error: &strError];
        NSLog(@"attrStr = %@", attrStr);
        NSLog(@"strError = %@", strError);
        
        // 使用NSOperation回到主线程
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            __weak typeof(self) weakSelf = self;
            [weakSelf.webView loadHTMLString:htmlStr baseURL:nil];
        }];
        //将任务加入到主队列中
        [[NSOperationQueue mainQueue] addOperation:op];
    }];
    
    //5. 开启任务, 默认创建后的NSURLSessionTask是关闭的
    [task resume];
}


#pragma mark -
#pragma mark - 文件下载

- (void)downloadTask {
    
    NSURL *url = [NSURL URLWithString:@"http://www.imageshop.com.tw/pic/shop/top/18083101.jpg"];
    
    //创建一个共享的单例session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //如果使用downloadTaskWithURL的block回调方式，无法监听文件下载进度，大文件下载时间比较长
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      
        NSLog(@"location = %@",location.absoluteString);

        NSLog(@"currentThread = %@", [NSThread currentThread]);

        //1. 设置目标路径
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) lastObject] stringByAppendingString:response.suggestedFilename];
        NSLog(@"fullPath = %@", fullPath);

        //2. 剪切文件到目标路径
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
        
    }];
        
    [downloadTask resume];
}


#pragma mark -
#pragma mark - URL拼接

- (void)printUrl {
    
    NSURL *baseURL = [NSURL URLWithString:@"http://example.com/v1/"];
    NSURL *url1 = [NSURL URLWithString:@"foo" relativeToURL:baseURL]; // http://example.com/v1/foo
    NSURL *url2 = [NSURL URLWithString:@"foo?bar=baz" relativeToURL:baseURL]; // http://example.com/v1/foo?bar=baz
    NSURL *url3 = [NSURL URLWithString:@"/foo" relativeToURL:baseURL]; // http://example.com/foo
    NSURL *url4 = [NSURL URLWithString:@"foo/" relativeToURL:baseURL]; // http://example.com/v1/foo
    NSURL *url5 = [NSURL URLWithString:@"/foo/" relativeToURL:baseURL]; // http://example.com/foo/
    NSURL *url6 = [NSURL URLWithString:@"http://example2.com/" relativeToURL:baseURL]; // http://example2.com/
    
    NSLog(@"url1 = %@", url1.absoluteString);
    NSLog(@"url2 = %@", url2.absoluteString);
    NSLog(@"url3 = %@", url3.absoluteString);
    NSLog(@"url4 = %@", url4.absoluteString);
    NSLog(@"url5 = %@", url5.absoluteString);
    NSLog(@"url6 = %@", url6.absoluteString);
}


#pragma mark -
#pragma mark - NSURLSessionTaskDelegate

/** 1. 接受到服务器的响应，默认会取消这个请求 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    NSLog(@"%s", __func__);
    completionHandler(NSURLSessionResponseAllow);/** 接受服务器的请求 */
    
}

/**
 * 接收到服务器返回的数据，多次调用
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"%s", __func__);
    //拼接数据
    [self.fileData appendData:data];
}

/**
 * 请求结束或者失败的时候调用
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"%s", __func__);
    //解析数据
    NSString *dataStr = [[NSString alloc] initWithData:self.fileData encoding:NSUTF8StringEncoding];
    NSLog(@"dataStr = %@", dataStr);
}

/** 接收到来自服务器的需要客户端身份验证的服务器的挑战 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
//    NSLog(@"challenge.protectionSpace = %@", challenge.protectionSpace);
    
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

@end
