//
//  NIMConversationManager.m
//  NIMLib
//
//  Created by amao on 2/4/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMConversationManager.h"
#import "bind.h"
#import "NIMMessage_Private.h"
#import "NIMSession_Private.h"
#import "NIMStorageManager.h"
#import "NIMRecentSessionManager.h"
#import "NIMRecentSession_Private.h"
#import "NIMDispatch.h"
#import "session_protocol.h"
#import "team_protocol.h"
#import "sync_protocol.h"
#import "NIMModelConverter.h"
#import "auth_protocol.h"
#import "chatroom_protocol.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMMessageSearchOption_Private.h"
#import "NIMCustomObject_Private.h"
#import "NIMCoreCenter.h"
#import "NIMDelegateCenter.h"
#import "NIMFetchMsgCallback.h"
#import "NIMRemoveSessionCallback.h"
#import "NIMDatabaseModel.h"
#import "NIMMessageSearchOptionValidator.h"
#import "NIMChatroomHistoryMessageCallback.h"
#import "NIMSessionValidator.h"
#import "NIMArrayValidator.h"
#import "NIMMessageValidator.h"
#import "NIMRecentSessionValidator.h"
#import "NIMMessageHistorySearchOptionValidator.h"



@interface NIMConversationManager ()
@property (nonatomic,strong)    NIMStorageManager           *storageManager;
@property (nonatomic,strong)    NIMRecentSessionManager     *recentManager;
@end

@implementation NIMConversationManager
- (instancetype)init
{
    if (self = [super init])
    {
        _storageManager = [[NIMStorageManager alloc] init];
        _recentManager = [[NIMRecentSessionManager alloc] init];
        
    }
    return self;
}

#pragma mark - SDK对外接口

- (void)deleteMessage:(NIMMessage*)message
{
    NIMSession *session = [message isKindOfClass:[NIMMessage class]] ? message.session : nil;
    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMMessageValidator validator:message],
                                                              [NIMSessionValidator validator:session]]];
    
    if (![validator isValid]){
        NIMLogErr(@"error delete message: invalid message");
        return;
    }
    
    [_storageManager deleteMessage:message];
    [_recentManager  deleteMessage:message];
}


- (void)deleteAllmessagesInSession:(NIMSession*)session
               removeRecentSession:(BOOL)removeRecentSession
{
    if (![[NIMSessionValidator validator:session] isValid]) {
        NIMLogErr(@"error delete message: invalid session");
        return;
    }

    [_storageManager deleteAllmessagesInSession:session];
    [_recentManager deleteAllmessagesInSession:session
                           removeRecentSession:removeRecentSession];
    nim_main_async_safe(^{
        [[NIMDelegateCenter conversationDelegate] messagesDeletedInSession:session];
    });
}


- (void)deleteAllMessages:(BOOL)removeSessions
{
    [_storageManager deleteAllmessages];
    [_recentManager deleteAllmessages:removeSessions];
    nim_main_async_safe(^{
        [[NIMDelegateCenter conversationDelegate] allMessagesDeleted];
    });
}



- (void)deleteRecentSession:(NIMRecentSession*)recentSession{
    if (![[NIMRecentSessionValidator validator:recentSession] isValid]) {
        NIMLogErr(@"error delete recentSession: invalid session");
        return;
    }
    nim_main_async_safe(^{
        [_recentManager main_removeRecentSession:recentSession];
    });
}

- (void)markAllMessagesReadInSession:(NIMSession*)session
{
    if (![[NIMSessionValidator validator:session] isValid]) {
        NIMLogErr(@"error delete message: invalid session");
        return;
    }
    nim_main_async_safe(^{
        NIMRecentSession *recent = _recentManager.sessions[session];
        if (recent.unreadCount) {
            [_storageManager markAllMessagesReadInSession:session];
            [_recentManager main_cleanRecentSession:session];
        }
    });
}

- (void)updateMessage:(NIMMessage *)message
           forSession:(NIMSession *)session
           completion:(NIMUpdateMessageBlock)completion
{

    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMMessageValidator validator:message],
                                                              [NIMSessionValidator validator:session]]];
    BOOL valid = [validator isValid] && message.serialID > 0;
    
    if (!valid)
    {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }

    
    NIMMessageUpdateInfo *info = [NIMMessageUpdateInfo updateInfoByMessage:message];
    [_storageManager updateMessage:info
                        forSession:session
                        completion:^(NSError *error) {
                            if (error == nil) {
                                [_recentManager main_updateRecentSession:message];
                            }
                            
                            if (completion) {
                                completion(error);
                            }
                        }];
}

- (void)saveMessage:(NIMMessage *)message
         forSession:(NIMSession *)session
         completion:(NIMUpdateMessageBlock)completion
{
    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMMessageValidator validator:message],
                                                              [NIMSessionValidator validator:session]]];
    BOOL valid = [validator isValid];
    if (valid)
    {
        message.session = session;
        valid = [self isSupportedMessageForSaving:message];
    }
    if (!valid)
    {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    NSString *currentUserID = [[NIMCoreCenter sharedCenter] currentUserID];
    NIMSession *mySession  = [NIMSession session:currentUserID
                                          type:NIMSessionTypeP2P];
    
    //没有消息发送方和接收方是自己的两种情况下都设置 消息发送方为自己
    if (!message.from || [message.session isEqual:mySession])
    {
        message.from = currentUserID;
    }
    
    //设置消息已发送或者接受状态
    if ([message.from isEqualToString:currentUserID]) {
        message.isDeliveried = YES;
    }
    else{
        message.isReceivedMsg = YES;
    }

    [_storageManager saveMessage:message
                      completion:^(NSError *error) {
                          if (error == nil) {
                              
                              NIMRecentSession *recentSession = [[NIMRecentSession alloc] init];
                              recentSession.session = session;
                              recentSession.lastMessage = message;
                              recentSession.unreadCount = [message shouldCountUnread] ? 1 : 0;
                              
                              [_recentManager main_addRecentSession:recentSession];
                              [[NIMDelegateCenter chatDelegate] onRecvMessages:@[message]];
                          }
                          
                          if (completion) {
                              completion(error);
                          }
                      }];
}



- (NSArray*)messagesInSession:(NIMSession*)session
                      message:(NIMMessage*)message
                        limit:(NSInteger)limit
{
    if (![[NIMSessionValidator validator:session] isValid]) {
        NIMLogErr(@"error get message: invalid session");
        return nil;
    }
    if (message && ![[NIMMessageValidator validator:message] isValid]) {
        NIMLogErr(@"error delete message: invalid message");
        return nil;
    }
    return [_storageManager messagesInSession:session
                                      message:message
                                        limit:limit];
}

- (NSArray *)messagesInSession:(NIMSession *)session
                    messageIds:(NSArray *)messageIds
{
    if (![[NIMArrayValidator validator:messageIds] allObjectsAreKindOf:[NSString class]] ||
        !messageIds.count) {
        NIMLogErr(@"error message by ids : invalid message ids");
        return nil;
    }
    else if (![[NIMSessionValidator validator:session] isValid]) {
        NIMLogErr(@"error message by ids : invalid session");
        return nil;
    }
    else {
        return [_storageManager messagesInSession:session
                                       messageIds:messageIds];
    }
}

- (void)fetchMessageHistory:(NIMSession *)session
                     option:(NIMHistoryMessageSearchOption *)option
                     result:(NIMFetchMessageHistoryBlock)block
{
    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMSessionValidator validator:session],
                                                 [NIMMessageHistorySearchOptionValidator validator:option]]];
    if (![validator isValid])
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    [self doFetchMessageHistory:session option:option result:block];
}

- (void)doFetchMessageHistory:(NIMSession *)session
                       option:(NIMHistoryMessageSearchOption *)option
                       result:(NIMFetchMessageHistoryBlock)block{
    
    NIMFetchMsgCallback *param = [[NIMFetchMsgCallback alloc] init];
    param.fetchBlock     = block;
    param.sync           = option.sync;
    param.session        = session;
    
    
    nimbiz::SessionHistoryMsgReqeustParam requestParam;
    requestParam.uid_ = UTF8(session.sessionId);
    requestParam.from_time_ = NIMTimeDoubleToLong(option.startTime);
    requestParam.end_time_  = NIMTimeDoubleToLong(option.endTime);
    requestParam.end_msg_id = UTF8(option.currentMessage.serverID);
    requestParam.reverse_   = (BOOL)option.order;
    requestParam.limit_     = (int32_t)option.limit;
    
    int32_t taskId = 0;
    if (session.sessionType == NIMSessionTypeP2P) {
        nimbiz::ISessionService *service = (nimbiz::ISessionService*)GetServiceFromCore(nimbiz::SVID_NIM_SESSION);
        taskId = service->Invoke_HistoryMsg(requestParam,nimbiz::GetNIMCallback());
    }else if (session.sessionType == NIMSessionTypeTeam){
        nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
        taskId = service->Invoke_HistoryMsg(requestParam,nimbiz::GetNIMCallback());
    }else{
        NIMAssert();
        return;
    }
    
    [[NIMCallbackManager sharedManager] setCallback:param
                                            forTask:taskId];
}

- (void)searchMessages:(NIMSession *)session
                option:(NIMMessageSearchOption *)option
                result:(NIMSearchMessageBlock)block
{
    
    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMSessionValidator validator:session],
                                                              [NIMMessageSearchOptionValidator validator:option]]];
    
    if (!validator.isValid)
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    [_storageManager searchMessages:session
                             option:option
                             result:block];
}

- (void)deleteRemoteSessions:(NSArray *)sessions
                  completion:(NIMRemoveRemoteSessionBlock)block
{
    BOOL valid = [[NIMArrayValidator validator:sessions] allObjectsAreKindOf:[NIMSession class]];
    if(!valid)
    {
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }

    nimbiz::ISessionService *service = (nimbiz::ISessionService *)GetServiceFromCore(nimbiz::SVID_NIM_SESSION);
    if (service)
    {
        std::list<nimbiz::UTF8String> sessionKeys;
        for (NIMSession *session in sessions) {
            sessionKeys.push_back(UTF8([session remoteSessionKey]));
        }
        
        NSInteger taskId = service->Invoke_DeleteSession(sessionKeys, nimbiz::GetNIMCallback());
        NIMRemoveSessionCallback *param = [NIMRemoveSessionCallback new];
        param.block = block;
        [[NIMCallbackManager sharedManager] setCallback:param
                                                forTask:taskId];
    }

}



- (NSInteger)allUnreadCount{
    return [_recentManager allUnreadCount];
}

- (NSArray*)allRecentSessions{
    return [_recentManager allRecentSessions];
}


- (void)addDelegate:(id<NIMConversationManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeConversation];
}

- (void)removeDelegate:(id<NIMConversationManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeConversation];
}


#pragma mark - 内部使用接口
- (NIMSessionSaveResult*)saveMessages:(NSArray*)messages
{
    return [_storageManager saveMessages:messages];
}

- (void)updateMessage:(NIMMessage *)message
    includeAttachment:(BOOL)attachment
{
    [_storageManager updateMessage:message
                 includeAttachment:attachment];
}

- (BOOL)isMessageReceived:(NSString *)messageId
               forSession:(NIMSession *)session
{
    BOOL received =  [_storageManager isMessageReceived:messageId
                                             forSession:session];
    if (received)
    {
        NIMLogWar(@"message id %@ for %@ has been received",messageId,session);
    }
    return received;
}


- (void)addRecentSession:(NIMRecentSession *)session{
    nim_main_async_safe(^{
       [_recentManager main_addRecentSession:session];
    });
}

- (void)cleanRecentSession:(NIMSession *)session{
    nim_main_async_safe(^{
        [_recentManager main_cleanRecentSession:session];
    });
}

- (void)updateRecentSession:(NIMMessage *)message{
    nim_main_async_safe(^{
        [_recentManager main_updateRecentSession:message];
    });
}

- (NSDictionary *)recentSessions{
    return _recentManager.sessions;
}

- (BOOL)isSupportedMessageForSaving:(NIMMessage *)message
{
    NIMMessageType messageType = [message messageType];
    BOOL supportedType =  messageType == NIMMessageTypeText ||
                          messageType == NIMMessageTypeTip ||
                          messageType == NIMMessageTypeCustom;
    BOOL invalidParam = NO;
    
    //个人会话发起者只能是 sessionId或者当前用户Id
    if (message.session.sessionType == NIMSessionTypeP2P)
    {
        NSString *from = message.from;
        NSString *sessionId = message.session.sessionId;
        NSString *currentUserId = [[NIMCoreCenter sharedCenter] currentUserID];
        if (from && ![from isEqualToString:sessionId] && ![from isEqualToString:currentUserId])
        {
            invalidParam = YES;
        }
    }
    
    return supportedType && !invalidParam;
}

- (void)updateRoamMsgTimetag:(int64_t)timetag
{
    nimbiz::ISyncService *service = (nimbiz::ISyncService *)GetServiceFromCore(nimbiz::SVID_NIM_SYNC);
    if (service)
    {
        service->SetSyncTimetag(nimbiz::NIMSyncTagRoamMsg, timetag);
    }
}

@end



