//
//  JLCacheSlider.h
//  VideoPlayer
//
//  Created by emerys on 2017/2/21.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLCacheSlider : UISlider

@property (nonatomic,strong) UIColor *cacheProgressTintColor;
@property (nonatomic,strong) UIColor *trackTintColor;
@property (nonatomic,strong) UIColor *progressTintColor;

@property (nonatomic,assign) double cacheValue;
@property (nonatomic,assign) double progress;

@end
