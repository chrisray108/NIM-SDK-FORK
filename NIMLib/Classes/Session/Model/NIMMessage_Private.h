//
//  NIMMessage_Private.h
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMMessage.h"
@class NIMMessageChatroomExtension;

typedef NS_ENUM(NSInteger, NIMMessageStatus) {
    NIMMessageStatusNone        =   0,      //消息初始状态
    NIMMessageStatusRead        =   1,      //已读
    NIMMessageStatusDeleted     =   2,      //已删除
};

typedef NS_ENUM(NSInteger, NIMMessageSubStatus) {

    NIMMessageSubStatusIsDeliveried  = 1 << 1, //消息已发送到服务器     0没有投递  1已投递

    NIMMessageSubStatusIsPlayed      = 1 << 3, //语音视频是否播放过     0未播放    1已播放
    
    NIMMessageSubStatusTryDownlaoded = 1 << 4, //附件是否试过下载       0未试过下载 1试过下载
    
    NIMMessageSubStatusIsReceivedMsg = 1 << 20,//是否是收到的消息       0发送的消息 1收到的消息
};



@interface NIMMessage ()

@property (nonatomic, assign) int64_t  serialID;

@property (nonatomic, copy)   NSString * serverID;

@property (nonatomic, assign, readwrite) NSTimeInterval timestamp;

@property (nonatomic, assign) NIMMessageSubStatus  subStatus;

@property (nonatomic, readwrite, assign) NIMMessageStatus status;

@property (nonatomic, readwrite, strong) NIMSession * session;

@property (nonatomic, readwrite, assign) NIMMessageType messageType;

@property (nonatomic, readwrite) NSString * messageId;

@property (nonatomic, copy) NSString *rawAttachContent;

@property (nonatomic, assign) NSInteger clientType;

@property (nonatomic, assign) BOOL isDeliveried;

@property (nonatomic, assign) BOOL isReceivedMsg;

@property (nonatomic, assign) BOOL tryDownloadOnce; //尝试过一次下载

@property (nonatomic, copy) NSString *senderName;


- (NSError*)prepareForSend;

- (NSError*)prepareForReSend;

- (NSError*)prepareForDownLoad;

- (BOOL)needUploadAttachment;

- (void)saveDataAfterReceiving:(BOOL)onlineMessage;

- (void)fireNotificationAfterReceiving;

- (BOOL)shouldCountUnread;

- (BOOL)shouldPersist;

@end




