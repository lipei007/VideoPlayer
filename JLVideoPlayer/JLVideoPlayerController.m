//
//  JLVideoPlayerController.m
//  VideoPlayer
//
//  Created by emerys on 2017/2/20.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import "JLVideoPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "JLCacheSlider.h"
#import "JLVideoPlayerManager.h"

#define TestURL @"http://baobab.cdn.wandoujia.com/1449121380062b.mp4"

@interface JLVideoPlayerController ()<JLVideoPlayerDelegate>

@property (nonatomic,strong) JLVideoPlayerManager *manager;


#pragma mark - control
@property (nonatomic,strong) UIView *controlView;
@property (nonatomic,strong) UIButton *controlBtn;///<控制暂停／播放
@property (nonatomic,strong) UIButton *fullScreenBtn;///<全屏按钮
@property (nonatomic,strong) JLCacheSlider *progressView;///<进度
@property (nonatomic,strong) UISlider *vioceView;///<音量
@property (nonatomic,strong) UILabel *titleLabel;///<标题
@property (nonatomic,strong) UILabel *playedTimeLabel;
@property (nonatomic,strong) UILabel *durationLabel;

@end

@implementation JLVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setNeedsLayout];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.manager.url = @"http://baobab.kaiyanapp.com/api/v1/playUrl?vid=27378&editionType=normal&source=qcloud";

}



- (JLVideoPlayerManager *)manager {
    if (!_manager) {
        _manager = [[JLVideoPlayerManager alloc] init];
        _manager.delegate = self;
        _manager.download = YES;
        _manager.cacheFolder = @"/Users/jacklee/Downloads";
    }
    return _manager;
}

#pragma mark - View

- (JLCacheSlider *)progressView {
    if (!_progressView) {
        _progressView = [[JLCacheSlider alloc] init];
        _progressView.cacheValue = 0;
        _progressView.progress = 0;
        [_progressView addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressView;
}

- (UIButton *)controlBtn {
    if (!_controlBtn) {
        _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_controlBtn setTitle:@"play" forState:UIControlStateNormal];
        [_controlBtn setTitle:@"pause" forState:UIControlStateSelected];
        [_controlBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _controlBtn;
}

- (UILabel *)playedTimeLabel {
    if (!_playedTimeLabel) {
        _playedTimeLabel = [[UILabel alloc] init];
        _playedTimeLabel.textColor = [UIColor whiteColor];
        _playedTimeLabel.font = [UIFont systemFontOfSize:14.0];
        _playedTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _playedTimeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = [UIFont systemFontOfSize:14.0];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _durationLabel;
}

- (UIView *)controlView {
    if (!_controlView) {
        _controlView = [[UIView alloc] init];
        _controlView.backgroundColor = [UIColor clearColor];
        
    }
    return _controlView;
}

- (void)configPlayerView {
    
    
    
    self.manager.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.manager.playerLayer];
    
    CGRect visiRect = self.view.bounds; // self.playerLayer.videoRect
    self.controlView.frame = visiRect;
    [self.view addSubview:_controlView];
    
    CGRect frame = self.controlView.frame;
    
    self.controlBtn.frame = CGRectMake(0, 0, 80, 50);
    self.controlBtn.center = self.controlView.center;
    [self.controlView addSubview:self.controlBtn];
    
    self.playedTimeLabel.frame = CGRectMake(10, CGRectGetHeight(frame) - 25, 70, 20);
    [self.controlView addSubview:self.playedTimeLabel];
    self.durationLabel.frame = CGRectMake(CGRectGetWidth(frame) - 80, CGRectGetHeight(frame) - 25, 70, 20);
    [self.controlView addSubview:self.durationLabel];
    
    CGFloat minX = CGRectGetMaxX(self.playedTimeLabel.frame) + 10;
    CGFloat maxX = CGRectGetMinX(self.durationLabel.frame) - 10;
    self.progressView.frame = CGRectMake(minX, CGRectGetHeight(frame) - 20, maxX - minX, 10);
    [self.controlView addSubview:self.progressView];
}

- (void)viewWillLayoutSubviews {
    
    [self configPlayerView];
    
}

#pragma mark - Target Action

- (void)changeProgress:(id)sender {
    
    self.manager.seekTime = self.progressView.progress * self.manager.videoDuration;
    
}

- (void)playOrPause:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.manager play];
    } else {
        [self.manager pause];
    }
    
}


#pragma mark - delegate 

- (void)jl_videoPlayerManagerDidEndPlay:(JLVideoPlayerManager *)manager {
    NSLog(@"end play");
}

- (void)jl_videoPlayBackStalled:(JLVideoPlayerManager *)manager {
    NSLog(@"stalled");
}

- (void)jl_videoPlayerManager:(JLVideoPlayerManager *)manager cacheProgress:(double)cacheProgress {
    self.progressView.cacheValue = cacheProgress;
}

- (void)jl_videoPlayerManager:(JLVideoPlayerManager *)manager playBackProgress:(double)playBackProgress {
    self.progressView.progress = playBackProgress;
    self.playedTimeLabel.text = [manager formatedPlayedTime];
}

- (void)jl_videoReadyToPlay:(JLVideoPlayerManager *)manager {
    
//    [manager play];
    self.controlBtn.selected = YES;;
    self.durationLabel.text = [manager formatedDuration];
}

- (void)jl_videoPlayFailed:(JLVideoPlayerManager *)manager {
    NSLog(@"play failed");
}

@end
