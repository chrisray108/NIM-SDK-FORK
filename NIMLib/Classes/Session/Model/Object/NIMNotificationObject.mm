//
//  NIMNotificationObject.m
//  NIMLib
//
//  Created by amao on 3/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMNotificationObject_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NIMMessage_Private.h"
#import "NIMTeamNotificationContent_Private.h"
#import "NIMNetCallNotificationContent_Private.h"
#import "NIMChatroomNotificationContent_Private.h"
#import "NIMTeamManager.h"

@implementation NIMNotificationObject
@synthesize message = _message;

- (NIMMessageType)type
{
    return NIMMessageTypeNotification;
}

//编码后的数据
- (NSString*)encodeContent
{
    return self.attachContent;
}

//解码
- (void)decodeWithContent:(NSString*)contentString
{
    self.attachContent = contentString;
    NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    if (data)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            NIMNotificationContent *notificationContent = nil;
            if ([self isValidNetCallNotification:dict])
            {
                notificationContent = [[NIMNetCallNotificationContent alloc] init];
            }
            else if ([self isValidTeamNotification:dict])
            {
                notificationContent = [[NIMTeamNotificationContent alloc] init];
            }
            else if ([self isValidChatroomNotification:dict])
            {
                notificationContent = [[NIMChatroomNotificationContent alloc] init];
            }
            
            
            if ([notificationContent decode:dict])
            {
                self.content = notificationContent;
            }
            else
            {
                self.content = [[NIMUnsupportedNotificationContent alloc] init];
                NIMLogErr(@"unsupported notification type %@",dict);
            }
        }
        else
        {
            NIMLogErr(@"decode object content failed %@",contentString);
        }
    }
    else
    {
        NIMLogErr(@"decode object content failed %@",contentString);
    }
    if (self.content == nil)
    {
        self.content = [[NIMUnsupportedNotificationContent alloc] init];
        NIMLogErr(@"invalid content for notifcation %@",contentString);
    }
}


- (NSError *)prepareForSend
{
    //客户端不能发送通知,通知只能由服务器下发
    return NIMLocalError(NIMLocalErrorCodeInvalidParam);
}

- (void)setContent:(NIMNotificationContent *)content
{
    _content = content;
    _content.messageObject = self;
}


- (void)saveDataAfterReceiving:(BOOL)onlineMessage
{
    if (self.notificationType == NIMNotificationTypeTeam)
    {
        [(NIMTeamNotificationContent *)_content saveDataAfterReceiving:onlineMessage];
    }
}

- (void)fireNotificationAfterReceiving
{
    id content = [self content];
    if (self.notificationType == NIMNotificationTypeTeam)
    {
        NSString *teamId = self.message.session.sessionId;
        
        [[NIMTeamManager sharedManager] onGetNotification:content
                                                  forTeam:teamId];
    }
}

- (NIMNotificationType )notificationType
{
    return [_content notificationType];
}


- (BOOL)shouldIgnoreUnread{
    
    switch (self.notificationType)
    {
        case NIMNotificationTypeTeam:
            return YES;
        case NIMNotificationTypeNetCall:
        {
            NIMNetCallNotificationContent *content = (NIMNetCallNotificationContent*)self.content;
            return content.eventType == NIMNetCallEventTypeBill;
        }
        default:
            return NO;
    }
}


#pragma mark - Check Valid

- (BOOL)isValidTeamNotification:(NSDictionary *)jsonBody
{
    BOOL result = NO;
    if ([jsonBody objectForKey:@"id"])
    {
        NSInteger idType = [jsonBody nim_jsonInteger:@"id"];
        result = idType >= NIMTeamOperationTypeInvite &&
        idType <= NIMTeamOperationTypeAcceptInvitation;
    }
    return result;
}


- (BOOL)isValidChatroomNotification:(NSDictionary *)jsonBody
{
    BOOL result = NO;
    if ([jsonBody objectForKey:@"id"])
    {
        NSInteger idType = [jsonBody nim_jsonInteger:@"id"];
        result = idType >= NIMChatroomEventTypeEnter &&
        idType <= NIMChatroomEventTypeKicked;
    }
    return result;
}

- (BOOL)isValidNetCallNotification:(NSDictionary *)jsonBody
{
    if ([jsonBody objectForKey:@"id"])
    {
        NSInteger idType = [jsonBody nim_jsonInteger:@"id"];
        switch (idType) {
            case NIMNetCallEventTypeMiss:
            case NIMNetCallEventTypeBill:
            case NIMNetCallEventTypeNoResponse:
            case NIMNetCallEventTypeReject:
                return YES;
            default:
                return NO;
        }
    }
    return NO;
}

@end




