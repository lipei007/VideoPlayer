//
//  JLVideoPlayerManager.m
//  VideoPlayer
//
//  Created by emerys on 2017/2/22.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import "JLVideoPlayerManager.h"
#import "JLPLayerProxyServer.h"

@interface JLVideoPlayerManager ()

#pragma mark - player
@property (nonatomic,strong) JLPLayerProxyServer *proxyServer;
@property (nonatomic,strong) AVURLAsset *asset;
@property (nonatomic,strong) AVPlayerItem *item;
@property (nonatomic,strong) id timeObserver;///<播放进度观察者

#pragma mark - status
@property (nonatomic,assign) BOOL endPlay;

@end

@implementation JLVideoPlayerManager
@synthesize player = _player;
@synthesize playerLayer = _playerLayer;
@synthesize playedTime = _playedTime;
@synthesize videoDuration = _videoDuration;


- (instancetype)init {
    if (self = [super init]) {
        [self addItemNotification];
    }
    return self;
}

#pragma mark - Notification

- (void)addItemNotification {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(itemTimeJumped:) name:AVPlayerItemTimeJumpedNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(itemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(itemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(itemNewAccessLogEntry:) name:AVPlayerItemNewAccessLogEntryNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(itemNewErrorLogEntry:) name:AVPlayerItemNewErrorLogEntryNotification object:nil];
    
    
}

#pragma mark - Notification Action

- (void)itemTimeJumped:(NSNotification *)notification { // seekTime，play，pause
    
    NSLog(@"item jumped %@",notification);
}

- (void)itemDidPlayToEndTime:(NSNotification *)notification { // 结束播放

    [self pause];
    self.endPlay = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_videoPlayerManagerDidEndPlay:)]) {
        [self.delegate jl_videoPlayerManagerDidEndPlay:self];
    }
    
    
}

- (void)itemFailedToPlayToEndTime:(NSNotification *)notification {
    NSLog(@"failed play -- %@",notification);
    [self pause];
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_videoPlayFailed:)]) {
        [self.delegate jl_videoPlayFailed:self];
    }
}

- (void)itemPlaybackStalled:(NSNotification *)notification { // 播放完已经加载的部分，剩下未加载
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_videoPlayBackStalled:)]) {
        [self.delegate jl_videoPlayBackStalled:self];
    }
}

- (void)itemNewAccessLogEntry:(NSNotification *)notification { // 所有player、item操作均记录
    NSLog(@"new access log %@",notification);
}

- (void)itemNewErrorLogEntry:(NSNotification *)notification {
    NSLog(@"new error log %@",notification);
}

#pragma mark - Init

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer layer];
        
    }
    return _playerLayer;
}

#pragma mark - Private

- (NSString *)formatedTimeInterval:(NSTimeInterval)timeInterval {
    
//    NSUInteger munite = (NSUInteger)timeInterval / 60;
//    NSUInteger second = (NSUInteger)timeInterval % 60;
//    
//    NSString *formated = [NSString stringWithFormat:@"%lu:%02lu",munite,second];
    if (!self.timeFormate) {
        self.timeFormate = @"HH:mm:ss";
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval - 8 * 60 * 60];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = self.timeFormate;
    NSString *formatedTime = [formatter stringFromDate:date];
    
    return formatedTime;
}

- (void)itemAddObserver {
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil]; // 状态
    [_item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil]; // 缓冲
}

- (void)itemRemoveObserver {
    [_item removeObserver:self forKeyPath:@"status"];
    [_item removeObserver:self forKeyPath:@"loadedTimeRanges"];
}


#pragma mark - Interface

- (void)play {
    if (self.endPlay) {
        [self setSeekTime:0];
        self.endPlay = NO;
    } else if (self.player.status == AVPlayerStatusReadyToPlay){
        [self.player play];
        self.endPlay = NO;
    }
}

- (void)pause {
    if (!self.endPlay && self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self.player pause];
    }
}

- (NSString *)formatedDuration {
    return [self formatedTimeInterval:_videoDuration];
}

- (NSString *)formatedPlayedTime {
    return [self formatedTimeInterval:_playedTime];
}

#pragma mark - Setter

- (void)setUrl:(NSString *)url {
    
    _url = url;
    
    if (_item) {
        [self itemRemoveObserver];
    }
    
    

    if (false) {
        // 系统
        NSURL *URL = nil;
        
        if (true) {
            URL = [NSURL URLWithString:_url]; // 网络
        } else {
            URL = [NSURL fileURLWithPath:_url]; // 本地
        }
        
        _item = [AVPlayerItem playerItemWithURL:URL];
        
    } else {
        JLPLayerProxyServer *server = [[JLPLayerProxyServer alloc] init];
        server.cacheFolder = self.cacheFolder;
        AVURLAsset *asset = [AVURLAsset assetWithURL:[server replaceSystemSchemeOfURL:_url]];
        [asset.resourceLoader setDelegate:server queue:dispatch_get_main_queue()];
        _item = [AVPlayerItem playerItemWithAsset:asset];
        
        self.proxyServer = server;
        self.asset = asset;
        
        
    }
    
    // 监听Item属性需要在Item与Player关联之前
    [self itemAddObserver];

    self.endPlay = NO;
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:_item];
        self.playerLayer.player = _player;
    } else {
        [_player replaceCurrentItemWithPlayerItem:_item];
    }

    
    __weak typeof(self) weakself = self;
    // 1.0 / 30.0秒调用一次Block更新播放进度
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float playedTime = CMTimeGetSeconds(time);
        
        double playedPorgress = playedTime / CMTimeGetSeconds(_item.duration);
        
        _playedTime = playedTime;
        
        if (weakself && weakself.delegate && [weakself.delegate respondsToSelector:@selector(jl_videoPlayerManager:playBackProgress:)]) {
            __strong typeof(weakself) strongself = weakself;
            [strongself.delegate jl_videoPlayerManager:strongself playBackProgress:playedPorgress];
        }
        
    }];
        
    [_player play];
    
}


- (void)setSeekTime:(NSTimeInterval)seekTime {
    
    CGFloat duration = CMTimeGetSeconds(_item.duration);
    
    if (duration <= 0) {
        return;
    }
    
    if (seekTime > duration) {
        _seekTime = duration;
    } else {
        _seekTime = seekTime;
    }
    
    
    __weak typeof(self) weakself = self;
    
    [self.player pause];
    
    CMTime time = CMTimeMakeWithSeconds(_seekTime, _item.duration.timescale);
    
    [self.item seekToTime:time completionHandler:^(BOOL finished) {
        
        if (weakself) {
            __strong typeof(weakself) strongself = weakself;
            [strongself.player play];
        }
        
    }];

    
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (void)setDowload:(BOOL)dowload {
    _dowload = dowload;
    self.proxyServer.dowload = dowload;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 新状态
        
        switch (status) {
            case AVPlayerItemStatusUnknown: {
//                NSLog(@"status unknown");
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                
                _videoDuration = CMTimeGetSeconds(_item.duration);
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(jl_videoReadyToPlay:)]) {
                    [self.delegate jl_videoReadyToPlay:self];
                }
                
            }
                break;
            case AVPlayerItemStatusFailed: { // 初始化加载Video失败
                if (self.delegate && [self.delegate respondsToSelector:@selector(jl_videoPlayFailed:)]) {
                    [self pause];
                    [self.delegate jl_videoPlayFailed:self];
                }
            }
                break;
                
            default:
                break;
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        CMTimeRange timeRange = [_item.loadedTimeRanges.firstObject CMTimeRangeValue];
        float start = CMTimeGetSeconds(timeRange.start);
        float duration = CMTimeGetSeconds(timeRange.duration);
        // 也可以做成一节一节的,表示那一段缓冲完成。。。
        
        float loadedTime = start + duration;
        
        float progress = loadedTime / CMTimeGetSeconds(_item.duration);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(jl_videoPlayerManager:cacheProgress:)]) {
            [self.delegate jl_videoPlayerManager:self cacheProgress:progress];
        }
    }
    
    
}

#pragma mark - Dealloc



- (void)dealloc {
    
    [_player removeTimeObserver:_timeObserver];
    
    [self itemRemoveObserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





@end
