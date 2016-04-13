//
//  NIMConversationManager.h
//  NIMLib
//
//  Created by amao on 2/4/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMConversationManagerProtocol.h"
#import "NIMManager.h"
#import "NIMSession_Private.h"

@class NIMMessage;
@class NIMRecentSession;

@interface NIMConversationManager : NIMManager

#pragma - 对外接口

- (void)deleteMessage:(NIMMessage *)message;

- (void)deleteAllmessagesInSession:(NIMSession *)session
               removeRecentSession:(BOOL)removeRecentSession;

- (void)deleteAllMessages:(BOOL)removeRecentSessions;

- (void)deleteRecentSession:(NIMRecentSession *)recentSession;

- (void)markAllMessagesReadInSession:(NIMSession *)session;

- (void)updateMessage:(NIMMessage *)message
           forSession:(NIMSession *)session
           completion:(NIMUpdateMessageBlock)completion;

- (void)saveMessage:(NIMMessage *)message
         forSession:(NIMSession *)session
         completion:(NIMUpdateMessageBlock)completion;

- (NSArray*)messagesInSession:(NIMSession *)session
                      message:(NIMMessage *)message
                        limit:(NSInteger)limit;

- (NSArray *)messagesInSession:(NIMSession *)session
                    messageIds:(NSArray *)messageIds;

- (void)fetchMessageHistory:(NIMSession *)session
                     option:(NIMHistoryMessageSearchOption *)option
                     result:(NIMFetchMessageHistoryBlock)block;

- (void)searchMessages:(NIMSession *)session
                option:(NIMMessageSearchOption *)option
                result:(NIMSearchMessageBlock)block;

- (void)deleteRemoteSessions:(NSArray *)sessions
                  completion:(NIMRemoveRemoteSessionBlock)block;

- (NSInteger)allUnreadCount;

- (NSArray*)allRecentSessions;

#pragma - 私有接口
- (NIMSessionSaveResult*)saveMessages:(NSArray*)messages;

- (void)updateMessage:(NIMMessage *)message
    includeAttachment:(BOOL)attachment;

- (BOOL)isMessageReceived:(NSString *)messageId
               forSession:(NIMSession *)session;

- (void)addRecentSession:(NIMRecentSession *)session;

//当前会话未读清零
- (void)cleanRecentSession:(NIMSession *)session;

//更新当前会话的最后一条消息，如果消息ID不匹配则忽略
- (void)updateRecentSession:(NIMMessage *)message;

//所有的当前最近会话(请在主线程上调用)
- (NSDictionary *)recentSessions;

- (void)updateRoamMsgTimetag:(int64_t)timetag;

@end



