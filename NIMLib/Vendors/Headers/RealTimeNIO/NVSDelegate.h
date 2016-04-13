//
//  NVSDelegate.h
//  nvs
//
//  Created by fenric on 15/4/29.
//  Copyright (c) 2015年 yixin.dev. All rights reserved.
//

#ifndef nvs_NVSDelegate_h
#define nvs_NVSDelegate_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGImage.h>
#import <QuartzCore/CALayer.h>
#import "NVSDefine.h"

@class NVSSessionReport;
@class NVSI420Frame;
@class NVSSessionRecordInfo;

//session
@protocol NVSSessionDelegate <NSObject>
@optional
- (void)onSessionStatus:(NVSVideoChatSessionStatus)status;
- (void)onNetstatBad:(NVSVideoChatSessionNetStat)stat;
- (void)onNetstatChanged:(NVSVideoChatSessionNetStat)stat;
- (void)onLoginError:(NVSLoginErrorCode)code;
- (void)onAudioDeviceError:(NVSAudioErrorCategory)category;
- (void)onSessionReport:(NVSSessionReport *)report;
- (void)onReceiveAppData:(NSData *)data from:(uint64_t)clientID withPacketID:(uint32_t)packetID;

- (void)onAudioInterrupted;

//for nrtc
- (void)onJoined:(NVSSessionRecordInfo *)info;
- (void)onLeft:(NVSSessionReport *)report;
- (void)onUserJoined:(UInt64)uid;
- (void)onUserLeft:(UInt64)uid forReason:(NVSLeaveReason) reason;

- (void)onUserMute:(BOOL)isMute user:(UInt64)uid;
- (void)onUserCamera:(BOOL)isOn user:(UInt64)uid;
- (void)onUserMode:(NVSSessionMode)mode user:(UInt64)uid;
- (void)onUserIsRecording:(BOOL)isOn user:(UInt64)uid;

- (void)onAudioInterruption:(BOOL)interrupted;

@end

//video
@protocol NVSVideoPlayerDelegate <NSObject>
@required
// 本地采集预览layer
- (void)displayLocalPreviewLayer:(CALayer *)previewLayer;

// 远程渲染接口，提供更上层进行显示
- (void)displayRemoteI420:(NVSI420Frame *)frame;

// 没有获取到本地camera
- (void)cameraNotAvalible;

@end

//log
@protocol NVSLogDelegate <NSObject>
@optional
- (void)log:(NVSLogLevel)level
       file:(NSString *)file
       line:(NSUInteger)line
       text:(NSString *)text;
@end

@protocol NVSRecordingDelegate <NSObject>

@optional

- (void) recordingStart:(UInt64)channelID
                 result:(NVSRecordingError)error
                fileURL:(NSURL *)fileURL;

- (void) recordingError:(NVSRecordingError)error
                channel:(UInt64)channelID;

- (void) recordingStopped:(UInt64)channelID
                  fileURL:(NSURL *)fileURL;

@end

#endif
