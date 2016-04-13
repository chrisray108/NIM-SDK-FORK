//
//  NIMNTSManager.h
//  NIMLib
//
//  Created by 高峰 on 15/7/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//
//  基于实时nio库的数据传输管理类

#import "NIMManager.h"
#import "NTSClient.h"
#import "NIMNTSObject.h"

@interface NIMNTSManager : NIMManager

- (void)startNTS:(NIMNTSObject *)object;

- (BOOL)tryNextServer:(NIMNTSObject *)object;

- (void)stopNTS:(NIMNTSObject *)object;

- (BOOL)sendNTSData:(NSData *)data from:(NIMNTSObject *)object to:(uint64_t)clientID;

@end
