//
//  JLPlayerRequestTask.m
//  VideoPlayer
//
//  Created by emerys on 2017/2/25.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import "JLPlayerRequestTask.h"

@interface JLPlayerRequestTask()<NSURLSessionDataDelegate>

@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDataTask *downloadTask;

@property (nonatomic,copy) NSURL *url;

@end

@implementation JLPlayerRequestTask

- (void)dealloc {
    NSLog(@"request task dealloc");
}


- (void)setURL:(NSURL *)url offset:(unsigned long long)offset {
    
    self.receiveSize = 0;
    self.expectedSize = 0;
    self.offset = offset;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
    
    self.session = session;
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url];
    self.downloadTask = task;
    [task resume];
}

#pragma mark - Task Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didFinishWithError:)]) {
        
        [self.delegate requestTask:self didFinishWithError:error];
        
    }
    
}

#pragma mark - DataTask Delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    
    self.receiveSize += data.length;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didReceiveData:)]) {
        
        [self.delegate requestTask:self didReceiveData:data];
        
    }
    
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    
    NSDictionary *dic = (NSDictionary *)[(NSHTTPURLResponse *)response allHeaderFields];
    NSString *content = [dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    
    NSUInteger videoLength;
    
    if ([length integerValue] == 0) {
        videoLength = (NSUInteger)response.expectedContentLength;
    } else {
        videoLength = [length integerValue];
    }
    
    self.expectedSize = videoLength;

    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didReceiveResponse:)]) {
        
        [self.delegate requestTask:self didReceiveResponse:response];
    }
    
    completionHandler(NSURLSessionResponseAllow);
    
}







@end
