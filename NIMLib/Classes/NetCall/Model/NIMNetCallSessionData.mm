//
//  NIMNetCallSessionData.m
//  NIMLib
//
//  Created by fenric on 15/5/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMNetCallSessionData.h"
#import "NIMProtocolUtil.h"

@implementation NIMNetCallSessionData

-(id)initWithNetcallInitParam:(nimbiz::CBNetcallInitParam *)param
{
    if (self = [super init]) {
        self.callType = param->call_type_;
        self.myUid = param->my_uid_;
        self.channelId = param->channel_id_;
        self.turnAddrs = [NIMProtocolUtil stringListToArray:param->turn_addrs_];
        self.stunAddrs = [NIMProtocolUtil stringListToArray:param->sturn_addrs_];
        self.proxyAddrs = [NIMProtocolUtil stringListToArray:param->proxy_addrs_];
        self.usersInfo = [self getUsersInfo:param->users_info_];

        //for caller
        self.callees = [NIMProtocolUtil stringListToArray:param->callee_users_];
        self.keepCallingCallees = [NIMProtocolUtil stringListToArray:param->keep_calling_users_];
        self.callConfig = NSUTF8(param->call_config_);
        
        //warning: for functional test only, change server ip
//        NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.turnAddrs];
//        tmp[0] = [tmp[0] stringByAppendingString:@"1"];
//        self.turnAddrs = tmp;
        
    }
    return self;
}

-(id)initWithNetcallBeCalledParam:(nimbiz::CBNetcallBeCalledParam *)param
{
    if (self = [super init]) {
        self.callType = param->call_type_;
        self.myUid = param->my_uid_;
        self.channelId = param->channel_id_;
        self.turnAddrs = [NIMProtocolUtil stringListToArray:param->turn_addrs_];
        self.stunAddrs = [NIMProtocolUtil stringListToArray:param->sturn_addrs_];
        self.proxyAddrs = [NIMProtocolUtil stringListToArray:param->proxy_addrs_];
        self.usersInfo = [self getUsersInfo:param->users_info_];
        //for callee
        self.caller = NSUTF8(param->caller_);
        self.callConfig = NSUTF8(param->call_config_);
        self.extendMessage = NSUTF8(param->extend_message_);
    }
    return self;

}

- (NSDictionary *)getUsersInfo:(std::map<uint64_t, nimbiz::UTF8String> &)info
{
    NSMutableDictionary *usersInfo = [NSMutableDictionary new];
    std::map<uint64_t, nimbiz::UTF8String>::iterator i = info.begin();
    for (; i != info.end(); ++i) {
        [usersInfo setObject:NSUTF8(i->second) forKey:@(i->first)];
    }
    return usersInfo;
}

@end
