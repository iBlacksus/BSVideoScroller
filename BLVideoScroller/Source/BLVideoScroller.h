//
//  BLVideoScroller.h
//  BLVideoScroller
//
//  Created by iBlacksus on 12/1/13.
//  Copyright (c) 2013 iBlacksus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLVideoScrollerDelegate;
@interface BLVideoScroller : UIView

// set delegate in IB
@property (nonatomic) IBOutlet id<BLVideoScrollerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIView *thumbnails;
@property (nonatomic, weak) IBOutlet UIView *thumb;

@property (nonatomic) NSURL *fileURL;

- (void)initializeThumbnails;
- (void)loadThumbnails;
- (void)setPosition:(CGFloat)position;

@end

@protocol BLVideoScrollerDelegate <NSObject>

- (void)videoScroller:(BLVideoScroller *)sender changePosition:(CGFloat)position;

@end