//
//  NIMNVSObject.h
//  NIMLib
//
//  Created by 高峰 on 15/7/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NVSSessionRecordInfo;
@class NIMNetCallOption;

@interface NIMNVSObject : NSObject

@property(nonatomic, assign) uint8_t callType;
@property(nonatomic, assign) uint64_t myUid;
@property(nonatomic, assign) uint64_t channelId;
@property(nonatomic, strong) NSArray *turnAddrs;
@property(nonatomic, strong) NSArray *stunAddrs;
@property(nonatomic, strong) NSArray *proxyAddrs;

@property(nonatomic, strong) NVSSessionRecordInfo *recordInfo;

@property(nonatomic, assign) BOOL serverRecordAudio;
@property(nonatomic, assign) BOOL serverRecordVideo;

@property(nonatomic, assign) BOOL disableP2P;
@property(nonatomic, copy  ) NSString *callConfig;

@property(nonatomic, strong) NIMNetCallOption *option;

@end
