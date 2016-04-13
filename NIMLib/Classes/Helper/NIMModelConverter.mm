//
//  NIMModelConverter.m
//  NIMLib
//
//  Created by amao on 4/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMModelConverter.h"
#import "session_protocol.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMImageObject_Private.h"
#import "NIMAudioObject_Private.h"
#import "NIMVideoObject_Private.h"
#import "NIMLocationObject_Private.h"
#import "NIMCustomObject_Private.h"
#import "NIMNotificationObject_Private.h"
#import "NIMMessage_Private.h"
#import "NIMFileObject_Private.h"
#import "NIMSDK_Private.h"
#import "NIMNetCallRecord_Private.h"
#import "NIMProtocolUtil.h"
#import "NIMMessageSetting_Private.h"
#import "ios_util.h"
#import "chatroom_protocol.h"
#import "NIMProtocolUtil.h"
#import "NIMChatroom_Private.h"

@implementation NIMModelConverter

+ (id<NIMMessageObject_Private>)messaegObjectWithType:(NIMMessageType)type
                                              content:(NSString*)content
{
    id<NIMMessageObject_Private> object;
    switch (type) {
        case NIMMessageTypeText:
            break;
        case NIMMessageTypeImage:
            object = [[NIMImageObject alloc] init];
            break;
        case NIMMessageTypeAudio:
            object = [[NIMAudioObject alloc] init];
            break;
        case NIMMessageTypeVideo:
            object = [[NIMVideoObject alloc] init];
            break;
        case NIMMessageTypeLocation:
            object = [[NIMLocationObject alloc] init];
            break;
        case NIMMessageTypeCustom:
            object = [[NIMCustomObject alloc] init];
            break;
        case NIMMessageTypeNotification:
            object = [[NIMNotificationObject alloc] init];
            break;
        case NIMMessageTypeFile:
            object = [[NIMFileObject alloc] init];
            break;
        default:
            NIMLogWar(@"invalid content type %@",@(type));
            break;
    }
    [object decodeWithContent:content];

    return object;
}

#pragma mark - IM消息
+ (NIMMessage *)imMessageFromProperty:(const nimbiz::Property &)messageProperty
{
    NIMMessage *message     = [[NIMMessage alloc] init];
    NSString *messageId     = NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagClientID));
    NSString *toAccount     = NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagToAccount));
    NSString *fromAccount   = NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagFromAccount));
    NSInteger sessionType   = (NSInteger)messageProperty.get_uint32(nimbiz::NIMSessionTagToType);
    NSString *sessionId     = [NIMModelConverter sessionIdByType:sessionType
                                                     fromAccount:fromAccount
                                                       toAccount:toAccount];
    NIMSession *session     =  [NIMSession session:sessionId
                                              type:sessionType];

    message.messageId       = messageId;
    message.session         = session;
    message.from            = fromAccount;
    message.timestamp       = NIMTimeLongToDouble(messageProperty.get_uint64(nimbiz::NIMSessionTagTime));
    message.messageType     = (NIMMessageType)messageProperty.get_uint32(nimbiz::NIMSessionTagContentType);
    message.text            = NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagBody));
    message.rawAttachContent= NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagAttach));  //存储用
    message.serverID        = NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagServerID));
    message.senderName      = NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagNick));
    message.clientType      = messageProperty.get_int32(nimbiz::NIMSessionTagClientType);
    message.remoteExt       = [NIMProtocolUtil dictByJsonString:messageProperty.get_string(nimbiz::NIMSessionTagServerExt)];
    message.apnsContent     = NSUTF8(messageProperty.get_string(nimbiz::NIMSessionTagPushContent));
    message.apnsPayload     = [NIMProtocolUtil dictByJsonString:messageProperty.get_string(nimbiz::NIMSessionTagPushPayload)];
    message.setting         = [NIMMessageSetting settingByProperty:messageProperty];
    
    //如果消息带有是否需要计入未读的标记，需要对status进行处理
    if (messageProperty.has_tag(nimbiz::NIMSessionTagShouldBeCounted))
    {
        BOOL shouldBeCounted = messageProperty.get_uint32(nimbiz::NIMSessionTagShouldBeCounted) != 0;
        if (!shouldBeCounted)
        {
            message.status = NIMMessageStatusRead;
        }
    }
    
    
    message.isReceivedMsg   = YES;
    
    //解析Attachment并保存数据
    id<NIMMessageObject_Private> attach = [NIMModelConverter messaegObjectWithType:message.messageType
                                                                           content:message.rawAttachContent];
    message.messageObject   = attach;

    
    return message;
}

+ (nimbiz::Property)imPropertyFromMessage:(NIMMessage *)message
{
    nimbiz::Property messageProperty;
    messageProperty.put_uint32(nimbiz::NIMSessionTagToType,         (uint32_t)message.session.sessionType);
    messageProperty.put_string(nimbiz::NIMSessionTagToAccount,      UTF8(message.session.sessionId));
    messageProperty.put_uint32(nimbiz::NIMSessionTagContentType,    (uint32_t)message.messageType);
    messageProperty.put_string(nimbiz::NIMSessionTagBody,           UTF8(message.text));
    messageProperty.put_string(nimbiz::NIMSessionTagAttach,         UTF8([(id<NIMMessageObject_Private>)message.messageObject encodeContent]));
    messageProperty.put_string(nimbiz::NIMSessionTagClientID,       UTF8(message.messageId));
    
    
    //如果是自己发给自己的消息，带上device id
    NSString *currentAccount = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    if (message.session.sessionType == NIMSessionTypeP2P &&
        [currentAccount length] &&
        [message.session.sessionId length] &&
        [currentAccount isEqualToString:message.session.sessionId])
    {
        messageProperty.put_string(nimbiz::NIMSessionTagDeviceID, nimbiz::GetDeviceID());
    }
    
    //添加消息设置
    NIMMessageSetting *setting  = [message setting];
    if (setting)
    {
        nimbiz::Property settingProperty = [setting settingProperty];
        messageProperty.update(settingProperty.props);
        
    }
    
    //添加服务器Ext
    nimbiz::UTF8String ext = [NIMProtocolUtil stringByJsonDictionary:message.remoteExt];
    if (!ext.empty())
    {
        messageProperty.put_string(nimbiz::NIMSessionTagServerExt, ext);
    }
    
    //添加推送字段
    if ([message.apnsContent length])
    {
        messageProperty.put_string(nimbiz::NIMSessionTagPushContent, UTF8(message.apnsContent));
    }
    nimbiz::UTF8String pushPayload = [NIMProtocolUtil stringByJsonDictionary:message.apnsPayload];
    if (!pushPayload.empty())
    {
        messageProperty.put_string(nimbiz::NIMSessionTagPushPayload, pushPayload);
    }
    return messageProperty;
}


#pragma mark - 聊天室
+ (NIMMessage *)chatroomMessageFromProperty:(const nimbiz::Property)messageProperty
{
    NIMMessage *message = [[NIMMessage alloc] init];

    NSString *messageId     = NSUTF8(messageProperty.get_string(nimbiz::NIMChatroomMsgTagClientId));
    NSInteger sessionType   = NIMSessionTypeChatroom;
    NSString *sessionId     = NSUTF8(messageProperty.get_string(nimbiz::NIMChatroomMsgTagRoomId));
    NIMSession *session     =  [NIMSession session:sessionId
                                              type:sessionType];
    message.messageId       = messageId;
    message.session         = session;
    message.from            = NSUTF8(messageProperty.get_string(nimbiz::NIMChatroomMsgTagFromId));
    message.timestamp       = NIMTimeLongToDouble(messageProperty.get_uint64(nimbiz::NIMChatroomMsgTagTime));
    message.messageType     = (NIMMessageType)messageProperty.get_uint32(nimbiz::NIMChatroomMsgTagContentType);
    message.serverID        = 0;
    message.clientType      = messageProperty.get_int32(nimbiz::NIMChatroomMsgTagClientType);
    message.remoteExt       = [NIMProtocolUtil dictByJsonString:messageProperty.get_string(nimbiz::NIMChatroomMsgTagServerExt)];
    
    message.isReceivedMsg   = YES;
    
    //聊天室拓展
    NIMMessageChatroomExtension *chatroomExtension = [[NIMMessageChatroomExtension alloc] init];
    chatroomExtension.roomNickname = NSUTF8(messageProperty.get_string(nimbiz::NIMChatroomMsgTagFromNick));
    chatroomExtension.roomAvatar   = NSUTF8(messageProperty.get_string(nimbiz::NIMChatroomMsgTagFromAvatar));
    chatroomExtension.roomExt      = [NIMProtocolUtil dictByJsonString:messageProperty.get_string(nimbiz::NIMChatroomMsgTagFromExt)];
    message.messageExt = chatroomExtension;
    
    
    //解析Attachment并保存数据
    NSString *attachString = NSUTF8(messageProperty.get_string(nimbiz::NIMChatroomMsgTagAttach));
    if (message.messageType == NIMMessageTypeText)
    {
        message.text = attachString;
    }
    else
    {
        id<NIMMessageObject_Private> attach = [NIMModelConverter messaegObjectWithType:message.messageType
                                                                               content:attachString];
        message.messageObject   = attach;
    }
    return message;
}

+ (nimbiz::Property)chatroomPropertyFromMessage:(NIMMessage *)message
{
    nimbiz::Property messageProperty;
    
    messageProperty.put_string(nimbiz::NIMChatroomMsgTagClientId, UTF8([message messageId]));
    messageProperty.put_uint32(nimbiz::NIMChatroomMsgTagContentType, (uint32_t)message.messageType);
    messageProperty.put_string(nimbiz::NIMChatroomMsgTagRoomId, UTF8([[message session] sessionId]));
    if (message.messageType == NIMMessageTypeText)
    {
        messageProperty.put_string(nimbiz::NIMChatroomMsgTagAttach, UTF8(message.text));
    }
    else
    {
         messageProperty.put_string(nimbiz::NIMChatroomMsgTagAttach, UTF8([(id<NIMMessageObject_Private>)message.messageObject encodeContent]));
    }
    
    //添加服务器Ext
    nimbiz::UTF8String ext = [NIMProtocolUtil stringByJsonDictionary:message.remoteExt];
    if (!ext.empty())
    {
        messageProperty.put_string(nimbiz::NIMChatroomMsgTagServerExt, ext);
    }

    return messageProperty;
}

#pragma mark - 网络电话
+ (NIMMessage *)netCallMessageFromRercord:(NIMNetCallRecord *)record{
    NSArray  *members       = record.members;
    if (members.count != 2) {
        //这个版本只支持P2P通话记录转消息，如果进来的是多人通话，直接不存消息，丢掉。
        return nil;
    }
    NIMMessage *message     = [[NIMMessage alloc] init];
    NSString *messageId     = record.recordId;
    NSString *fromAccount   = record.from;
    NSString *toAccount     = [members[0] isEqualToString:fromAccount] ? members[1] : members[0];
    NSInteger sessionType   = NIMSessionTypeP2P;
    NSString *sessionId     = [NIMModelConverter sessionIdByType:sessionType
                                                     fromAccount:fromAccount
                                                       toAccount:toAccount];
    NIMSession *session     =  [NIMSession session:sessionId
                                              type:sessionType];
    message.from            = fromAccount;
    message.messageId       = messageId;
    message.session         = session;
    message.timestamp       = record.timestamp;
    message.messageType     = NIMMessageTypeNotification;
    message.rawAttachContent= record.attach;
    message.serverID        = record.serverId;
    message.senderName      = record.senderName;
    
    //解析Attachment并保存数据
    id<NIMMessageObject_Private> attach = [NIMModelConverter messaegObjectWithType:message.messageType
                                                                           content:message.rawAttachContent];
    message.messageObject   = attach;
    return message;
}

#pragma mark - misc
+ (NSString *)sessionIdByType:(NSInteger)sessionType
                  fromAccount:(NSString *)from
                    toAccount:(NSString *)to
{
    NSString *myUserID      = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    NSString *sessionId     = to;
    switch (sessionType) {
        case NIMSessionTypeP2P:
        {
            if (myUserID && from && [myUserID isEqualToString:from])
            {
                sessionId = to;
            }
            else
            {
                sessionId = from;
            }
        }
            break;
        case NIMSessionTypeTeam:
            sessionId = to;
            break;
        case NIMSessionTypeChatroom:
            sessionId = to;
            break;
        default:
            NIMAssert();
            break;
    }
    return sessionId;
}
@end
