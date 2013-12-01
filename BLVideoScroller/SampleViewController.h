//
//  ViewController.h
//  BLVideoScroller
//
//  Created by iBlacksus on 12/1/13.
//  Copyright (c) 2013 iBlacksus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLVideoScroller.h"

@interface SampleViewController : UIViewController <BLVideoScrollerDelegate>

@property (nonatomic, weak) IBOutlet BLVideoScroller *videoScroller;
@property (nonatomic, weak) IBOutlet UIView *videoPlayerView;

@end
