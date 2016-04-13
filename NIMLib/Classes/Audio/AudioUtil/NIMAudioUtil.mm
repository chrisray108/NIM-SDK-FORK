//
//  NIMAudioUtil.m
//  NIM
//
//  Created by amao on 13-2-22.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "NIMAudioUtil.h"

@interface NIMAudioUtil ()
@end

@implementation NIMAudioUtil

+ (BOOL)switchToSpeakerMode
{
    return [NIMAudioUtil setSpeakerMode:YES];
}

+ (BOOL)switchToReceiverMode
{
    return [NIMAudioUtil setSpeakerMode:NO];
}


+ (BOOL)setSpeakerMode:(BOOL)useSpeaker
{
    BOOL isPlayAndRecordCategory = [AVAudioSession.sharedInstance.category isEqualToString:AVAudioSessionCategoryPlayAndRecord];
    
    AVAudioSessionCategoryOptions currentOptions = 0;
    if (isPlayAndRecordCategory) {
        currentOptions = AVAudioSession.sharedInstance.categoryOptions;
    }
    
    AVAudioSessionCategoryOptions newOption;
    if (useSpeaker) {
        newOption = currentOptions | AVAudioSessionCategoryOptionDefaultToSpeaker;
    }
    else {
        newOption = currentOptions & ~AVAudioSessionCategoryOptionDefaultToSpeaker;
    }
    
    if (isPlayAndRecordCategory && (newOption == currentOptions)) {
        return YES;
    }

    NSError *error;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                                    withOptions:newOption
                                                          error:&error];
    if (!success) {
        NIMLogErr(@"error switch to %@ mode:%@", useSpeaker ? @"speaker" : @"receiver", [error localizedDescription]);
    }
    return success;
}


+ (BOOL)isUsingBluetooth
{
#if TARGET_IPHONE_SIMULATOR
   return NO;
#else
    NSString *portType = [self getCurrentAudioRouteType];
    if (([portType rangeOfString:@"Bluetooth"].location != NSNotFound)) {
        return YES;
    }
    return NO;
#endif
}


+ (void)hasRecordGranted:(PermissionBlock)block
{
   if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
   {
      [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
         block(granted);
         
      }];
      
   }
   else {
      block(YES);
   }
}

+ (void)enableBluetooth
{
    BOOL isPlayAndRecordCategory = [AVAudioSession.sharedInstance.category isEqualToString:AVAudioSessionCategoryPlayAndRecord];
    
    AVAudioSessionCategoryOptions currentOptions = 0;
    if (isPlayAndRecordCategory) {
        currentOptions = AVAudioSession.sharedInstance.categoryOptions;
    }
    
    AVAudioSessionCategoryOptions newOption = currentOptions | AVAudioSessionCategoryOptionAllowBluetooth;
    
    if (isPlayAndRecordCategory && (newOption == currentOptions)) {
        return;
    }
    
    NSError *error;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                                    withOptions:newOption
                                                          error:&error];
    if (!success) {
        NIMLogErr(@"error enable bluetooth:%@", [error localizedDescription]);
    }
   
   NIMLogApp(@"playback route:%@", [self getCurrentAudioRouteType]);
}


#pragma mark private

+ (NSString *)getCurrentAudioRouteType
{
   NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
   return [[outputs objectAtIndex:0] portType];
}

@end