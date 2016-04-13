//
//  NIMNVSManager.h
//  NIMLib
//
//  Created by 高峰 on 15/7/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//
//  基于实时nio库的音视频会话管理类

#import "NIMManager.h"

@class NVSSessionManager;
@class NIMNVSObject;
@class NVSSessionRecordInfo;

@interface NIMNVSManager : NIMManager

@property (nonatomic, strong) NVSSessionManager *session;

- (void)start:(NIMNVSObject *)object delegate:(id)delegate;

- (BOOL)stop:(uint64_t)channelID;

- (uint64_t)currentChannelID;

- (BOOL)isBusy;

- (NSString *)logFilePath;

- (NVSSessionRecordInfo *)getRecordInfo;

@end
