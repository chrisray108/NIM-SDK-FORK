//
//  NIMAudioPlayer.h
//  NIM
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMAudioDelegate.h"
@interface NIMAudioPlayer : NSObject

@property (nonatomic,weak)      id<NIMAudioPlayerDelegate> delegate;
@property (nonatomic,strong)    NSString *filepath;
@property (nonatomic,assign)    BOOL isNeedProximityMonitor;
@property (nonatomic,assign)    BOOL autoDeactivateAudioSession;
@property (nonatomic, readonly) float averagePower;
@property (nonatomic, readonly) float peakPower;

- (BOOL)play:(NSString *)filepath;
- (void)stop;
- (BOOL)isPlaying;
- (NSTimeInterval)currentTime;
@end
