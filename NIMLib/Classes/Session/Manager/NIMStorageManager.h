//
//  NIMStorageManager.h
//  NIMLib
//
//  Created by chris on 15/1/24.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMManager.h"
#import "NIMSession_Private.h"
#import "NIMConversationManagerProtocol.h"

@class NIMMessage;
@class NIMSession;
@class NIMMessageUpdateInfo;

@interface NIMStorageManager : NSObject

- (NIMSessionSaveResult*)saveMessages:(NSArray*)messages;

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



- (void)deleteMessage:(NIMMessage*)message;

- (void)deleteAllmessagesInSession:(NIMSession*)session;

- (void)deleteAllmessages;

- (void)markAllMessagesReadInSession:(NIMSession*)session;

- (NSArray*)messagesInSession:(NIMSession*)session message:(NIMMessage*)message limit:(NSInteger)limit;

- (NSArray *)messagesInSession:(NIMSession *)session
                    messageIds:(NSArray *)messageIds;

- (BOOL)isMessageReceived:(NSString *)messageId
               forSession:(NIMSession *)session;


@end

