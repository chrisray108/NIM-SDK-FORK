//
//  NIMCustomSystemNotification.m
//  NIMLib
//
//  Created by amao on 7/28/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMCustomSystemNotification_Private.h"
#import "NSDictionary+NIMJson.h"
#import "team_protocol.h"
#import "session_protocol.h"
#import "NIMProtocolUtil.h"
#import "NIMCustomSystemNotificationSetting_Private.h"

@implementation NIMCustomSystemNotification

- (instancetype)init
{
    if (self = [super init])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithContent:(NSString *)content
{
    if (self = [super init])
    {
        [self commonInit];
        _content = content;
    }
    return self;
}

- (instancetype)initWithPorperty:(const nimbiz::Property &)property
{
    if (self = [super init])
    {
        _timestamp                  = NIMTimeLongToDouble(property.get_uint64(nimbiz::NIMSystemMsgTagTime));
        _sender                     = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagFromAccount));
        _receiver                   = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagToAccount));
        _msgId                      = property.get_uint64(nimbiz::NIMSystemMsgTagMsgID);
        _content                    = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagAttach));
        _apnsContent                = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagApnsText));
        _apnsPayload                = [NIMProtocolUtil dictByJsonString:property.get_string(nimbiz::NIMSystemMsgTagApnsPayload)];
        NSInteger type              = (NSInteger)property.get_uint32(nimbiz::NIMSystemMsgTagType);
        _receiverType               = type == NIMCustomSystemNotificationTypeTeam ? NIMSessionTypeTeam : NIMSessionTypeP2P;
        _sendToOnlineUsersOnly      = _msgId == 0;
        _setting                    = [NIMCustomSystemNotificationSetting settingByProperty:property];
        
    }
    return self;
}

- (void)commonInit
{
    _sendToOnlineUsersOnly = YES;
    _timestamp = [[NSDate date] timeIntervalSince1970];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"cn: msg id %lld content %@ setting %@",_msgId,_content,_setting];
}
@end
