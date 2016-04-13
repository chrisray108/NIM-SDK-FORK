//
//  NIMTimer.m
//  NIMLib
//
//  Created by amao on 1/19/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMTimer.h"

@interface NIMTimer ()
{
    NSTimer *_timer;
    BOOL    _repeats;
}
- (void)onTimer: (NSTimer *)timer;
@end

@implementation NIMTimer

- (void)dealloc
{
    [self stopTimer];
}

- (BOOL)isScheduled
{
    return _timer != nil;
}

- (void)startTimer:(NSTimeInterval)seconds
          delegate:(id<NIMTimerDelegate>)delegate
           repeats:(BOOL)repeats;
{
    _delegate = delegate;
    _repeats = repeats;
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                              target:self
                                            selector:@selector(onTimer:)
                                            userInfo:nil
                                             repeats:repeats];
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
    _delegate = nil;
}

- (void)onTimer:(NSTimer *)timer
{
    if (!_repeats)
    {
        _timer = nil;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onNIMTimerFired:)])
    {
        [_delegate onNIMTimerFired:self];
    }
}


@end
