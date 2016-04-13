//
//  NIMSessionDB.h
//  NIMLib
//
//  Created by chris on 15/1/21.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSession_Private.h"
#import "NIMConversationManagerProtocol.h"

@class NIMMessage;
@class NIMMessageUpdateInfo;

@interface NIMSessionDB : NSObject

//保存消息.
- (NIMSessionSaveResult*)saveMessages:(NSArray*)messages;

//修改消息.
- (void)updateMessage:(NIMMessage *)message
    includeAttachment:(BOOL)attachment;

- (void)updateMessage:(NIMMessageUpdateInfo *)info
           forSession:(NIMSession *)session
           completion:(NIMUpdateMessageBlock)completion;

- (void)saveMessage:(NIMMessage *)message
         completion:(NIMUpdateMessageBlock)completion;

- (void)searchMessages:(NIMSession *)session
                option:(NIMMessageSearchOption *)option
                result:(NIMSearchMessageBlock)block;

//删除消息.
- (void)delMessages:(NSArray*)messages;
- (void)delMessagesInSession:(NIMSession*)session;
- (void)deleteAllmessages;

// 设置一个会话里所有消息为已读
- (void)readAllMessageInSession:(NIMSession*)session;

// 获取最新或某条消息之前的条消息,最新的话message传nil
- (NSArray*)fetchMessagesInSession:(NIMSession*)session message:(NIMMessage*)message limit:(NSInteger)limit;

//根据messageId获取message
- (NSArray *)fetchMessagesInSession:(NIMSession *)session byIds:(NSArray *)messageIds;

//判断某条消息是不是已收取
- (BOOL)isMessageReceived:(NSString *)messageId
               forSession:(NIMSession *)session;


@end
