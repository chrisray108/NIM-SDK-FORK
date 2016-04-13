//
//  NIMSessionManager.m
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSessionManager.h"
#import "session_protocol.h"
#import "chatroom_protocol.h"
#import "NIMMessage_Private.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMConversationManager.h"
#import "NIMMessageDownloadParam.h"
#import "NIMChatManagerProtocol.h"
#import "NIMDispatch.h"
#import "NIMSDK_Private.h"
#import "NIMRecentSessionManager.h"
#import "ios_util.h"
#import "NIMDelegateCenter.h"
#import "user_protocol.h"
#import "NIMProtocolUtil.h"
#import "NIMMessageSetting_Private.h"
#import "NIMModelConverter.h"

@interface NIMMessageInfo : NSObject
@property (nonatomic,strong)    NIMMessage  *message;
@property (nonatomic,assign)    CGFloat     progress;
@end

@implementation NIMMessageInfo
@end

@interface NIMSessionManager ()
@property (nonatomic,strong)    NSMutableDictionary *messages;
@end



@implementation NIMSessionManager
- (instancetype)init
{
    if (self = [super init])
    {
        _messages = [NSMutableDictionary dictionary];
        
    }
    return self;
}

- (void)sendMessage:(NIMMessage *)message
{
    dispatch_block_t block = ^()
    {
        if ([self storeMessage:message])
        {
            [[NIMDelegateCenter chatDelegate] willSendMessage:message];
    
            if ([message needUploadAttachment])
            {
                [self uploadAttachment:message];
            }
            else
            {
                [self sendMessageByApp:message];
            }
        }
    };
    nim_main_async_safe(block);
}


- (void)fetchMessageAttachments:(NSArray *)messages
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^()
    {
        for (NIMMessage *message in messages)
        {
            if ([weakSelf storeMessage:message])
            {
                [message setTryDownloadOnce:YES];
                
                id<NIMMessageObject_Private> messageObject =(id<NIMMessageObject_Private>)[message messageObject];
                if ([messageObject respondsToSelector:@selector(fileParamForDownload)])
                {
                    [weakSelf fetchMessageAttachment:message
                                            progress:0];
                    
                    NIMMessageDownloadParam * param = [messageObject fileParamForDownload];
                    id<NIMResourceManager> resManager = [[NIMSDK sharedSDK] resourceManager];
                    [resManager  download:param.url
                                 filepath:param.destinationPath
                                 progress:^(CGFloat progress) {
                                     [weakSelf fetchMessageAttachment:message
                                                             progress:progress];
                                 } completion:^(NSError *error) {
                                     [weakSelf fetchMessageAttachment:message
                                                 didCompleteWithError:error];
                                 }];
                }
            }

        }
    };
    nim_main_sync_safe(block);//需要在UI线程同步进行,否则UI调用当前方法后立马进行状态判断将有问题
}



- (BOOL)messageInTransport:(NIMMessage *)message
{
    NSString *messageId = message.messageId;
    __block BOOL result = NO;
    nim_main_sync_safe(^{
        result = messageId ? [_messages objectForKey:messageId] != nil : NO;
    });
    return result;
}


- (CGFloat)messageTransportProgress:(NIMMessage *)message
{
    __block NIMMessageInfo *info = nil;
    NSString *messageId = message.messageId;
    if (messageId)
    {
        nim_main_sync_safe(^{
            info = [_messages objectForKey:messageId];
        });
    }
    return [info progress];
}

- (void)onMsgAck:(NSString *)messageId
            info:(NSDictionary *)userInfo
{
    NIMMessageInfo *info = [_messages objectForKey:messageId];
    if (info)
    {
        [_messages removeObjectForKey:messageId];
        NSInteger code = [[userInfo objectForKey:NIMACKCode] integerValue];
        NSError *error = nil;
        NIMMessage *message = info.message;
        if (code == nimbiz::NIMResSuccess)
        {
            NSString *serverID = [userInfo objectForKey:NIMACKServerID];
            long long timetag   = [[userInfo objectForKey:NIMACKTimetag] longLongValue];
            
            message.serverID    = serverID;
            message.timestamp   = NIMTimeLongToDouble(timetag);
            message.isDeliveried= YES;
            
            [[NIMConversationManager sharedManager] updateMessage:message
                                                includeAttachment:NO];
            [[NIMConversationManager sharedManager] updateRecentSession:message];
        }
        else
        {
            error = NIMRemoteError(code);
        }
        [[NIMDelegateCenter chatDelegate] sendMessage:message
                                 didCompleteWithError:error];
    }
}

- (void)onRoomMsgAck:(NSString *)roomId
           messageId:(NSString *)messageId
                info:(NSDictionary *)userInfo
{
    NIMMessageInfo *info = [_messages objectForKey:messageId];
    if (info)
    {
        [_messages removeObjectForKey:messageId];
        NSInteger code = [[userInfo objectForKey:NIMACKCode] integerValue];
        NSError *error = NIMRemoteError(code);
        NIMMessage *message  = info.message;
        if (code == nimbiz::NIMResSuccess) {
            message.isDeliveried = YES;
        }
        [[NIMDelegateCenter chatDelegate] sendMessage:message
                                 didCompleteWithError:error];
    }
}

#pragma mark - Store and remove message
- (BOOL)storeMessage:(NIMMessage *)message
{
    if ([self messageInTransport:message])
    {
        NIMLogWar(@"message already in transport %@",message);
        return NO;
    }
    NIMMessageInfo *info = [[NIMMessageInfo alloc] init];
    info.message = message;
    [_messages setObject:info
                  forKey:message.messageId];

    return YES;
}

- (void)removeMessage:(NIMMessage *)message
{
    NSString *messageId = message.messageId;
    if ([_messages objectForKey:messageId])
    {
        [_messages removeObjectForKey:messageId];
    }
}

#pragma mark - 发送消息 delegate
- (void)sendMessage:(NIMMessage *)message
           progress:(CGFloat)progress
{
    CGFloat messageProgress = MIN(0.99, progress);
    [[NIMDelegateCenter chatDelegate] sendMessage:message
                                         progress:progress];

    NSString *messageId = message.messageId;
    NIMMessageInfo *info = [_messages objectForKey:messageId];
    [info setProgress:messageProgress];
}

- (void)fireUploadError:(NSError *)error
             forMessage:(NIMMessage *)message
{
    [self removeMessage:message];
    [[NIMDelegateCenter chatDelegate] sendMessage:message
                             didCompleteWithError:error];
}

- (void)fireUploadSuccess:(NSString *)urlString
               forMessage:(NIMMessage *)message
{
    id<NIMMessageObject_Private> messageObject = (id<NIMMessageObject_Private>)message.messageObject;
    [messageObject setUploadURL:urlString];
    
    if ([message shouldPersist])
    {
        [[NIMConversationManager sharedManager] updateMessage:message
                                            includeAttachment:YES];

    }
    [self sendMessageByApp:message];
}


#pragma mark - 收取消息附件 delegate
- (void)fetchMessageAttachment:(NIMMessage *)message
                      progress:(CGFloat)progress
{
    CGFloat messageProgress = MIN(1.00, progress);
    [[NIMDelegateCenter chatDelegate] fetchMessageAttachment:message
                                                    progress:progress];
    NSString *messageId = message.messageId;
    NIMMessageInfo *info = [_messages objectForKey:messageId];
    [info setProgress:messageProgress];
}

- (void)fetchMessageAttachment:(NIMMessage *)message
          didCompleteWithError:(NSError *)error;
{
    [self removeMessage:message];
    [[NIMDelegateCenter chatDelegate] fetchMessageAttachment:message
                                        didCompleteWithError:error];
}


#pragma mark - 发送消息到APP
- (void)sendMessageByApp:(NIMMessage *)message
{
    if (message.session.sessionType == NIMSessionTypeChatroom)
    {
        [self sendChatroomMessage:message];
    }
    else
    {
        [self sendAppMessage:message];
    }
}

- (void)sendAppMessage:(NIMMessage *)message
{
    nimbiz::ISessionService *service = (nimbiz::ISessionService *)GetServiceFromCore(nimbiz::SVID_NIM_SESSION);
    if (service)
    {
        nimbiz::Property messageProperty = [NIMModelConverter imPropertyFromMessage:message];
        service->Invoke_SendMsg(messageProperty);
    }
}


- (void)sendChatroomMessage:(NIMMessage *)message
{
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service)
    {
        nimbiz::Property messageProperty = [NIMModelConverter chatroomPropertyFromMessage:message];
        service->Invoke_Say(messageProperty);
    }
}

#pragma mark - 上传资源文件
- (void)uploadAttachment:(NIMMessage *)message
{
    id<NIMMessageObject_Private> messageObject =(id<NIMMessageObject_Private>)[message messageObject];
    if ([messageObject respondsToSelector:@selector(filepathForUpload)])
    {
        NSString *filepath = [messageObject filepathForUpload];
        __weak typeof(self) weakSelf = self;
        id<NIMResourceManager> resManager = [[NIMSDK sharedSDK] resourceManager];
        
        [resManager  upload:filepath
                   progress:^(CGFloat progress){
                       [weakSelf sendMessage:message
                                    progress:progress];
                   }
                 completion:^(NSString *urlString, NSError *error){
                       if (urlString && error == nil)
                       {
                           [weakSelf fireUploadSuccess:urlString
                                            forMessage:message];
                       }
                       else
                       {
                           [weakSelf fireUploadError:error
                                          forMessage:message];
                       }
                   }];
    }
    else
    {
        NIMAssert();
        NSError *error = NIMLocalError(NIMLocalErrorCodeInvalidParam);
        [self fireUploadError:error
                   forMessage:message];
    }
}


@end
