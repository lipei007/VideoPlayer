//
//  JLCacheSlider.m
//  VideoPlayer
//
//  Created by emerys on 2017/2/21.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import "JLCacheSlider.h"


@interface JLCacheSlider ()

@property (nonatomic,strong) UIProgressView *cacheProgress;

@end

@implementation JLCacheSlider
@synthesize cacheProgressTintColor = _cacheProgressTintColor;
@synthesize trackTintColor = _trackTintColor;
@synthesize progressTintColor = _progressTintColor;
@synthesize progress = _progress;



#pragma mark - Setter

- (void)configView {
    CGRect frame = self.bounds;
    self.cacheProgressTintColor = [UIColor darkGrayColor];
    self.trackTintColor = [UIColor lightGrayColor];
    self.progressTintColor = [UIColor blueColor];
    
    [self addSubview:self.cacheProgress];
    [self sendSubviewToBack:self.cacheProgress];
    
    self.cacheProgress.frame = self.bounds;
    self.cacheProgress.center = CGPointMake(CGRectGetWidth(frame) * 0.5, CGRectGetHeight(frame) * 0.5);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self configView];
    
}

- (void)setCacheProgressTintColor:(UIColor *)cacheProgressTintColor {
    _cacheProgressTintColor = cacheProgressTintColor;
    self.cacheProgress.progressTintColor = _cacheProgressTintColor;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    self.cacheProgress.trackTintColor = _trackTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    
    self.backgroundColor = [UIColor clearColor];
    self.minimumTrackTintColor = _progressTintColor;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setCacheValue:(double)cacheValue {
    _cacheValue = cacheValue;
    self.cacheProgress.progress = _cacheValue;
}

- (void)setProgress:(double)progress {
    _progress = progress;
    self.value = _progress;
}

- (float)value {
    
    _progress = [super value];
    
    return _progress;
}

- (double)progress {
    
    return self.value;
    
}

- (UIProgressView *)cacheProgress {
    if (!_cacheProgress) {
        
        _cacheProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        
    }
    return _cacheProgress;
}



@end
