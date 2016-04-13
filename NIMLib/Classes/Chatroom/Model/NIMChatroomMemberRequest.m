//
//  NIMChatroomMemberRequest.m
//  NIMLib
//
//  Created by chris on 16/1/4.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomMemberRequest_Private.h"

@implementation NIMChatroomMemberRequest

@end


@implementation NIMChatroomMemberUpdateRequest

- (instancetype)init{
    self = [super init];
    if (self) {
        _enable = YES;
    }
    return self;
}

@end


@implementation NIMChatroomMembersByIdsRequest

- (NSString *)description
{
    return [NSString stringWithFormat:@"MembersByIdsRequest roomId:%@ userIds:%@",_roomId,_userIds];
}

@end

@implementation NIMChatroomMemberKickRequest

- (NSString *)description
{
    return [NSString stringWithFormat:@"MemberKickRequest roomId:%@ userId:%@ notifyExt%@", _roomId,_userId,_notifyExt];
}

@end
