//
//  NIMNTSObject.h
//  NIMLib
//
//  Created by 高峰 on 15/7/6.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMRTSManagerProtocol.h"

@class NTSClient;
@class NTSConnectResultInfo;
@protocol NTSClientDelegate;

@interface NIMNTSObject : NSObject

@property(nonatomic, copy)    NSString *sessionID;
@property(nonatomic, assign)  uint64_t channelId;

@property(nonatomic, assign)  uint64_t myUid;
@property(nonatomic, strong)  NSArray *turnAddrs;
@property(nonatomic, strong)  NSArray *proxyAddrs;

@property(nonatomic, assign)  BOOL disableRecord;

@property(nonatomic, weak)    NTSClient *client;

@property(nonatomic, strong)  NTSConnectResultInfo *info;

@property (nonatomic, assign) NSInteger  turnAddrIndex;
@property (nonatomic, assign) NSInteger  proxyAddrIndex;

@property (nonatomic, weak) id<NTSClientDelegate> delegate;

@end
