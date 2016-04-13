//
//  NIMTeamMember_Private.m
//  NIMLib
//
//  Created by amao on 3/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMTeamMember_Private.h"
#import "team_protocol.h"

@implementation NIMTeamMember

- (instancetype)initWithProperty:(const nimbiz::Property&)info
{
    if (self = [super init])
    {
        _teamId     = NSUTF8(info.get_string(nimbiz::NIMTeamMemberTagTID));
        _userId     = NSUTF8(info.get_string(nimbiz::NIMTeamMemberTagAccountID));
        _type       = (NSInteger)info.get_int32(nimbiz::NIMTeamMemberTagType);
        _invitor    = NSUTF8(info.get_string(nimbiz::NIMTeamMemberTagInvitor));
        _createTime = NIMTimeLongToDouble(info.get_uint64(nimbiz::NIMTeamMemberTagCreateTime));
        _nickname   = NSUTF8(info.get_string(nimbiz::NIMTeamMemberTagNick));
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"team id %@ user id %@ type %zd invitor %@ create time %lf nickname %@",
            _teamId,_userId,_type,_invitor,_createTime,_nickname];
}
@end