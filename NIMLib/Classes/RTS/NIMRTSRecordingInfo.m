//
//  NIMRTSRecordingInfo.m
//  NIMLib
//
//  Created by 高峰 on 15/7/24.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMRTSRecordingInfo.h"

@implementation NIMRTSRecordingInfo

- (instancetype)initWithService:(NIMRTSService) service
                        address:(NSString *)serverAddress
                           file:(NSString *)fileName
{
    if (self = [super init]) {
        _service = service;
        _serverAddress = serverAddress;
        _recordFileName = fileName;
    }
    return self;
}


@end
