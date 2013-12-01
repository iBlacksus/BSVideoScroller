//
//  ViewController.m
//  BLVideoScroller
//
//  Created by iBlacksus on 12/1/13.
//  Copyright (c) 2013 iBlacksus. All rights reserved.
//

#import "SampleViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define sampleVideoFile @"sample"

@interface SampleViewController () {
    MPMoviePlayerViewController *player;
    NSTimer *playbackTimer;
}

@end

@implementation SampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializePlayer];
    [self initializeVideoScroller];
}

- (void)initializeVideoScroller {
    CGRect frame = self.videoScroller.frame;
    frame.origin.y = 0.0;
    self.videoScroller.frame = frame;
    self.videoScroller.alpha = 0.0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:sampleVideoFile ofType:@".mov"];
    self.videoScroller.fileURL = [NSURL fileURLWithPath:path];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.videoScroller initializeThumbnails];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                [self.videoScroller loadThumbnails];
                
                CGRect frame = self.videoScroller.frame;
                frame.origin.y = 44.0;
                self.videoScroller.frame = frame;
                
                self.videoScroller.alpha = 1.0;
            }];
        });
        
    });
}

- (void)initializePlayer {
    NSString *path = [[NSBundle mainBundle] pathForResource:sampleVideoFile ofType:@".mov"];
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    player = [[MPMoviePlayerViewController alloc] initWithContentURL:fileUrl];
    
    [player.view setFrame:self.videoPlayerView.bounds];
    
    player.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    player.moviePlayer.shouldAutoplay = NO;
    player.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    
    [self.videoPlayerView addSubview:player.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
}

- (void)playbackChanged {
    CGFloat position = player.moviePlayer.currentPlaybackTime;
    if (position > 0.0) {
        [self.videoScroller setPosition:position];
    }
}

#pragma mark - Interface Orientation -

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - MPMoviePlayerPlayback Events -

- (void)playbackDidChange:(NSNotification*)aNotification {
    if (player.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self addPlaybackTimer];
    }
    else {
        [self removePlaybackTimer];
    }
}

#pragma mark - NKVideoScrollerDelegate -

- (void)videoScroller:(BLVideoScroller *)sender changePosition:(CGFloat)position {
    [player.moviePlayer setCurrentPlaybackTime:position];
}

#pragma mark - General methods -

- (void)addPlaybackTimer {
    if (playbackTimer) {
        [self removePlaybackTimer];
    }
    
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playbackChanged) userInfo:nil repeats:YES];
}

- (void)removePlaybackTimer {
    if (playbackTimer) {
        [playbackTimer invalidate];
    }
}

@end
