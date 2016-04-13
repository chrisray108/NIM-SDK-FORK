//
//  NIMAudioRecorder.h
//  NIM
//
//  Created by amao on 13-1-23.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NIMAudioDelegate.h"
#import "AQRecorder.h"

@interface NIMAudioRecorder : NSObject
<AVAudioRecorderDelegate>

@property (nonatomic,weak)    id<NIMAudioRecorderDelegate>   delegate;
@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, readonly) float averagePower;
@property (nonatomic, readonly) float peakPower;
@property (nonatomic,readonly)  NSTimeInterval currentTime;

- (BOOL)prepareToRecord;

- (BOOL)record:(NIM::AudioType)type;

- (void)cancelRecord;
- (void)completeRecord;

- (void)setAutoDeactivateAudioSession:(BOOL)deactivate;

@end
