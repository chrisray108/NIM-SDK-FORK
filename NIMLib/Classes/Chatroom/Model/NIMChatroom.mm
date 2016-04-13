//
//  NIMChatroom.m
//  NIMLib
//
//  Created by amao on 12/14/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroom_Private.h"
#import "chatroom_protocol.h"
#import "NIMProtocolUtil.h"
#import "NIMNOSResizer.h"

@implementation NIMChatroom
- (instancetype)initWithProperty:(const nimbiz::Property &)info
{
    if (self = [super init])
    {
        _roomId = NSUTF8(info.get_string(nimbiz::NIMChatroomTagRoomId));
        _name   = NSUTF8(info.get_string(nimbiz::NIMChatroomTagName));
        _announcement = NSUTF8(info.get_string(nimbiz::NIMChatroomTagAnnouncement));
        _creator= NSUTF8(info.get_string(nimbiz::NIMChatroomTagCreator));
        _ext = [NIMProtocolUtil dictByJsonString:info.get_string(nimbiz::NIMChatroomTagExt)];
        _onlineUserCount = info.get_int32(nimbiz::NIMChatroomTagOnlineCount);
        _broadcastUrl = NSUTF8(info.get_string(nimbiz::NIMChatroomTagBroadcastUrl));
    }
    return self;
}
@end


@implementation NIMChatroomEnterRequest

@end


@implementation NIMMessageChatroomExtension

- (NSString *)roomAvatarThumbnail
{
    return [[NIMNOSResizer sharedResizer] imageThumbnailURL:self.roomAvatar];
}
@end