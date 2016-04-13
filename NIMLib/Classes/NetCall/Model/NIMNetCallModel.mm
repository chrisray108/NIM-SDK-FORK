//
//  NIMNetCallModel.m
//  NIMLib
//
//  Created by fenric on 15/5/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMNetCallModel.h"
#import "NIMUtil.h"

@implementation NIMNetCallModel

- (id)initCallerWithCallees:(NSArray *)callees type:(NIMNetCallType)type
{
    if (self = [super init]) {
        [self generalInit:type];
        _callees = callees;
        _isCaller = YES;
        _channelID = 0;
    }
    return self;
}

- (id)initCalleeWithCaller:(NSString *)caller type:(NIMNetCallType)type channelID:(UInt64)channelID
{
    if (self = [super init]) {
        [self generalInit:type];
        _caller = caller;
        _isCaller = NO;
        _channelID = channelID;
    }
    return self;
}


- (void)generalInit:(NIMNetCallType)type
{
    _uuid = [NIMUtil uuid];
    _type = type;
    _isMute = NO;
    _useSpeaker = (_type == NIMNetCallTypeVideo) ? YES : NO;
    _netStatus = NIMNetCallNetStatusGood;
}

@end
