//
//  NIMChatroomMember.m
//  NIMLib
//
//  Created by chris on 16/1/4.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomMember_Private.h"
#import "chatroom_protocol.h"

@implementation NIMChatroomMember

- (instancetype)initWithProperty:(const nimbiz::Property&)user{
    self = [super init];
    if (self) {
        _userId        = NSUTF8(user.get_string(nimbiz::NIMChatroomMemberTagUid));
        _roomNickname  = NSUTF8(user.get_string(nimbiz::NIMChatroomMemberTagNick));
        _roomAvatar    = NSUTF8(user.get_string(nimbiz::NIMChatroomMemberTagAvatar));
        _isMuted       = user.get_uint32(nimbiz::NIMChatroomMemberTagMuted);
        _isInBlackList = user.get_uint32(nimbiz::NIMChatroomMemberTagBlackList);
        _isOnline      = user.get_uint32(nimbiz::NIMChatroomMemberTagOnline);
        _isVaild       = user.get_uint32(nimbiz::NIMChatroomMemberTagVaild);
        _enterTimeInterval  = NIMTimeLongToDouble(user.get_uint64(nimbiz::NIMChatroomMemberTagEnterTime));
        _updateTimeInterval = NIMTimeLongToDouble(user.get_uint64(nimbiz::NIMChatroomMemberTagUpdateTime));

        BOOL isGuest   = user.get_uint32(nimbiz::NIMChatroomMemberTagGuest);
        if (isGuest)
        {
            _type      = NIMChatroomMemberTypeGuest;
        }
        else
        {
            _type      = user.get_int32(nimbiz::NIMChatroomMemberTagType);
        }
        
        NSString *ext = NSUTF8(user.get_string(nimbiz::NIMChatroomMemberTagExt));
        NSData *jsonData = [ext dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            if ([dict isKindOfClass:[NSDictionary class]]) {
                _roomExt = dict;
            }
        }
    }
    return self;
}

@end
