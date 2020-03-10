//
//  JLPLayerPorxyServer.m
//  VideoPlayer
//
//  Created by emerys on 2017/2/25.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import "JLPLayerProxyServer.h"
#import "JLPlayerRequestTask.h"

#import <MobileCoreServices/MobileCoreServices.h>


@interface JLPLayerProxyServer ()<JLPLayerRequestTaskDelegate>

@property (nonatomic,strong) JLPlayerRequestTask *requesTask;

@property (nonatomic,strong) NSMutableArray<AVAssetResourceLoadingRequest *> *loadingRequests;

#pragma mark - Data

@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,copy) NSString *mimeType;
@property (nonatomic,assign) unsigned long long expectedSize;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,strong) NSURL *url;

@end


@implementation JLPLayerProxyServer

#pragma mark - life

- (void)dealloc {
    NSLog(@"server dealloc");
}


#pragma mark - Interface

- (NSURL *)replaceSystemSchemeOfURL:(NSString *)url {
    
    return [self replaceURL:url scheme:@"jlScheme" recover:NO];
}

#pragma mark - Getter

- (NSMutableArray<AVAssetResourceLoadingRequest *> *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}

- (NSMutableData *)data {
    if (!_data) {
        _data = [NSMutableData data];
    }
    return _data;
}

#pragma mark - Private

- (NSURL *)replaceURL:(NSString *)url scheme:(NSString *)scheme recover:(BOOL)recover {
    
    /*
     NSURLComponents用来替代NSMutableURL，可以readwrite修改URL
     AVAssetResourceLoader通过你提供的委托对象去调节AVURLAsset所需要的加载资源。
     而很重要的一点是，AVAssetResourceLoader仅在AVURLAsset不知道如何去加载这个URL资源时才会被调用
     就是说你提供的委托对象在AVURLAsset不知道如何加载资源时才会得到调用。
     所以我们又要通过一些方法来曲线解决这个问题，把我们目标视频URL地址的scheme替换为系统不能识别的scheme
     */
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:url] resolvingAgainstBaseURL:NO];
    
    // scheme就是://前面的协议，比如http，https
    if (!recover) {
        // 将原scheme写进新scheme中，以便后面恢复
        components.scheme = [NSString stringWithFormat:@"%@RECOVER%@",components.scheme,scheme];
    } else {
        NSArray *schemes = [components.scheme componentsSeparatedByString:@"RECOVER"];
        components.scheme = [schemes objectAtIndex:0];
    }
    
    return [components URL];
    
}


- (BOOL)respondsRequest:(AVAssetResourceLoadingRequest *)request {
    AVAssetResourceLoadingDataRequest *dataRequest = request.dataRequest;
    NSUInteger offset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        offset = dataRequest.currentOffset;
    }
    offset = MAX(0, offset);
    if (self.requesTask.receiveSize < offset) {
        return NO;
    }
    
    NSUInteger unreadByte = self.requesTask.receiveSize - offset;
    unreadByte = MAX(0, unreadByte);
    NSUInteger responseLen = MIN(unreadByte, dataRequest.requestedLength);
    if (self.data.length >= responseLen) {
        [dataRequest respondWithData:[self.data subdataWithRange:NSMakeRange(offset, responseLen)]];
    }
    long long endOffset = offset + dataRequest.requestedLength;
    if (self.requesTask.receiveSize >= endOffset) {
        return YES;
    }
    
    return NO;
}

- (void)fillContentInfomationRequest:(AVAssetResourceLoadingContentInformationRequest *)contentInfomationRequest {
    if (contentInfomationRequest) {
        const NSString *mimeType = self.mimeType;
        CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)mimeType, NULL);
        contentInfomationRequest.byteRangeAccessSupported = YES;
        contentInfomationRequest.contentType = CFBridgingRelease(contentType);
        contentInfomationRequest.contentLength = self.expectedSize;
        
    }
}

- (void)processRequests {
    
    // 资源竞争
    @synchronized (self) { //解决_NSArrayM: 0xb550c30> was mutated while being enumerated
        NSMutableArray <AVAssetResourceLoadingRequest *> *finishRequests = [NSMutableArray array];
        
        for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
            [self fillContentInfomationRequest:loadingRequest.contentInformationRequest];
            BOOL finish = [self respondsRequest:loadingRequest];
            if (finish) {
                [loadingRequest finishLoading];
                [finishRequests addObject:loadingRequest];
            }
        }
        
        if (finishRequests.count) {
            NSLog(@"finish %@",finishRequests);
            [self.loadingRequests removeObjectsInArray:finishRequests];
        }
    }
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"=====request: %lu   %lu",loadingRequest.dataRequest.requestedOffset,loadingRequest.dataRequest.requestedLength);
    // 判断是否支持请求链接，若支持，则返回YES，并开始下载视频，边下载，边传给Player显示播放。
    if (!self.requesTask) {
        NSString *urlStr = loadingRequest.request.URL.absoluteString;
        NSURL *URL = [self replaceURL:urlStr scheme:@"jlScheme" recover:YES];
        JLPlayerRequestTask *task = [[JLPlayerRequestTask alloc] init];
        self.requesTask = task;
        task.delegate = self;
        [task setURL:URL offset:0];
    }
    
    if (resourceLoader && loadingRequest) {
        [self.loadingRequests addObject:loadingRequest];
        [self processRequests];
    }

    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    [self.loadingRequests removeObject:loadingRequest];
    
}


#pragma mark - Request Task Delegate

- (void)requestTask:(JLPlayerRequestTask *)requestTask didReceiveFile:(NSString *)filename size:(unsigned long long)size mimeType:(NSString *)type {

    self.expectedSize = size;
    self.mimeType = type;
    if (filename) {
        self.fileName = filename;
    } else {
        self.fileName = [NSUUID UUID].UUIDString;
    }
}

- (void)requestTask:(JLPlayerRequestTask *)requestTask didReceiveData:(NSData *)data {

    [self.data appendData:data];
    [self processRequests];
}

- (void)requestTask:(JLPlayerRequestTask *)requestTask didFinishWithError:(NSError *)error {
    
    [self processRequests];
    
    if (self.download) {
        if (!error && requestTask.offset == 0) {
            NSString *path = nil;
            if (self.cacheFolder.length) {
                path = self.cacheFolder;
            } else {
                NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
                path = [cachePath stringByAppendingPathComponent:@"downloadVideo"];
            }
            path = [path stringByAppendingPathComponent:self.fileName];
            [self.data writeToFile:path atomically:NO];
            
        }
    }
}

@end
