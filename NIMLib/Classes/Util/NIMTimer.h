//
//  NIMTimer.h
//  NIMLib
//
//  Created by amao on 1/19/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMTimer;

@protocol NIMTimerDelegate <NSObject>
- (void)onNIMTimerFired:(NIMTimer *)timer;
@end

@interface NIMTimer : NSObject
@property (nonatomic,weak)  id<NIMTimerDelegate>  delegate;
- (BOOL)isScheduled;

- (void)startTimer:(NSTimeInterval)seconds
          delegate:(id<NIMTimerDelegate>)delegate
           repeats:(BOOL)repeats;

- (void)stopTimer;
@end
