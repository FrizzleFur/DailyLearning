# SDWebImage解析.md

>简介
>Asynchronous image downloader with cache support as a UIImageView category.

言简意赅：SDWebImage 以 UIImageView category（分类）的形式，来支持图片的异步下载与缓存。


```其提供了以下功能：

以 UIImageView 的分类，来支持网络图片的加载与缓存管理
一个异步的图片加载器
一个异步的内存 + 磁盘图片缓存
支持 GIF
支持 WebP
后台图片解压缩处理
确保同一个 URL 的图片不被多次下载
确保虚假的 URL 不会被反复加载
确保下载及缓存时，主线程不被阻塞
使用 GCD 与 ARC
支持 Arm64
```

### 架构：

![SDWebImage(3.8.2) ](http://upload-images.jianshu.io/upload_images/6287298-c307e8ce394cf54c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![SDWebImage步骤](https://github.com/rs/SDWebImage/blob/master/Docs/SDWebImageSequenceDiagram.png?raw=true)

代码的第一句是

```
[self sd_cancelCurrentImageLoad];
```
看方法名就知道它的作用，就是取消这个视图 ImageView 正在加载图片的操作，如果这个 ImageView 正在加载图片，保障在开始新的加载图片任务之前，取消掉正在进行的加载操作。


### 核心方法：
在`UIImageView`分类`UIImageView+UIImageView+WebCache`中，集成了图片下载和缓存的方法：

```
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
```


```
/**
 * 根据 url、placeholder 与 custom options 为 imageview 设置 image
 *
 * 下载是异步的，并且被缓存的
 *
 * @param url            网络图片的 url 地址
 * @param placeholder    用于预显示的图片
 * @param options        一些定制化选项
 * @param progressBlock  下载时的 Block，其定义为：typedef void(^SDWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
 * @param completedBlock 下载完成时的 Block，其定义为：typedef void(^SDWebImageDownloaderCompletedBlock)(UIImage *image, NSData *data, NSError *error, BOOL finished);
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock)
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}
```


在走到`url`存在的时候，就使用`SDWebImageManager`调用`downloadImageWithURL：options:progress:completed:`方法

### 查找缓存

```
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        doneBlock(image, SDImageCacheTypeMemory);
        return nil;
    }

    NSOperation *operation = [NSOperation new];
    dispatch_async(self.ioQueue, ^{
        if (operation.isCancelled) {
            return;
        }

        @autoreleasepool {
            UIImage *diskImage = [self diskImageForKey:key];
            if (diskImage && self.shouldCacheImagesInMemory) {
                NSUInteger cost = SDCacheCostForImage(diskImage);
                [self.memCache setObject:diskImage forKey:key cost:cost];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                doneBlock(diskImage, SDImageCacheTypeDisk);
            });
        }
    });
```

```
    if (url) {
        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url 
         options:options progress:progressBlock completed:^(UIImage *image, 
        NSError *error, SDImageCacheType cacheType, 
        BOOL finished, NSURL *imageURL) {
            ...省略...        
         }
            ...省略...
    }
```

这个方法会先检查一下`url`，然后初始化一个`SDWebImageCombinedOperation`，然后判断这个 URL 在之前的操作中是否已经失败了，如果失败了，并且不进行重试!(options & SDWebImageRetryFailed)，则直接返回错误，最后，从 SDWebImageCache 中开始查找缓存。


```
- (id <SDWebImageOperation>)loadImageWithURL:(nullable NSURL *)url
                                     options:(SDWebImageOptions)options
                                    progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                                   completed:(nullable SDInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    /// 1.如果想预先下载图片，使用[SDWebImagePrefetcher prefetchURLs]取代本方法
    /// 预下载图片是有很多种使用场景的，当我们使用SDWebImagePrefetcher下载图片后，之后使用该图片时就不用再网络上下载了。
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    /// 2.XCode有时候经常会犯一些错误，当用户给url赋值了字符串的时候，XCode也没有报错，因此这里提供一种
    /// 错误修正的处理。
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    /// 3.防止参数的其他错误
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    /// 4.operation会被作为该方法的返回值，但operation的类型是SDWebImageCombinedOperation，是一个封装的对象，并不是一个NSOperation
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;

    /// 5.在图片的下载中，会有一些下载失败的情况，这时候我们把这些下载失败的url放到一个集合中去，
    /// 也就是加入了黑名单中，默认是不会再继续下载黑名单中的url了，但是也有例外，当options被设置为
    /// SDWebImageRetryFailed的时候，会尝试进行重新下载。
    BOOL isFailedUrl = NO;
    if (url) {
        @synchronized (self.failedURLs) {
            isFailedUrl = [self.failedURLs containsObject:url];
        }
    }

    /// 6.会有两种情况让我们停止下载这个url指定的图片：
    /// - url的长度为0
    /// - options并没有选择SDWebImageRetryFailed(重新下载错误url)且这个url在黑名单之中
    /// 调用完成Block，返回operation
    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil] url:url];
        return operation;
    }

    /// 7.排除了所有的错误可能后，我们就先把这个operation添加到正在运行操作的数组中
    /// 这里没有判断self.runningOperations是不是包含了operation，
    /// 说明肯定会在下边的代码中做判断，如果存在就删除operation
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    NSString *key = [self cacheKeyForURL:url];

    /// 8.self.imageCache的queryCacheOperationForKey方法是异步的获取指定key的图片，
    /// 但是这个方法的operation是同步返回的，也就是说下边的代码会直接执行到return那里。
    operation.cacheOperation = [self.imageCache queryCacheOperationForKey:key done:^(UIImage *cachedImage, NSData *cachedData, SDImageCacheType cacheType) {
        /// (8.1).这个Block会在查询完指定的key的图片后调用，由` dispatch_async(self.ioQueue, ^{`
        /// 这个可以看出，实在异步线程采用串行的方式在调用，任务在self.imageCache的ioQueue中一个一个执行，是线程安全的

        /// (8.2).如果每次调用loadImage方法都会生成一个operation，如果我们想取消某个下载任务
        /// 再设计上来说，只要把响应的operation.isCancelled设置为NO，那么下载就会被取消。
        if (operation.isCancelled) {
            [self safelyRemoveOperationFromRunning:operation];
            return;
        }

        /// (8.3).代码来到这里，我们就要根据是否有缓存的图片来做出响应的处理
        /// 如果没有获取到缓存图片或者需要刷新缓存图片我们应该通过网络获取图片，但是这里增加了一个额外的控制
        /// 根据delegate的imageManager:shouldDownloadImageForURL:获取是否下载的权限，返回YES，就继续下载
        if ((!cachedImage || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
            /// (8.3.1).这里需要注意了，当图片已经下载了，Options又选择了SDWebImageRefreshCached
            /// 就会触发一次completionBlock回调，这说明这个下载的回调不是只触发一次的
            /// 如果使用了dispatch_group_enter和dispatch_group_leave就一定要注意了
            if (cachedImage && options & SDWebImageRefreshCached) {
                // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
                // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                [self callCompletionBlockForOperation:weakOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            }

            // download if no image or requested to refresh anyway, and download allowed by delegate
            /// (8.3.2).这里是SDWebImageOptions到SDWebImageDownloaderOptions的转换
            /// 其实就是0 |= xxx
            SDWebImageDownloaderOptions downloaderOptions = 0;
            if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
            if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
            if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
            if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
            if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
            if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
            if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
            if (options & SDWebImageScaleDownLargeImages) downloaderOptions |= SDWebImageDownloaderScaleDownLargeImages;

            /// (8.3.3).已经缓存且SDWebImageRefreshCached的比较特殊
            if (cachedImage && options & SDWebImageRefreshCached) {
                // force progressive off if image already cached but forced refreshing
                /// (8.3.3.1).SDWebImageDownloaderProgressiveDownload为 1<<1 ,
                /*
                    由于当options == SDWebImageRefreshCached时，downloaderOptions |= SDWebImageDownloaderUseNSURLCache（1 << 2）
                    00000000 | 00000100 =>  00000100
                    ~SDWebImageDownloaderProgressiveDownload : ~ 00000010 => 111111101
                    00000100 & 11111101 => 00000100
                 */
                downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                // ignore image read from NSURLCache if image if cached but force refreshing
                /// (8.3.3.2). 00000100 | 00001000 => 00001100
                /// 通过这种位的运算，就能够给同一个值赋值两种转态
                downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
            }

            /// (8.3.4).下载图片
            SDWebImageDownloadToken *subOperationToken = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                if (!strongOperation || strongOperation.isCancelled) {
                    // Do nothing if the operation was cancelled
                    // See #699 for more details
                    // if we would call the completedBlock, there could be a race condition between this block and another completedBlock for the same object, so if this one is called second, we will overwrite the new data
                } else if (error) {
                    /// (8.3.4.1).发生错误就返回
                    [self callCompletionBlockForOperation:strongOperation completion:completedBlock error:error url:url];

                    /// (8.3.4.2).除了下边这几种情况之外的情况则把url加入黑名单
                    if (   error.code != NSURLErrorNotConnectedToInternet
                        && error.code != NSURLErrorCancelled
                        && error.code != NSURLErrorTimedOut
                        && error.code != NSURLErrorInternationalRoamingOff
                        && error.code != NSURLErrorDataNotAllowed
                        && error.code != NSURLErrorCannotFindHost
                        && error.code != NSURLErrorCannotConnectToHost) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs addObject:url];
                        }
                    }
                }
                else {

                    /// (8.3.4.3).如果是SDWebImageRetryFailed就在黑名单中移除，不管有没有
                    if ((options & SDWebImageRetryFailed)) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs removeObject:url];
                        }
                    }

                    BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);

                    if (options & SDWebImageRefreshCached && cachedImage && !downloadedImage) {
                        // Image refresh hit the NSURLCache cache, do not call the completion block
                    } else if (downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) { // 要不要修改图片，这个修改图片完全由代理来操作
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];

                            if (transformedImage && finished) {
                                BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                // pass nil if the image was transformed, so we can recalculate the data from the image
                                [self.imageCache storeImage:transformedImage imageData:(imageWasTransformed ? nil : downloadedData) forKey:key toDisk:cacheOnDisk completion:nil];
                            }

                            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:transformedImage data:downloadedData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
                        });
                    } else {
                        if (downloadedImage && finished) {
                            [self.imageCache storeImage:downloadedImage imageData:downloadedData forKey:key toDisk:cacheOnDisk completion:nil];
                        }
                        [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:downloadedImage data:downloadedData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
                    }
                }

                /// (8.3.4.4).完成了就把该任务在正运行着的数组中删除
                if (finished) {
                    [self safelyRemoveOperationFromRunning:strongOperation];
                }
            }];

            /// (8.3.5).设置取消的回调
            operation.cancelBlock = ^{
                [self.imageDownloader cancel:subOperationToken];
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                [self safelyRemoveOperationFromRunning:strongOperation];
            };
        } else if (cachedImage) {
            __strong __typeof(weakOperation) strongOperation = weakOperation;
            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            [self safelyRemoveOperationFromRunning:operation];
        } else {
            // Image not in cache and download disallowed by delegate
            /// (8.4).既没有缓存也下载了代理不允许的图片
            __strong __typeof(weakOperation) strongOperation = weakOperation;
            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:nil data:nil error:nil cacheType:SDImageCacheTypeNone finished:YES url:url];
            [self safelyRemoveOperationFromRunning:operation];
        }
    }];

    return operation;
}
```


整体的关键步骤是这样的：

一、 UIImageView 通过 SDWebImage 请求一个 URL 获取图片

二、 SDWebImage 根据这个 URL 先去 内存中寻找，如果找不到去硬盘中寻找（这里忽略一些 ignore cache 的 case）

三、 如果第二步再找不到，SDWebImage 会先检查之前是否有这个 URL 正在下载，之后创建一个 NSMutableURLRequest: request

四、 将第三步的 request 封装成一个 SDWebImageDownloaderOperation(subclass of NSOperation) operation

五、 将第四步的 operation 根据 option 的配置，加入到队列中（提供先进先出以及先进后出两种）

六、 operation 线程开始，开启 第三步 NSMutableURLRequest 的 request 配置的 NSURLSessionDataTask

七、 第一个 NSURLSessionDataTaskDelegate 接收 response， 此时，配置好 expectedSize, 如果 responseCode 在 400 以下（除 304，304 是缓存 code），则开始接收 data；如果是 304，则不更新本地缓存，否则按照错误处理。

八、 接收返回 data， 如果有 progressBlock 则根据 data 的百分比调用 progressBlock， 并且把每次接受的 data 加入到 NSMutableData *imageData 里面

九、 接受完成后，判断是否有错误，如果有错误，返回错误；如果没有，则根据第八步的 NSMutableData *imageData 去组装成一个 UIImage, 根据是否组装成功，以及组装出来的 UIImage 是否 size 出现了 0，然后返回

十、 如果图片正常返回，开启内存缓存和磁盘缓存（这里都是可以根据 option 配置的）

十一、 使用 NSCache 缓存，更具图片的 width、height 以及 scale 计算 NSCache 的 cost

十二、 根据 URL 的 MD5 值作为 key，在 ioQueue 线程中， 把图片写入到 NSSearchPathForDirectoriesInDomains 中

十三、 回主线程设置 UIImageView


#### SDWebImageOptions

```
SDWebImageOptions

SDWebImageOptions作为下载的选项提供了非常多的子项，用法和注意事项我都写在代码的注释中了：

typedef NS_OPTIONS(NSUInteger, SDWebImageOptions) {
    /**
     * By default, when a URL fail to be downloaded, the URL is blacklisted so the library won't keep trying.
     * This flag disable this blacklisting.
     */
    /// 每一个下载都会提供一个URL，如果这个URL是错误，SD就会把它放入到黑名单之中，
    /// 黑名单中的URL是不会再次进行下载的,但是，当设置了该选项时，SD会将其在黑名单中移除，重新下载该URL，
    SDWebImageRetryFailed = 1 << 0,

    /**
     * By default, image downloads are started during UI interactions, this flags disable this feature,
     * leading to delayed download on UIScrollView deceleration for instance.
     */
    /// 一般来说，下载都是按照一定的先后顺序开始的，但是该选项能够延迟下载，也就说他的权限比较低，权限比他高的在他前边下载
    SDWebImageLowPriority = 1 << 1,

    /**
     * This flag disables on-disk caching
     */
    /// 该选项要求SD只把图片缓存到内存中，不缓存到disk中
    SDWebImageCacheMemoryOnly = 1 << 2,

    /**
     * This flag enables progressive download, the image is displayed progressively during download as a browser would do.
     * By default, the image is only displayed once completely downloaded.
     */
    /// 给下载添加进度
    SDWebImageProgressiveDownload = 1 << 3,

    /**
     * Even if the image is cached, respect the HTTP response cache control, and refresh the image from remote location if needed.
     * The disk caching will be handled by NSURLCache instead of SDWebImage leading to slight performance degradation.
     * This option helps deal with images changing behind the same request URL, e.g. Facebook graph api profile pics.
     * If a cached image is refreshed, the completion block is called once with the cached image and again with the final image.
     *
     * Use this flag only if you can't make your URLs static with embedded cache busting parameter.
     */
    /// 有这么一种使用场景，如果一个图片的资源发生了改变。但是url并没有变，我们就可以使用该选项来刷新数据了
    SDWebImageRefreshCached = 1 << 4,

    /**
     * In iOS 4+, continue the download of the image if the app goes to background. This is achieved by asking the system for
     * extra time in background to let the request finish. If the background task expires the operation will be cancelled.
     */
    /// 支持切换到后台也能下载
    SDWebImageContinueInBackground = 1 << 5,

    /**
     * Handles cookies stored in NSHTTPCookieStore by setting
     * NSMutableURLRequest.HTTPShouldHandleCookies = YES;
     */
    /// 使用Cookies
    SDWebImageHandleCookies = 1 << 6,

    /**
     * Enable to allow untrusted SSL certificates.
     * Useful for testing purposes. Use with caution in production.
     */
    /// 允许验证证书
    SDWebImageAllowInvalidSSLCertificates = 1 << 7,

    /**
     * By default, images are loaded in the order in which they were queued. This flag moves them to
     * the front of the queue.
     */
    /// 高权限
    SDWebImageHighPriority = 1 << 8,

    /**
     * By default, placeholder images are loaded while the image is loading. This flag will delay the loading
     * of the placeholder image until after the image has finished loading.
     */
    /// 一般情况下，placeholder image 都会在图片下载完成前显示，该选项将设置placeholder image在下载完成之后才能显示
    SDWebImageDelayPlaceholder = 1 << 9,

    /**
     * We usually don't call transformDownloadedImage delegate method on animated images,
     * as most transformation code would mangle it.
     * Use this flag to transform them anyway.
     */
    /// 使用该属性来自由改变图片，但需要使用transformDownloadedImage delegate
    SDWebImageTransformAnimatedImage = 1 << 10,

    /**
     * By default, image is added to the imageView after download. But in some cases, we want to
     * have the hand before setting the image (apply a filter or add it with cross-fade animation for instance)
     * Use this flag if you want to manually set the image in the completion when success
     */
    /// 该选项允许我们在图片下载完成后不会立刻给view设置图片，比较常用的使用场景是给赋值的图片添加动画
    SDWebImageAvoidAutoSetImage = 1 << 11,

    /**
     * By default, images are decoded respecting their original size. On iOS, this flag will scale down the
     * images to a size compatible with the constrained memory of devices.
     * If `SDWebImageProgressiveDownload` flag is set the scale down is deactivated.
     */
    /// 压缩大图片
    SDWebImageScaleDownLargeImages = 1 << 12
};
Block

```

### UIView (WebCacheOperation）


```
- (NSMutableDictionary *)operationDictionary {
    NSMutableDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)sd_setImageLoadOperation:(id)operation forKey:(NSString *)key {
    [self sd_cancelImageLoadOperationWithKey:key];
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary setObject:operation forKey:key];
}
- (void)sd_cancelImageLoadOperationWithKey:(NSString *)key {
    // Cancel in progress downloader from queue
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    id operations = [operationDictionary objectForKey:key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id <SDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(SDWebImageOperation)]){
            [(id<SDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}
```
代码中，通过 `objc_setAssociatedObject` 关联对象的方法，给 `UIImageView` 动态添加了一个 `NSMutableDictionary` 的属性。通过 `key-value` 维护这个 `ImageView` 已经有了哪些下载操作，如果是数组就是 `UIImageViewAnimationImages` 否则就是 `UIImageViewImageLoad` 。最后获得的都是遵从了 `<SDWebImageOperation>` 协议的对象，可以统一调用定义好的方法 `cancel`，达到取消下载操作的目的，如果 `operation` 都被取消了，则删除对应 `key` 的值。


### 参考

1. [SDWebImage 源码解析](https://juejin.im/post/5a4080d16fb9a0451969d0aa)
2. [SDWebImage(3.8.2) 源码解读](http://www.jianshu.com/p/b8a3f7cf1659)
3. [SDWebImage，Github](https://github.com/rs/SDWebImage)
4. [SDWebImage源码解读之SDWebImageManager](http://www.jianshu.com/p/a2cc208ee016)

