//
//  ViewController.m
//  VideoPlayer
//
//  Created by emerys on 2017/2/20.
//  Copyright © 2017年 Emerys. All rights reserved.
//

#import "ViewController.h"
#import "JLVideoPlayerController.h"
#import "JLCacheSlider.h"
#import "JLPlayerRequestTask.h"


#define PLAY_URL @"http://baobab.cdn.wandoujia.com/1449121380062b.mp4"

@interface ViewController ()

@property (nonatomic,strong) JLCacheSlider *pv;///<进度

@property (nonatomic,strong) UISlider *sl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.pv];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    JLVideoPlayerController *pc = [[JLVideoPlayerController alloc] init];
    
    [self presentViewController:pc animated:YES completion:nil];

    
    
//
}

- (JLCacheSlider *)pv {
    if (!_pv) {
        CGRect frame = self.view.bounds;
        _pv = [[JLCacheSlider alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame) - 20, 10)];
        _pv.cacheValue = 0.4;
        _pv.progress = 0.1;
    }
    return _pv;
}

- (UISlider *)sl {
    if (!_sl) {
        _sl = [[UISlider alloc] init];
        _sl.value = 0.8;
        _sl.maximumTrackTintColor = [UIColor purpleColor];
        _sl.minimumTrackTintColor = [UIColor redColor];
    }
    return _sl;
}


@end
