//
//  JLVideoPlayerManager.h
//  VideoPlayer
//
//  Created by emerys on 2017/2/22.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class JLVideoPlayerManager;

@protocol JLVideoPlayerDelegate <NSObject>

@optional

- (void)jl_videoPlayerManagerDidEndPlay:(JLVideoPlayerManager *)manager;

- (void)jl_videoPlayBackStalled:(JLVideoPlayerManager *)manager;

- (void)jl_videoPlayerManager:(JLVideoPlayerManager *)manager cacheProgress:(double)cacheProgress;

- (void)jl_videoPlayerManager:(JLVideoPlayerManager *)manager playBackProgress:(double)playBackProgress;

- (void)jl_videoReadyToPlay:(JLVideoPlayerManager *)manager;

- (void)jl_videoPlayFailed:(JLVideoPlayerManager *)manager;

@end

@interface JLVideoPlayerManager : NSObject

@property (nonatomic,copy) NSString *url; ///<设置URL自动播放

@property (nonatomic,weak) id<JLVideoPlayerDelegate> delegate;

@property (nonatomic,strong,readonly) AVPlayerLayer *playerLayer;

@property (nonatomic,strong,readonly) AVPlayer *player;

@property (nonatomic,assign) NSTimeInterval seekTime;

@property (nonatomic,assign,readonly) NSTimeInterval playedTime;

@property (nonatomic,assign,readonly) NSTimeInterval videoDuration;

@property (nonatomic,copy) NSString *cacheFolder;
@property (nonatomic,assign) BOOL dowload;

// use MPVolumeView(not availible)
//@property (nonatomic,assign) float volume;

@property (nonatomic,assign) BOOL muted;

@property (nonatomic,copy) NSString *timeFormate;///< Default is HH:mm:ss

- (void)play;

- (void)pause;

- (NSString *)formatedDuration;

- (NSString *)formatedPlayedTime;

@end
