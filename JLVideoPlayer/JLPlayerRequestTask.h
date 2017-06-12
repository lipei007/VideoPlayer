//
//  JLPlayerRequestTask.h
//  VideoPlayer
//
//  Created by emerys on 2017/2/25.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import <Foundation/Foundation.h>


@class JLPlayerRequestTask;
@protocol JLPLayerRequestTaskDelegate <NSObject>

@optional

- (void)requestTask:(JLPlayerRequestTask *)requestTask didFinishWithError:(NSError *)error;

- (void)requestTask:(JLPlayerRequestTask *)requestTask didReceiveResponse:(NSURLResponse *)response;

- (void)requestTask:(JLPlayerRequestTask *)requestTask didReceiveData:(NSData *)data;


@end

/*
 * @brief 完成数据请求，并实时将已经请求到的数据写入缓存并通知给JLPlayerProxyServer
 */
@interface JLPlayerRequestTask : NSObject

@property (nonatomic,assign) unsigned long long receiveSize;
@property (nonatomic,assign) unsigned long long offset;
@property (nonatomic,assign) unsigned long long expectedSize;


@property (nonatomic,weak) id<JLPLayerRequestTaskDelegate> delegate;

- (void)setURL:(NSURL *)url offset:(unsigned long long)offset;

@end
