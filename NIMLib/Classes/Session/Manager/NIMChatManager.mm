//
//  NIMChatManager.m
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMChatManager.h"
#import "session_protocol.h"
#import "NIMSessionManager.h"
#import "NIMMessage_Private.h"
#import "NIMConversationManager.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMCoreCenter.h"
#import "NIMModelConverter.h"
#import "NIMUtil.h"
#import "NIMRecentSession_Private.h"
#import "NIMSystemNotificationManager.h"
#import "NIMSystemNotification_Priviate.h"
#import "NIMDispatch.h"
#import "NIMRecvMessageHandler.h"
#import "NIMDelegateCenter.h"
#import "user_protocol.h"
#import "NIMUserManager.h"
#import "NIMValidator.h"
#import "NIMMessageValidator.h"
#import "NIMSDKConfig_Private.h"
#import "NIMSessionValidator.h"
#import "NIMMessageObjectValidator.h"
#import "NIMMessageReceiptValidator.h"
#import "NIMCallbackManager.h"
#import "NIMMarkSessionReadCallback.h"
#import "NIMMessageReceipt_Private.h"

@interface NIMChatManager ()
@property (nonatomic,strong)    NIMSessionManager       *sessionManager;
@end


@implementation NIMChatManager

- (instancetype)init
{
    if (self = [super init])
    {
        _sessionManager = [[NIMSessionManager alloc] init];
    }
    return self;
}

- (BOOL)sendMessage:(NIMMessage *)message
          toSession:(NIMSession *)session
              error:(NSError **)error
{
    //检查参数 并生成缩略图
    NSError *err = nil;
    id messageObject = [message isKindOfClass:[NIMMessage class]] ? message.messageObject : nil;
    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMMessageValidator validator:message],
                                                              [NIMSessionValidator validator:session],
                                                              [NIMMessageObjectValidator validator:messageObject]]];
    if (![validator isValid])
    {
        err = NIMLocalError(NIMLocalErrorCodeInvalidParam);
    }
    if (err == nil)
    {
        err = [message prepareForSend];
    }
    if (err)
    {
        if (error)
        {
            *error = err;
        }
        return NO;
    }
    
    message.from = [[NIMCoreCenter sharedCenter] currentUserID];
    message.session = session;
    
    
    //写入message
    if ([message shouldPersist])
    {
        [[NIMConversationManager sharedManager] saveMessages:@[message]];
    }
    
    
    //调用SessionManager进行发送
    //保证先有willSendMessage回调，再有addRecent回调
    
    [_sessionManager sendMessage:message];
    
    
    //写入recent
    if ([message shouldPersist])
    {
        NIMRecentSession *recentSession = [NIMRecentSession recentSessionWithMessage:message];
        [[NIMConversationManager sharedManager] addRecentSession:recentSession];
    }
    return YES;
}


- (BOOL)resendMessage:(NIMMessage *)message
                error:(NSError **)error
{
    //检查资源文件是否存在
    NSError *err = nil;
    id messageObject = [message isKindOfClass:[NIMMessage class]] ? message.messageObject : nil;
    NIMSession *session = [message isKindOfClass:[NIMMessage class]] ? message.session : nil;
    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMMessageValidator validator:message],
                                                              [NIMSessionValidator validator:session],
                                                              [NIMMessageObjectValidator validator:messageObject]]];
    if (![validator  isValid])
    {
        err = NIMLocalError(NIMLocalErrorCodeInvalidParam);
    }
    if (err == nil)
    {
        err = [message prepareForReSend];
    }
    if (err)
    {
        if (error)
        {
            *error = err;
        }
        return NO;
    }
    
    if ([message shouldPersist])
    {
        NIMRecentSession *recentSession = [NIMRecentSession recentSessionWithMessage:message];
        [[NIMConversationManager sharedManager] addRecentSession:recentSession];
    }
    [_sessionManager sendMessage:message];
    return YES;
}


- (void)sendMessageReceipt:(NIMMessageReceipt *)receipt
                completion:(NIMSendMessageReceiptBlock)completion
{
    if (![[NIMMessageReceiptValidator validator:receipt] isValid]) {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::ISessionService *service =(nimbiz::ISessionService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_SESSION);
    if (service) {
        
        nimbiz::Property msg;
        msg.put_string(nimbiz::NIMSessionTagToAccount, UTF8(receipt.session.sessionId));
        msg.put_uint64(nimbiz::NIMSessionTagTime, NIMTimeDoubleToLong(receipt.timestamp));
        msg.put_string(nimbiz::NIMSessionTagClientID, UTF8(receipt.messageId));
        
        NIMMarkSessionReadCallback *callback = [NIMMarkSessionReadCallback new];
        callback.block = completion;
        
        NSInteger taskId = (NSInteger)service->Invoke_SendSessionReceipt(msg, nimbiz::GetNIMCallback());
        
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}


- (BOOL)fetchMessageAttachment:(NIMMessage *)message
                         error:(NSError **)error
{
    //检查参数
    NSError *err = nil;
    if (![[NIMMessageValidator validator:message] isValid])
    {
        err = NIMLocalError(NIMLocalErrorCodeInvalidParam);
    }
    if (err == nil)
    {
        err = [message prepareForDownLoad];
    }
    if (err)
    {
        if (error)
        {
            *error = err;
        }
        return NO;
    }
    [_sessionManager fetchMessageAttachments:@[message]];
    return YES;
}

- (void)fetchMessageAttachments:(NSArray *)messages
{
    NSMutableArray *messagesWithAttachment = [[NSMutableArray alloc] init];
    for (NIMMessage *message in messages)
    {
        if ([message prepareForDownLoad] == nil)
        {
            [messagesWithAttachment addObject:message];
        }
    }
    if ([messagesWithAttachment count])
    {
        [_sessionManager fetchMessageAttachments:messagesWithAttachment];
    }
}


- (BOOL)messageInTransport:(NIMMessage *)message
{
    if (![[NIMMessageValidator validator:message] isValid]) {
        return NO;
    }
    return [_sessionManager messageInTransport:message];
}

- (CGFloat)messageTransportProgress:(NIMMessage *)message
{
    if (![[NIMMessageValidator validator:message] isValid]) {
        return 0.0f;
    }
    return [_sessionManager messageTransportProgress:message];
}



#pragma mark - APP 回调
- (void)onMsgAck:(NSString *)messageId
            info:(NSDictionary *)userInfo
{
    [_sessionManager onMsgAck:messageId
                         info:userInfo];
}

- (void)onRoomMsgAck:(NSString *)roomId
           messageId:(NSString *)messageId
                info:(NSDictionary *)info
{
    [_sessionManager onRoomMsgAck:roomId
                        messageId:messageId
                             info:info];
}


- (void)onRecvMessages:(NSArray *)messages
{
    //自动下载附件
    if ([[NIMSDKConfig sharedConfig] fetchAttachmentAutomaticallyAfterReceiving])
    {
        [self fetchMessageAttachments:messages];
    }

    [[NIMDelegateCenter chatDelegate] onRecvMessages:messages];
}

- (NSTimeInterval)receiptTimestamp:(NSString *)userId
{
    uint64_t value = 0;
    nimbiz::ISessionService *service = (nimbiz::ISessionService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_SESSION);
    if (service)
    {
        value = service->GetRecvReceiptTimetag(UTF8(userId));
    }
    return NIMTimeLongToDouble(value);
}

@end

namespace nimbiz
{

#pragma mark - 全局回调函数
void CallbackSendMsg(struct IAsynCallbackParam *msgParam)
{
    @autoreleasepool {
        CBSendMsgParam *param = (CBSendMsgParam *)msgParam;
        NSInteger code      = (NSInteger)param->code_;
        NSString *messageId = NSUTF8(param->client_id_);
        NSString *serverID  = NSUTF8(param->cb_msg_.get_string(nimbiz::NIMSessionTagServerID));
        uint64_t timetag   =  param->cb_msg_.get_uint64(nimbiz::NIMSessionTagTime);
        
        NSDictionary *info = @{NIMACKCode       : @(code),
                               NIMACKTimetag    : @(timetag),
                               NIMACKServerID   : serverID,
                               };
        
        NIMLogApp(@"on msg ack %@ \n %@",messageId,info);
        
        [[NIMConversationManager sharedManager] updateRoamMsgTimetag:timetag];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMChatManager sharedManager] onMsgAck:messageId
                                                info:info];
        });
    }
}

void CallbackRecvMsgs(struct IAsynCallbackParam *msgParam)
{
    @autoreleasepool
    {
        CBRecvMsgsParam *param = (CBRecvMsgsParam *)msgParam;
        NSInteger state = (NSInteger)param->msg_state_;
        nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
        
        
        
        NSMutableArray *messages = [NSMutableArray array];
        for (size_t i = 0; i < param->msgs_.size(); i++) {
            nimbiz::Property &messageProperty = param->msgs_[i];
            
            //检查当前消息info
            if (service)
            {
                service->CheckUserInfo(messageProperty);
            }
            
            NIMMessage *message = [NIMModelConverter imMessageFromProperty:messageProperty];
            [messages addObject:message];
        }
        NIMRecvMessageHandler *handler = [NIMRecvMessageHandler handler:state];
        [handler recvMessages:messages];
    }
}
    
    
void    CallbackRecvReceipt(struct IAsynCallbackParam *msgParam)
{
    @autoreleasepool {
        CBRecvReceiptParam *param = (CBRecvReceiptParam *)msgParam;
        NSString *sessionId = NSUTF8(param->uid_);
        NSTimeInterval timetag = NIMTimeLongToDouble(param->timetag_);
        NIMSession *session = [NIMSession session:sessionId type:NIMSessionTypeP2P];
        NIMMessageReceipt *receipt = [[NIMMessageReceipt alloc] init];
        receipt.session = session;
        receipt.timestamp = timetag;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMDelegateCenter chatDelegate] onRecvMessageReceipt:receipt];
        });
        
    }
}
}
