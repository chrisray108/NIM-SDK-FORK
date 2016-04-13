//
//  NIMAudioRecorderDelegate.h
//  NIM
//
//  Created by amao on 13-1-24.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NIMAudioRecorderDelegate <NSObject>
@required
- (void)audioDidStarted: (BOOL)isSuccessed filepath:(NSString *)filepath;
- (void)audioDidFinished: (NSString *)filepath url: (NSURL *)url successfully: (BOOL)flag;
@end

@protocol NIMAudioPlayerDelegate <NSObject>
@required
- (void)audioPlayerBegin: (NSString *)filepath;
- (void)audioPlayerEnd: (NSString *)filepath error:(NSError *)error;
- (void)audioPlayerCancelled: (NSString *)filepath;
@optional
- (void)audioPlayerBeginInterruption: (NSString *)filepath;
- (void)audioPlayerEndInterruption: (NSString *)filepath;
- (void)afterAVAudioSessionSetActive;
@end
