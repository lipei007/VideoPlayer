//
//  JLPLayerPorxyServer.h
//  VideoPlayer
//
//  Created by emerys on 2017/2/25.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*
 *@brief 遵守AVAssetResourceLoaderDelegate协议，处理来自播放器的数据请求，并将已经请求到的数据实时传给播放器。
 */
@interface JLPLayerProxyServer : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic,copy) NSString *cacheFolder;
@property (nonatomic,assign) BOOL download;

- (NSURL *)replaceSystemSchemeOfURL:(NSString *)url;

@end
