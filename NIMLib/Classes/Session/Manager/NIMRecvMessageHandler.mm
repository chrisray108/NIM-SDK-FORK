//
//  NIMRecvMessageHandler.m
//  NIMLib
//
//  Created by amao on 15/4/17.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMRecvMessageHandler.h"
#import "session_protocol.h"
#import "NIMChatManager.h"
#import "NIMConversationManager.h"
#import "NIMMessage_Private.h"
#import "NIMRecentSession_Private.h"
#import "NIMReplacableMessageValidator.h"
#import "NIMTeamManager_Private.h"
#import "NIMTeamNotificationContent_Private.h"


@interface NIMRecvMessageHandler ()
@property (nonatomic,strong)    NSMutableDictionary *messageDict;
@property (nonatomic,assign)    NSInteger messageState;
@end

@implementation NIMRecvMessageHandler
+ (instancetype)handler:(NSInteger)state
{
    NIMRecvMessageHandler *instance = [[NIMRecvMessageHandler alloc] init];
    instance.messageState = state;
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _messageDict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)recvMessages:(NSArray *)messages
{
    BOOL markAsRead = [self shouldMarkAsRead];
    for (NIMMessage *message in messages)
    {
        if ([self shouldSkipMessage:message])
        {
            NIMLogApp(@"skip message %@ for %@",message.messageId,message.session);
            continue;

        }
        [message saveDataAfterReceiving:[self isOnlineMessages]];
        if (markAsRead)
        {
            message.status = NIMMessageStatusRead;
        }
        [self addMessage:message];
    }
    [self saveAndPostNotifications];
}

- (void)addMessage:(NIMMessage *)message
{
    NIMSession *session = message.session;
    NSMutableArray *messages = [_messageDict objectForKey:session];
    if ([messages isKindOfClass:[NSMutableArray class]])
    {
        [messages addObject:message];
    }
    else
    {
        messages = [NSMutableArray array];
        [messages addObject:message];
        [_messageDict setObject:messages
                        forKey:session];
    }
}

- (void)saveAndPostNotifications
{
    for (NSMutableArray *messages in _messageDict.allValues)
    {
        //排序
        [messages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NIMMessage *)obj1 timestamp] < [(NIMMessage *)obj2 timestamp] ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        //输出log和保存timetag
        [self saveMessageInfo:messages];
        
        //保存信息
        NIMSessionSaveResult *result = [[NIMConversationManager sharedManager] saveMessages:messages];
        
        //只有真正有写入到DB才发起回调,写入DB失败的一般是有收到重复（重发）的消息引起,这种情况下不发起通知
        if (result.savedMessages.count)
        {
            //请求额外数据
            [self requestInfos:result.savedMessages];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                //添加最近会话
                NIMRecentSession *recent = [self recentSessionBySaveResult:result];
                [[NIMConversationManager sharedManager] addRecentSession:recent];
                
                //通知收到消息
                [[NIMChatManager sharedManager] onRecvMessages:result.savedMessages];
                
                //从消息中分理出各种通知回调
                [self fireNotifications:result.savedMessages];
                
            });
        }

    }
}

#pragma mark - 消息操作
- (void)requestInfos:(NSArray *)savedMessages
{
    if ([self isOnlineMessages])
    {
        BOOL shouldRequestTeamInfos = NO;
        NIMMessage *firstMessage = [savedMessages firstObject];
        if ([[firstMessage session] sessionType] == NIMSessionTypeTeam)
        {
            for (NIMMessage *message in savedMessages)
            {
                id messageObject = [message messageObject];
                if ([messageObject isKindOfClass:[NIMNotificationObject class]])
                {
                    NIMNotificationObject *notificationObject = (NIMNotificationObject *)messageObject;
                    if ([[notificationObject content] isKindOfClass:[NIMTeamNotificationContent class]] &&
                        [(NIMTeamNotificationContent *)[notificationObject content] shouldRefreshTList])
                    {
                        shouldRequestTeamInfos = YES;
                        break;
                    }
                }
            }
        }
        
        
        //收到群通知,进行一次tlist的刷新
        if (shouldRequestTeamInfos)
        {
            NSString *teamId = [[firstMessage session] sessionId];
            [[NIMTeamManager sharedManager] requestTeamMembers:teamId];
            NIMLogApp(@"request team members for %@",teamId);
        }
    }
}

- (void)saveMessageInfo:(NSArray *)messages
{
    NIMMessage *firstMessage = [messages firstObject];
    NIMMessage *lastMessage = [messages lastObject];
    
    //如果不是在线消息,输出log
    if (![self isOnlineMessages])
    {
        NIMLogApp(@"sync messages for %@ count %zd from %@ to %@ is roam messages %d",
                  firstMessage.session,[messages count],firstMessage.serverID,lastMessage.serverID,[self isRoamMessages]);
    }
    
    
    NSTimeInterval timetag = MAX(firstMessage.timestamp, lastMessage.timestamp);
    if (timetag)
    {
        [[NIMConversationManager sharedManager] updateRoamMsgTimetag:NIMTimeDoubleToLong(timetag)];
    }
}

- (void)fireNotifications:(NSArray *)savedMessages
{
    if ([self isOnlineMessages])
    {
        for (NIMMessage *notificationMessage in savedMessages)
        {
            [notificationMessage fireNotificationAfterReceiving];
        }
    }
}

- (NIMRecentSession *)recentSessionBySaveResult:(NIMSessionSaveResult *)result
{
    //服务器的消息可能不按顺序过来(如普通离线消息和音视频会话离线消息，音视频的会晚到)，给上层的是按时间序给的，这里保持统一，取时间最大的做lastMessage。
    NIMMessage *message = result.savedMessages.lastObject;
    NIMRecentSession *recent  = [[NIMConversationManager sharedManager].recentSessions objectForKey:message.session];
    
    if (recent.lastMessage.timestamp <= message.timestamp) {
        recent = [NIMRecentSession recentSessionWithMessage:message];
    }else{
        recent = [NIMRecentSession recentSessionWithMessage:recent.lastMessage];
    }
    recent.unreadCount       = result.unreadCount;
    return recent;
}


#pragma mark - 消息状态判断
- (BOOL)shouldSkipMessage:(NIMMessage *)message
{
    //先判断消息是不是已经收过
    BOOL shouldSkip = [[NIMConversationManager sharedManager] isMessageReceived:message.messageId
                                                                     forSession:message.session];
    
    if (shouldSkip)
    {
        if ([[NIMReplacableMessageValidator validator:message] isValid])
        {
            shouldSkip = NO;
        }
    }
    return shouldSkip;
}

- (BOOL)isOnlineMessages
{
    return (_messageState & nimbiz::CBRecvMsgStateOnline) != 0;
}

- (BOOL)isRoamMessages
{
    return (_messageState & nimbiz::CBRecvMsgStateRoam) != 0;
}

- (BOOL)isOLSyncMessages
{
    return (_messageState & nimbiz::CBRecvMsgStateOnlineSync) != 0;
}

- (BOOL)shouldMarkAsRead
{
    return [self isRoamMessages] || [self isOLSyncMessages];
}
@end
