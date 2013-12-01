//
//  BLVideoScroller.m
//  BLVideoScroller
//
//  Created by iBlacksus on 12/1/13.
//  Copyright (c) 2013 iBlacksus. All rights reserved.
//

#import "BLVideoScroller.h"
#import <AVFoundation/AVFoundation.h>

#define thumbFrameY 7.f
#define thumbFrameWidth 5.f
#define thumbFrameHeight 30.f

#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define ThumbnailsCountInPortrait (iPad ? 25 : 10)
#define ThumbnailsCountInLandscape (iPad ? 38 : 15)
#define ThumbnailsHeight 29.0
#define ThumbnailsWidth ThumbnailsHeight

@implementation BLVideoScroller {
    UIPanGestureRecognizer *panGestureRecognizer;
    NSMutableArray *portraitThumbnails, *landscapeThumbnails;
    CGFloat durationInSeconds;
    UIDeviceOrientation currentOrientation;
    BOOL isScrolling;
    CGFloat currentPosition;
    
    BOOL isBusy;
}

@synthesize delegate;

- (void)awakeFromNib {
    [self initialization];
}

#pragma mark - Initialization -

- (void)initializeOrientation {
    currentOrientation = [[UIDevice currentDevice] orientation];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)initialization {
    currentPosition = 0.0;
    
    [self initializeOrientation];
    [self initializeGestureRecognizer];
    [self customizeThumb];
}

- (void)initializeGestureRecognizer {
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)customizeThumb {
    self.thumb.layer.cornerRadius = 3.f;
    self.thumb.layer.masksToBounds = YES;
}

- (void)initializeThumbnails {
    isBusy = YES;
    
    portraitThumbnails = [NSMutableArray array];
    landscapeThumbnails = [NSMutableArray array];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.fileURL options:nil];
    // duration
    CMTime duration = asset.duration;
    durationInSeconds = CMTimeGetSeconds(duration);
    // thumbnails generator
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize = CGSizeMake(ThumbnailsWidth*2, ThumbnailsHeight*2);
    generator.appliesPreferredTrackTransform = YES;
    
    // generate portrait thumbnails
    for (NSInteger i=0; i < ThumbnailsCountInPortrait; i++) {
        NSError *err;
        CMTime time = CMTimeMake(duration.value/ThumbnailsCountInPortrait*i, duration.timescale);
        CGImageRef oneRef = [generator copyCGImageAtTime:time actualTime:nil error:&err];
        [portraitThumbnails addObject:[UIImage imageWithCGImage:oneRef]];
    }
    
    // generate landscape thumbnails
    for (NSInteger i=0; i < ThumbnailsCountInLandscape; i++) {
        NSError *err;
        CMTime time = CMTimeMake(duration.value/ThumbnailsCountInLandscape*i, duration.timescale);
        CGImageRef oneRef = [generator copyCGImageAtTime:time actualTime:nil error:&err];
        [landscapeThumbnails addObject:[UIImage imageWithCGImage:oneRef]];
    }
//    
    isBusy = NO;
}

#pragma mark - Interface Orientation -

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation != UIDeviceOrientationPortrait &&
        orientation != UIDeviceOrientationLandscapeRight &&
        orientation != UIDeviceOrientationLandscapeLeft) {
        return;
    }
    
    currentOrientation = orientation;
    
    double delayToStartLoading = 0.5;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartLoading * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        [self loadThumbnails];
    });
}

#pragma mark - General -

- (void)loadThumbnails {
    if (isBusy) {
        return;
    }
    
    if (!portraitThumbnails || !landscapeThumbnails) {
        [self initializeThumbnails];
    }
    
    for (UIView *subview in self.thumbnails.subviews) {
        [subview removeFromSuperview];
    }
    
    NSInteger thumbnailsCount = (UIDeviceOrientationIsPortrait(currentOrientation)) ? ThumbnailsCountInPortrait : ThumbnailsCountInLandscape;
    NSArray *thumbnailsArray = (UIDeviceOrientationIsPortrait(currentOrientation)) ? portraitThumbnails : landscapeThumbnails;
    
    NSLog(@"%f", self.thumbnails.frame.size.width);
    
    for (NSInteger i=0; i < thumbnailsCount; i++) {
        CGFloat imageX = self.thumbnails.frame.size.width/thumbnailsCount*i+1.0;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, 1.0, ThumbnailsWidth, ThumbnailsHeight)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image = thumbnailsArray[i];
        
        [self.thumbnails addSubview:imageView];
    }
    
    [self setPosition:currentPosition];
}

- (void)setPosition:(CGFloat)position {
    if (isScrolling) {
        return;
    }
    
    currentPosition = position;
    
    CGFloat locationX = 10.0 + self.thumbnails.frame.size.width / durationInSeconds * position - thumbFrameWidth/2;
    self.thumb.frame = CGRectMake(locationX, thumbFrameY, thumbFrameWidth, thumbFrameHeight);
}

#pragma mark - Gestures -

- (void)pan:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            isScrolling = YES;
            
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [panGestureRecognizer locationInView:self];
            
            if (location.x < 10.f) {
                location.x = 10.f;
            }
            else if (location.x > self.frame.size.width-10.f) {
                location.x = self.frame.size.width-10.f;
            }
            
            location.x -= thumbFrameWidth/2;
            
            self.thumb.frame = CGRectMake(location.x, thumbFrameY, thumbFrameWidth, thumbFrameHeight);
            
            currentPosition = durationInSeconds / self.frame.size.width * location.x;
            [delegate videoScroller:self changePosition:currentPosition];
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            double delayToScrolling = 1.0;
            dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToScrolling * NSEC_PER_SEC);
            dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
                isScrolling = NO;
            });
        }
            
            break;
            
        default:
            break;
    }
}

@end
