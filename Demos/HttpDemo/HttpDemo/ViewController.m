//
//  ViewController.m
//  HttpDemo
//
//  Created by MichaelMao on 2018/9/2.
//  Copyright © 2018年 MichaelMao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ViewController
@synthesize webView;

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self makeGetRequest];
}


#pragma mark -
#pragma mark - NSURLSession

/** get请求 */
- (void)makeGetRequest{

    //1. 创建一个url
    NSString *requestStr = @"http://www.baidu.com";
    NSURL *url = [NSURL URLWithString:requestStr];
    
    //2. 创建一个请求对象
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //3. 创建一个session 默认是get请求
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

@end
