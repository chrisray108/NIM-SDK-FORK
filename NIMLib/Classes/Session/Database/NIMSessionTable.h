//
//  NIMConversationTable.h
//  NIMLib
//
//  Created by chris on 15/1/22.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMMessage;
@class NIMSession;
@class NIMDatabase;
@class NIMMessageSearchOption;
@class NIMMessageUpdateInfo;

@interface NIMSessionTable : NSObject


- (instancetype)initWithDb:(NIMDatabase*)db
                   session:(NIMSession*)session;

@end

/**
 *  私有接口，除了DB以外请勿直接调用
 *  数据的增删改查请调用DB提供的接口
 */
@interface NIMSessionTable(Private)

- (BOOL)saveMessage:(NIMMessage*)message;

- (BOOL)updateMessage:(NIMMessage *)message
    includeAttachment:(BOOL)attachment;

- (BOOL)updateMessageInfo:(NIMMessageUpdateInfo *)info;

- (void)deleteMessage:(NIMMessage*)message;

- (NSArray*)fetchMessagesWithLimit:(NSInteger)limit
                       lastMessage:(NIMMessage*)lastMessage;

- (NSArray *)fetchMessagesByIds:(NSArray *)messageIds;

- (void)deleteAllMessageStatus;

- (void)readAllMessageStatus;

- (BOOL)isMessageReceived:(NSString *)messageId;

- (NSArray *)searchMessages:(NIMMessageSearchOption *)option;

+ (void)earseAllTables:(NIMDatabase *)db;

@end
