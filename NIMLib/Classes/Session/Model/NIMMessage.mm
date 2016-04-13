//
//  NIMMessage.m
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMMessage_Private.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMImageObject_Private.h"
#import "NIMLocationObject_Private.h"
#import "NIMVideoObject_Private.h"
#import "NIMAudioObject_Private.h"
#import "NIMCustomObject_Private.h"
#import "NIMNotificationObject_Private.h"
#import "NIMChatManager.h"
#import "NIMUtil.h"
#import "NIMConversationManager.h"
#import "NIMMessageDownloadParam.h"
#import "NIMGlobalDefs.h"
#import "NIMTeamManager.h"
#import "NIMInfoManager.h"
#import "NIMSDK_Private.h"
#import "NSObject+NIM.h"

@implementation NIMMessage

@synthesize status        = _status;
@synthesize session       = _session;
@synthesize messageType   = _messageType;
@synthesize isPlayed      = _isPlayed;

- (instancetype)init{
    self = [super init];
    if (self) {
        _messageId = [NIMUtil uuid];
        _timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}


- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NIMMessage class]]) {
        return NO;
    }
    NIMMessage *message = object;
    return [message.messageId isEqualToString:self.messageId];
}

- (NSString*)description{
    NSMutableString *descriptionString = [NSMutableString stringWithString:@"****** "];
    [descriptionString appendFormat:@"NIMMessage %@ Info", [super description]];
    [descriptionString appendString:@" ******\n"];
    
    [descriptionString appendFormat:@" serial        : %zd\n", self.serialID];
    [descriptionString appendFormat:@" messageId     : %@\n",  self.messageId];
    [descriptionString appendFormat:@" messageType   : %zd\n", self.messageType];
    [descriptionString appendFormat:@" sessionId     : %@\n",  self.session.sessionId];
    [descriptionString appendFormat:@" sessionType   : %zd\n", self.session.sessionType];
    [descriptionString appendFormat:@" time          : %.2f\n",self.timestamp];
    [descriptionString appendFormat:@" text          : %@\n",  self.text];
    [descriptionString appendFormat:@" deliveryState : %zd\n", self.deliveryState];
    [descriptionString appendFormat:@" attachmentDownloadState : %zd\n",  self.attachmentDownloadState];
    [descriptionString appendFormat:@" remote read   : %zd\n",  self.isRemoteRead];
    [descriptionString appendFormat:@" received msg  : %zd\n",  self.isReceivedMsg];
    [descriptionString appendFormat:@" outgoing msg  : %zd\n",  self.isOutgoingMsg];
    [descriptionString appendFormat:@" sub status    : %zd\n",  self.subStatus];
    [descriptionString appendFormat:@" status        : %zd\n",  self.status];
    [descriptionString appendFormat:@" setting       : %@\n",self.setting];
    [descriptionString appendFormat:@" push content  : %@\n",self.apnsContent];
    [descriptionString appendFormat:@" push payload  : %@\n",self.apnsPayload];
    [descriptionString appendFormat:@" remote ext    : %@\n",self.remoteExt];
    [descriptionString appendFormat:@" local ext     : %@\n",self.localExt];

    [descriptionString appendString:@"****** NIMMessage End ******\n"];
    return descriptionString;
}

- (NSError*)prepareForSend{
    id<NIMMessageObject_Private> messageObject = (id<NIMMessageObject_Private>)self.messageObject;
    if ([messageObject respondsToSelector:@selector(prepareForSend)]) {
        return [messageObject prepareForSend];
    }
    return nil;
}

- (NSError*)prepareForReSend{
    if (!self.session) {
        return NIMLocalError(NIMLocalErrorCodeInvalidParam);
    }
    id<NIMMessageObject_Private> messageObject = (id<NIMMessageObject_Private>)self.messageObject;
    if ([messageObject respondsToSelector:@selector(filepathForUpload)]) {
        NSString * filepath = [messageObject filepathForUpload];
        if (filepath && ![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
            return NIMLocalError(NIMLocalErrorCodeIOError);
        }
    }
    return nil;
}

- (NSError*)prepareForDownLoad{
    id<NIMMessageObject_Private> messageObject = (id<NIMMessageObject_Private>)self.messageObject;
    if ([messageObject respondsToSelector:@selector(prepareForDownLoad)]) {
        NSError *error = [messageObject prepareForDownLoad];
        if (error)
        {
            if ([messageObject isKindOfClass:[NIMCustomObject class]] &&
                ![(NIMCustomObject *)messageObject needsDownloadAttachment])
            {
                //do nothing...
            }
            else
            {
                NIMLogErr(@"prepare for download error %@ for messageobject %@",error,messageObject);
            }
            
        }
        return error;
    }
    return NIMLocalError(NIMLocalErrorCodeInvalidUrl);
}

- (BOOL)needUploadAttachment{
    BOOL needUpload = NO;
    id<NIMMessageObject_Private> messageObject = (id<NIMMessageObject_Private>)self.messageObject;
    if ([messageObject respondsToSelector:@selector(needUpload)]) {
        needUpload = [messageObject needUpload];
    }
    return needUpload && [messageObject respondsToSelector:@selector(filepathForUpload)];
}

#pragma mark - misc
- (void)setMessageObject:(id<NIMMessageObject>)messageObject{
    if (messageObject) {
        id<NIMMessageObject_Private> obj = (id<NIMMessageObject_Private>)messageObject;
        _messageType  = obj.type;
    }
    _messageObject         = messageObject;
    _messageObject.message = self;
}


- (NIMMessageDeliveryState)deliveryState{

    if (self.isDeliveried) {
        return NIMMessageDeliveryStateDeliveried;
    }
    if ([[NIMChatManager sharedManager] messageInTransport:self]) {
        return NIMMessageDeliveryStateDelivering;
    }
    return NIMMessageDeliveryStateFailed;
}

- (NIMMessageAttachmentDownloadState)attachmentDownloadState
{
    NSString *filepath = nil;
    id<NIMMessageObject_Private> messageObject = (id<NIMMessageObject_Private>)self.messageObject;
    if ([messageObject respondsToSelector:@selector(fileParamForDownload)]) {
        NIMMessageDownloadParam *param = [messageObject fileParamForDownload];
        filepath = param.destinationPath;
    }
    if ([filepath length])
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
        {
            return NIMMessageAttachmentDownloadStateDownloaded;
        }
        if ([[NIMChatManager sharedManager] messageInTransport:self])
        {
            return NIMMessageAttachmentDownloadStateDownloading;
        }
        if ([self tryDownloadOnce])
        {
            return NIMMessageAttachmentDownloadStateFailed;
        }
        else
        {
            return NIMMessageAttachmentDownloadStateNeedDownload;
        }
    }
    else
    {
        //无附件时直接返回下载成功
        return NIMMessageAttachmentDownloadStateDownloaded;
    }
}

- (BOOL)isOutgoingMsg
{
    NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    if (self.session.sessionType == NIMSessionTypeP2P && [self.session.sessionId isEqualToString:currentUserID]) {
        return  !self.isReceivedMsg;
    }else{
        return  [self.from isEqualToString:currentUserID];
    }
}


- (BOOL)isDeliveried{
    return (self.subStatus & NIMMessageSubStatusIsDeliveried) != 0;
}

- (BOOL)isDeleted{
    return self.status == NIMMessageStatusDeleted;
}

- (BOOL)isPlayed{
    return (self.subStatus & NIMMessageSubStatusIsPlayed) != 0;
}


- (BOOL)isReceivedMsg{
    return (self.subStatus & NIMMessageSubStatusIsReceivedMsg) != 0;
}

- (BOOL)tryDownloadOnce{
    return (self.subStatus & NIMMessageSubStatusTryDownlaoded) != 0;
}

- (BOOL)isRemoteRead
{
    BOOL read = NO;
    if ([self isOutgoingMsg] && self.session.sessionType == NIMSessionTypeP2P)
    {
        NSString *sessionId = self.session.sessionId;
        BOOL messageInServer = self.isReceivedMsg || (!self.isReceivedMsg && self.isDeliveried);
        read = messageInServer && self.timestamp <= [[NIMChatManager sharedManager] receiptTimestamp:sessionId];
    }
    return read;
}



- (void)setIsDeliveried:(BOOL)isDeliveried{
    NIMMessageSubStatus status = [self status:NIMMessageSubStatusIsDeliveried
                                         flag:isDeliveried];
    self.subStatus = status;
}

- (void)setIsPlayed:(BOOL)isPlayed{
    NIMMessageSubStatus status = [self status:NIMMessageSubStatusIsPlayed
                                         flag:isPlayed];
    [self updateSubStatusAndAutoRefresh:status];
}

- (void)setIsReceivedMsg:(BOOL)isReceivedMsg{
    NIMMessageSubStatus status = [self status:NIMMessageSubStatusIsReceivedMsg
                                         flag:isReceivedMsg];
    self.subStatus = status;
}

- (void)setTryDownloadOnce:(BOOL)tryDownloadOnce
{
    NIMMessageSubStatus status = [self status:NIMMessageSubStatusTryDownlaoded
                                         flag:tryDownloadOnce];
    [self updateSubStatusAndAutoRefresh:status];
}


- (NIMMessageSubStatus)status:(NIMMessageSubStatus)status
                         flag:(BOOL)flag
{
    return flag ? (self.subStatus | status) : (self.subStatus & ~status);
}


- (void)updateSubStatusAndAutoRefresh:(NIMMessageSubStatus)subStatus
{
    if (_subStatus != subStatus)
    {
        _subStatus = subStatus;
        
        if ([self shouldPersist])
        {
            [[NIMConversationManager sharedManager] updateMessage:self
                                                includeAttachment:NO];
        }
    }
}

- (NSString *)senderName
{
    if (_session.sessionType == NIMSessionTypeChatroom)
    {
        return [[_messageExt nim_asObject:[NIMMessageChatroomExtension class]] roomNickname];
    }
    else
    {
        return [[NIMInfoManager sharedManager] senderNameByMessage:self];
    }
}


#pragma mark - 内部方法
- (void)saveDataAfterReceiving:(BOOL)onlineMessage
{
    //保存SenderName信息
    [[NIMInfoManager sharedManager] saveSenderName:_senderName
                                        forMessage:self];
    
    //额外的保存工作
    if ([(id<NIMMessageObject_Private>)self.messageObject respondsToSelector:@selector(saveDataAfterReceiving:)])
    {
        [(id<NIMMessageObject_Private>)self.messageObject saveDataAfterReceiving:onlineMessage];
    }
    
}

- (void)fireNotificationAfterReceiving
{
    if ([(id<NIMMessageObject_Private>)self.messageObject respondsToSelector:@selector(fireNotificationAfterReceiving)])
    {
        [(id<NIMMessageObject_Private>)self.messageObject fireNotificationAfterReceiving];
    }
}

- (BOOL)shouldCountUnread
{
    //一下几种情况不需要计算未读数
    //1.已经被设为已读 (漫游消息)
    //2.一些遵循shouldIgnoreUnread协议的对象,且返回了YES，如部分提示
    //3.如果消息的setting上设置为不需要计入未读
    if (_status == NIMMessageStatusRead)
    {
        return NO;
    }
    
    if ([self.messageObject respondsToSelector:@selector(shouldIgnoreUnread)] &&
        [(id<NIMMessageObject_Private>)self.messageObject shouldIgnoreUnread])
    {
        return NO;
    }
    
    if (self.setting && !self.setting.shouldBeCounted)
    {
        return NO;
    }
    
    
    
    return YES;
}

- (BOOL)shouldPersist
{
    return _session.sessionType != NIMSessionTypeChatroom;
}

@end


